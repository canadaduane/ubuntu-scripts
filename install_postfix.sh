# Install postfix mail server
# aptitude -y install debconf-utils
# debconf-get-selections >pre
# aptitude -y install postfix
# debconf-get-selections >post
# diff -u pre post
