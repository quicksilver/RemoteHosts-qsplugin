//
//  RemoteHostsAction.m
//  RemoteHosts
//
//  Created by Rob McBroom on 12/24/09.
//

#import "RemoteHostsAction.h"

@implementation QSRemoteHostsAction

- (id)init {
    if ((self = [super init])) {
        // define what each action will work with (for validation)
        actionCapabilities = [[NSDictionary dictionaryWithObjectsAndKeys:
            [NSArray arrayWithObjects:kUnixHosts, nil], @"AFPBrowse",
            [NSArray arrayWithObjects:kUnixHosts, nil], @"AFPMount",
            [NSArray arrayWithObjects:kWindowsHosts, kUnixHosts, nil], @"CIFSBrowse",
            [NSArray arrayWithObjects:kWindowsHosts, kUnixHosts, nil], @"CIFSMount",
            [NSArray arrayWithObjects:kUnixHosts, kMultipleHosts, nil], @"ConnectUsingSSH",
            [NSArray arrayWithObjects:kUnixHosts, kMultipleHosts, nil], @"ConnectUsingSSHroot",
            [NSArray arrayWithObjects:kUnixHosts, kMultipleHosts, nil], @"ConnectUsingSSHuser",
            [NSArray arrayWithObjects:kUnixHosts, kMultipleHosts, nil], @"ConnectUsingTelnet",
            [NSArray arrayWithObjects:kUnixHosts, kWindowsHosts, kMultipleHosts, nil], @"ConnectUsingTelnetPort",
            [NSArray arrayWithObjects:kUnixHosts, kWindowsHosts, kMultipleHosts, nil], @"ConnectUsingVNC",
            [NSArray arrayWithObjects:kUnixHosts, kWindowsHosts, nil], @"GetIPAddress",
            nil
        ] retain];
        // store known actions
        actionList = [[actionCapabilities allKeys] retain];
    }
    return self;
}

/* helper methods */
// TODO create a method to take a QSObject and return an array of connection URLs
// TODO use notification system for erors instead of returning them as objects?

- (void)launchConnection:(NSString *)inetloc
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
}

- (QSObject *)sendWarningToUser:(NSString *)textForUser
{
    /*
     Display a warning to the user
    */
    QSObject *resultObject = [QSObject objectWithString:textForUser];
    [resultObject setIcon:[QSResourceManager imageNamed:@"AlertCautionIcon"]];
    return resultObject;
    // dictionary with icon, title, text for notifications
    // NSDictionary *notification = [NSDictionary dictionaryWithObjectsAndKeys:
    //     @"title", @"Remote Host Warning",
    //     @"text", textForUser,
    //     @"icon", [QSResourceManager imageNamed:@"AlertCautionIcon"],
    //     nil
    // ];
    // [QSSilverNotifier displayNotificationWithAttributes:notification];
}

- (QSObject *)sendErrorToUser:(NSString *)textForUser
{
    /*
     Display an error to the user
    */
    QSObject *resultObject = [QSObject objectWithString:textForUser];
    [resultObject setIcon:[QSResourceManager imageNamed:@"AlertStopIcon"]];
    return resultObject;
}

/* action methods */

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

- (QSObject *)browseWithCIFS:(QSObject *)dObject
{
    // this action doesn't support the comma-trick
    NSString *remoteHost = [dObject name];
    [self launchConnection:[NSString stringWithFormat:@"cifs://%@/",remoteHost]];
    return nil;
}

- (QSObject *)mountWithCIFS:(QSObject *)dObject withShareName:(QSObject *)share
{
    // this action doesn't support the comma-trick
    NSString *remoteHost = [dObject name];
    [self launchConnection:[NSString stringWithFormat:@"cifs://%@/%@/",remoteHost, [share stringValue]]];
    return nil;
}

- (QSObject *)browseWithAFP:(QSObject *)dObject
{
    // this action doesn't support the comma-trick
    NSString *remoteHost = [dObject name];
    [self launchConnection:[NSString stringWithFormat:@"afp://%@/",remoteHost]];
    return nil;
}

- (QSObject *)mountWithAFP:(QSObject *)dObject withShareName:(QSObject *)share
{
    // this action doesn't support the comma-trick
    NSString *remoteHost = [dObject name];
    [self launchConnection:[NSString stringWithFormat:@"afp://%@/%@/",remoteHost, [share stringValue]]];
    return nil;
}

- (QSObject *)getIPForHost:(QSObject *)dObject
{
    // look up the IP address for this host and return it to the Quicksilver interface
    NSString *hostName = [dObject name];
    NSHost *host = [NSHost hostWithName:hostName];
    
    // this action doesn't support the comma-trick
    
    // if there is no such host, return an error
    if (!host) {
        return [self sendErrorToUser:@"Host not found"];
    } else {
        // using objectWithString here would cause Quicksilver to treat the IP as a URL
        // so we create the object with a few explicit details to make it act like text
        NSString *ip = [host address];
        QSObject *ipObject = [QSObject objectWithName:ip];
        [ipObject setObject:ip forType:QSTextType];
        [ipObject setIcon:[QSResourceManager imageNamed:@"GenericNetworkIcon"]];
        return ipObject;
    }
}

/* methods called by Quicksilver as needed */

// declaring this here will cause the third pane to pop up in text-entry mode by default
- (NSArray *)validIndirectObjectsForAction:(NSString *)action directObject:(QSObject *)dObject
{
    // set default text for certain actions
    if ([action isEqualToString:@"ConnectUsingSSHuser"]) {
        /* If you just conect with SSH and provide no options, it assumes the
        username of the currently logged on user, so providing the current
        username as a default here is really a waste of time. I know that.
        Put this in the "because I can" category. What else should I use as a
        default? :) */
        return [NSArray arrayWithObject: [QSObject textProxyObjectWithDefaultValue:NSUserName()]];
    }
    if([action isEqualToString:@"CIFSMount"] || [action isEqualToString:@"AFPMount"]) {
        return [NSArray arrayWithObject: [QSObject textProxyObjectWithDefaultValue:@"share name"]];
    }
    // text-entry mode with an empty string
    return [NSArray arrayWithObject: [QSObject textProxyObjectWithDefaultValue:@""]];
    
    // unconditionally (should be fine if all actions expect text in the third pane, right?)
    //return [NSArray arrayWithObject: [QSObject textProxyObjectWithDefaultValue:@""]];
}

// do some checking on the objects in the first pane
// if an action has `validatesObjects` enabled in Info.plist, this method must return the action's name or it will never appear
- (NSArray *)validActionsForDirectObject:(QSObject *)dObject indirectObject:(QSObject *)iObject
{
    // actions to be returned
    NSMutableArray *newActions=[NSMutableArray arrayWithCapacity:1];
    
    //QSObject *host = [[dObject arrayForType:QSRemoteHostsType] lastObject];
    // use ostype to validate
    // NSString *ostype = [host objectForMeta:@"ostype"];
    // NSLog(@"OS type: %@", ostype);
    // 
    // if (![ostype isEqualToString:@"windows"]) {
    //     NSLog(@"Not a Unix variant");
    //     [newActions addObject:@"ConnectUsingSSH"];
    //     [newActions addObject:@"ConnectUsingSSHroot"];
    //     [newActions addObject:@"ConnectUsingSSHuser"];
    // }
    
    // check to see if multiple objects have been sent using the comma trick
    // only return actions that support that
    if ([[dObject stringValue] isEqualToString:@"combined objects"])
    {
        for (NSString *action in actionList)
        {
            // if this action supports the comma trick, return it
            NSArray *capabilities = [actionCapabilities valueForKey:action];
            if ([capabilities containsObject:[NSString stringWithString:kMultipleHosts]]) {
                [newActions addObject:action];
            }
        }
        return newActions;
    }
    
    // return all known actions by default
    return actionList;
}

@end
