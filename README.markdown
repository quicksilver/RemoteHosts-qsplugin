### Why? ###

If you have more than two or three systems that you regularly interact with, this plug-in will speed up the process tremendously.

I have over 100 systems that I connect to via SSH on a regular basis -- sometimes as a regular user, sometimes as root. That is the main motivation behind this plug-in. But once Quicksilver knows about all these remote systems, it makes sense to start adding other actions besides those related to SSH, which is where some of the additional functionality comes in.

I've kept a list of systems I use in `~/.hosts` for years to allow shell completion on hostnames. It made sense to have Quicksilver use this as well. In the past, Quicksilver was made aware of these through `.term` files in `~/Library/Application Support/Terminal` under 10.4 and using `.inetloc` files in 10.5+. It was a pain to keep in sync with `~/.hosts`, you needed duplicate entries if you wanted to connect as root, via telnet, etc. and the resulting functionality was limited.

### Known Issues and To Do Items ###

  * There's no interface for configuring a custom catalog entry (to pull hosts from different files) although you can add them, and such entries will work if you edit them in `Catalog.plist` by hand.
  * The extra step of converting text in the first pane to a remote host before being able to connect is intentional. I wanted to give the actions some default priority to make them easier to access in the most common use cases. If I supported strings and assigned these priorities, the remote host actions would end up being higher than other defaults for things typed by hand, such as "Large Type". If we let "Large Type" remain as default, you would need to select an action like "SSH" by hand each and every time. As of ß65, Quicksilver will automatically treat FQDNs and IP addresses as remote hosts, so this extra step should be largely unnecessary.
  * I've attempted to add the obvious NFS actions, but the "Internet Locations" for this protocol doesn't seem to work everywhere. If you use "Connect to Server…" in the Finder and type `nfs://server/share_name`, it works. But `open nfs://server/share_name` from Terminal fails. This is essentially what the plugin is asking the system to do, so if `open` doesn't like it, we're out of luck. Sorry.

### Possible Future Actions ###

  * Ping
  * Scan with nmap
  * Etc.

### Pie-in-the-Sky Stuff ###

  * Optionally use the output from a command as the source instead of a file
    (so you could pull a list of hostnames from LDAP, DNS, etc. in real-time)
  * Make each host object a target for file copy operations
    (resulting in an SCP to the default user's home directory?)
  * Right-arrow into a host to get a list of files (via SCP or SFTP?)

### Credit ###

This would not be possible without the information found at <http://lipidity.com/apple/quicksilver-plugins-in-objective-c>.

See the [Documentation](Documentation.mdown)
