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
    NSMutableArray *objects=[NSMutableArray arrayWithCapacity:1];
    QSObject *newObject;
    
    NSString *path = [@"~/.hosts" stringByStandardizingPath];
    
    NSLog(@"Hosts scanned from: %@", path);
    
    newObject=[QSObject objectWithName:@"Mandingo"];
    //[newObject setName:@"Mandingo"];
    [newObject setObject:@"wanker.skurfer.com" forType:QSRemoteHostsType];
    //[newObject setIdentifier:@"QSMachineObject0"];
    //[newObject setPrimaryType:QSRemoteHostsType];
    [objects addObject:newObject];
    
    return objects;
    
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
