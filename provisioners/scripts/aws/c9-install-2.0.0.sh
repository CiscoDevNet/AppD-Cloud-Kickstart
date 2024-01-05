#!/bin/bash -e
set -e
has() {
  type "$1" > /dev/null 2>&1
}

# Redirect stdout ( > ) into a named pipe ( >() ) running "tee"
# exec > >(tee /tmp/installlog.txt)

# Without this, only stdout would be captured - i.e. your
# log file would not contain any error messages.
exec 2>&1

if has "wget"; then
  DOWNLOAD() {
    wget --no-check-certificate -nc -O "$2" "$1"
  }
elif has "curl"; then
  DOWNLOAD() {
    curl -sSL -o "$2" "$1"
  }
else
  echo "Error: you need curl or wget to proceed" >&2;
  exit 1
fi

# Specify the CDN URL using `PROD_CLOUDFRONT_URL=...`. Defaults to us-east-1 region url
PROD_CLOUDFRONT_URL=${PROD_CLOUDFRONT_URL:-'https://d3kgj69l4ph6w4.cloudfront.net/static'}
C9_DIR=$HOME/.c9
if [[ ${1-} == -d ]]; then
    C9_DIR=$2
    shift 2
fi

# Check if C9_DIR exists
if [ ! -d "$C9_DIR" ]; then
  mkdir -p $C9_DIR
fi

VERSION=1
NPM=$C9_DIR/node/bin/npm
NODE=$C9_DIR/node/bin/node

export TMP=$C9_DIR/tmp
export TMPDIR=$TMP

PYTHON=python3

# node-gyp uses sytem node or fails with command not found if
# we don't bump this node up in the path
PATH="$C9_DIR/node/bin/:$C9_DIR/node_modules/.bin:$PATH"

start() {
  if [ $# -lt 1 ]; then
    start base
    return
  fi

  check_deps
  
  # Try to figure out the os and arch for binary fetching
  local uname="$(uname -s)"
  local os=
  local arch="$(uname -m)"
  case "$uname" in
    Linux*) os=linux ;;
    Darwin*) os=darwin ;;
    SunOS*) os=sunos ;;
    FreeBSD*) os=freebsd ;;
    CYGWIN*) os=windows ;;
    MINGW*) os=windows ;;
  esac
  case "$arch" in
    *arm64*) arch=arm64 ;;
    *aarch64*) arch=arm64 ;;
    *armv7l*) arch=armv7l ;;
    *x86_64*) arch=x64 ;;
    *)
      echo "Unsupported Architecture: $os $arch" 1>&2
      exit 1
    ;;
  esac

  if [ "$os" != "linux" ] && [ "$os" != "darwin" ]; then
    echo "Unsupported Platform: $os $arch" 1>&2
    exit 1
  fi

  case $1 in
    "help" )
      echo
      echo "Cloud9 Installer"
      echo
      echo "Usage:"
      echo "    install help                       Show this message"
      echo "    install install [name [name ...]]  Download and install a set of packages"
      echo "    install ls                         List available packages"
      echo
    ;;

    "ls" )
      echo "!node - Node.js"
      echo "!tmux - TMUX"
      echo "!nak - NAK"
      echo "!ptyjs - pty.js"
      echo "!collab - collab"
      echo "coffee - Coffee Script"
      echo "less - Less"
      echo "sass - Sass"
      echo "typescript - TypeScript"
      echo "stylus - Stylus"
      echo "codeintel - CodeIntel"
    ;;
    
    "install" )
      shift
    
      # make sure dirs are around
      mkdir -p "$C9_DIR"/bin
      mkdir -p "$C9_DIR"/tmp
      mkdir -p "$C9_DIR"/node_modules
    
      # install packages
      while [ $# -ne 0 ]
      do
        if [ "$1" == "tmux" ]; then
          cd "$C9_DIR"
          time tmux_install $os $arch
          shift
          continue
        fi
        cd "$C9_DIR"
        time eval ${1} $os $arch
        shift
      done
      
      # finalize
      pushd "$C9_DIR"/node_modules/.bin
      for FILE in "$C9_DIR"/node_modules/.bin/*; do
        FILE=$(readlink "$FILE")
        # can't use the -i flag since it is not compatible between bsd and gnu versions
        sed -e's/#!\/usr\/bin\/env node/#!'"${NODE//\//\\/}/" "$FILE" > "$FILE.tmp-sed"
        mv "$FILE.tmp-sed" "$FILE"
      done
      popd
      
      echo $VERSION > "$C9_DIR"/installed
      
      cd "$C9_DIR"
      DOWNLOAD "$PROD_CLOUDFRONT_URL/license-notice.md" "Third-Party Licensing Notices.md"
      
      echo :Done.
    ;;
    
    "base" )
      echo "Installing base packages. Use --help for more options"
      start install node tmux_install nak ptyjs collab codeintel
    ;;
    
    * )
      start base
    ;;
  esac
}

check_deps() {
  local ERR
  local OS
  
  if [[ `cat /etc/os-release 2>/dev/null` =~ CentOS ]]; then
    OS="CentOS"
  elif [[ `cat /proc/version 2>/dev/null` =~ Ubuntu|Debian ]]; then
    OS="DEBIAN"
  fi

  for DEP in make gcc; do
    if ! has $DEP; then
      echo "Error: please install $DEP to proceed" >&2
      if [ "$OS" == "CentOS" ]; then
        echo "To do so, log into your machine and type 'yum groupinstall -y development'" >&2
      elif [ "$OS" == "DEBIAN" ]; then
        echo "To do so, log into your machine and type 'sudo apt-get install build-essential'" >&2
      fi
      ERR=1
    fi
  done
  
  # CentOS
  if [ "$OS" == "CentOS" ]; then
    if ! yum list installed glibc-static >/dev/null 2>&1; then
      echo "Error: please install glibc-static to proceed" >&2
      echo "To do so, log into your machine and type 'yum install glibc-static'" >&2
      ERR=1
    fi
  fi
  
  check_python
  
  if [ "$ERR" ]; then exit 1; fi
}

check_python() {
  if type -P python3 &> /dev/null; then
    PYTHON="python3"
  elif type -P python &> /dev/null; then
    PYTHON="python"
  fi

  PYTHON_VERSION=$($PYTHON -c 'import sys; print(".".join(map(str, sys.version_info[:2])))')
  
  if [[ $PYTHON_VERSION != "3."* ]]; then
    echo "Python 3 is required to install pty.js. Please install python and try again. You can find more information on how to install Python in the docs: https://docs.aws.amazon.com/cloud9/latest/user-guide/ssh-settings.html#ssh-settings-requirements"
    exit 100
  fi

  if $PYTHON -c 'import venv,ensurepip' &>/dev/null; then
    echo "venv is installed"
  else
    if which apt &> /dev/null; then
      echo "venv and ensurepip is required to create virtual environment. Please run command 'sudo apt install python3-venv' to install dependencies."
    else
      echo "venv and ensurepip is required to create virtual environment. Please install and try again."
    fi
    exit 100
  fi
}

# NodeJS

setup_gyp_config() {
  set_npm_global_config python3 "$PYTHON"
  set_npm_global_config python "$PYTHON"
  set_npm_global_config unsafe-perm "true"
  
  local GYP_PATH=$C9_DIR/node/lib/node_modules/npm/node_modules/node-gyp/bin/node-gyp.js
  if [ -f  "$GYP_PATH" ]; then
    ln -s "$GYP_PATH" "$C9_DIR"/node/bin/node-gyp &> /dev/null || :
  fi
}

set_npm_global_config() {
  if "$NPM" config -g set $1 $2 >/dev/null 2>&1; then
    return 0
  else
    GLOBAL_NPMRC=$C9_DIR/node/etc/npmrc
    grep "$1 = " $GLOBAL_NPMRC || echo "$1 = $2" >> $GLOBAL_NPMRC
  fi
}

get_node_version() {
  if minimum_kernel_version 4 18 && \
     supports_c_standard gnu++17 && \
     verify_lib_dependency libc.so.6 GLIBC_2.28 && \
     verify_lib_dependency libstdc++.so.6 GLIBCXX_3.4.25 CXXABI_1.3.9; then
    printf "%s" "v18.19.0"
  elif supports_c_standard gnu++14; then
    printf "%s" "v16.20.1"
  else
    printf "%s" "v12.16.1"
  fi
}

minimum_kernel_version() {
  KERNEL_MAJOR_VERSION=`uname -r | cut -d '.' -f 1`
  KERNEL_MINOR_VERSION=`uname -r | cut -d '.' -f 2`
  minimum_version_check $KERNEL_MAJOR_VERSION $KERNEL_MINOR_VERSION $1 $2
}

minimum_version_check() {
  # minimum_version_check(4, 19, 4, 18) will check if version 4.19 is greater than or equal to 4.18
  MAJOR_VERSION_1=$1
  MINOR_VERSION_1=$2
  MAJOR_VERSION_2=$3
  MINOR_VERSION_2=$4
  if [ $MAJOR_VERSION_1 -gt $MAJOR_VERSION_2 ]; then
    return 0
  elif [ $MAJOR_VERSION_1 -eq $MAJOR_VERSION_2 ] && [ $MINOR_VERSION_1 -ge $MINOR_VERSION_2 ]; then
    return 0
  else
    return 1
  fi
}

supports_c_standard() {
  gcc -v --help 2> /dev/null | grep -q "std=$1"
}


verify_lib_dependency() {
  LIB_NAME=$1
  shift 1
  for path in $(get_lib_paths $LIB_NAME); do
    verify_symbols_in_lib_object "$path" "$@" && return 0
  done
  return 1
}

verify_symbols_in_lib_object() {
  if has "nm"; then
    # Only verify if nm is available to read symbols from object files
    LIB_PATH=$1
    shift 1
    NUM_SYMBOLS=$#
    REGEX=$(make_symbol_regex "$@")
    COUNT=$(nm -gDPA $LIB_PATH | grep -oE "$REGEX" | sort -u | wc -l)
    if [ $COUNT -eq $NUM_SYMBOLS ]; then
      return 0
    fi
  fi
  return 1
}

make_symbol_regex() {
  REGEX=""
  while [ $# -gt 0 ]; do
    REGEX="$REGEX\s$1\s"
    if [ $# -gt 1 ]; then
      REGEX="$REGEX|"
    fi
    shift 1
  done
  echo "$REGEX"
}

get_lib_paths() {
  if has "whereis"; then
    for path in $(whereis $1 | cut -d ' ' -f 2-); do
      if [[ "$path" =~ "$1" ]]; then
        printf "%s " "$path"
      fi
    done | sed 's/ $/\n/'
  elif has "ldconfig"; then
    for line in $(ldconfig -p | grep $1 | sed 's/.* => \(.*\)$/\1/'); do
      printf "%s " "$line"
    done | sed 's/ $/\n/'
  fi
}

node(){
  NODE_VERSION=$(get_node_version)
  # clean up 
  rm -rf node 
  rm -rf node.tar.gz
  
  echo :Installing Node $NODE_VERSION
  
  DOWNLOAD "$PROD_CLOUDFRONT_URL/node-$NODE_VERSION/node-$NODE_VERSION-$1-$2.tar.gz" node.tar.gz
  tar xzf node.tar.gz
  mv "node-$NODE_VERSION-$1-$2" node
  rm -f node.tar.gz

  # use local npm cache
  "$NPM" config -g set cache  "$C9_DIR/tmp/.npm"
  setup_gyp_config

}

compile_tmux(){
  cd "$C9_DIR"
  echo ":Compiling libevent..."
  tar xzf libevent-2.1.8-stable.tar.gz
  rm libevent-2.1.8-stable.tar.gz
  cd libevent-2.1.8-stable
  echo ":Configuring Libevent"
  ./configure --disable-shared --prefix="$C9_DIR/local"
  echo ":Compiling Libevent"
  make
  echo ":Installing libevent"
  make install
 
  cd "$C9_DIR"
  echo ":Compiling ncurses..."
  tar xzf ncurses-6.3.tar.gz
  rm ncurses-6.3.tar.gz
  cd ncurses-6.3
  echo ":Configuring Ncurses"
  CPPFLAGS=-P ./configure --prefix="$C9_DIR/local" --without-tests --without-cxx
  echo ":Compiling Ncurses"
  make
  echo ":Installing Ncurses"
  make install
 
  cd "$C9_DIR"
  echo ":Compiling tmux..."
  tar xzf tmux-2.2.tar.gz
  rm tmux-2.2.tar.gz
  cd tmux-2.2
  echo ":Configuring Tmux"
  ./configure CFLAGS="-I$C9_DIR/local/include -I$C9_DIR/local/include/ncurses" LDFLAGS="-static-libgcc -L$C9_DIR/local/lib" --prefix="$C9_DIR/local"
  echo ":Compiling Tmux"
  make
  echo ":Installing Tmux"
  make install
}

tmux_download(){
  echo ":Downloading tmux source code"
  echo ":N.B: This will take a while. To speed this up install tmux 2.2 manually on your machine and restart this process."
  
  echo ":Downloading Libevent..."
  DOWNLOAD "$PROD_CLOUDFRONT_URL/libevent-2.1.8-stable.tar.gz" libevent-2.1.8-stable.tar.gz
  echo ":Downloading Ncurses..."
  DOWNLOAD "$PROD_CLOUDFRONT_URL/ncurses-6.3.tar.gz" ncurses-6.3.tar.gz
  echo ":Downloading Tmux..."
  DOWNLOAD "$PROD_CLOUDFRONT_URL/tmux-2.2.tar.gz" tmux-2.2.tar.gz
}

check_tmux_version(){
  if [ ! -x "$1" ]; then
    return 1
  fi
  tmux_version=$($1 -V | sed -e's/^[a-z0-9.-]* //g' | sed -e's/[a-z]*$//')  
  if [ ! "$tmux_version" ]; then
    return 1
  fi

  if [ "$("$PYTHON" -c "print(1.7<=$tmux_version and $tmux_version <= 2.2)")" == "True" ]; then
    return 0
  else
    return 1
  fi
}

tmux_install(){
  echo :Installing TMUX
  mkdir -p "$C9_DIR/bin"
  if check_tmux_version "$C9_DIR/bin/tmux"; then
    echo ':Existing tmux version is up-to-date'
  
  # If we can support tmux 1.9 or detect upgrades, the following would work:
  elif has "tmux" && check_tmux_version "$(which tmux)"; then
    echo ':A good version of tmux was found, creating a symlink'
    ln -sf "$(which tmux)" "$C9_DIR"/bin/tmux
    return 0
  
  # If tmux is not present or at the wrong version, we will install it
  else
    if ! has "make"; then
      echo ":Could not find make. Please install make and try again."
      exit 100;
    fi

    tmux_download
    compile_tmux
    ln -sf "$C9_DIR"/local/bin/tmux "$C9_DIR"/bin/tmux
  fi
  
  if ! check_tmux_version "$C9_DIR"/bin/tmux; then
    echo "Installed tmux does not appear to work:"
    exit 100
  fi
}

collab(){
  echo :Installing Collab Dependencies
  "$NPM" install sqlite3@4.2.0
  mkdir -p "$C9_DIR"/lib
  cd "$C9_DIR"/lib
  DOWNLOAD "$PROD_CLOUDFRONT_URL/sqlite3.tar.gz" sqlite3.tar.gz
  tar xzf sqlite3.tar.gz
  rm sqlite3.tar.gz
  ln -sf "$C9_DIR"/lib/sqlite3/sqlite3 "$C9_DIR"/bin/sqlite3
}

nak(){
  echo :Installing Nak
  "$NPM" install https://github.com/c9/nak/tarball/c9
}

ptyjs(){
  echo :Installing pty.js
  "$NPM" install @ionic/node-pty-prebuilt@0.9.1

  if ! hasPty; then
    echo "Unknown exception installing pty.js"
    "$C9_DIR/node/bin/node" -e "console.log(require('@ionic/node-pty-prebuilt'))"
    exit 100
  fi
}

hasPty() {
  local HASPTY=$("$C9_DIR/node/bin/node" -p "typeof require('@ionic/node-pty-prebuilt').createTerminal=='function'" 2> /dev/null)
  if [ "$HASPTY" != true ]; then
    return 1
  fi
}

coffee(){
  echo :Installing Coffee Script
  "$NPM" install coffee
}

less(){
  echo :Installing Less
  "$NPM" install less
}

sass(){
  echo :Installing Sass
  "$NPM" install sass
}

typescript(){
  echo :Installing TypeScript
  "$NPM" install typescript  
}

stylus(){
  echo :Installing Stylus
  "$NPM" install stylus  
}

codeintel(){
  local CODEINTEL_ENV="$C9_DIR/python3_codeintel"
  local PYTHON3
  
  if which python3 &> /dev/null; then
    PYTHON3="python3"
  elif [[ `python --version` =~ 'Python 3' ]]; then
    PYTHON3="python"
  else
    echo "Skipping CodeIntel installation because python3 is not installed."
    return
  fi

  if ! $PYTHON3 -c "import venv" 1> /dev/null; then
    echo "Skipping CodeIntel installation because python3 venv module is not installed."
    return
  fi

  INCLUDEPY=$($PYTHON3 -c "from distutils import sysconfig; print(sysconfig.get_config_vars()['INCLUDEPY'])")
  if [[ ! -f "$INCLUDEPY/Python.h" ]]; then
      echo "Skipping CodeIntel installation because python3 dev files aren't present."
      return
  fi

  echo "Creating a CodeIntel venv at $CODEINTEL_ENV"
  rm -rf $CODEINTEL_ENV
  $PYTHON3 -m venv "$CODEINTEL_ENV"

  echo "Activating a CodeIntel venv"
  source "$CODEINTEL_ENV/bin/activate"

  if ! pip --version &> /dev/null; then
    echo "Skipping CodeIntel installation because pip is not installed."
  fi

  echo "Installing CodeIntel"
  pip install "$PROD_CLOUDFRONT_URL/CodeIntel-2.0.0.post1.tar.gz" inflector==3.1.0

  echo "Successfully installed CodeIntel."
}

start "$@"

# cleanup tmp files
rm -rf "$C9_DIR/tmp"
