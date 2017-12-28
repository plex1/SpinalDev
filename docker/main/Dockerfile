#
# SpinalDev Dockerfile
#
# https://github.com/plex1/SpinalD
#
# This Dockerfile creates a container full of lots of useful tools for
# SpinalHDL development. See associated README.md for more
# information. This Dockerfile is mostly based on the instructions
# found at https://spinalhdl.github.io/SpinalDoc.

# Pull base image.
FROM ubuntu:16.04

# Set the maintainer
MAINTAINER Felix Arnold (plex1) <felix.arnold@gmail.com>

# Install some base tools that we will need to get the risc-v
# toolchain working.
RUN apt-get update && apt-get install -y \
  firefox \
  emacs \
  git \
  x11-apps

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

CMD /usr/bin/xeyes


