#!/bin/sh -eux
#---------------------------------------------------------------------------------------------------
# Install Amazon Corretto 8 OpenJDK by Amazon.
#
# Amazon Corretto is a no-cost, multiplatform, production-ready distribution of the Open Java
# Development Kit (OpenJDK). Corretto comes with long-term support that will include performance
# enhancements and security fixes. Amazon runs Corretto internally on thousands of production
# services and Corretto is certified as compatible with the Java SE standard. With Corretto, you
# can develop and run Java applications on popular operating systems, including Linux, Windows,
# and macOS.
#
# For more details, please visit:
#   https://aws.amazon.com/corretto/
#   https://docs.aws.amazon.com/corretto
#
# NOTE: Script should be run with 'root' privilege.
#---------------------------------------------------------------------------------------------------

# set amazon corretto 8 installation variables. ----------------------------------------------------
jdk_home="jdk180"
jdk_build="8.252.09.1"
jdk_checksum="7e9925dbe18506ce35e226c3b4d05613"
jdk_folder="amazon-corretto-${jdk_build}-linux-x64"
jdk_binary="amazon-corretto-${jdk_build}-linux-x64.tar.gz"
#jdk_binary="amazon-corretto-${jdk_build:0:1}-x64-linux-jdk.tar.gz"     # permanent (latest) binary.
jdk_pgpkey_file="B04F24E3.pub"
jdk_sig_file="${jdk_binary}.sig"

# create java home parent folder. ------------------------------------------------------------------
mkdir -p /usr/local/java
cd /usr/local/java

# download and validate corretto 8 binary from aws. ------------------------------------------------
# download the corretto 8 binary.
rm -f ${jdk_binary}
wget --no-verbose https://corretto.aws/downloads/resources/${jdk_build}/${jdk_binary}
#wget --no-verbose https://corretto.aws/downloads/latest/${jdk_binary}  # permanent (latest) url.

# verify the downloaded binary using the md5 checksum.
echo "${jdk_checksum} ${jdk_binary}" | md5sum --check -
# amazon-corretto-${jdk_build}-linux-x64.tar.gz: OK

# download the corretto 8 pgp signature.
rm -f ${jdk_sig_file}
wget --no-verbose https://corretto.aws/downloads/resources/${jdk_build}/${jdk_sig_file}

# create pgp public key file.
rm -f ${jdk_pgpkey_file}
cat <<EOF > ${jdk_pgpkey_file}
-----BEGIN PGP PUBLIC KEY BLOCK-----
Version: GnuPG v2.0.22 (GNU/Linux)

mQINBF3pShkBEADJzglehQDFlc1+9VFubVPzpq8ZYtzmJkNjf09scOUzaKZOm3Ar
mPh9Rufk4mB7t1LP4JeHAKAS17ggCHGVxRGXAAQ9Laf8ibX4SiFO3Ehyyl3smuFf
ZhexBnvc7vRc4EUlKqarCQRUlaraDOrmq7WbhXdvCgc4u2uBLwUjAd3PHQUByAZw
lsEQzpQnehNomjrE0pO6ms9AhmpbXlf/yr14EXvlo4lTd8QUdvS+AOCYfrHb9WGO
IEsyyDuzuf2grV/QFpoi0VBhTCyiNYXla2AfCreMGlOCYsjw1nU93OyAqF3SaTOC
o52yrzcb2NpbBDwRXOHNwe1md+DbRwEfkaWr5I91FqRpgEeawqyxY1miJRHduhsz
WTgTMBF/EQfmTspD2YBX/BjNJTrdDXYvACX8slVV/vBnpi+dEpVEK3hh21ij991S
lv8YoFnoC7XP44C7WNpVQpGW9ZWpnjLCvm3DMKW0r3Vfb3XDYhnHI1Q14Pxn0cwf
x1L2RA4doyWd1TRZBFBe2f0vSkZT0YFaibKaKi6AkDIMU/+u+/e3wWbYXqzsSITj
ffMkpMMNSwxbm8JqnsudjuzdEsYAiBUcFMwWysQDcyu63un2OmLKLfKxy19vCpS1
8mkNy95JuO4jZtu+IiinvSSjlbJmslu3uK3/cTRsWaB7BRtHewE7SugMOwARAQAB
tEhBbWF6b24gU2VydmljZXMgTExDIChBbWF6b24gQ29ycmV0dG8gcmVsZWFzZSkg
PGNvcnJldHRvLXRlYW1AYW1hem9uLmNvbT6JAjEEEwECABsFAl3pShkCGy8FCQlm
AYAFFQgKCQsCHgECF4AACgkQoSJUKrBPJOOJDg/6AqmntaxDWX6qfR++0qwtD9Lp
vgONFvA+9AYQeGt7OX79O/SSPy97Kvn6DYRBdelShTAH60DbXCUs42sIRFqRjmHY
HfIgOkUJjWoJz9oQnY+mzAKbOohCrR+YIvyCegFb0dboDaqSQ4w68+d1is7L84pz
ZB2j0nrQDbFihPmR+epfHkLUGGywuZHCdEFfD8nXMOJeVbgSzf7Vhl8ZrydIkZTI
7aASG5MkDO/GuVpEGQYAnH9h/jzJlfUKndswC6UFcM5Ol07pDPdHVBAi9q1SyxDe
uSS1NgDW7OW7zgpB+4/PrZKKiEP/fBAWa9nFSLwTaMdsoaAuQAmmgbqYfy3XXKK7
IBaKSnJpQDvNb0vmXJEY3qX2Bfh0p1KCeaQhYwIJi8rPQWC24fiLY9bdCIlkbbPQ
CSNOEq9nUWRg9KbUGmd/PWSkT6Jheyq3BZBF1YPYEt8o/l437HHd08lREqH0sana
Hb72GZTi2RUrNBBp5C1e8MqllXE6RKmri2m0TSBHR5C4ZLII9duyA839dYIA4KGU
nmetZckuRuwHFmd3/YWtMEfn47UedzhVT16z3OvBipHU1BKzLGcvUFXrUKvpJQlh
dNPUQh+wb91EzItjkJ96m+N+81iQdN3yd8cE38NTA8b+Qc7tmTYxwNZxcv16FxLA
y2VhKc09A8RwSI69vDs=
=ZNRH
-----END PGP PUBLIC KEY BLOCK-----
EOF

# import the corretto 8 public key.
gpg --import ${jdk_pgpkey_file}

# verify the downloaded binary using the pgp signature.
gpg --verify ${jdk_sig_file} ${jdk_binary}

# install amazon corretto 8. -----------------------------------------------------------------------
# remove existing installation.
rm -f ${jdk_home}
rm -Rf ${jdk_folder}

# extract corretto 8 binary and create softlink to 'jdk180'.
tar -zxvf ${jdk_binary} --no-same-owner --no-overwrite-dir
chown -R root:root ./${jdk_folder}
ln -s ${jdk_folder} ${jdk_home}

# cleanup install files.
rm -f ${jdk_binary}
rm -f ${jdk_sig_file}
rm -f ${jdk_pgpkey_file}

# set corretto 8 home environment variables.
JAVA_HOME=/usr/local/java/${jdk_home}
export JAVA_HOME
PATH=${JAVA_HOME}/bin:$PATH
export PATH

# verify installation.
java -version
