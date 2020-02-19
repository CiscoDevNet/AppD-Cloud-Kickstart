#!/bin/sh -eux
# install jmespath jp command-line json processor for linux 64-bit.

# install jp json processor. ---------------------------------------------------
jp_binary="jp-linux-amd64"

# create local bin directory (if needed).
mkdir -p /usr/local/bin
cd /usr/local/bin

# set current date for temporary filename.
curdate=$(date +"%Y-%m-%d.%H-%M-%S")

# retrieve version number of latest release.
curl --silent --dump-header curl-jp.${curdate}.out https://github.com/jmespath/jp/releases/latest --output /dev/null
jp_release=$(awk '{ sub("\r$", ""); print }' curl-jp.${curdate}.out | awk '/Location/ {print $2}' | awk -F "/" '{print $8}')
jp_release="0.1.3"
rm -f curl-jp.${curdate}.out

# download jp binary from github.com.
rm -f jp
curl --silent --location "https://github.com/jmespath/jp/releases/download/${jp_release}/${jp_binary}" --output jp

# change execute permissions.
chmod 755 jp

# set jp environment variables.
PATH=/usr/local/bin:$PATH
export PATH

# verify installation.
jp --version

# jmespath jp command-line examples. -------------------------------------------
# Example #1:
#   $ echo '{"foo": {"bar": ["a", "b", "c"]}}' | jp foo.bar[1]
#   "b"
#
# Example #2:
#   input file: 'locations.json'
#   {
#     "locations": [
#       {"name": "Seattle", "state": "WA"},
#       {"name": "New York", "state": "NY"},
#       {"name": "Bellevue", "state": "WA"},
#       {"name": "Olympia", "state": "WA"}
#     ]
#   }
#
#   $ cat locations.json | jp "locations[?state == 'WA'].name | sort(@) | {WashingtonCities: join(', ', @)}"
#   {
#     "WashingtonCities": "Bellevue, Olympia, Seattle"
#   }
