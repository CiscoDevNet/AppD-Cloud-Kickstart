#!/bin/sh -eux
# install jq command-line json processor for linux 64-bit.

# install jq json processor. ---------------------------------------------------
jq_binary="jq-linux64"

# create local bin directory (if needed).
mkdir -p /usr/local/bin
cd /usr/local/bin

# set current date for temporary filename.
curdate=$(date +"%Y-%m-%d.%H-%M-%S")

# retrieve version number of latest release.
curl --silent --dump-header curl-jq.${curdate}.out https://github.com/stedolan/jq/releases/latest --output /dev/null
jq_release=$(awk '{ sub("\r$", ""); print }' curl-jq.${curdate}.out | awk '/Location/ {print $2}' | awk -F "/" '{print $8}')
jq_release="jq-1.6"
rm -f curl-jq.${curdate}.out

# download jq binary from github.com.
rm -f jq
curl --silent --location "https://github.com/stedolan/jq/releases/download/${jq_release}/${jq_binary}" --output jq

# change execute permissions.
chmod 755 jq

# set jq environment variables.
PATH=/usr/local/bin:$PATH
export PATH

# verify installation.
jq --version

# jq command-line examples. ----------------------------------------------------
# Example #1:
#   GitHub returns nicely formatted JSON. For servers that don't, it can be
#   helpful to pipe the response through jq to pretty-print it. The simplest
#   jq program is the expression '.', which takes the input and produces it
#   unchanged as output.
#
#   $ curl 'https://api.github.com/repos/stedolan/jq/commits?per_page=5' | jq '.'
#
# Example #2:
#  The 'curl' request returns a lot of information, so we'll restricty it down
#  to the most interesting fields. This example takes the first element of the
#  array and builds a new JSON object out of the 'message' and 'name' fields.
#
#   $ curl 'https://api.github.com/repos/stedolan/jq/commits?per_page=5' | jq '.[0] | {message: .commit.message, name: .commit.committer.name}'
#   {
#     "message": "Merge pull request #162 from stedolan/utf8-fixes\n\nUtf8 fixes. Closes #161",
#     "name": "Stephen Dolan"
#   }
