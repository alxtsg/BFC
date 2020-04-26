#!/bin/sh
#
# Author: Alex TSANG <alextsang@live.com>
# License: The 3-Clause BSD License

# Strict mode.
set -e
set -u
IFS='\n\t'

# See NRO website for allocation statistics from RIRs:
# https://www.nro.net/about/rirs/statistics/

workDirectory="$(cd "$(dirname "${0}")"; pwd)"
source='https://ftp.apnic.net/public/stats/apnic/delegated-apnic-latest'
statsFile=$(mktemp)

ftp -V -M -o "${statsFile}" "${source}"

filterByCodes() {
  typeset codes="${1}"
  typeset pattern="/${codes}\|ipv4/"
  # IPv4 address allocations.
  # The 5th column indicates the number of hosts.
  # Calclulate the routing prefix by 32 minus the number of host identifier
  # bits.
  typeset statement="${pattern}"'{ print $4 "/" (32 - log($5) / log(2)) }'
  awk -F '|' "${statement}" "${statsFile}"
  # IPv6 address allocations.
  # The 5th column indicates the CIDR prefix length.
  typeset pattern="/${codes}\|ipv6/"
  typeset statement="${pattern}"'{ print $4 "/" $5 }'
  awk -F '|' "${statement}" "${statsFile}"
}

generateAcceptedTable() {
  typeset whitelistFile="${workDirectory}/whitelist.txt"
  typeset dataFile="${workDirectory}/accepted.data"
  typeset tableFile='/etc/pf-accepted.data'
  typeset codes='(JP)'
  cp "${whitelistFile}" "${dataFile}"
  sed -i.backup '/^$/d' "${dataFile}"
  filterByCodes "${codes}" >> "${dataFile}"
  doas /bin/mv "${dataFile}" "${tableFile}"
  rm "${dataFile}.backup"
}

generateBlockedTable() {
  typeset dataFile="${workDirectory}/blocked.data"
  typeset tableFile='/etc/pf-blocked.data'
  typeset codes='(CN|KP)'
  filterByCodes "${codes}" >> "${dataFile}"
  doas /bin/mv "${dataFile}" "${tableFile}"
}

generateAcceptedTable
generateBlockedTable
doas /sbin/pfctl -f /etc/pf.conf
rm "${statsFile}"
