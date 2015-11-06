#import "RemoteHosts.h"

NSPredicate* predicateForValidHostname() {
  NSString *hostRegEx = @"^[a-zA-Z0-9\\-\\.]*$";
  NSRegularExpression *regex =
    [NSRegularExpression
            regularExpressionWithPattern:hostRegEx
                                 options:NSRegularExpressionUseUnixLineSeparators | NSRegularExpressionAnchorsMatchLines
                                   error:nil];
  return [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject,
                                               NSDictionary<NSString*,id>* bindings) {
      return [regex firstMatchInString:evaluatedObject options:0 range:NSMakeRange(0, [evaluatedObject length])] != nil;
    }];
}

NSString* identifierForHost(NSString* host) {
  return [NSString stringWithFormat:@"remote-host-%@", host];
}

NSMutableArray* sortQSObjects(NSMutableArray* objects) {
  [objects sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
      QSObject* o1 = obj1;
      QSObject* o2 = obj2;
      return [[o1 name] compare:[o2 name]];
    }];
  return objects;
}
