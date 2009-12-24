## A Quicksilver plug-in for dealing with large numbers of computers ###

Given a text file with a list of machine names in it (either hostname or FQDN), add the ability to index these as some sort of "remote host" object and provide the following actions:

  * Login
  * Login as root
  * Login as… (username in 3rd pane)

All of those will use `ssh://[user@]host`.

The plug-in will scan `~/.hosts` for a list of machines.

### Why? ###

Prior to Mac OS X 10.5 (Leopard), the Terminal application allowed you to store `.term` files in `~/Library/Application Support/Terminal`. These files were just settings to use in a Terminal session, which could be colors, key bindings, etc. but the most useful thing for me was to change the command that was launched for that session. By setting the command for each one to `ssh some.host`, you could quickly reach all of the hosts you normally log into.

You could access these in Terminal by going to File → Library. Bet you didn't know that. Anyway, the Terminal plug-in for Quicksilver knew about this directory and could index it. This made it even faster to connect to any given host without going to Terminal and typing the SSH command. It also gives you a Terminal window with no parent shell, so you can have the window close when ssh exits.

The Terminal in 10.5 and later recognizes `.term` files but handles them in such a way that they are no longer useful. (Memory is fuzzy, but I think they get imported as a new [duplicate] entry under Settings every time you launch them.) A workaround is to create a bunch of `.inetloc` files with `ssh://some.host` as the address and have Quicksilver index those. This works well enough if the only command you ever use is ssh, but we can do better.

### Possible other actions ###

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
    (resulting in an SCP to the default user's home directory)
  * Right-arrow into a host to get a list of files (via SCP or SFTP?)

### Status ###

The three login actions are working.

A preset catalog entry pulls hostnames from `~/.hosts` using the built-in file parser. This gets them each into the catalog as a simple string (most likely interpreted as a web site URL, but don't worry — it will be passed to the actions without the `http://`.)

The optional username on “Connect as…” is not asked for in text mode automatically, so you'll have to hit `.` to switch.

### Credit ###

This would not be possible without the information found at <http://lipidity.com/apple/quicksilver-plugins-in-objective-c>.
