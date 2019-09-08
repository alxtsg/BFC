# BFC #

## Description ##

BFC (Block From Countries) uses Packet Filter (PF) to block network traffic from
specific countries. Written for use on OpenBSD.

BFC uses data from APNIC. Currently blocks traffic from China.

## Installation ##

0. Clone the code repository.
1. Update `/etc/doas.conf`.
2. Update `/etc/pf.conf`.
3. Update crontab to update the data file periodically.

## Usage ##

BFC copies the processed data file to /etc directory and reload the ruleset
using `pfctl(8)`, which both require root privileges.

Assume BFC is installed at `/home/joe/bfc` and run as the user joe, update
`/etc/doas.conf`:

    permit nopass joe as root cmd /bin/mv args /home/joe/bfc/bfc.data /etc/pf-blocked.data
    permit nopass joe as root cmd /sbin/pfctl args -f /etc/pf.conf

Update `/etc/pf.conf` to block the traffic:

    table <blocked> persist file "/etc/pf-blocked.data"

    # This line should be added early in the configuration file.
    block in quick from <blocked> to any

Update crontab to run BFC periodically:

    # Run daily.
    0 0 * * * /bin/sh /home/joe/bfc/bfc.sh

## License ##

[The 3-Clause BSD License](http://opensource.org/licenses/BSD-3-Clause)
