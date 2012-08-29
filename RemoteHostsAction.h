//
//  RemoteHostsAction.h
//  RemoteHosts
//
//  Created by Rob McBroom on 12/24/09.
//

#import "RemoteHosts.h"

#define kQSObjectComponents @"QSObjectComponents"

#define kRemoteHostsAction @"RemoteHostsAction"
#define QSRemoteHostsType @"QSRemoteHostsType"
#define QSRemoteHostsGroupType @"QSRemoteHostsGroupType"

// known capabilities for actions
#define kMultipleHosts @"works with multiple objects"
#define kWindowsHosts @"works with windows"
#define kUnixHosts @"works with unix"
#define kRequireCoRD @"requires the CoRD application"

@interface QSRemoteHostsAction : QSActionProvider
{
    // array to store details about which actions work with what
    NSDictionary *actionCapabilities;
    // keep a list of all known actions
    NSArray *actionList;
    // path to the CoRD application
    NSString *cordPath;
}
@end

