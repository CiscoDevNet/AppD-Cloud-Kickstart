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
#       See 'usage()' function below for environment variable descriptions.
#       Script should be run with 'root' privilege.
#---------------------------------------------------------------------------------------------------

# set default values for input environment variables if not set. -----------------------------------
# [OPTIONAL] aws cli 2 install parameters [w/ defaults].
user_name="${user_name:-centos}"
aws_cli_user_config="${aws_cli_user_config:-false}"
set +x  # temporarily turn command display OFF.
AWS_ACCESS_KEY_ID="${AWS_ACCESS_KEY_ID:-}"
AWS_SECRET_ACCESS_KEY="${AWS_SECRET_ACCESS_KEY:-}"
set -x  # turn command display back ON.
aws_cli_default_region_name="${aws_cli_default_region_name:-us-east-1}"
aws_cli_default_output_format="${aws_cli_default_output_format:-json}"

# [OPTIONAL] appdynamics cloud kickstart home folder [w/ default].
kickstart_home="${kickstart_home:-/opt/appd-cloud-kickstart}"

# define usage function. ---------------------------------------------------------------------------
usage() {
  cat <<EOF
Usage:
  Install AWS Command Line Interface (CLI) 2 by Amazon.

  NOTE: All inputs are defined by external environment variables.
        Optional variables have reasonable defaults, but you may override as needed.
        Script should be run with 'root' privilege.

  -------------------------------------
  Description of Environment Variables:
  -------------------------------------
  [OPTIONAL] aws cli 2 install parameters [w/ defaults].
    [root]# export user_name="centos"                           # [optional] user name (defaults to 'centos').
    [root]# export aws_cli_user_config="true"                   # [optional] configure aws cli 2 for user? [boolean] (defaults to 'false').

    NOTE: Setting 'aws_cli_user_config' to 'true' allows you to perform the AWS CLI configuration concurrently
          with the installation. When 'true', the following environment variables are used for the
          configuration. To successfully connect to your AWS environment, you should set 'AWS_ACCESS_KEY_ID'
          and 'AWS_SECRET_ACCESS_KEY'.

    [root]# export AWS_ACCESS_KEY_ID="<YourKeyID>"              # aws access key id.
    [root]# export AWS_SECRET_ACCESS_KEY="<YourSecretKey>"      # aws secret access key.
    [root]# export aws_cli_default_region_name="us-east-1"      # [optional] aws cli 2 default region name (defaults to 'us-east-1' [N. Virginia]).
    [root]# export aws_cli_default_output_format="json"         # [optional] aws cli 2 default output format (defaults to 'json').
                                                                #            valid output formats:
                                                                #              'json', 'text', 'table'
  [OPTIONAL] appdynamics cloud kickstart home folder [w/ default].
    [root]# export kickstart_home="/opt/appd-cloud-kickstart"   # [optional] kickstart home (defaults to '/opt/appd-cloud-kickstart').
  --------
  Example:
  --------
    [root]# $0
EOF
}

# validate environment variables. ------------------------------------------------------------------
if [ "$aws_cli_user_config" == "true" ]; then
  set +x    # temporarily turn command display OFF.
  if [ -z "$AWS_ACCESS_KEY_ID" ]; then
    echo "Error: 'AWS_ACCESS_KEY_ID' environment variable not set."
    usage
    exit 1
  fi

  if [ -z "$AWS_SECRET_ACCESS_KEY" ]; then
    echo "Error: 'AWS_SECRET_ACCESS_KEY' environment variable not set."
    usage
    exit 1
  fi
  set -x    # turn command display back ON.

  if [ -n "$aws_cli_default_output_format" ]; then
    case $aws_cli_default_output_format in
        json|text|table)
          ;;
        *)
          echo "Error: invalid 'aws_cli_default_output_format'."
          usage
          exit 1
          ;;
    esac
  fi
fi

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
rm -Rf ${aws_cli_folder}
unzip ${aws_cli_binary}
chown -R root:root ./${aws_cli_folder}
./${aws_cli_folder}/install --install-dir ${aws_cli_install_dir} --bin-dir ${aws_cli_bin_dir}

# cleanup installer files.
rm -f ${aws_cli_binary}
rm -f ${aws_cli_sig_file}
rm -Rf ${aws_cli_folder}

# upgrade aws cli 2.
#./${aws_cli_folder}/install --install-dir ${aws_cli_install_dir} --bin-dir ${aws_cli_bin_dir} --update

# uninstall aws cli 2.
#rm -f ${aws_cli_bin_dir}/aws
#rm -f ${aws_cli_bin_dir}/aws_completer
#rm -Rf ${aws_cli_install_dir}

# verify installation. -----------------------------------------------------------------------------
# set aws cli 2 environment variables.
PATH=/usr/local/bin:$PATH
export PATH

# verify aws cli 2 version.
aws --version
#runuser -c "PATH=/home/${user_name}/.local/bin:/usr/local/bin:${PATH} aws --version" - ${user_name}

# configure the aws 2 cli client. ------------------------------------------------------------------
if [ "$aws_cli_user_config" == "true" ]; then
  set +x    # temporarily turn command display OFF.
  aws_config_cmd=$(printf "aws configure <<< \$\'%s\\\\n%s\\\\n%s\\\\n%s\\\\n\'\n" ${AWS_ACCESS_KEY_ID} ${AWS_SECRET_ACCESS_KEY} ${aws_cli_default_region_name} ${aws_cli_default_output_format})
  runuser -c "PATH=/home/${user_name}/.local/bin:/usr/local/bin:${PATH} eval ${aws_config_cmd}" - ${user_name}
  set -x    # turn command display back ON.

  # verify the aws cli 2 configuration by displaying a list of aws regions in table format.
  runuser -c "PATH=/home/${user_name}/.local/bin:/usr/local/bin:${PATH} aws ec2 describe-regions --output table" - ${user_name}
fi
