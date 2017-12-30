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
RUN chown ${USER}:${USER} $WORKDIR/intellij

# Download and install intellij scala plugin

RUN mkdir -p /home/$USER/.IdeaIC$INTELLIJ_VER/config/plugins && \
    wget https://plugins.jetbrains.com/plugin/download?updateId=$INTELLIJ_VERID -O /home/$USER/.IdeaIC$INTELLIJ_VER/config/plugins/scalaplugin.zip -q && \    
    cd /home/$USER/.IdeaIC$INTELLIJ_VER/config/plugins/ && \
    unzip -q scalaplugin.zip && \
    rm scalaplugin.zip


####### Spinal HDL ########################################
# Install java and scala
RUN apt-get update && apt-get install -y \
  openjdk-8-jdk \
  scala

# Install sbt
RUN apt-get install -y apt-transport-https #required for sbt debian
RUN echo "deb https://dl.bintray.com/sbt/debian /" | sudo tee -a /etc/apt/sources.list.d/sbt.list
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 2EE0EA64E40A89B84B2DF73499E82A75642AC823
RUN apt-get update
RUN apt-get -y install sbt

# Install vertilator
# Vertilaor (version 3.9+ required, in general apt-get will give 3.8)
RUN apt-get update && apt-get install -y \
  git \
  make \
  autoconf \
  g++ \
  flex \
  bison
RUN mkdir -p /home/$USER/tools
RUN git clone http://git.veripool.org/git/verilator /home/$USER/tools/verilator
RUN unset VERILATOR_ROOT  
WORKDIR /home/$USER/tools/verilator
# Create ./configure script
RUN autoconf
RUN ./configure
RUN make -j$(nproc)
RUN make install

# COCOTB
WORKDIR /home/$USER/tools
RUN apt-get update && apt-get install -y \
  gcc \
  g++ \
  swig \
  python-dev
RUN git clone https://github.com/potentialventures/cocotb
RUN export COCOTB=/home/$USER/tools/cocotb

# GTKWave
RUN apt-get install -y gtkwave

# Install spinal core & lib
RUN mkdir -p /home/$USER/tools/spinal
RUN git clone https://github.com/SpinalHDL/SpinalHDL.git /home/$USER/tools/spinal/SpinalHDL
WORKDIR /home/$USER/tools/spinal/SpinalHDL
RUN sbt clean compile publish-local

RUN mkdir -p /home/$USER/projects/spinal
RUN cd /home/$USER/projects/spinal
RUN git clone https://github.com/SpinalHDL/VexRiscv.git

RUN mkdir /home/$USER/projects/user
RUN git clone https://github.com/SpinalHDL/SpinalTemplateSbt.git /home/$USER/projects/user/SpinalTemplateSbt

WORKDIR /

####### Startup Script ####################################
# run the startup script each time the container is created
COPY ./startup.sh /opt
RUN chmod +x /opt/startup.sh
ENTRYPOINT ["/opt/startup.sh"]




