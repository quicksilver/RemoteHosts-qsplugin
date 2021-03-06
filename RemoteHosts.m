#import "RemoteHosts.h"

NSPredicate *predicateForValidHostname() {
	NSString *hostRegEx = @"^[a-zA-Z0-9\\-\\.]*$";
	NSRegularExpression *regex = [NSRegularExpression
						regularExpressionWithPattern:hostRegEx
						options:NSRegularExpressionUseUnixLineSeparators | NSRegularExpressionAnchorsMatchLines
						error:nil];
	return [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary<NSString*,id>* bindings) {
		return [regex firstMatchInString:evaluatedObject options:0 range:NSMakeRange(0, [evaluatedObject length])] != nil;
	}];
}

NSString *identifierForHost(NSString *host) {
	return [NSString stringWithFormat:@"remote-host-%@", host];
}

BOOL isIPAddress(NSString *fqdn) {
	NSString *ipRegEx = @"^\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}$";
	NSRegularExpression *ipaddr = [NSRegularExpression regularExpressionWithPattern:ipRegEx options:0 error:nil];
	return [ipaddr firstMatchInString:fqdn options:0 range:NSMakeRange(0, [fqdn length])] != nil;
}

QSObject *hostObjectForSource(NSString *fqdn, NSString *source) {
	QSObject *result = [QSObject objectWithName:fqdn];
	[result setObject:source forMeta:@"source"];
	[result setIdentifier:identifierForHost(fqdn)];
	[result setPrimaryType:QSRemoteHostsType];
	[result setObject:fqdn forType:QSRemoteHostsType];

	// this type allows paste, large type, e-mail, IM, etc
	[result setObject:fqdn forType:QSTextType];
	// figure out what the label should be
	BOOL displayHostname = [[NSUserDefaults standardUserDefaults] boolForKey:kDisplayHostname]
	                       && !isIPAddress(fqdn);
	NSString *hostname = displayHostname ? [fqdn componentsSeparatedByString:@"."][0] : fqdn;
	[result setLabel:hostname];
	return result;
}

BOOL isFromCurrentSource(NSString *fqdn, NSString *source) {
	QSObject *candidate = [QSLib objectWithIdentifier:identifierForHost(fqdn)];
	NSString *sourceOfEntry = [candidate objectForMeta:@"source"];
	if (!sourceOfEntry) {
		// qsobjects without source are overwritten
		return YES;
	}
	return [sourceOfEntry isEqualToString:source];
}
