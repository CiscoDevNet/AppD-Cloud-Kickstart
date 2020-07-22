#! /bin/bash
cp -r /AD-Capital ${PROJECT}
echo "AD-Capital project copied to docker volume"

cp -r /opt/gradle-2.1 ${PROJECT}
echo "GRADLE project copied to docker volume"
