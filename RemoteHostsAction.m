//
//  RemoteHostsAction.m
//  RemoteHosts
//
//  Created by Rob McBroom on 12/24/09.
//

#import "RemoteHostsAction.h"

//# define kConnectUsingSSHuser @"ConnectUsingSSHuser"

@implementation QSRemoteHostsAction

- (int *)launchConnection:(NSString *)SSHinetloc
{
    /*
     This is a convenience method for the three actions below.
     The process of connecting is identical for all three, once the location
     string has ben sorted out.
    */
    NSURL *url = [NSURL URLWithString:SSHinetloc];
    if (url)
        [[NSWorkspace sharedWorkspace] openURL:url];
    else
        NSLog(@"error with url: %@", SSHinetloc);
    
    return nil;
}

// TODO look for "combined objects" (sent via the comma trick) and handle them
- (QSObject *)connectAsDefault:(QSObject *)dObject
{
    // launch SSH with system defaults
    // equivalent to running `ssh hostname` on the command-line
    QSObject *result;
    NSString *dWithSSH;
    
    dWithSSH = [NSString stringWithFormat:@"ssh://%@",[dObject stringValue]];
    
    [self launchConnection:dWithSSH];
    
    return nil;
}

- (QSObject *)connectAsRoot:(QSObject *)dObject
{
    // launch SSH with a username of "root"
    // equivalent to running `ssh -l root hostname` on the command-line
    QSObject *result;
    NSString *dWithSSH;
    
    dWithSSH = [NSString stringWithFormat:@"ssh://root@%@",[dObject stringValue]];
    
    [self launchConnection:dWithSSH];
    
    return nil;
}

- (QSObject *)connectAsUser:(QSObject *)dObject withUserName:(QSObject *)userName
{
    // launch SSH with a user provided username
    // equivalent to running `ssh -l username hostname` on the command-line
    QSObject *result;
    NSString *dWithSSH;
    
    dWithSSH = [NSString stringWithFormat:@"ssh://%@@%@",[userName stringValue],[dObject stringValue]];
    
    [self launchConnection:dWithSSH];
    
    return nil;
}

- (QSObject *)getIPForHost:(QSObject *)dObject
{
    // look up the IP address for this host and return it to the Quicksilver interface
    NSString *hostName = [dObject stringValue];
    NSHost *host = [NSHost hostWithName:hostName];
    
    // if there is no such host, return an error
    if (!host) {
        return [QSObject objectWithString:@"Host not found"];
    } else {
        return [QSObject objectWithString:[host address]];
    }
}

// declaring this here will cause the third pane to pop up in text-entry mode by default
- (NSArray *)validIndirectObjectsForAction:(NSString *)action directObject:(QSObject *)dObject{

    // only for certain actions (make sure to #define them above)
//	if ([action isEqualToString:kConnectUsingSSHuser]){
//		return [NSArray arrayWithObject: [QSObject textProxyObjectWithDefaultValue:@""]];
//	}
//	return nil;
    
    // unconditionally (should be fine if all actions expect text in the third pane, right?)
    return [NSArray arrayWithObject: [QSObject textProxyObjectWithDefaultValue:@""]];
}

@end
