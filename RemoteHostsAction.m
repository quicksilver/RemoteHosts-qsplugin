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
            [NSArray arrayWithObjects:kUnixHosts, kWindowsHosts, kMultipleHosts, nil], @"ConnectUsingFTP",
            [NSArray arrayWithObjects:kUnixHosts, kWindowsHosts, kMultipleHosts, nil], @"ConnectUsingHTTP",
            [NSArray arrayWithObjects:kUnixHosts, kWindowsHosts, kMultipleHosts, nil], @"ConnectUsingHTTPS",
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
// TODO use notification system for erors instead of returning them as objects? see Calculator Module

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

// TODO Add HTTP:port & HTTPS:port actions?

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

- (QSObject *)connectWithFTP:(QSObject *)dObject
{
    // launch an FTP connection in Finder
    
    for(NSString *remoteHost in [dObject arrayForType:QSRemoteHostsType])
    {
        //NSLog(@"Connection for %@", remoteHost);
        
        [self launchConnection:[NSString stringWithFormat:@"ftp://%@/",remoteHost]];
    
    }
    return nil;
}

- (QSObject *)connectWithHTTP:(QSObject *)dObject
{
    // launch an HTTP connection in the default browser
    
    for(NSString *remoteHost in [dObject arrayForType:QSRemoteHostsType])
    {
        //NSLog(@"Connection for %@", remoteHost);
        
        [self launchConnection:[NSString stringWithFormat:@"http://%@/",remoteHost]];
    
    }
    return nil;
}

- (QSObject *)connectWithHTTPS:(QSObject *)dObject
{
    // launch an HTTP connection in the default browser
    
    for(NSString *remoteHost in [dObject arrayForType:QSRemoteHostsType])
    {
        //NSLog(@"Connection for %@", remoteHost);
        
        [self launchConnection:[NSString stringWithFormat:@"https://%@/",remoteHost]];
    
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
    
    /*  The general idea here is to loop through all actions and if
        we find a reason — any reason — to allow it, add it to the array
        and bail out with a call to `continue`. This has two advantages:
        1. If there are 10 reasons to allow an action, it only gets added
           to the array once, not 10 times
        2. We can skip a lot of validation steps and speed up the process
        
        With that in mind, the tests most likely to match should be first.
    */
    
    for (NSString *action in actionList)
    {
        NSArray *capabilities = [actionCapabilities valueForKey:action];
        
        // comma trick support is all or nothing
        // other checks are only attempted on single objects
        if ([[dObject stringValue] isEqualToString:@"combined objects"])
        {
            if ([capabilities containsObject:[NSString stringWithString:kMultipleHosts]])
            {
                [newActions addObject:action];
                continue;
            }
        } else {
            // checks based on OS type
            NSString *ostype = [dObject objectForMeta:@"ostype"];
            if (![ostype isEqualToString:@"windows"]
                && [capabilities containsObject:[NSString stringWithString:kUnixHosts]])
            {
                [newActions addObject:action];
                continue;
            }
            if ([ostype isEqualToString:@"windows"]
                && [capabilities containsObject:[NSString stringWithString:kWindowsHosts]])
            {
                [newActions addObject:action];
                continue;
            }
        }
    }
    
    return newActions;
}

@end
