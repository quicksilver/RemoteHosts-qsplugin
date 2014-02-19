//
//  RemoteHostsPrefPane.m
//  RemoteHosts
//
//  Created by Rob McBroom on 2012/03/02.
//

#import "RemoteHostsPrefPane.h"

@implementation RemoteHostsPrefPane

- (IBAction)rescanRemoteHosts:(id)sender
{
    // tell all Remote Hosts catalog entries to rescan
    [[NSNotificationCenter defaultCenter] postNotificationName:QSCatalogSourceInvalidated object:@"QSRemoteHostsSource"];
}

@end
