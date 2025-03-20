#!/bin/sh -eux
#---------------------------------------------------------------------------------------------------
# Install JMESPath jp command-line JSON processor for Linux 64-bit.
#
# The jp command is a command line interface to JMESPath, an expression language for manipulating
# JSON. The most basic usage of jp is to accept input JSON data through stdin, apply the JMESPath
# expression you've provided as an argument to jp, and print the resulting JSON data to stdout:
#
# $ echo '{"key": "value"}' | jp key
# "value"
#
# Note the argument after jp--this is a JMESPath expression. To learn more about the JMESPath
# language, take a look at the JMESPath Tutorial (provided in the link below) that will take you
# through the JMESPath language.
#
# For more details, please visit:
#   https://github.com/jmespath/jp
#   https://jmespath.org/
#   https://jmespath.org/tutorial.html
#
# NOTE: Script should be run with 'root' privilege.
#---------------------------------------------------------------------------------------------------

# retrieve the current cpu architecture. -----------------------------------------------------------
cpu_arch=$(uname -m)

# install jp json processor. -----------------------------------------------------------------------
jp_release="0.2.1"

# set the jp cli binary and sha256 values based on cpu architecture.
if [ "$cpu_arch" = "x86_64" ]; then
  # set the amd64 variables.
  jp_binary="jp-linux-amd64"
  jp_sha256="f3c5d4cd38a971d9c1666555deb208f080b62708b89d0f5f615e4ae605a0cb8e"
elif [ "$cpu_arch" = "aarch64" ]; then
  # set the arm64 variables.
  jp_binary="jp-linux-arm64"
  jp_sha256="eba658170bfbcad1b5a49c0b087ce153544575e082f77b049de3563f0c5dd536"
else
  echo "Error: Unsupported CPU architecture: '${cpu_arch}'."
  exit 1
fi

# create local bin directory (if needed).
mkdir -p /usr/local/bin
cd /usr/local/bin

# download jp binary from github.com.
rm -f ${jp_binary} jp
curl --silent --location "https://github.com/jmespath/jp/releases/download/${jp_release}/${jp_binary}" --output ${jp_binary}

# verify the downloaded binary.
echo "${jp_sha256} ${jp_binary}" | sha256sum --check
# jp-linux-amd64: OK
# jp-linux-arm64: OK

# rename executable and change execute permissions.
mv -f ${jp_binary} jp
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
