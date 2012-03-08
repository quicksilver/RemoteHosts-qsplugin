//
//  RemoteHostsSource.h
//  RemoteHosts
//
//  Created by Rob McBroom on 12/24/09.
//

#define QSRemoteHostsType @"QSRemoteHostsType"

@interface QSRemoteHostsSource : QSObjectSource
{
	IBOutlet NSTextField *hostsFilePath;
}
- (NSString *)fullPathForSettings:(NSDictionary *)settings;
- (IBAction)selectHostsFile:(NSButton *)sender;
@end
