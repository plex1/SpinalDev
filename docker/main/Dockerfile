#
# SpinalDev Dockerfile
#
# https://github.com/plex1/SpinalDev
#
# This Dockerfile creates a container full of useful tools for
# SpinalHDL development. See associated README.md for more
# information. This Dockerfile is mostly based on the instructions
# found at https://spinalhdl.github.io/SpinalDoc.

# Pull base image
FROM ubuntu:16.04

# Set the maintainer
MAINTAINER Felix Arnold (plex1) <felix.arnold@gmail.com>

# Global arguments
ARG USER=spinaldev
ARG USERPWD=spinaldev 
ARG WORKDIR=/home/spinaldev
ARG ROOTPWD=spinaldev

# Set frontend required for docker
ENV DEBIAN_FRONTEND noninteractive

####### Packages #######################################
# Install some base tools and x11 tools
RUN apt-get update && apt-get install -y \
  apt-utils \
  sudo \
  unzip \
  wget \
  emacs \
  git \
  x11-apps \
  xfce4\
  xrdp \ 
  xfce4-terminal 
 

####### Linux ##########################################
# Change root password
RUN echo "root:${ROOTPWD}" | chpasswd

# Create the default user
RUN useradd -m -d ${WORKDIR} ${USER}
RUN echo "${USER}:${USERPWD}" | chpasswd


####### RICSV ##########################################
# Make a working folder and set the necessary environment variables.
ENV RISCV /opt/riscv
ENV NUMJOBS 1
RUN mkdir -p $RISCV

# Add the GNU utils bin folder to the path.
ENV PATH $RISCV/bin:$PATH

# Obtain the RISCV-tools repo which consists of a number of submodules
# so make sure we get those too.
#WORKDIR $RISCV
#RUN git clone https://github.com/riscv/riscv-tools.git && \
#  cd riscv-tools && git submodule update --init --recursive


####### IntelliJ ##########################################
# Set the version variables
ARG INTELLIJ_VER=2017.3
ARG INTELLIJ_SUBVER=1
ARG INTELLIJ_VERID=41523

# Download and install intellij
RUN wget https://download.jetbrains.com/idea/ideaIC-$INTELLIJ_VER.$INTELLIJ_SUBVER.tar.gz -O /tmp/intellij.tar.gz -q && \
    mkdir -p /opt/intellij && \
    tar -xf /tmp/intellij.tar.gz --strip-components=1 -C /opt/intellij && \
    rm /tmp/intellij.tar.gz

# Create a link to intellij
RUN ln -s /opt/intellij/bin/idea.sh $WORKDIR/intellij
chown ${USER}:${USER} $WORKDIR/intellij

# Download and install intellij scala plugin
RUN wget https://plugins.jetbrains.com/plugin/download?updateId=$INTELLIJ_VERID -O /home/$USER/.IdeaIC$INTELLIJ_VER/config/plugins/scalaplugin.zip -q && \
    cd /home/$USER/.IdeaIC$INTELLIJ_VERSION/config/plugins/ && \
    unzip -q scalaplugin.zip && \
    rm scalaplugin.zip


####### Spinal HDL ########################################
# Install java and scala
RUN apt-get update && apt-get install -y \
  openjdk-8-jdk \
  scala
  
# Install sbt  
RUN echo "deb https://dl.bintray.com/sbt/debian /" | sudo tee -a /etc/apt/sources.list.d/sbt.list
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 2EE0EA64E40A89B84B2DF73499E82A75642AC823
RUN apt-get update
RUN apt-get -y install sbt

# Install spinal core & lib
RUN mkdir /home/$USER/tools
RUN mkdir /home/$USER/tools/spinal
RUN cd /home/$USER/tools/spinal
RUN git clone https://github.com/SpinalHDL/SpinalHDL.git
RUN cd SpinalHDL
RUN clean compile publish-local

RUN mkdir /home/$USER/projects
RUN mkdir /home/$USER/projects/spinal
RUN cd /home/$USER/projects/spinal
RUN git clone https://github.com/SpinalHDL/VexRiscv.git

RUN mkdir /home/$USER/projects/user
RUN cd /home/$USER/projects/user
RUN git clone https://github.com/SpinalHDL/SpinalTemplateSbt

####### Startup Script ####################################
# run the startup script each time the container is created
COPY ./startup.sh /opt
RUN chmod +x /opt/startup.sh
ENTRYPOINT ["/opt/startup.sh"]




