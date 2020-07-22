FROM openjdk:8

RUN apt-get install -y git

# Install Gradle (unzip this into the shared volume (into appdynamics))
RUN curl -O http://downloads.gradle.org/distributions/gradle-2.1-bin.zip
RUN unzip gradle-2.1-bin.zip -d /opt
RUN rm gradle-2.1-bin.zip

ENV GRADLE_HOME /opt/gradle-2.1
ENV PATH $PATH:$GRADLE_HOME/bin

# Clone source repo from GitHub
RUN git clone -b logging --single-branch https://github.com/Appdynamics/AD-Capital.git

# Gradle build
RUN cd /AD-Capital; gradle build uberjar

# Shared directory mounted as docker volume
ENV PROJECT /project

ADD startup.sh /
RUN chmod 744 /startup.sh

CMD "/startup.sh"
