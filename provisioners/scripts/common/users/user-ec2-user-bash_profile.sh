# .bash_profile

# get the aliases and functions.
if [ -f ~/.bashrc ]; then
  . ~/.bashrc
fi

# user specific environment and startup programs.
PATH=$PATH:$HOME/.local/bin:$HOME/bin
export PATH
