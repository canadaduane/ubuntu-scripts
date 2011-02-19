# Parameters:
# account_for_user.sh [login]

USER_ACCOUNT=$1
USER_HOME=/home/$1

# NOTE: Need to change %sudo ALL=(ALL) NOPASSWD: ALL

# Create user-level account and allow ssh key login
# -m creates home dir
# -U creates group with same name as user
# -p sets password
# -s sets shell
useradd -U -m -p '*' -G sudo -s /bin/bash $USER_ACCOUNT

cd $USER_HOME

tee << '+++' >>.bashrc
export EDITOR=vim
+++
chown $USER_ACCOUNT:$USER_ACCOUNT .bashrc

