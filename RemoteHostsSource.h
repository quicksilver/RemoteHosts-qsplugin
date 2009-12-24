//
//  RemoteHostsSource.h
//  RemoteHosts
//
//  Created by Rob McBroom on 12/24/09.
//

#import <QSCore/QSObjectSource.h>

#define QSRemoteHostsType @"QSRemoteHostsType"

@interface QSRemoteHostsSource : QSObjectSource
{
}
- (NSString *)fullPathForSettings:(NSDictionary *)settings;
@end
