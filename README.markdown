### A Quicksilver plug-in for dealing with a large number of computers ###

Given a text file with a list of machine names in it (either hostname or Fully Qualified Domain Name), this plug-in indexes them as "remote host" objects and provides the following actions:

  * SSH to host
  * SSH to host as root
  * SSH to host as… [username in 3rd pane]
  * Telnet to host
  * Telnet to host on port… [port number in 3rd pane]
  * Screen Sharing (VNC)
  * Browse host with CIFS
  * Mount share with CIFS… [share name in 3rd pane]
  * Get IP Address

The plug-in will scan `~/.hosts` for a list of machines by default. The file is treated as UTF-8. I'm not sure what will happen if it's encoded otherwise. The file should contain one host per line. The hostname or FQDN should be the first thing on each line, but other metadata is allowed (separated by whitespace). Additional metadata is currently ignored by the plug-in. An example might look like this:

    server1.example.com linux
    server2 solaris
    windows.example.com skip
    ahostiuse

#### Tips ####

After installation, you may want to check the precedence of the actions and make sure they're to your liking. The actions only apply to "remote hosts" in the catalog, so moving them up rather high on the list shouldn't interfere with other tasks.

If you find yourself using "SSH to host as…" frequently, you may want to add something like this to your `~/.ssh/config`:

    Host server.domain
      User someuser

See the `ssh_config(5)` man page for details.

### Why? ###

If you have more than two or three systems that you regularly interact with, this plug-in will speed up the process tremendously.

I have over 100 systems that I connect to via SSH on a regular basis -- sometimes as a regular user, sometimes as root. That is the main motivation behind this plug-in. But once Quicksilver knows about all these remote systems, it makes sense to start adding other actions besides those related to SSH, which is where some of the additional functionality comes in.

I've kept a list of systems I use in `~/.hosts` for years to allow shell completion on hostnames. It made sense to have Quicksilver use this as well. In the past, Quicksilver was made aware of these through `.term` files in `~/Library/Application Support/Terminal` under 10.4 and using `.inetloc` files in 10.5+. It was a pain to keep in sync with `~/.hosts`, you needed duplicate entries if you wanted to connect as root, via telnet, etc. and the resulting functionality was limited.

### Known Issues and To Do Items ###

  * There's no interface for configuring a custom catalog entry (to pull hosts from different files) although you can add them, and such entries will work if you edit them in `Catalog.plist` by hand.
  * The actions won't apply to strings typed by hand or pasted (so you can type a hostname by hand if it wasn't scanned in from a file). I wanted to give the actions some default priority to make them easier to access in the most common use cases. If I supported strings and assigned these priorities, the remote host actions would end up being higher than other defaults for things typed by hand, such as "Large Type". If enough people ask, I may add arbitrary string support and just set the priorities for all to 0.

### Possible Future Actions ###

  * Connect with MS Remote Desktop
  * Ping
  * Scan with nmap
  * Connect with FTP
  * Etc.

### Pie-in-the-Sky Stuff ###

  * Optionally use the output from a command as the source instead of a file
    (so you could pull a list of hostnames from LDAP, DNS, etc. in real-time)
  * Make each host object a target for file copy operations
    (resulting in an SCP to the default user's home directory?)
  * Right-arrow into a host to get a list of files (via SCP or SFTP?)

### Status ###

The core functionality is working. The plug-in will scan hosts into the catalog (from `~/.hosts`) and allow you to SSH to them quickly. The "comma trick" is supported for connecting to several hosts at once.

### Credit ###

This would not be possible without the information found at <http://lipidity.com/apple/quicksilver-plugins-in-objective-c>.
