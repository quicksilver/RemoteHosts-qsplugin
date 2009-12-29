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
    
    // a list of objects that will get returned (and added to the Catalog)
    NSMutableArray *objects=[NSMutableArray arrayWithCapacity:1];
    
    // somewhere to dump errors… I guess?
    NSError **e;
    
    // read the entire file in as a string
    NSString *hostsSource = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:e];
    hostsSource = [hostsSource stringByReplacing:@"\n" with:@"\r"];
    NSArray *lines = [hostsSource componentsSeparatedByString:@"\r"];
    
    // read in hosts, one per line
    QSObject *newObject;
    NSString *line;
    int i;
    for (i = 0; i<[lines count]; i++) {
        line = [lines objectAtIndex:i];
        // skip empty lines
        if ([line length] == 0) {
            continue;
        }
        // allow other metadata in the file, separated by whitespace
        // hostname or FQDN should be the first thing on the line
        NSArray *lineParts = [line componentsSeparatedByString:@" "];
        NSString *host = [lineParts objectAtIndex:0];
        NSString *label = [NSString stringWithFormat:@"%@ (remote host)", host];
        NSString *ident = [NSString stringWithFormat:@"remote-host-%@", host];
        // build a QSObject
        newObject = [QSObject objectWithName:host];
        [newObject setIdentifier:ident];
        [newObject setObject:host forType:QSRemoteHostsType];
        [newObject setIcon:[QSResourceManager imageNamed:@"com.apple.mac"]];
        [newObject setLabel:label];
        //[newObject setPrimaryType:QSRemoteHostsType];
        
        // if the object is OK, add it to the list
        if (newObject)
            [objects addObject:newObject];
    }
    
    return objects;
    
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
