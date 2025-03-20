#!/bin/bash -eux
#---------------------------------------------------------------------------------------------------
# Install Scala 2 programming language.
#
# Scala 2 is a language that addresses the needs of the modern software developer. It is a
# statically typed, object-oriented, and functional mixed-platform language with a succinct,
# elegant, and flexible syntax, a sophisticated type system, and idioms that promote scalability
# from small tools to large sophisticated applications.
#
# High-level Features:
# - It’s a high-level language
# - It’s statically typed
# - Its syntax is concise but still readable — we call it expressive
# - It supports the object-oriented programming (OOP) paradigm
# - It supports the functional programming (FP) paradigm
# - It has a sophisticated type inference system
# - Scala code results in .class files that run on the Java Virtual Machine (JVM)
# - It’s easy to use Java libraries in Scala
#
# For more details, please visit:
#   https://scala-lang.org/
#   https://scala-lang.org/download/
#   https://docs.scala-lang.org/overviews/scala-book/introduction.html
#   https://docs.scala-lang.org/tutorials/FAQ/index.html
#   https://github.com/scala/scala/
#
# NOTE: Script should be run with 'root' privilege.
#---------------------------------------------------------------------------------------------------

# install scala 2. ---------------------------------------------------------------------------------
scala_home="scala-lang"
scala_release="v2.13.16"
scala_dir="scala-${scala_release:1}"
scala_folder="${scala_home}-${scala_release:1}"
scala_binary="scala-${scala_release:1}.tgz"
scala_sha256="937f743be315302caad15be99ab1ca425ff7e63f15ef5790db6c81bb49543256"

# create scala parent folder.
mkdir -p /usr/local/scala
cd /usr/local/scala

# download scala 2 from lightbend.com.
rm -f ${scala_binary}
wget --no-verbose https://downloads.lightbend.com/scala/${scala_release:1}/${scala_binary}

# verify the downloaded binary.
echo "${scala_sha256} ${scala_binary}" | sha256sum --check
# scala-${scala_release:1}.tgz: OK

# extract scala 2 binary.
rm -f ${scala_home}
rm -Rf ${scala_folder}
tar -zxvf ${scala_binary} --no-same-owner --no-overwrite-dir
mv -f ${scala_dir} ${scala_folder}
chown -R root:root ./${scala_folder}
ln -s ${scala_folder} ${scala_home}
rm -f ${scala_binary}

# verify installation. -----------------------------------------------------------------------------
# set jdk home environment variables.
JAVA_HOME=/usr/local/java/jdk17
export JAVA_HOME

# set scala 2 home environment variables.
SCALA_HOME=/usr/local/scala/${scala_home}
export SCALA_HOME
PATH=${SCALA_HOME}/bin:${JAVA_HOME}/bin:$PATH
export PATH

# display scala 2 version information.
scala -version

# scala 2 quick-start example. ---------------------------------------------------------------------
# 1. Create a project folder for your source code.
#
#    $ mkdir -p scala2/hello-world
#    $ cd scala2/hello-world
#
# 2. Set scala 2 environment variables.
#
#    $ export JAVA_HOME=/usr/local/java/jdk17
#    $ export SCALA_HOME=/usr/local/scala/scala-lang
#    $ export PATH=${SCALA_HOME}/bin:${JAVA_HOME}/bin:$PATH
#
# 3. Create the 'hello.scala' source file.
#    In this code, we defined a method named 'main', inside a Scala object named 'hello'. An
#    object in Scala is similar to a class, but defines a singleton instance that you can pass
#    around. 'main' takes an input parameter named 'args' that must be typed as 'Array[String]'.
#    It prints the given string to standard output (STDOUT) using the 'println' method.
#
#    $ vi hello.scala
#    object hello {
#      def main(args: Array[String]) = {
#        println("Hello, Scala 2 World!")
#      }
#    }
#
# 4. Compile and run the code with scala.
#
#    $ scalac hello.scala
#    $ scala hello
#    Hello, Scala 2 World!
#
# Congratulations, you just compiled and ran your first Scala 2 application!
