/*
 * Created by Youssef Francis on October 5th, 2012.
 */

@interface LSDocumentProxy : NSObject
- (id)initWithName:(NSString*)name
              type:(NSString*)type
          MIMEType:(NSString*)mime;
@end

@interface LSApplicationWorkspace : NSObject
+ (LSApplicationWorkspace*)defaultWorkspace;
- (NSArray*)applicationsAvailableForOpeningDocument:(LSDocumentProxy*)doc;
@end

@interface LSApplicationProxy : NSObject
- (NSString*)applicationIdentifier;
@end

@interface LSOpenOperation : NSObject
- (void)start;
- (void)setCompletionBlock:(void (^)(void))block;
// iOS 6
- (id)initForOpeningResource:(NSURL*)url
            usingApplication:(NSString*)appIdent
    uniqueDocumentIdentifier:(NSString*)docIdent
                    userInfo:(NSDictionary*)userInfo
                    options:(NSDictionary*)options
                    delegate:(id)delegate;
// iOS 5 and before
- (id)initForOpeningResource:(NSURL*)url
            usingApplication:(NSString*)appIdent
    uniqueDocumentIdentifier:(NSString*)docIdent
                    userInfo:(NSDictionary*)userInfo
                    delegate:(id)delegate;
@end
