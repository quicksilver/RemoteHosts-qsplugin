//
//  RemoteHostsAction.m
//  RemoteHosts
//
//  Created by Rob McBroom on 12/24/09.
//

#import "RemoteHostsAction.h"

# define kConnectUsingSSHuser @"ConnectUsingSSHuser"

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

- (QSObject *)connectAsDefault:(QSObject *)dObject
{
    // launch SSH with system defaults
    // equivalent to running `ssh hostname` on the command-line
    QSObject *result;
    
    for(NSString *remoteHost in [dObject arrayForType:QSRemoteHostsType])
    {
        //NSLog(@"Connection for %@", remoteHost);
        
        // launch an SSH connection
        [self launchConnection:[NSString stringWithFormat:@"ssh://%@",remoteHost]];
    
    }
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

- (QSObject *)connectWithTelnet:(QSObject *)dObject
{
    // launch Telnet connection
    // equivalent to running `telnet hostname` on the command-line
    QSObject *result;
    NSString *dWithTelnet;
    
    dWithTelnet = [NSString stringWithFormat:@"telnet://%@",[dObject stringValue]];
    
    [self launchConnection:dWithTelnet];
    
    return nil;
}

- (QSObject *)connectToPortWithTelnet:(QSObject *)dObject withPortNumber:(QSObject *)port
{
    // launch Telnet connection to a specific port
    // equivalent to running `telnet hostname port` on the command-line
    QSObject *result;
    NSString *dWithTelnet;
    
    dWithTelnet = [NSString stringWithFormat:@"telnet://%@:%@",[dObject stringValue],[port stringValue]];
    
    [self launchConnection:dWithTelnet];
    
    return nil;
}

- (QSObject *)getIPForHost:(QSObject *)dObject
{
    // look up the IP address for this host and return it to the Quicksilver interface
    NSString *hostName = [dObject name];
    NSHost *host = [NSHost hostWithName:hostName];
    
    // this action doesn't support the comma-trick, but we'll check for attempts to use it so the error can be more useful
    if([[dObject stringValue] isEqualToString:@"combined objects"])
    {
        return [QSObject objectWithString:@"Multiple hosts unsupported"];
    }
    
    // if there is no such host, return an error
    if (!host) {
        // NSLog(@"Failed to find host: %@", hostName);
        return [QSObject objectWithString:@"Host not found"];
    } else {
        // using objectWithString here would cause Quicksilver to treat the IP as a URL
        // so we create the object with a few explicit details to make it act like text
        NSString *ip = [host address];
        QSObject *ipObject = [QSObject objectWithName:ip];
        [ipObject setObject:ip forType:QSTextType];
        return ipObject;
    }
}

// declaring this here will cause the third pane to pop up in text-entry mode by default
- (NSArray *)validIndirectObjectsForAction:(NSString *)action directObject:(QSObject *)dObject
{

    // only for certain actions (make sure to #define them above)
    if ([action isEqualToString:kConnectUsingSSHuser]){
        return [NSArray arrayWithObject: [QSObject textProxyObjectWithDefaultValue:NSUserName()]];
    }
    // text-entry mode with an empty string
    return [NSArray arrayWithObject: [QSObject textProxyObjectWithDefaultValue:@""]];
    
    // unconditionally (should be fine if all actions expect text in the third pane, right?)
    //return [NSArray arrayWithObject: [QSObject textProxyObjectWithDefaultValue:@""]];
}

@end
