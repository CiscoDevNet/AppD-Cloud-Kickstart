#!/bin/sh -eux
# install gradle build tool by gradle.org.

# install gradle. ----------------------------------------------------------------------------------
# retrieve version number of latest release.
rm -f gradle-release-notes.html
curl --silent https://docs.gradle.org/current/release-notes.html --output gradle-release-notes.html
gradle_home="gradle"
gradle_release=$(awk '/Release Notes<\/title>/ {print $2}' gradle-release-notes.html)
gradle_release="8.13"
gradle_folder="gradle-${gradle_release}"
gradle_binary="gradle-${gradle_release}-all.zip"
gradle_sha256="fba8464465835e74f7270bbf43d6d8a8d7709ab0a43ce1aa3323f73e9aa0c612"

rm -f gradle-release-notes.html

# create gradle parent folder.
mkdir -p /usr/local/gradle
cd /usr/local/gradle

# download gradle build tool from gradle.org.
rm -f ${gradle_binary}
curl --silent --location https://services.gradle.org/distributions/${gradle_binary} --output ${gradle_binary}

# verify the downloaded binary.
echo "${gradle_sha256} ${gradle_binary}" | sha256sum --check
# gradle-${gradle_release}-all.zip: OK

# extract gradle binary.
rm -f ${gradle_home}
rm -Rf ${gradle_folder}
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
