//
//  RemoteHostsSource.m
//  RemoteHosts
//
//  Created by Rob McBroom on 12/24/09.
//

#import "RemoteHostsSource.h"
#import <QSCore/QSObject.h>


@implementation QSRemoteHostsSource
// if this returns FALSE, the source will be rescanned
// if it returns TRUE, the source is left alone
// unconditional returns will cause it to either be scanned every time, or never
- (BOOL)indexIsValidFromDate:(NSDate *)indexDate forEntry:(NSDictionary *)theEntry
{
    // use the plist settings to determine which file to check
    NSMutableDictionary *settings = [theEntry objectForKey:kItemSettings];
    NSString *sourceFile = [self fullPathForSettings:settings];
    // get the last modified date on the source file
    NSFileManager *manager = [NSFileManager defaultManager];
    if (![manager fileExistsAtPath:sourceFile isDirectory:NULL]) return YES;
    NSDate *modDate = [[manager attributesOfItemAtPath:sourceFile error:NULL] fileModificationDate];
    // compare dates and return whether or not the entry should be rescanned
    if ([modDate compare:indexDate] == NSOrderedDescending) return NO;
    // if we fall through to this point, don't rescan by default
    return YES;
}

// TODO create interface for adding custom catalog entries
// show this on the drop-down for adding custom catalog entries?
- (BOOL)isVisibleSource
{
    return NO;
}

// this doesn't seem to do anything (setIcon is used on each object as it's created)
// - (NSImage *) iconForEntry:(NSDictionary *)dict
// {
//     return [QSResourceManager imageNamed:@"com.apple.mac"];
// }

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
    NSLog(@"Loading remote hosts from: %@", path);
    
    // a list of objects that will get returned (and added to the Catalog)
    NSMutableArray *objects=[NSMutableArray arrayWithCapacity:1];
    
    // somewhere to dump errors
    NSError *e;
    
    // read the entire file in as a string
    NSString *hostsSource = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&e];
    // bail out with an error if the file couldn't be opened
    if(!hostsSource) {
        // there was an error reading the file
        NSLog(@"Remote hosts could not be loaded: %@", [e localizedFailureReason]);
        return nil;
    }
    hostsSource = [hostsSource stringByReplacing:@"\n" with:@"\r"];
    NSArray *lines = [hostsSource componentsSeparatedByString:@"\r"];
    
    // read in hosts, one per line
    QSObject *newObject;
    for (NSString *line in lines) {
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
        // [newObject setIcon:[QSResourceManager imageNamed:@"com.apple.mac"]];
        [newObject setLabel:label];
        //[newObject setPrimaryType:QSRemoteHostsType];
        // add some meta-data
        if([lineParts count] > 1)
        {
            NSString *ostype = [lineParts objectAtIndex:1];
            [newObject setObject:ostype forMeta:@"ostype"];
        } else {
            [newObject setObject:@"unknown" forMeta:@"ostype"];
        }
        
        // if the object is OK, add it to the list
        if (newObject)
            [objects addObject:newObject];
    }
    
    return objects;
    
}

// this method gets the path for a file to scan from an Info.plist
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

// TODO look into customizing icon based on OS type? (this assumes the os is in the file)
- (void)setQuickIconForObject:(QSObject *)object
{
    // An icon that is either already in memory or easy to load
    [object setIcon:[QSResourceManager imageNamed:@"com.apple.mac"]];
}
/*
- (BOOL)loadIconForObject:(QSObject *)object{
    return NO;
    id data=[object objectForType:kRemoteHostsType];
    [object setIcon:nil];
    return YES;
}
*/
@end
