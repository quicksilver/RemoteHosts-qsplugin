//
//  RemoteHostsSource.m
//  RemoteHosts
//
//  Created by Rob McBroom on 12/24/09.
//

#import "RemoteHostsSource.h"
#import <QSCore/QSObject.h>


@implementation QSRemoteHostsSource
- (BOOL)indexIsValidFromDate:(NSDate *)indexDate forEntry:(NSDictionary *)theEntry{
    return YES;
}

- (BOOL)isVisibleSource
{
    return YES;
}

- (NSImage *) iconForEntry:(NSDictionary *)dict
{
    return [QSResourceManager imageNamed:@"com.apple.mac"];
}

// Return a unique identifier for an object (if you haven't assigned one before)
//- (NSString *)identifierForObject:(id <QSObject>)object
//{
//    return @"QSMachineObject0";
//}

- (NSArray *) objectsForEntry:(NSDictionary *)theEntry
{
    // use the plist settings to determine which file to load from
    NSMutableDictionary *settings = [theEntry objectForKey:kItemSettings];
    NSString *path = [self fullPathForSettings:settings];
    NSLog(@"Remote hosts loaded from: %@", path);
    
    NSMutableArray *objects=[NSMutableArray arrayWithCapacity:1];
    NSError **e;
    
    NSString *string = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:e];
	return [self linesFromString:string atPath:path lineType:[settings objectForKey:@"lineContentType"]];
//
//    
//    QSObject *newObject;
//    
//    newObject=[QSObject objectWithName:@"host1.skurfer.com"];
//    //[newObject setName:@"Mandingo"];
//    [newObject setObject:@"Remote Host host1" forType:QSRemoteHostsType];
//    //[newObject setIdentifier:@"QSMachineObject0"];
//    //[newObject setPrimaryType:QSRemoteHostsType];
//    [newObject setIcon:[QSResourceManager imageNamed:@"com.apple.mac"]];
//    [objects addObject:newObject];
//
//    newObject=[QSObject objectWithName:@"host2.skurfer.com"];
//    [newObject setObject:@"Remote Host host2" forType:QSRemoteHostsType];
//    [newObject setIcon:[QSResourceManager imageNamed:@"com.apple.mac"]];
//    [objects addObject:newObject];
//    
//    return objects;
    
}

- (NSArray *)linesFromString:(NSString *)string atPath:(NSString *)path lineType:(NSString *)lineType
{
	NSMutableArray *array = [NSMutableArray arrayWithCapacity:1];
	QSObject *newObject;
	string = [string stringByReplacing:@"\n" with:@"\r"];
	NSArray *lines = [string componentsSeparatedByString:@"\r"];
	NSString *line;
    int i;
	for (i = 0; i<[lines count]; i++) {
		line = [lines objectAtIndex:i];
		if (lineType)
			newObject = [QSObject objectWithType:lineType value:line name:line];
		else
			newObject = [QSObject objectWithString:line];
        
		[newObject setDetails:nil];
        
		if (path) {
			[newObject setObject:[NSDictionary dictionaryWithObjectsAndKeys:path, @"path", [NSNumber numberWithInt:i+1] , @"line", nil]
						 forType:@"QSLineReferenceType"];
		}
		if (newObject)
			[array addObject:newObject];
	}
    return array;
}


- (NSString *)fullPathForSettings:(NSDictionary *)settings
{
	if (![settings objectForKey:kItemPath]) return nil;
	NSString *itemPath = [[settings objectForKey:kItemPath] stringByResolvingWildcardsInPath];
	if (![itemPath isAbsolutePath]) {
		NSString *bundlePath = [[QSReg bundleWithIdentifier:[settings objectForKey:kItemBaseBundle]] bundlePath];
		if (!bundlePath) bundlePath = [[NSBundle mainBundle] bundlePath];
		itemPath = [bundlePath stringByAppendingPathComponent:itemPath];
	}
	return itemPath;
}

// Object Handler Methods

/*
- (void)setQuickIconForObject:(QSObject *)object{
    [object setIcon:nil]; // An icon that is either already in memory or easy to load
}
- (BOOL)loadIconForObject:(QSObject *)object{
	return NO;
    id data=[object objectForType:kRemoteHostsType];
	[object setIcon:nil];
    return YES;
}
*/
@end
