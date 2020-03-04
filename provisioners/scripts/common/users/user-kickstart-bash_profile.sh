# @(#).bash_profile 1.0 2020/02/28 SMI

# get the aliases and functions.
if [ -f ~/.bashrc ]; then
  . ~/.bashrc
fi

# user specific environment and startup programs.
PATH=$PATH:$HOME/.local/bin:$HOME/bin
export PATH
