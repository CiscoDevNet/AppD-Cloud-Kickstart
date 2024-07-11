# @(#).bashrc       1.0 2024/07/10 SMI
# bash resource configuration for kickstart users.

# source global definitions.
if [ -f /etc/bashrc ]; then
  . /etc/bashrc
fi

# Uncomment the following line if you don't like systemctl's auto-paging feature:
# export SYSTEMD_PAGER=

# user specific aliases and functions.
umask 022

# set java home path.
JAVA_HOME=/usr/local/java/jdk180
#JAVA_HOME=/usr/local/java/jdk11
#JAVA_HOME=/usr/local/java/jdk17
#JAVA_HOME=/usr/local/java/jdk21
export JAVA_HOME

# set ant home path.
ANT_HOME=/usr/local/apache/apache-ant
export ANT_HOME

# set maven home environment variables.
M2_HOME=/usr/local/apache/apache-maven
export M2_HOME
M2_REPO=$HOME/.m2
export M2_REPO
MAVEN_OPTS=-Dfile.encoding="UTF-8"
export MAVEN_OPTS
M2=$M2_HOME/bin
export M2

# set groovy home environment variables.
GROOVY_HOME=/usr/local/apache/groovy
export GROOVY_HOME

# set gradle home path.
GRADLE_HOME=/usr/local/gradle/gradle
export GRADLE_HOME

# set git home paths.
GIT_HOME=/usr/local/git/git
export GIT_HOME
GIT_FLOW_HOME=/usr/local/git/gitflow
export GIT_FLOW_HOME

# set go home paths.
GOROOT=/usr/local/google/go
export GOROOT
GOPATH=$HOME/go
export GOPATH

# set phantomjs environment variables (if needed).
user_host_os=$(hostnamectl | awk '/Operating System/ {printf "%s %s %s %s %s", $3, $4, $5, $6, $7}' | xargs)

# trim excess version characters from amazon linux 2023 release.
if [ "${user_host_os:0:17}" = "Amazon Linux 2023" ]; then
  user_host_os="${user_host_os:0:17}"
fi

# if needed, apply fix for incompatible openssl.
case $user_host_os in
  "Amazon Linux 2023"|"Ubuntu 22.04.4 LTS")
    OPENSSL_CONF=/dev/null
    export OPENSSL_CONF
    ;;

  *)
    ;;
esac

# set appd kickstart home path.
kickstart_home=/opt/appd-cloud-kickstart
export kickstart_home

# set kubectl config path.
KUBECONFIG=$HOME/.kube/config
export KUBECONFIG

# define prompt code and colors.
reset='\[\e]0;\w\a\]'

black='\[\e[30m\]'
red='\[\e[31m\]'
green='\[\e[32m\]'
yellow='\[\e[33m\]'
blue='\[\e[34m\]'
magenta='\[\e[35m\]'
cyan='\[\e[36m\]'
white='\[\e[0m\]'

# define command line prompt.
#PS1="\h[\u] \$ "
#PS1="$(uname -n)[$(whoami)] $ "
#PS1="${reset}${blue}\h${magenta}[${cyan}\u${magenta}]${white}\$ "
PS1="${reset}${cyan}\h${blue}[${green}\u${blue}]${white}\$ "
export PS1

# add local applications to main PATH.
PATH=$JAVA_HOME/bin:$ANT_HOME/bin:$M2:${GROOVY_HOME}/bin:$GRADLE_HOME/bin:$GIT_HOME/bin:$GIT_FLOW_HOME/bin:$GOROOT/bin:$GOPATH/bin:$HOME/.local/bin:$PATH
export PATH

# set options.
set -o noclobber
set -o ignoreeof
set -o vi

# set environment variables to configure command history.
HISTSIZE=16384
export HISTSIZE
HISTCONTROL=ignoredups
export HISTCONTROL

# define system alias commands.
alias back='cd $OLDPWD; pwd'
alias c=clear
alias here='cd $here; pwd'
alias kickstarthome='cd $kickstart_home; pwd'
alias more='less'
alias there='cd $there; pwd'
alias vi='vim'

# fix issue with bash shell tab completion.
complete -r

# process bash completion files.
bcfiles=( .docker-completion.sh .git-completion.bash )

for bcfile in ${bcfiles[@]}; do
  # source bash completion file.
  if [ -f $HOME/${bcfile} ]; then
    . $HOME/${bcfile}
  fi
done

function lsf {
  echo ""
  pwd
  echo ""
  ls -alF $@
  echo ""
}

function psgrep {
  ps -ef | grep "UID\|$@" | grep -v grep
}

function netstatgrep {
  netstat -ant | grep "Active\|Proto\|$@"
}
