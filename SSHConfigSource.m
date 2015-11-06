#import "SSHConfigSource.h"

NSString* getConfigPath() {
  return [@"~/.ssh/config" stringByExpandingTildeInPath];
}

NSRegularExpression* hostRegex() {
  return [NSRegularExpression
           regularExpressionWithPattern:@"^Host (.*)$"
                                options:NSRegularExpressionUseUnixLineSeparators | NSRegularExpressionAnchorsMatchLines
                                  error:nil];
}

NSArray* hostsFromMatch(NSTextCheckingResult *result, NSString *sshConfig) {
  NSString *hostsString = [sshConfig substringWithRange:[result rangeAtIndex:1]];
  NSArray *hosts = [[hostsString componentsSeparatedByString:@" "]
                      filteredArrayUsingPredicate:predicateForValidHostname()];
  return hosts;
}

@implementation SSHConfigSource

- (NSArray *)objectsForEntry:(NSDictionary *)theEntry {
  NSString *sshConfig = [NSString stringWithContentsOfFile:getConfigPath() encoding:NSUTF8StringEncoding error:nil];

  NSMutableArray *res = [NSMutableArray array];
  if (!sshConfig) {
    return res;
  }

  [hostRegex() enumerateMatchesInString:sshConfig
                                options:0
                                  range:NSMakeRange(0, [sshConfig length])
                             usingBlock:^(NSTextCheckingResult * match, NSMatchingFlags flags, BOOL * stop) {
      NSArray *hosts = hostsFromMatch(match, sshConfig);
      for (NSString *hostName in hosts) {
        QSObject *hostEntry = [QSObject objectWithName:hostName];
        [hostEntry setIdentifier:identifierForHost(hostName)];
        [hostEntry setObject:hostName forType:QSRemoteHostsType];
        [hostEntry setObject:hostName forType:QSTextType];
        [hostEntry setPrimaryType:QSRemoteHostsType];
        [hostEntry setDetails:@"Host in ~/.ssh/config"];
        [res addObject:hostEntry];
      }
    }];
  return sortQSObjects(res);
}

- (BOOL)indexIsValidFromDate:(NSDate *)indexDate forEntry:(NSDictionary *)theEntry {
  NSString* sshConfigPath = getConfigPath();
  NSFileManager *manager = [NSFileManager defaultManager];
  if (![manager fileExistsAtPath:sshConfigPath isDirectory:NULL]) {
    return YES;
  }
  NSDate *modDate = [[manager attributesOfItemAtPath:sshConfigPath error:NULL] fileModificationDate];
  return [modDate compare:indexDate] == NSOrderedAscending;
}
@end