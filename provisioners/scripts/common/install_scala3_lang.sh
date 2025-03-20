#!/bin/bash -eux
#---------------------------------------------------------------------------------------------------
# Install Scala 3 programming language.
#
# Scala 3 is a language that addresses the needs of the modern software developer. It is a
# statically typed, object-oriented, and functional mixed-platform language with a succinct,
# elegant, and flexible syntax, a sophisticated type system, and idioms that promote scalability
# from small tools to large sophisticated applications.
#
# High-level Features:
# - It’s a high-level programming language.
# - It has a concise, readable syntax.
# - It’s statically-typed (but feels dynamic).
# - It has an expressive type system.
# - It’s a functional programming (FP) language.
# - It’s an object-oriented programming (OOP) language.
# - It supports the fusion of FP and OOP.
# - Contextual abstractions provide a clear way to implement term inference.
# - It runs on the JVM (and in the browser).
# - It interacts seamlessly with Java code.
# - It’s used for server-side applications (including microservices), big data applications, and
#   can also be used in the browser with Scala.js.
#
# For more details, please visit:
#   https://scala-lang.org/
#   https://scala-lang.org/download/
#   https://docs.scala-lang.org/scala3/book/introduction.html
#   https://docs.scala-lang.org/tutorials/FAQ/index.html
#   https://github.com/scala/scala3/
#
# NOTE: Script should be run with 'root' privilege.
#---------------------------------------------------------------------------------------------------

# install scala 3. ---------------------------------------------------------------------------------
scala3_home="scala-lang"
scala3_release="3.6.4"
scala3_dir="scala3-${scala3_release}"
scala3_folder="${scala3_home}-${scala3_release}"
scala3_binary="scala3-${scala3_release}.tar.gz"
scala3_sha256="23c269abf69e942272019cef36ae7f41b7dd0f4324e663eecd30f155d908c4a5"

# create scala parent folder.
mkdir -p /usr/local/scala
cd /usr/local/scala

# download scala 3 from github.com.
rm -f ${scala3_binary}
wget --no-verbose https://github.com/lampepfl/dotty/releases/download/${scala3_release}/${scala3_binary}

# verify the downloaded binary.
echo "${scala3_sha256} ${scala3_binary}" | sha256sum --check
# scala3-${scala3_release}.tar.gz: OK

# extract scala 3 binary.
rm -f ${scala3_home}
rm -Rf ${scala3_folder}
tar -zxvf ${scala3_binary} --no-same-owner --no-overwrite-dir
mv -f ${scala3_dir} ${scala3_folder}
chown -R root:root ./${scala3_folder}
ln -s ${scala3_folder} ${scala3_home}
rm -f ${scala3_binary}

# verify installation. -----------------------------------------------------------------------------
# set jdk home environment variables.
JAVA_HOME=/usr/local/java/jdk17
export JAVA_HOME

# set scala 3 home environment variables.
SCALA_HOME=/usr/local/scala/${scala3_home}
export SCALA_HOME
PATH=${SCALA_HOME}/bin:${JAVA_HOME}/bin:$PATH
export PATH

# display scala 3 version information.
scala version

# scala 3 quick-start example. ---------------------------------------------------------------------
# 1. Create a project folder for your source code.
#
#    $ mkdir -p scala3/hello-world
#    $ cd scala3/hello-world
#
# 2. Set scala 3 environment variables.
#
#    $ export JAVA_HOME=/usr/local/java/jdk17
#    $ export SCALA_HOME=/usr/local/scala/scala-lang
#    $ export PATH=${SCALA_HOME}/bin:${JAVA_HOME}/bin:$PATH
#
# 3. Create the 'hello.scala' source file.
#    In this code, 'hello' is a method. It’s defined with 'def' and declared to be a "main" method
#    with the '@main' annotation. It prints the given string to standard output (STDOUT) using the
#    'println' method.
#
#    $ vi hello.scala
#    @main def hello() = println("Hello, Scala 3 World!")
#
# 4. Compile and run the code with scala.
#
#    $ scala run hello.scala
#    Downloading compilation server 2.0.5
#    Starting compilation server
#    Compiling project (Scala 3.6.4, JVM (17))
#    Compiled project (Scala 3.6.4, JVM (17))
#    Hello, Scala 3 World!
#
# Congratulations, you just compiled and ran your first Scala 3 application!
