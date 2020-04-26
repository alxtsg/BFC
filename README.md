# BFC #

## Description ##

Uses Packet Filter (PF) to accept or block traffic from specific countries.
Written for use on OpenBSD.

Data from APNIC is being used to generate the IP address collections.

## Installation ##

0. Clone the code repository.
1. Update `/etc/doas.conf`.
2. Update `/etc/pf.conf`.
3. Update crontab to update the data file periodically.

## Configuration ##

The `whitelist.txt` file contains IP addresses that traffic from those hosts
are accepted. 1 network block per line. By default, the following network blocks
are whitelisted:

* `10.0.0.0/8`
* `172.16.0.0/12`
* `192.168.0.0/16`
* `fc00::/7`

## Usage ##

BFC copies the processed data files to `/etc` directory and reload the ruleset
using `pfctl(8)`.

Assume BFC is installed at `/home/joe/bfc` and run as the user joe, update
`/etc/doas.conf`:

    permit nopass joe as root cmd /bin/mv args /home/joe/bfc/accepted.data /etc/pf-accepted.data
    permit nopass joe as root cmd /bin/mv args /home/joe/bfc/blocked.data /etc/pf-blocked.data
    permit nopass joe as root cmd /sbin/pfctl args -f /etc/pf.conf

Update `/etc/pf.conf` to load the IP addresses:

    table <accepted> persist file "/etc/pf-accepted.data"
    table <blocked> persist file "/etc/pf-blocked.data"

Update `/etc/pf.conf` to accept and block traffic from the tables. For example:

    # Accept incoming traffic from hosts in <accepted> table to connect to
    # port 22, and block other hosts to connect to port 22.
    pass in quick on egress proto tcp from <accepted> to egress port 22
    block in quick on egress proto tcp from any to egress port 22

    # Block all incoming traffic from hosts in <blocked> table:
    block in quick from <blocked> to any

Update crontab to run BFC periodically:

    # Run daily.
    0 0 * * * /bin/sh /home/joe/bfc/bfc.sh

## License ##

[The 3-Clause BSD License](http://opensource.org/licenses/BSD-3-Clause)
