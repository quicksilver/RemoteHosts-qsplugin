//
//  SSHKeySource.m
//  RemoteHosts
//
//  Created by Rob McBroom on 2015/02/05.
//  Copyright (c) 2015 Skurfers' Alliance. All rights reserved.
//

#import "SSHKeySource.h"

@implementation SSHKeySource

- (BOOL)indexIsValidFromDate:(NSDate *)indexDate forEntry:(NSDictionary *)theEntry
{
    NSString *sshDir = [@"~/.ssh" stringByExpandingTildeInPath];
    // get the last modified date on the source file
    NSFileManager *manager = [NSFileManager defaultManager];
    if (![manager fileExistsAtPath:sshDir isDirectory:NULL]) {
        return YES;
    }
    NSDate *modDate = [[manager attributesOfItemAtPath:sshDir error:NULL] fileModificationDate];
    // compare dates and return whether or not the entry should be rescanned
    if ([modDate compare:indexDate] == NSOrderedDescending) {
        return NO;
    }
    // if we fall through to this point, don't rescan by default
    return YES;
}

- (NSArray *)objectsForEntry:(NSDictionary *)theEntry
{
    NSString *sshDir = [@"~/.ssh" stringByExpandingTildeInPath];
    NSFileManager *manager = [NSFileManager defaultManager];
    if (![manager fileExistsAtPath:sshDir isDirectory:NULL]) {
        return nil;
    }
    NSError *err = nil;
    NSArray *sshContents = [manager contentsOfDirectoryAtPath:sshDir error:&err];
    NSIndexSet *indexes = [sshContents indexesOfObjectsPassingTest:^BOOL(NSString *filename, NSUInteger idx, BOOL *stop) {
        return [filename hasSuffix:@".pub"];
    }];
    NSArray *publicKeys = [sshContents objectsAtIndexes:indexes];
    NSString *keyPath = nil;
    NSString *keyContents = nil;
    NSMutableArray *keyParts = nil;
    NSIndexSet *commentIndexes = nil;
    NSArray *commentParts = nil;
    NSString *label = nil;
    NSString *name = nil;
    NSCharacterSet *whitespace = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    QSObject *key = nil;
    NSMutableArray *objects = [NSMutableArray array];
    for (NSString *pubkey in publicKeys) {
        keyPath = [sshDir stringByAppendingPathComponent:pubkey];
        keyContents = [NSString stringWithContentsOfFile:keyPath encoding:NSUTF8StringEncoding error:&err];
        keyParts = [[keyContents componentsSeparatedByCharactersInSet:whitespace] mutableCopy];
        [keyParts removeObject:@""];
        if ([keyParts count] > 2) {
            // look for the comment
            NSRange commentRange = NSMakeRange(2, [keyParts count] - 2);
            commentIndexes = [NSIndexSet indexSetWithIndexesInRange:commentRange];
            commentParts = [keyParts objectsAtIndexes:commentIndexes];
            label = [commentParts componentsJoinedByString:@" "];
        } else {
            // if no comment, use the file name
            label = pubkey;
        }
        name = [NSString stringWithFormat:@"%@ SSH Public Key", label];
        key = [QSObject makeObjectWithIdentifier:[NSString stringWithFormat:@"sshkey:%@", pubkey]];
        [key setName:name];
        [key setLabel:label];
        [key setObject:keyContents forType:QSTextType];
        [key setPrimaryType:QSTextType];
        [key setDetails:@"SSH Public Key"];
        [objects addObject:key];
    }
    return objects;
}

@end
