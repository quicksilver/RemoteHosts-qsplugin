//
//  RemoteHostsAction.h
//  RemoteHosts
//
//  Created by Rob McBroom on 12/24/09.
//

#import <QSCore/QSObject.h>
#import <QSCore/QSActionProvider.h>

#define kRemoteHostsAction @"RemoteHostsAction"
#define QSRemoteHostsType @"QSRemoteHostsType"

// known capabilities for actions
#define kMultipleHosts @"works with multiple objects"
#define kWindowsHosts @"works with windows"
#define kUnixHosts @"works with unix"
#define kHostsWithLOM @"hosts with Lights-Out Management"

@interface QSRemoteHostsAction : QSActionProvider
{
    // array to store details about which actions work with what
    NSDictionary *actionCapabilities;
    // keep a list of all known actions
    NSArray *actionList;
}
@end

