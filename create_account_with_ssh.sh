USER_ACCOUNT=$1

./create_account.sh $USER_ACCOUNT

# Once an account is created, we can add our authorized keys for more secure (and password-less) login

mkdir .ssh
chmod 700 .ssh
chown $USER_ACCOUNT:$USER_ACCOUNT .ssh
cd .ssh

touch authorized_keys
chmod 600 authorized_keys 
chown $USER_ACCOUNT:$USER_ACCOUNT authorized_keys

cat /root/.deploy/id_rsa.pub >>authorized_keys
