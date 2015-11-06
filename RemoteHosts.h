//
//  RemoteHosts.h
//  RemoteHosts
//
//  Created by Rob McBroom on 12/24/09.
//

// TODO add interface for listing usernames
// TODO add action to copy (SCP) to a remote host

#define QSRemoteHostsType @"QSRemoteHostsType"
#define QSRemoteHostsGroupType @"QSRemoteHostsGroupType"
#define kStripDomain @"RemoteHostsStripDomain"
#define kInfoURL @"RemoteHostsInfoURL"
#define kDisplayHostname @"RemoteHostsDisplayHostname"
#define kQSMetaOSType @"ostype"
#define kQSMetaGroupMembers @"members"

/**
 * returns a predicate, that checks for valid hostnames.
 * valid characters are a-z, 0-9, '.', and '-'
 * must begin with a letter or digit, can contain '-', and can end with '.'
 * in addition, allow hosts to end with colon and port number
 */
NSPredicate* predicateForValidHostname();

/**
 * calcs the identifier that is used for a host throughout the remote hosts plugin
 */
NSString* identifierForHost(NSString* host);

/**
 * sorts the NSObject-arrays alphabetical after the name
 */
NSMutableArray* sortQSObjects(NSMutableArray* objects);

