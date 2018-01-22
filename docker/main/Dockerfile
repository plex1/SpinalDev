#
# SpinalDev Dockerfile
#
# https://github.com/plex1/SpinalDev
#
# This Dockerfile creates a image full of useful tools for
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
  adwaita-icon-theme-full \ 
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
RUN useradd -m -s /bin/bash -d ${WORKDIR} ${USER}
RUN echo "${USER}:${USERPWD}" | chpasswd
RUN adduser ${USER} sudo

# Customize terminal
RUN echo 'RESET="\[$(tput sgr0)\]"' >> $WORKDIR/.bashrc
RUN echo 'GREEN="\[$(tput setaf 2)\]"' >> $WORKDIR/.bashrc 
RUN echo 'export PS1="${GREEN}\u:\W${RESET} $ "' >> $WORKDIR/.bashrc 

# owner settings:
#  - user root for all files in /opt
#  - user spinaldev for all files in /home/spinaldev


####### Spinal HDL and tools ##############################

USER root
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

USER $USER

# Install spinal core & lib
RUN mkdir -p $WORKDIR/tools/spinal
RUN git clone https://github.com/SpinalHDL/SpinalHDL.git $WORKDIR/tools/spinal/SpinalHDL
WORKDIR $WORKDIR/tools/spinal/SpinalHDL
RUN sbt clean compile publish-local

RUN mkdir -p $WORKDIR/projects/spinal
RUN cd $WORKDIR/projects/spinal
RUN git clone https://github.com/SpinalHDL/VexRiscv.git $WORKDIR/projects/spinal/VexRiscv
RUN git clone https://github.com/SpinalHDL/SpinalTemplateSbt.git $WORKDIR/projects/spinal/SpinalTemplateSbt
RUN git clone https://github.com/SpinalHDL/VexRiscvSocSoftware.git $WORKDIR/projects/spinal/VexRiscvSocSoftware

USER root

# Install verilator
# Verilator (version 3.9+ required, in general apt-get will give 3.8)
RUN apt-get update && apt-get install -y \
  git \
  make \
  autoconf \
  g++ \
  flex \
  bison

USER $USER

RUN mkdir -p $WORKDIR/tools
RUN git clone http://git.veripool.org/git/verilator $WORKDIR/tools/verilator
RUN unset VERILATOR_ROOT  
WORKDIR $WORKDIR/tools/verilator
# Create ./configure script
RUN autoconf
RUN ./configure
RUN make -j$(nproc)
USER root
RUN echo "${USER} ALL =(ALL) NOPASSWD:ALL" | sudo tee -a /etc/sudoers
USER $USER
RUN sudo make install

# Install COCOTB
RUN sudo apt-get update && sudo apt-get install -y \
  gcc \
  g++ \
  swig \
  python-dev
  
WORKDIR $WORKDIR/tools

RUN git clone https://github.com/potentialventures/cocotb
RUN export COCOTB=$WORKDIR/tools/cocotb
RUN echo 'export COCOTB=$WORKDIR/tools/cocotb' >> ~/.bashrc 

# Install GTKWave
RUN sudo apt-get install -y gtkwave

RUN mkdir -p $WORKDIR/projects/user


####### RICSV #############################################

USER root

# Make a working folder and set the necessary environment variables.
ENV RISCV /opt/riscv
ENV NUMJOBS 1


# Add the GNU utils bin folder to the path.
ENV PATH $RISCV/bin:$PATH
RUN echo 'export PATH=/opt/riscv/bin:$PATH' >> $WORKDIR/.bashrc

# Set the version variables
ARG RISCV_GCC_VER=riscv64-unknown-elf-gcc-20170612-x86_64-linux-centos6

WORKDIR /opt

# Download pre-built gcc compiler
RUN wget https://static.dev.sifive.com/dev-tools/$RISCV_GCC_VER.tar.gz -q && \
    tar -xzvf $RISCV_GCC_VER.tar.gz && \
    mv $RISCV_GCC_VER /opt/riscv && \
    rm $RISCV_GCC_VER.tar.gz

# Run a simple test to make sure compile is setup corretly
RUN mkdir -p $RISCV/test
WORKDIR $RISCV/test
RUN echo '#include <stdio.h>\n int main(void) { printf("Hello \
  world!\\n"); return 0; }' > hello.c 
RUN riscv64-unknown-elf-gcc -o hello hello.c


####### FPGA/ASIC FLOW ####################################

WORKDIR /opt

#openocd-riscv-vecriscv
RUN apt-get install -y \
  libtool automake libusb-1.0.0-dev texinfo libusb-dev libyaml-dev pkg-config
  
RUN git clone https://github.com/SpinalHDL/openocd_riscv.git && \
    cd openocd_riscv && \
    ./bootstrap && \
    ./configure --enable-ftdi --enable-dummy  && \
    make
    
#icepack see http://www.clifford.at/icestorm/   
#icepack dependencies
RUN apt-get install -y \
  pkg-config \
  libftdi-dev \
  libffi-dev
  
#yosys dependencies  
RUN apt-get install -y \ 
  tcl-dev \
  clang\
  gawk \
  libreadline-dev \
  mercurial 
  
# yosys  
RUN git clone https://github.com/cliffordwolf/yosys.git yosys && \
    cd yosys && \
    make -j$(nproc) && \
    make install
    
# icepack
RUN git clone https://github.com/cliffordwolf/icestorm.git icestorm && \
    cd icestorm && \
    make -j$(nproc) && \
    make install

# arachne-pnr
RUN git clone https://github.com/cseed/arachne-pnr.git arachne-pnr && \
    cd arachne-pnr && \
    make -j$(nproc) && \
    make install

# iceprogduino
# see https://github.com/OLIMEX/iCE40HX1K-EVB/tree/master/programmer/iceprogduino


####### IntelliJ #######################################

USER root

# Set the version variables
ARG INTELLIJ_VER=2017.3
ARG INTELLIJ_SUBVER=1
ARG INTELLIJ_VERID=41523

# Download and install intellij
RUN wget https://download.jetbrains.com/idea/ideaIC-$INTELLIJ_VER.$INTELLIJ_SUBVER.tar.gz -O /tmp/intellij.tar.gz -q && \
    mkdir -p /opt/intellij && \
    tar -xf /tmp/intellij.tar.gz --strip-components=1 -C /opt/intellij && \
    rm /tmp/intellij.tar.gz
RUN cd /opt/intellij/bin && \
    ln -s idea.sh intellij

# Add intellij to path
RUN echo 'export PATH=$PATH:/opt/intellij/bin/' >> $WORKDIR/.bashrc 

USER $USER

# Download and install intellij scala plugin

RUN mkdir -p $WORKDIR/.IdeaIC$INTELLIJ_VER/config/plugins && \
    wget https://plugins.jetbrains.com/plugin/download?updateId=$INTELLIJ_VERID -O $WORKDIR/.IdeaIC$INTELLIJ_VER/config/plugins/scalaplugin.zip -q && \    
    cd $WORKDIR/.IdeaIC$INTELLIJ_VER/config/plugins/ && \
    unzip -q scalaplugin.zip && \
    rm scalaplugin.zip
    

####### Eclipse ###########################################

USER root
WORKDIR /opt

RUN wget http://www.eclipse.org/downloads/download.php?file=/technology/epp/downloads/release/helios/SR2/eclipse-cpp-helios-SR2-linux-gtk-x86_64.tar.gz -O eclipse.tar.gz -q  && \
    tar -xvzf eclipse.tar.gz && \
    rm eclipse.tar.gz
    
ENV PATH /opt/eclipse:$PATH
RUN echo 'export PATH=/opt/eclipse:$PATH' >> $WORKDIR/.bashrc

# install Zylin Embedded Debugging Plugin
USER $USER
WORKDIR $WORKDIR
RUN eclipse -noSplash -application org.eclipse.equinox.p2.director -repository http://opensource.zylin.com/zylincdt -installIU com.zylin.cdt.feature.feature.group/ 


####### Eclipse and Intellij config  ######################
USER $USER

# copy options where the default Intellij SDK is set to Java 1.8
# manually this can be done by doing
# in welcome screen, configure -> Project defaults -> Project structure
# -> add JDK -> select propesed file JDK 1.8
RUN mkdir -p  $WORKDIR/.IdeaIC$INTELLIJ_VER/config/
COPY ./files/options/ $WORKDIR/.IdeaIC$INTELLIJ_VER/config/options/
USER root
RUN chown -R $USER $WORKDIR/.IdeaIC$INTELLIJ_VER/config/options/
USER $USER

# save an eclipse debug configuration, see https://github.com/spinalhdl/vexriscv
RUN mkdir -p  $WORKDIR/workspace/.metadata/.plugins/org.eclipse.debug.core/.launches/
COPY ./files/Murax.launch $WORKDIR/workspace/.metadata/.plugins/org.eclipse.debug.core/.launches/
USER root
RUN chown -R $USER $WORKDIR/workspace/
USER $USER

########## (move this section up
USER $USER

RUN git clone https://github.com/plex1/SpinalDevTemplateStandalone.git $WORKDIR/projects/user/SpinalDevTemplateStandalone

RUN git clone https://github.com/plex1/SpinalDevTemplateSoc.git $WORKDIR/projects/user/SpinalDevTemplateSoc

####### Startup Script ####################################

USER root
WORKDIR /
# run the startup script each time the container is created
COPY ./startup.sh /opt
RUN chmod +x /opt/startup.sh
ENTRYPOINT ["/opt/startup.sh"]




