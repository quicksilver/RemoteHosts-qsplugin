## A Quicksilver plug-in for dealing with large numbers of computers ###

Given a text file with a list of machine names in it (either hostname or FQDN), this plug-in indexes them as "remote host" objects and provides the following actions:

  * Login
  * Login as root
  * Login as… (username in 3rd pane)
  * Get IP Address

The plug-in will scan `~/.hosts` for a list of machines by default. The file is treated as UTF-8. I'm not sure what will happen if it isn't.

### Why? ###

If you have more than two or three systems that you regularly interact with, this plug-in will speed up the process tremendously.

I have over 100 systems that I connect to via SSH on a regular basis -- sometimes as a regular user, sometimes as root. That is the main motivation behind this plug-in. But once Quicksilver knows about all these remote systems, it makes sense to start adding other actions besides those related to SSH, which is where some of the additional functionality comes in.

### Known Issues and To Do Items ###

  * The third pane doesn't come up in text-entry mode by default.
  * The "comma trick" doesn't work (for connecting to several hosts at once).
  * There's no interface for configuring a custom catalog entry (to pull hosts from different files) although you can add them, and such entries will work if you edit them in `Catalog.plist` by hand.
  * Icons appear when items are first indexed, but then seem to get lost soon after. I'm also not 100% sure that remote hosts in the catalog are ever updated automatically.
  * There will eventually be an extended description in the `Info.plist` to provide basic features and documentation.

### Possible Future Actions ###

  * Connect with Remote Desktop
  * Ping
  * Scan with nmap
  * Telnet
  * Telnet to port… (port number in 3rd pane)
  * Connect with FTP
  * Connect with VNC
  * Etc.

### Pie-in-the-Sky Stuff ###

  * Make each host object a target for file copy operations
    (resulting in an SCP to the default user's home directory?)
  * Right-arrow into a host to get a list of files (via SCP or SFTP?)

### Status ###

The core functionality is working. The plug-in will scan hosts into the catalog (from `~/.hosts`) and allow you to SSH to them quickly.

### Credit ###

This would not be possible without the information found at <http://lipidity.com/apple/quicksilver-plugins-in-objective-c>.
