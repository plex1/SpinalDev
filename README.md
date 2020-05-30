# SpinalDev - Development Environment for SpinalHDL

[SpinalHDL](https://github.com/SpinalHDL/SpinalHDL) is a hardware description language (HDL). SpinalHDL written on top of Scala and allows for high level constructs. This repository contains a **Dockerfile** for FPGA/ASIC development with SpinalHDL. The Dockerfile and content of this README is mostly based on the instructions found at <https://spinalhdl.github.io/SpinalDoc>. The container includes a number of tools, libraries and dependencies related to SpinalHDL.


## Container Content

The following tools and libraries are installed:

- [Scala](https://www.scala-lang.org/)/[Sbt](https://www.scala-sbt.org/)
- [SpinalHDL](https://github.com/SpinalHDL/SpinalHDL)
    - SpinalHDL core
    - SpinalHDL lib
    - SpinalSim
    - [SpinalTemplate](https://github.com/SpinalHDL/SpinalTemplateSbt)
- [VexRiscv CPU](https://github.com/SpinalHDL/VexRiscv)
- [VexRiscv SoC software](https://github.com/SpinalHDL/VexRiscvSocSoftware)
- [CocoTB](https://github.com/potentialventures/cocotb)
- [GTK wave](http://gtkwave.sourceforge.net/)
- [Verilator](https://www.veripool.org/wiki/verilator)
- [RiscV gcc cross-compiler](https://github.com/riscv/riscv-gnu-toolchain)
- [Yosys](http://www.clifford.at/yosys/)
- [IceStorm Tools](http://www.clifford.at/icestorm/)
    - IcePack/IceUnPack/Icetime/IceProg
      /IceMulti/IcePLL/IceBRAM
- [Arachne-PNR](https://github.com/cseed/arachne-pnr)
- general tools: GIT/python/emacs/...
- X11/ xfce4 desktop environment
- Remote Desktop (rdp) Server listening on port 3389
- [Intellij IDE](https://www.jetbrains.com/idea/) with [Scala plugin](https://plugins.jetbrains.com/plugin/1347-scala)
- Eclipse IDE


## Getting Started

The best way to get started is to download the image for this
container directly from Doc Hub and then run the container and play
inside it. Here are the steps for Ubuntu.

   1. Install docker client (e.g. see [docker docks](https://docs.docker.com/engine/installation/linux/docker-ce/ubuntu/#install-docker-ce))
   2. Get the image, either
      * get image from docker hub
        * `sudo docker pull plex1/spinaldev`
      * OR build image yourself
        * `git clone https://github.com/plex1/SpinalDev.git`
        * `cd SpinalDev/docker/main/`
        * `sudo docker build -t plex1/spinaldev .` 
   3. Add X access for root
      * `xhost local:root`
   4. Run the docker container
      * `sudo docker run -it --rm -e DISPLAY=$DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix -p 3389:3389 plex1/spinaldev:latest`
   5. You are now logged into the development environment as the user spinaldev

As a first step you can run the following commands. They build and test an example design.
```sh
# Go to a SpinalHDL example project
cd projects/spinal/SpinalTemplateSbt

# Generate the Verilog of the design
sbt "runMain mylib.MyTopLevelVerilog"

# Inspect generated files
ls
cat MyTopLevel.v

# Run the scala testbench
sbt "runMain mylib.MyTopLevelSim"

# Inspect the waveform of the simulation
gtkwave simWorkspace/MyTopLevel/test.vcd&

```
Have fun!


## Remote Desktop

There is a remote desktop server running in the container. To connect from linux you may execute the following command.

`rdesktop -z -P -x l -g 1024x768 127.0.0.1:3389`

Then login as user spinaldev with password spinaldev. To connect from windows you may use the native remote desktop client.


## Tour of the environment

### Build the CPU
The VexRiscv risc-v processor can be build with the following set of commands.

```sh
# Go to a risc-v cpu
cd /home/spinaldev/projects/spinal/VexRiscv

# Generate the verilog of the cpu
sbt "runMain vexriscv.demo.GenFull"

# Inspect generated files
ls
head VexRiscv.v
```

### Run a simulation of the CPU
The cpu including software can be simulated and debugged in the container. First, we start a simulation using verilator.

```sh
# Run a simulation of the cpu with a port for OpenOCD to connect to
cd src/test/cpp/regression
make run DEBUG_PLUGIN_EXTERNAL=yes

```

The last message shows BOOT which means that the simulation is running in a process. We open a second terminal. E.g. via docker from your host:
```
docker exec -u spinaldev -it container_id bash
```
In this second terminal we run the following commands to start the OpenOCD server. The server is connected to the simulation which we started above.

```sh
# Start the OpenOCD server
cd /opt/openocd_riscv/
src/openocd -c "set VEXRISCV_YAML /home/spinaldev/projects/spinal/VexRiscv/cpu0.yaml" -f tcl/target/vexriscv_sim.cfg
```

We should now have two terminals open and we will open a third one (e.g. as describe above). Here we run the actual debugger and connect it to the OpenOCD server via tcp port 3333.
```sh
# Run the debugger with prebuild uart example sw
riscv64-unknown-elf-gdb ~/projects/spinal/VexRiscv/src/test/resources/elf/uart.elf
target remote localhost:3333
monitor reset halt
load
continue
```
Now, the simulation of the cpu is running and messages shoud be printed in the first terminal. Specifically, we can see the uart output of the program.

### Build the software
Software for the VexRiscv can be compiled as follows. In this example the uart program for the briey soc is built.
```sh
# Build the elf file
cd ~/projects/spinal/VexRiscvSocSoftware/projects/briey/uart
make all

# Inspect the generated files
ls build/

```

### Create programming file
This container contains all the tools to generate the programming files for a lattice iCE40
FPGAs. A script to generate the [Murax System-on-chip](https://github.com/SpinalHDL/VexRiscv#murax-soc) for the [iCE40HX8K-EVB](https://www.olimex.com/Products/FPGA/iCE40/iCE40HX8K-EVB/open-source-hardware) open source hardware board is provided in the VexRiscv repository. The following command is necssary to build the bin file.
```sh
# Compilation / synthesis / place and route / bitstream generation
cd ~/projects/spinal/VexRiscv/scripts/Murax/iCE40HX8K-EVB
make compile

# Inspect the generated files
ls bin/

```


## Docker Volumes

When working with projects in SpinalDev it is recommended to use docker volumes. The data in containers is not persistent. Therfore the data needs to be stored on the host and mounted in the container (volumes). Docker has build in methods to deal with volumes. It is recommeded to mount the complete home directory (/home/spinaldev). This is because in home some application data is stored. E.g the for the intellij editor this data is under ~/.idea. Without keeping this data upd to date, the idea application and  projects become unsynchronized and projects cannot be opened anymore. The following procedure to generate the docker volumes is recommended. The first time when the docker run command is executed the content of the docker home directory is copied onto the host (in this example under /home/username/spinalvol).

```sh
mkdir /home/username/spinalvol
sudo docker volume create --driver local --opt type=none --opt device=/home/username/spinalvol --opt o=bind spinalvol
sudo docker volume inspect spinalvol

sudo docker run -it --rm -e DISPLAY=$DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix -v spinalvol:/home/spinaldev -p 3389:3389 plex1/spinaldev:latest
```

See also on the [docker website](https://docs.docker.com/engine/admin/volumes/volumes/).


## Create your own projects

To create your own projects run the `project.bash` script and follow the instructions.

```sh
cd /home/spinaldev/projects/user
./project.bash -h
```
