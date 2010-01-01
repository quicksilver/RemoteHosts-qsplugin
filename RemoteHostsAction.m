//
//  RemoteHostsAction.m
//  RemoteHosts
//
//  Created by Rob McBroom on 12/24/09.
//

#import "RemoteHostsAction.h"

@implementation QSRemoteHostsAction

- (int *)launchConnection:(NSString *)inetloc
{
    /*
     This is a convenience method for the actions below.
     The process of connecting is identical, once the location
     string has been sorted out.
    */
    NSURL *url = [NSURL URLWithString:inetloc];
    if (url)
        [[NSWorkspace sharedWorkspace] openURL:url];
    else
        NSLog(@"error with location: %@", inetloc);
    
    return nil;
}

// TODO create a method to take a QSObject and return an array of connection URLs
- (QSObject *)connectAsDefault:(QSObject *)dObject
{
    // launch SSH with system defaults
    // equivalent to running `ssh hostname` on the command-line
    
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
    
    for(NSString *remoteHost in [dObject arrayForType:QSRemoteHostsType])
    {
        //NSLog(@"Connection for %@", remoteHost);
        
        // launch an SSH connection
        [self launchConnection:[NSString stringWithFormat:@"ssh://root@%@",remoteHost]];
    
    }
    return nil;
}

- (QSObject *)connectAsUser:(QSObject *)dObject withUserName:(QSObject *)userName
{
    // launch SSH with a user provided username
    // equivalent to running `ssh -l username hostname` on the command-line
    
    for(NSString *remoteHost in [dObject arrayForType:QSRemoteHostsType])
    {
        //NSLog(@"Connection for %@", remoteHost);
        
        // launch an SSH connection
        [self launchConnection:[NSString stringWithFormat:@"ssh://%@@%@",[userName stringValue],remoteHost]];
    
    }
    return nil;
}

- (QSObject *)connectWithTelnet:(QSObject *)dObject
{
    // launch Telnet connection
    // equivalent to running `telnet hostname` on the command-line
    
    for(NSString *remoteHost in [dObject arrayForType:QSRemoteHostsType])
    {
        //NSLog(@"Connection for %@", remoteHost);
        
        // launch a Telnet connection
        [self launchConnection:[NSString stringWithFormat:@"telnet://%@",remoteHost]];
    
    }
    return nil;
}

- (QSObject *)connectToPortWithTelnet:(QSObject *)dObject withPortNumber:(QSObject *)port
{
    // launch Telnet connection to a specific port
    // equivalent to running `telnet hostname port` on the command-line
    
    for(NSString *remoteHost in [dObject arrayForType:QSRemoteHostsType])
    {
        //NSLog(@"Connection for %@", remoteHost);
        
        // launch a Telnet connection
        [self launchConnection:[NSString stringWithFormat:@"telnet://%@:%@",remoteHost,[port stringValue]]];
    
    }
    return nil;
}

- (QSObject *)connectWithVNC:(QSObject *)dObject
{
    // launch Screen Sharing and connect to host
    
    for(NSString *remoteHost in [dObject arrayForType:QSRemoteHostsType])
    {
        //NSLog(@"Connection for %@", remoteHost);
        
        [self launchConnection:[NSString stringWithFormat:@"vnc://%@",remoteHost]];
    
    }
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

    // set default text for certain actions
    if ([action isEqualToString:@"ConnectUsingSSHuser"]){
        return [NSArray arrayWithObject: [QSObject textProxyObjectWithDefaultValue:NSUserName()]];
    }
    // text-entry mode with an empty string
    return [NSArray arrayWithObject: [QSObject textProxyObjectWithDefaultValue:@""]];
    
    // unconditionally (should be fine if all actions expect text in the third pane, right?)
    //return [NSArray arrayWithObject: [QSObject textProxyObjectWithDefaultValue:@""]];
}

// do some checking on the objects in the first pane
// if an action has `validatesObjects` enabled in Info.plist, this method must return the action's name or it will never appear
// - (NSArray *)validActionsForDirectObject:(QSObject *)dObject indirectObject:(QSObject *)iObject
// {
//     //QSObject *host = [[dObject arrayForType:QSRemoteHostsType] lastObject];
//     // use ostype to validate
//     NSString *ostype = [host objectForMeta:@"ostype"];
//     NSLog(@"OS type: %@", ostype);
//     
//     NSMutableArray *newActions=[NSMutableArray arrayWithCapacity:1];
//     if (![ostype isEqualToString:@"windows"]) {
//         NSLog(@"Not a Unix variant");
//         [newActions addObject:@"ConnectUsingSSH"];
//         [newActions addObject:@"ConnectUsingSSHroot"];
//         [newActions addObject:@"ConnectUsingSSHuser"];
//     }
//     
//     return newActions;
// }

@end
