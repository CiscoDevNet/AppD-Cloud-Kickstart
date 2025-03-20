#!/bin/bash -eux
#---------------------------------------------------------------------------------------------------
# Install Scala Build Tool (sbt) for scala.
#
# sbt is a build tool for Scala, Java, and more. It is the build tool of choice for 84.7% of the
# Scala developers (2023). One of the examples of Scala-specific feature is the ability to cross
# build your project against multiple Scala versions. sbt requires Java 1.8 or later.
#
# Features of sbt:
# - Little or no configuration required for simple projects.
# - Scala-based build definition that can use the full flexibility of Scala code.
# - Accurate incremental recompilation using information extracted from the compiler.
# - Library management support using Coursier.
# - Continuous compilation and testing with triggered execution.
# - Supports mixed Scala/Java projects.
# - Supports testing with ScalaCheck, specs, and ScalaTest. JUnit is supported by a plugin.
# - Starts the Scala REPL with project classes and dependencies on the classpath.
# - Modularization supported with sub-projects.
# - External project support (list a git repository as a dependency!).
# - Parallel task execution, including parallel test execution.
#
# For more details, please visit:
#   https://www.scala-sbt.org/
#   https://www.scala-sbt.org/download/
#   https://www.scala-sbt.org/1.x/docs/
#   https://github.com/sbt/sbt/
#
# NOTE: Script should be run with 'root' privilege.
#---------------------------------------------------------------------------------------------------

# install sbt. -------------------------------------------------------------------------------------
sbt_home="scala-sbt"
sbt_release="v1.10.11"
sbt_dir="sbt"
sbt_folder="${sbt_home}-${sbt_release:1}"
sbt_binary="sbt-${sbt_release:1}.tgz"
sbt_sha256="5034a64841b8a9cfb52a341e45b01df2b8c2ffaa87d8d2b0fe33c4cdcabd8f0c"

# create scala parent folder.
mkdir -p /usr/local/scala
cd /usr/local/scala

# download sbt from github.com.
rm -f ${sbt_binary}
wget --no-verbose https://github.com/sbt/sbt/releases/download/${sbt_release}/${sbt_binary}

# verify the downloaded binary.
echo "${sbt_sha256} ${sbt_binary}" | sha256sum --check
# sbt-${sbt_release:1}.tgz: OK

# extract sbt binary.
rm -f ${sbt_home}
rm -Rf ${sbt_folder}
tar -zxvf ${sbt_binary} --no-same-owner --no-overwrite-dir
mv -f ${sbt_dir} ${sbt_folder}
chown -R root:root ./${sbt_folder}
ln -s ${sbt_folder} ${sbt_home}
rm -f ${sbt_binary}

# verify installation. -----------------------------------------------------------------------------
# set jdk home environment variables.
JAVA_HOME=/usr/local/java/jdk17
export JAVA_HOME

# set scala home environment variables.
SCALA_HOME=/usr/local/scala/scala-lang
export SCALA_HOME

# set sbt home environment variables.
# NOTE: sbt 1.7.0 introduced an out of memory issue when '-Xms' heap size is set or the default is used.
#       expliciting setting 'SBT_OPTS' to exclude it solved the problem.
SBT_OPTS="-Xmx1024m -Xss4m -XX:ReservedCodeCacheSize=128m"
export SBT_OPTS
SBT_HOME=/usr/local/scala/${sbt_home}
export SBT_HOME
PATH=${SBT_HOME}/bin:${SCALA_HOME}/bin:${JAVA_HOME}/bin:$PATH
export PATH

# display sbt version information.
sbt --allow-empty version
sbt --allow-empty about

# delete temporary sbt files.
rm -Rf /tmp/.sbt*

# sbt quick-start example. -------------------------------------------------------------------------
# 1. Create a minimum SBT build to use Scala 3.6.4.
#
#    $ mkdir -p sbt/hello-world
#    $ cd sbt/hello-world
#    $ touch build.sbt
#    $ echo "ThisBuild / scalaVersion := \"3.6.4\"" >> build.sbt
#
# 2. Set SBT environment variables.
#
#    $ export JAVA_HOME=/usr/local/java/jdk17
#    $ export SCALA_HOME=/usr/local/scala/scala-lang
#    $ export SBT_OPTS="-Xmx1024m -Xss4m -XX:ReservedCodeCacheSize=128m"
#    $ export SBT_HOME=/usr/local/scala/scala-sbt
#    $ export PATH=${SBT_HOME}/bin:${SCALA_HOME}/bin:${JAVA_HOME}/bin:$PATH
#
# 3. Create a source file.
#
#    $ mkdir -p src/main/scala/example
#    $ vi src/main/scala/example/Hello.scala
#    package example
#
#    object Hello {
#      def main(args: Array[String]): Unit = {
#        println("Hello, SBT world!")
#      }
#    }
#
# 4. Start SBT shell.
#
#    $ sbt
#    ...
#    [info] [launcher] getting org.scala-sbt sbt 1.10.10  (this may take some time)...
#    [info] [launcher] getting Scala 2.12.20 (for sbt)...
#    [info] Updated file /home/vagrant/sbt/hello-world/project/build.properties: set sbt.version to 1.10.10
#    [info] welcome to sbt 1.10.10 (Amazon.com Inc. Java 17.0.14)
#    [info] loading project definition from /home/vagrant/sbt/hello-world/project
#    [info] Updating hello-world-build
#    ...
#    [info] loading settings for project hello-world from build.sbt...
#    [info] set current project to hello-world (in build file:/home/vagrant/sbt/hello-world/)
#    [info] sbt server started at local:///home/vagrant/.sbt/1.0/server/7f8775e321749d739d56/sock
#    [info] started sbt server
#    sbt:hello-world>
#
# 5. Compile a project.
#
#    sbt:hello-world> compile
#    ...
#    [info] compiling 1 Scala source to /home/vagrant/sbt/hello-world/target/scala-3.6.4/classes ...
#    [success] Total time: 4 s, completed Mar 13, 2025, 10:19:47 PM
#    sbt:hello-world>
#
# 6. Run your application.
#
#    sbt:hello-world> run
#    [info] running example.Hello
#    Hello, SBT world!
#    [success] Total time: 0 s, completed Mar 13, 2025, 10:20:50 PM
#    sbt:hello-world>
#
# 7. Exit the SBT shell.
#
#    sbt:hello-world> exit
#    [info] shutting down sbt server
#
# Congratulations, you just compiled and ran your first SBT application!
