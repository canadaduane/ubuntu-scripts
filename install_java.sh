# Install Java 6 from Sun (avoid interactive prompts)
echo 'sun-java6-bin shared/accepted-sun-dlj-v1-1 boolean true
sun-java6-jdk shared/accepted-sun-dlj-v1-1 boolean true
sun-java6-jre shared/accepted-sun-dlj-v1-1 boolean true
sun-java6-jre sun-java6-jre/stopthread boolean true
sun-java6-jre sun-java6-jre/jcepolicy note
sun-java6-bin shared/present-sun-dlj-v1-1 note
sun-java6-jdk shared/present-sun-dlj-v1-1 note
sun-java6-jre shared/present-sun-dlj-v1-1 note
'|debconf-set-selections

aptitude -y install sun-java6-jdk