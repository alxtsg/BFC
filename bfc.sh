#!/bin/sh
#
# Creates a list of blacklisted IP addresses for pf to identity and block the
# traffic.
# Author: Alex TSANG <alextsang@live.com>
# License: The 3-Clause BSD License

# Strict mode.
set -e
set -u
IFS='\n\t'

# See NRO website for allocation statistics from RIRs:
# https://www.nro.net/about/rirs/statistics/

workDirectory="$(cd "$(dirname "${0}")"; pwd)"
source='ftp://ftp.apnic.net/public/stats/apnic/delegated-apnic-latest'
statsFile=$(mktemp)
tableFile="${workDirectory}/bfc.data"
pfTableFile='/etc/pf-blocked.data'

ftp -V -M -o "${statsFile}" "${source}"

# IP addresses allocated to China (CN).
# IPv4 address allocations.
awk -F '|' '/CN\|ipv4/{ print $4 "/" (32 - log($5) / log(2)) }' "${statsFile}" \
  >> "${tableFile}"
# IPv6 address allocations.
awk -F '|' '/CN\|ipv6/{ print $4 "/" $5 }' "${statsFile}" >> "${tableFile}"

doas /bin/mv "${tableFile}" "${pfTableFile}"
doas /sbin/pfctl -f /etc/pf.conf

rm "${statsFile}"
