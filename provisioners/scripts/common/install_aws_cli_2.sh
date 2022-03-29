#!/bin/sh -eux
#---------------------------------------------------------------------------------------------------
# Install AWS Command Line Interface (CLI) 2 by Amazon.
#
# The AWS Command Line Interface (AWS CLI) 2 is an open source tool that enables you to interact
# with AWS services using commands in your command-line shell. AWS CLI version 2 is the most
# recent major version of the AWS CLI and supports all of the latest features. Some features
# introduced in version 2 are not backward compatible with version 1 and you must upgrade to
# access those features.
#
# For more details, please visit:
#   https://aws.amazon.com/cli/
#   https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2-linux-mac.html
#
# NOTE: All inputs are defined by external environment variables.
#       Optional variables have reasonable defaults, but you may override as needed.
#       Script should be run with 'root' privilege.
#---------------------------------------------------------------------------------------------------

# set default values for input environment variables if not set. -----------------------------------
# [OPTIONAL] appdynamics cloud kickstart home folder [w/ default].
kickstart_home="${kickstart_home:-/opt/appd-cloud-kickstart}"

# create temporary download directory. -------------------------------------------------------------
mkdir -p ${kickstart_home}/provisioners/scripts/centos
cd ${kickstart_home}/provisioners/scripts/centos

# set aws cli 2 installation variables. ------------------------------------------------------------
aws_cli_install_dir="/usr/local/aws-cli"
aws_cli_bin_dir="/usr/local/bin"
aws_cli_binary="awscli-exe-linux-x86_64.zip"
aws_cli_folder="aws"
aws_cli_pgpkey_file="aws-cli-2-public-key.asc"
aws_cli_sig_file="${aws_cli_binary}.sig"

# download the aws cli 2 installer. ----------------------------------------------------------------
rm -f ${aws_cli_binary}
curl --silent --location "https://d1vvhvl2y92vvt.cloudfront.net/${aws_cli_binary}" --output "${aws_cli_binary}"

# validate the installer using the pgp signature. --------------------------------------------------
rm -f ${aws_cli_sig_file}
curl --silent --location "https://d1vvhvl2y92vvt.cloudfront.net/${aws_cli_sig_file}" --output ${aws_cli_sig_file}

# create pgp public key file.
cat <<EOF > ${aws_cli_pgpkey_file}
-----BEGIN PGP PUBLIC KEY BLOCK-----

mQINBF2Cr7UBEADJZHcgusOJl7ENSyumXh85z0TRV0xJorM2B/JL0kHOyigQluUG
ZMLhENaG0bYatdrKP+3H91lvK050pXwnO/R7fB/FSTouki4ciIx5OuLlnJZIxSzx
PqGl0mkxImLNbGWoi6Lto0LYxqHN2iQtzlwTVmq9733zd3XfcXrZ3+LblHAgEt5G
TfNxEKJ8soPLyWmwDH6HWCnjZ/aIQRBTIQ05uVeEoYxSh6wOai7ss/KveoSNBbYz
gbdzoqI2Y8cgH2nbfgp3DSasaLZEdCSsIsK1u05CinE7k2qZ7KgKAUIcT/cR/grk
C6VwsnDU0OUCideXcQ8WeHutqvgZH1JgKDbznoIzeQHJD238GEu+eKhRHcz8/jeG
94zkcgJOz3KbZGYMiTh277Fvj9zzvZsbMBCedV1BTg3TqgvdX4bdkhf5cH+7NtWO
lrFj6UwAsGukBTAOxC0l/dnSmZhJ7Z1KmEWilro/gOrjtOxqRQutlIqG22TaqoPG
fYVN+en3Zwbt97kcgZDwqbuykNt64oZWc4XKCa3mprEGC3IbJTBFqglXmZ7l9ywG
EEUJYOlb2XrSuPWml39beWdKM8kzr1OjnlOm6+lpTRCBfo0wa9F8YZRhHPAkwKkX
XDeOGpWRj4ohOx0d2GWkyV5xyN14p2tQOCdOODmz80yUTgRpPVQUtOEhXQARAQAB
tCFBV1MgQ0xJIFRlYW0gPGF3cy1jbGlAYW1hem9uLmNvbT6JAlQEEwEIAD4WIQT7
Xbd/1cEYuAURraimMQrMRnJHXAUCXYKvtQIbAwUJB4TOAAULCQgHAgYVCgkICwIE
FgIDAQIeAQIXgAAKCRCmMQrMRnJHXJIXEAChLUIkg80uPUkGjE3jejvQSA1aWuAM
yzy6fdpdlRUz6M6nmsUhOExjVIvibEJpzK5mhuSZ4lb0vJ2ZUPgCv4zs2nBd7BGJ
MxKiWgBReGvTdqZ0SzyYH4PYCJSE732x/Fw9hfnh1dMTXNcrQXzwOmmFNNegG0Ox
au+VnpcR5Kz3smiTrIwZbRudo1ijhCYPQ7t5CMp9kjC6bObvy1hSIg2xNbMAN/Do
ikebAl36uA6Y/Uczjj3GxZW4ZWeFirMidKbtqvUz2y0UFszobjiBSqZZHCreC34B
hw9bFNpuWC/0SrXgohdsc6vK50pDGdV5kM2qo9tMQ/izsAwTh/d/GzZv8H4lV9eO
tEis+EpR497PaxKKh9tJf0N6Q1YLRHof5xePZtOIlS3gfvsH5hXA3HJ9yIxb8T0H
QYmVr3aIUes20i6meI3fuV36VFupwfrTKaL7VXnsrK2fq5cRvyJLNzXucg0WAjPF
RrAGLzY7nP1xeg1a0aeP+pdsqjqlPJom8OCWc1+6DWbg0jsC74WoesAqgBItODMB
rsal1y/q+bPzpsnWjzHV8+1/EtZmSc8ZUGSJOPkfC7hObnfkl18h+1QtKTjZme4d
H17gsBJr+opwJw/Zio2LMjQBOqlm3K1A4zFTh7wBC7He6KPQea1p2XAMgtvATtNe
YLZATHZKTJyiqA==
=vYOk
-----END PGP PUBLIC KEY BLOCK-----
EOF

# import the aws cli 2 public key.
gpg --import ${aws_cli_pgpkey_file}

# verify the downloaded binary.
gpg --verify ${aws_cli_sig_file} ${aws_cli_binary}

# install aws cli 2. -------------------------------------------------------------------------------
# uninstall existing aws cli 2 installation.
rm -f ${aws_cli_bin_dir}/aws
rm -f ${aws_cli_bin_dir}/aws_completer
rm -Rf ${aws_cli_install_dir}

rm -Rf ${aws_cli_folder}
unzip ${aws_cli_binary}
chown -R root:root ./${aws_cli_folder}
./${aws_cli_folder}/install --install-dir ${aws_cli_install_dir} --bin-dir ${aws_cli_bin_dir}
#./${aws_cli_folder}/install --install-dir ${aws_cli_install_dir} --bin-dir ${aws_cli_bin_dir} --update

# cleanup installer files.
rm -f ${aws_cli_binary}
rm -f ${aws_cli_sig_file}
rm -Rf ${aws_cli_folder}

# verify installation. -----------------------------------------------------------------------------
# set aws cli 2 environment variables.
PATH=/usr/local/bin:$PATH
export PATH

# verify aws cli 2 version.
aws --version
