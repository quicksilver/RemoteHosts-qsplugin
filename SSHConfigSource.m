#import "SSHConfigSource.h"

@implementation SSHConfigSource

- (NSArray *)objectsForEntry:(NSDictionary *)theEntry {
    NSString *sshConfigPath = [@"~/.ssh/config" stringByExpandingTildeInPath];
    NSString* sshConfig =
        [NSString stringWithContentsOfFile:sshConfigPath
                                  encoding:NSUTF8StringEncoding error:nil];

    NSRegularExpression *regex =
        [NSRegularExpression regularExpressionWithPattern:@"^Host (.*)$"
                                                  options:NSRegularExpressionUseUnixLineSeparators | NSRegularExpressionAnchorsMatchLines
                                                    error:nil];

    NSMutableArray *entries = [NSMutableArray array];
    [regex enumerateMatchesInString:sshConfig
                            options:0
                              range:NSMakeRange(0, [sshConfig length])
                         usingBlock:^(NSTextCheckingResult * result, NSMatchingFlags flags, BOOL * stop) {
            NSString* hostName = [sshConfig substringWithRange:[result rangeAtIndex:1]];
            NSString *identifier = [NSString stringWithFormat:@"remote-host-%@", hostName];
            QSObject* hostEntry = [QSObject objectWithName:hostName];
            [hostEntry setIdentifier:identifier];
            [hostEntry setObject:hostName forType:QSRemoteHostsType];
            [hostEntry setObject:hostName forType:QSTextType];
            [hostEntry setPrimaryType:QSRemoteHostsType];
            [hostEntry setDetails:@"Host in ~/.ssh/config"];
            [entries addObject:hostEntry];
        }];
    return  entries;
}

@end
