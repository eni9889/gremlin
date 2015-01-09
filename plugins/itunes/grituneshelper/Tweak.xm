#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

@interface SSDownloadMetadata : NSObject
@property (copy) NSString* bundleIdentifier;
@end

@interface IPodLibraryItem : NSObject
@property (copy) SSDownloadMetadata* itemMetadata;
@property (copy) NSString* itemDownloadIdentifier;
@end

static NSMutableArray* _imported;

%group IOS7

%hook IPodLibrary
- (void)_addLibraryItem:(IPodLibraryItem*)item toMusicLibrary:(id)library error:(NSError**)error
{
	SSDownloadMetadata* metadata = [item itemMetadata];
	if ([[metadata bundleIdentifier] isEqualToString:@"co.cocoanuts.gremlin.gritunesimporter"]) {
		[metadata setBundleIdentifier:nil];
		NSString* identifier = [item itemDownloadIdentifier];
		if ([_imported containsObject:identifier])
			return;
		[_imported addObject:identifier];
	}

	%orig;
}

%end
%end

%group IOS8
%hook IPodLibrary

-(long long)addLibraryItem:(IPodLibraryItem*)item error:(id*)arg2 {

	SSDownloadMetadata* metadata = [item itemMetadata];
	if ([[metadata bundleIdentifier] isEqualToString:@"co.cocoanuts.gremlin.gritunesimporter"]) {
		[metadata setBundleIdentifier:nil];
		NSString* identifier = [item itemDownloadIdentifier];
		if ([_imported containsObject:identifier]) {
			return 0;
		}
		[_imported addObject:identifier];
	}

	return %orig;
}

-(_Bool)addLibraryItems:(NSArray *)items error:(id*)arg2{

	NSMutableArray *newItems = [NSMutableArray array];

	for (IPodLibraryItem* item in items) {

		SSDownloadMetadata* metadata = [item itemMetadata];

		if ([[metadata bundleIdentifier] isEqualToString:@"co.cocoanuts.gremlin.gritunesimporter"]) {
			[metadata setBundleIdentifier:nil];
			NSString* identifier = [item itemDownloadIdentifier];
			if (![_imported containsObject:identifier]) {
				[newItems addObject:item];
			}

			[_imported addObject:identifier];
		} else {
			[newItems addObject:item];
		}

	}

	if([newItems count] > 0) {
		return %orig((NSArray *)newItems, arg2);

	} else {
		return 0;
	}
}

%end
%end

%ctor
{
	_imported = [NSMutableArray new];
	if(SYSTEM_VERSION_LESS_THAN(@"8.0")){
		NSLog(@"Hooking IPodLibrary in IOS7");
		%init(IOS7);
	} else {
		NSLog(@"Hooking IPodLibrary in IOS8");
		%init(IOS8);
	}
	
}
