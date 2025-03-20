#!/bin/sh -eux
#---------------------------------------------------------------------------------------------------
# Install Jsonnet Bundler 'jb' package manager for Jsonnet.
#
# The Jsonnet Bundler project is a package manager for Jsonnet to share and reuse code across the
# internet, similar to 'npm' or 'go mod'. Jsonnet is a configuration language for app and tool
# developers which expresses your apps more obviously than YAML.
#
# For more details, please visit:
#   https://github.com/jsonnet-bundler/jsonnet-bundler
#   https://tanka.dev/install/
#   https://jsonnet.org/
#
# NOTE: Script should be run with 'root' privilege.
#---------------------------------------------------------------------------------------------------

# retrieve the current cpu architecture. -----------------------------------------------------------
cpu_arch=$(uname -m)

# install jsonnet bundler cli client. --------------------------------------------------------------
jb_release="0.6.0"

# set the jsonnet bundler binary and sha256 values based on cpu architecture.
if [ "$cpu_arch" = "x86_64" ]; then
  # set the amd64 variables.
  jb_binary="jb-linux-amd64"
  jb_sha256="78e54afbbc3ff3e0942b1576b4992277df4f6beb64cddd58528a76f0cd70db54"
elif [ "$cpu_arch" = "aarch64" ]; then
  # set the arm64 variables.
  jb_binary="jb-linux-arm64"
  jb_sha256="19f2da64816137cd87a82dd963c752ff4b7c8701fc1ed7b979c356321dcf3f5a"
else
  echo "Error: Unsupported CPU architecture: '${cpu_arch}'."
  exit 1
fi

# create local bin directory (if needed).
mkdir -p /usr/local/bin
cd /usr/local/bin

# download jsonnet bundler from github.com.
rm -f jb
curl --silent --location "https://github.com/jsonnet-bundler/jsonnet-bundler/releases/download/v${jb_release}/${jb_binary}" --output jb
###curl --silent --location "https://github.com/jsonnet-bundler/jsonnet-bundler/releases/latest/download/jb-linux-amd64" --output jb

# change owner and execute permissions.
chown root:root jb
chmod 755 jb

# verify the downloaded binary.
echo "${jb_sha256} jb" | sha256sum --check
# jb: OK

# set jb environment variables.
PATH=/usr/local/bin:$PATH
export PATH

# verify installation. -----------------------------------------------------------------------------
jb --version
