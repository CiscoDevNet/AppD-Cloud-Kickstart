#!/bin/sh -eux
# install gradle build tool by gradle.org.

# install gradle. ----------------------------------------------------------------------------------
# create gradle parent folder.
mkdir -p /usr/local/gradle
cd /usr/local/gradle

# retrieve version number of latest release.
rm -f gradle-release-notes.html
curl --silent https://docs.gradle.org/current/release-notes.html --output gradle-release-notes.html
gradle_home="gradle"
gradle_release=$(awk '/Release Notes<\/title>/ {print $2}' gradle-release-notes.html)
gradle_release="7.5.1"
gradle_folder="gradle-${gradle_release}"
gradle_binary="gradle-${gradle_release}-all.zip"
gradle_sha256="db9c8211ed63f61f60292c69e80d89196f9eb36665e369e7f00ac4cc841c2219"

# download gradle build tool from gradle.org.
curl --silent --location https://services.gradle.org/distributions/${gradle_binary} --output ${gradle_binary}

# verify the downloaded binary.
echo "${gradle_sha256} ${gradle_binary}" | sha256sum --check
# gradle-${gradle_release}-all.zip: OK

# extract gradle binary.
rm -f ${gradle_home}
unzip ${gradle_binary}
chown -R root:root ./${gradle_folder}
ln -s ${gradle_folder} ${gradle_home}
rm -f ${gradle_binary}

# set jdk home environment variables.
JAVA_HOME=/usr/local/java/jdk180
export JAVA_HOME

# set gradle environment variables.
GRADLE_HOME=/usr/local/gradle/${gradle_home}
export GRADLE_HOME
PATH=${GRADLE_HOME}/bin:${JAVA_HOME}/bin:$PATH
export PATH

# verify installation.
gradle --version
