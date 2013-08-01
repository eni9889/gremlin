#import "GRImporterProtocol.h"

#import <MobileCoreServices/UTCoreTypes.h>
#import <MobileCoreServices/UTType.h>

#define NSDataReadingMappedAlways (1UL << 3)

@interface PLAssetsSaver : NSObject
+ (id)sharedAssetsSaver;
- (void)queueJobData:(id)d completionBlock:(void (^)(id,id))block;        // iOS 5
- (void)queueJobDictionary:(id)d completionBlock:(void (^)(id,id))block;  // iOS 6
@end

@interface GRPhotoImporter : NSObject <GRImporter>
@end

@implementation GRPhotoImporter

+ (GRImportOperationBlock)newImportBlock
{
    return Block_copy(^(NSDictionary* info, NSError** err)
    {
        @try {
            NSString* path = [info objectForKey:@"path"];
            CFStringRef utt = (CFStringRef)[info objectForKey:@"UTType"]; 
            
            NSData* imageData = nil;
            SEL mappedDataSel = @selector(dataWithContentsOfMappedFile:);
            if ([NSData respondsToSelector:mappedDataSel])
                imageData = [NSData dataWithContentsOfMappedFile:path];
            else {
                NSError *error = nil;
                NSDataReadingOptions readOptions = NSDataReadingMappedAlways;
                imageData = [NSData dataWithContentsOfFile:path 
                                                   options:readOptions
                                                     error:&error];
            }
            
            NSNumber* yes = [NSNumber numberWithBool:YES];
            NSString* jobType = @"ImageJob";
            NSNumber* assetType = [NSNumber numberWithInt:3];
            NSString* extension = [[path pathExtension] uppercaseString];
            NSMutableDictionary* job;
            job = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                yes,       @"CreatePreviewWellThumbnail",
                yes,       @"kPLImageWriterAddAssetToCameraRoll",
                yes,       @"kPLImageWriterPhotoStreamImageForPublishing",
                yes,       @"PLAssetsSaverNotifyForPictureWasTakenOrChanged",
                yes,       @"QueueEnforcement",
                assetType, @"kPLImageWriterSavedAssetTypeKey",
                extension, @"FileExtension",
                imageData, @"ImageData",
                jobType,   @"JobType",
                utt,       @"Type",
                nil];

            NSConditionLock* cond;
            cond = [[NSConditionLock alloc] initWithCondition:0];
            
            PLAssetsSaver * assetSaver = [PLAssetsSaver sharedAssetsSaver];
            NSData* jobData = nil;
            __block BOOL success = NO;

            if ([assetSaver respondsToSelector:@selector(queueJobDictionary:completionBlock:)]){
                // iOS 6
                [[PLAssetsSaver sharedAssetsSaver] queueJobDictionary:job
                                                completionBlock:^(id x1, id x2) 
                {
                    // detect success/failure here somehow
                    success = YES;
                    [cond lock];
                    [cond unlockWithCondition:1];
                }];
            } else {
                // iOS 5
                jobData = [NSKeyedArchiver archivedDataWithRootObject:job];
                [[PLAssetsSaver sharedAssetsSaver] queueJobData:jobData
                                                completionBlock:^(id x1, id x2) {
                    // detect success/failure here somehow
                    success = YES;
                    [cond lock];
                    [cond unlockWithCondition:1];
                }];
            }

            [cond lockWhenCondition:1];
            [cond unlock];
            [cond release];

            [job release];

            return success;
        }
        @catch (...) {
            if (err != NULL)
                *err = [NSError errorWithDomain:@"gremlin.plugin.import"
                                           code:500
                                       userInfo:info];
            return NO;
        }
    });
}

@end
