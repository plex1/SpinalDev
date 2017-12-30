# SpinalDev - Development Environment for SpinalHDL

[SpinalHDL](https://github.com/SpinalHDL/SpinalHDL) is a hardware description language (HDL). SpinalHDL is based on Scala and allows for high level constructs. This repository contains a **Dockerfile** for FPGA/ASIC development with SpinalHDL. The Dockerfile is mostly based on the instructions found at <https://spinalhdl.github.io/SpinalDoc>. The container includes a number of tools, libraries and dependencies based around SpinalHDL.

## Container content

The following tools and libraries are installed:

- [Scala](https://www.scala-lang.org/)/[Sbt](https://www.scala-sbt.org/)
- [SpinalHDL](https://github.com/SpinalHDL/SpinalHDL)
    - SpinalHDL core
    - SpinalHDL lib
    - SpinalSim
    - [SpinalTemplate](https://github.com/SpinalHDL/SpinalTemplateSbt)
- [VexRiscV CPU](https://github.com/SpinalHDL/VexRiscv)
- [VexRiscV SoC software](https://github.com/SpinalHDL/VexRiscvSocSoftware)
- [CocoTB](https://github.com/potentialventures/cocotb)
- [GTK wave](http://gtkwave.sourceforge.net/)
- [Vertilator](https://www.veripool.org/wiki/verilator)
- [RiscV gcc cross-compiler](https://github.com/riscv/riscv-gnu-toolchain)
- [Yosys](http://www.clifford.at/yosys/)
- [IceStorm Tools](http://www.clifford.at/icestorm/)
    - IcePack/IceUnPack/Icetime/IceProg
      /IceMulti/IcePLL/IceBRAM
- [Arachne-PNR](https://github.com/cseed/arachne-pnr)
- [IceProgduino](https://github.com/OLIMEX/iCE40HX1K-EVB/tree/master/programmer/iceprogduino)
- general tools: GIT/python/emacs/...
- X11/ xfce4 desktop environment
- Remote Desktop (rdp) Server listening on port 3389
- [Intellij IDE](https://www.jetbrains.com/idea/) with [Scala plugin](https://plugins.jetbrains.com/plugin/1347-scala)

## Getting Started

The best way to get started is to download the image for this
container directly from Doc Hub and then run the container and play
inside it. Here are the steps for that.

   1. Install docker on your client.
   2. docker pull plex1/spinaldev
   3. docker run -it --rm -e DISPLAY=$DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix -p 3390:3390 plex1/ spinaldev:latest
   4. You are now logged into the environment as the user spinaldev.

For example you can run:
```sh
cd projects/spinal/SpinalTemplateSbt

//Generate the Verilog of your design
sbt "run-main mylib.MyTopLevelVerilog"

//Inspect generated files
ls
less MyTopLevel.v

//Run the scala testbench
sbt "run-main mylib.MyTopLevelSim"

//Inspect the waveform of the simulation
gtkwave simWorkspace/MyTopLevel/test.vcd &

```

Have fun!

