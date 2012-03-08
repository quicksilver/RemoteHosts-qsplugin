//
//  RemoteHostsSource.m
//  RemoteHosts
//
//  Created by Rob McBroom on 12/24/09.
//

#import "RemoteHostsSource.h"


@implementation QSRemoteHostsSource
// if this returns FALSE, the source will be rescanned
// if it returns TRUE, the source is left alone
// unconditional returns will cause it to either be scanned every time, or never
- (BOOL)indexIsValidFromDate:(NSDate *)indexDate forEntry:(NSDictionary *)theEntry
{
    // use the plist settings to determine which file to check
    NSMutableDictionary *settings = [theEntry objectForKey:kItemSettings];
    NSString *sourceFile = [self fullPathForSettings:settings];
    // get the last modified date on the source file
    NSFileManager *manager = [NSFileManager defaultManager];
    if (![manager fileExistsAtPath:sourceFile isDirectory:NULL]) return YES;
    NSDate *modDate = [[manager attributesOfItemAtPath:sourceFile error:NULL] fileModificationDate];
    // compare dates and return whether or not the entry should be rescanned
    if ([modDate compare:indexDate] == NSOrderedDescending) return NO;
    // if we fall through to this point, don't rescan by default
    return YES;
}

// show this on the drop-down for adding custom catalog entries
- (BOOL)isVisibleSource
{
    return YES;
}

- (NSView *)settingsView
{
    if (![super settingsView]) {
        [NSBundle loadNibNamed:NSStringFromClass([self class]) owner:self];
    }
    return [super settingsView];
}

- (NSImage *) iconForEntry:(NSDictionary *)theEntry
{
	return [QSResourceManager imageNamed:@"com.apple.xserve"];
}

// this is set in the Info.plist
// not sure if this method is to conditioanlly override it or what
// - (NSImage *) iconForEntry:(NSDictionary *)dict
// {
//     return [QSResourceManager imageNamed:@"com.apple.xserve"];
// }

// Return a unique identifier for an object (if you haven't assigned one before)
//- (NSString *)identifierForObject:(id <QSObject>)object
//{
//    return @"QSMachineObject0";
//}

- (NSArray *) objectsForEntry:(NSDictionary *)theEntry
{
    // use the plist settings to determine which file to load from
    NSDictionary *settings = [theEntry objectForKey:kItemSettings];
    NSString *path = [self fullPathForSettings:settings];
    //NSLog(@"Loading remote hosts from: %@", path);
    
    // a list of objects that will get returned (and added to the Catalog)
    NSMutableArray *objects=[NSMutableArray arrayWithCapacity:1];
    
    // somewhere to dump errors
    NSError *e;
    
    // read the entire file in as a string
    NSString *hostsSource = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&e];
    // bail out with an error if the file couldn't be opened
    if(!hostsSource) {
        // there was an error reading the file
        NSLog(@"Remote hosts could not be loaded: %@", [e localizedFailureReason]);
        return nil;
    }
    hostsSource = [hostsSource stringByReplacing:@"\n" with:@"\r"];
    NSArray *lines = [hostsSource componentsSeparatedByString:@"\r"];
    
    // read in hosts, one per line
    QSObject *newObject;
    for (NSString *line in lines) {
        // skip empty lines
        if ([line length] == 0) {
            continue;
        }
        // allow other metadata in the file, separated by whitespace
        // hostname or FQDN should be the first thing on the line
        NSArray *lineParts = [line componentsSeparatedByString:@" "];
        // ~/.ssh/known_hosts could be host or host,ip
        // to support that file, split on comma
        NSArray *hostParts = [[lineParts objectAtIndex:0] componentsSeparatedByString:@","];
        NSString *host = [hostParts objectAtIndex:0];
        // check for valid hostnames with a regex
        // valid characters are a-z, 0-9, '.', and '-'
        // must begin with a letter or digit, can contain '-', and can end with '.'
        NSString *hostRegEx = @"^[[:letter:][:number:]][[:letter:][:number:]\\-\\.]*[[:letter:] [:number:]\\.]$";
        NSPredicate *regextest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", hostRegEx];
        if (![regextest evaluateWithObject:host])
        {
            // this doesn't look like a valid hostname - skip it
            continue;
        }
        NSString *ident = [NSString stringWithFormat:@"remote-host-%@", host];
        // build a QSObject
        newObject = [QSObject objectWithName:host];
        [newObject setIdentifier:ident];
        [newObject setObject:host forType:QSRemoteHostsType];
        // this type allows paste, large type, e-mail, IM, etc
        [newObject setObject:host forType:QSTextType];
        [newObject setPrimaryType:QSRemoteHostsType];
        // add some metadata
        if([lineParts count] > 1)
        {
            NSRange allButFirst;
            allButFirst.location = 1;
            allButFirst.length = [lineParts count] - 1;
            for (NSString *metadata in [lineParts subarrayWithRange:allButFirst])
            {
                // metadata should look like 'key:value'
                // if we find something like this, add it
                NSArray *dataParts = [metadata componentsSeparatedByString:@":"];
                if ([dataParts count] == 2)
                {
                    [newObject setObject:[dataParts objectAtIndex:1] forMeta:[dataParts objectAtIndex:0]];
                }
            }
        }
        // make the description and label more useful if possible
        NSString *ostype = [newObject objectForMeta:@"ostype"];
        NSString *hostType;
        if (ostype)
        {
            hostType = [ostype capitalizedString];
        } else {
            hostType = @"Remote";
        }
        // the "details" string appears in smaller text below the object in the UI
        [newObject setDetails:[NSString stringWithFormat:@"%@ (%@ Host)", host, hostType]];
        NSString *labelExtra = [newObject objectForMeta:@"label"];
        if (labelExtra)
        {
            [newObject setLabel:[NSString stringWithFormat:@"%@ • %@", host, labelExtra]];
        }
        
        // if the object is OK, add it to the list
        if (newObject)
            [objects addObject:newObject];
    }
    
    return objects;
    
}

// this method gets the path for a file to scan from an Info.plist
- (NSString *)fullPathForSettings:(NSDictionary *)settings
{
    if (![settings objectForKey:kItemPath]) return nil;
    NSString *itemPath = [[settings objectForKey:kItemPath] stringByResolvingWildcardsInPath];
    if (![itemPath isAbsolutePath]) {
        NSString *bundlePath = [[QSReg bundleWithIdentifier:[settings objectForKey:kItemBaseBundle]] bundlePath];
        if (!bundlePath) bundlePath = [[NSBundle mainBundle] bundlePath];
        itemPath = [bundlePath stringByAppendingPathComponent:itemPath];
    }
    return itemPath;
}

- (IBAction)selectHostsFile:(NSButton *)sender
{
	NSOpenPanel *openPanel = [NSOpenPanel openPanel];
	NSString *oldFile = [[hostsFilePath stringValue] stringByStandardizingPath];
	[openPanel setCanChooseDirectories:YES];
	if (![openPanel runModalForDirectory:[oldFile stringByDeletingLastPathComponent] file:[oldFile lastPathComponent] types:nil]) return;
	[hostsFilePath setStringValue:[[openPanel filename] stringByAbbreviatingWithTildeInPath]];
	[[self selection] setName:[[openPanel filename] lastPathComponent]];
	// update catalog entry
	NSMutableDictionary *settings = [[self currentEntry] objectForKey:kItemSettings];
	if (!settings) {
		settings = [NSMutableDictionary dictionaryWithCapacity:1];
		[[self currentEntry] setObject:settings forKey:kItemSettings];
	}
	[settings setObject:[hostsFilePath stringValue] forKey:kItemPath];
	[settings setObject:[[hostsFilePath stringValue] lastPathComponent] forKey:kItemName];
	[currentEntry setObject:[NSNumber numberWithFloat:[NSDate timeIntervalSinceReferenceDate]] forKey:kItemModificationDate];
	[self populateFields];
	[[NSNotificationCenter defaultCenter] postNotificationName:QSCatalogEntryChanged object:[self currentEntry]];
}

- (void)populateFields
{
	NSMutableDictionary *settings = [[self currentEntry] objectForKey:kItemSettings];
	NSString *path = [settings objectForKey:kItemPath];
	[hostsFilePath setStringValue:(path?path:@"")];
}

// Object Handler Methods

- (void)setQuickIconForObject:(QSObject *)object
{
    // An icon that is either already in memory or easy to load
    
    // check for an icon in metadata
    NSString *icon = [object objectForMeta:@"icon"];
    if (!icon)
    {
        // no icon specified, so pick one based on OS type
        NSString *ostype = [object objectForMeta:@"ostype"];
        if([ostype isEqualToString:@"windows"])
        {
            icon = @"public.generic-pc";
        } else if ([ostype isEqualToString:@"lom"]) {
            icon = @"ToolbarUtilitiesFolderIcon";
        } else {
            icon = @"com.apple.xserve";
        }
    }
    [object setIcon:[QSResourceManager imageNamed:icon]];
}
/*
- (BOOL)loadIconForObject:(QSObject *)object{
    return NO;
    id data=[object objectForType:kRemoteHostsType];
    [object setIcon:nil];
    return YES;
}
*/

- (BOOL)loadChildrenForObject:(QSObject *)object
{
    NSMutableArray *children = [NSMutableArray arrayWithCapacity:1];
    NSString *hostName = [object name];
    // look up the LOM address for this host and add it as a child
    NSString *lom = [object objectForMeta:@"lom"];
    if (lom)
    {
        // NSString *hostNameOnly = [[host componentsSeparatedByString:@"."] objectAtIndex:0];
        // NSString *label = [NSString stringWithFormat:@"%@ • LOM", hostName];
        NSString *label = @"Lights-Out Management";
        // using objectWithString here would cause Quicksilver to treat the address as a URL
        // so we create the object with a few explicit details to make it act like text
        NSString *ident = [NSString stringWithFormat:@"remote-host-%@", lom];
        QSObject *lomObject = [QSObject objectWithName:lom];
        [lomObject setIdentifier:ident];
        [lomObject setObject:lom forType:QSRemoteHostsType];
        // this type allows paste, large type, e-mail, IM, etc
        [lomObject setObject:lom forType:QSTextType];
        [lomObject setPrimaryType:QSRemoteHostsType];
        [lomObject setLabel:label];
        [lomObject setObject:@"lom" forMeta:@"ostype"];
        [children addObject:lomObject];
    }
    // if there's a URL for host info, add it as a child
    NSString *infoURLtemplate = [[NSUserDefaults standardUserDefaults] objectForKey:kInfoURL];
    if (infoURLtemplate) {
        // there's a URL defined to provide host info
        NSString *nameForURL;
        if ([[NSUserDefaults standardUserDefaults] boolForKey:kStripDomain]) {
            nameForURL = [[hostName componentsSeparatedByString:@"."] objectAtIndex:0];
        } else {
            nameForURL = hostName;
        }
        NSString *infoURL = [infoURLtemplate stringByReplacing:@"***" with:nameForURL];
        QSObject *hostInfo = [QSObject URLObjectWithURL:infoURL title:@"Host Info"];
        [hostInfo setIcon:[QSResourceManager imageNamed:@"ToolbarInfo"]];
        [children addObject:hostInfo];
    }
    // look up the IP address for this host and add it as a child
    NSHost *host = [NSHost hostWithName:hostName];
    
    // this action doesn't support the comma-trick
    
    // if there is no such host, skip this
    if (host) {
        for (NSString *ip in [host addresses])
        {
            // using objectWithString here would cause Quicksilver to treat the IP as a URL
            // so we create the object with a few explicit details to make it act like text
            QSObject *ipObject = [QSObject objectWithName:ip];
            [ipObject setObject:ip forType:QSTextType];
            [ipObject setIcon:[QSResourceManager imageNamed:@"GenericNetworkIcon"]];
            [children addObject:ipObject];
        }
        for (NSString *alias in [host names])
        {
            // using objectWithString here would cause Quicksilver to treat the IP as a URL
            // so we create the object with a few explicit details to make it act like text
            QSObject *aliasObject = [QSObject objectWithName:alias];
            [aliasObject setObject:alias forType:QSTextType];
            [aliasObject setIcon:[QSResourceManager imageNamed:@"GenericNetworkIcon"]];
            [children addObject:aliasObject];
        }
    }
    
    [object setChildren:children];
    return TRUE;
}

@end
