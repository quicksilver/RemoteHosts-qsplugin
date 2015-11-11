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

QSObject* hostObjectForSource(NSString* fqdn, NSString* source) {
  QSObject* result = [QSObject objectWithName:fqdn];
  [result setObject:source forMeta:@"source"];
  [result setIdentifier:identifierForHost(fqdn)];
  [result setPrimaryType:QSRemoteHostsType];
  [result setObject:fqdn forType:QSRemoteHostsType];

  // this type allows paste, large type, e-mail, IM, etc
  [result setObject:fqdn forType:QSTextType];
  return result;
}

BOOL isFromCurrentSource(NSString* fqdn, NSString* source) {
  QSObject* candidate = [QSLib objectWithIdentifier:identifierForHost(fqdn)];
  NSString* sourceOfEntry = [candidate objectForMeta:@"source"];
  if (!sourceOfEntry) {
    // qsobjects without source are overwritten
    return YES;
  }
  return [sourceOfEntry isEqualToString:source];
}
