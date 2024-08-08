# Downloading Bitstreams

To test your synthesized and implemented designs you will need a way to download the bitstream to your FPGA board.
This page summarizes several different ways for downloading your bitstreams to your board.

## Vivado Hardware Manager

The Vivado tool suite contains a tool named the "Hardware Manager" for downloading your bitstream to your board.
If you have the Vivado tools installed on your computer you can use this tool to download your bitstream to your board.
If you don't have this tool installed on your computer you will need to physically access one of the digital lab computers and download while logged on to one of these machines.

You can run the Vivado hardware manager in one of two ways:
1. From the Vivado GUI by selecting the "Open Hardware Manager" option from the "Program and Debug" section of the left-hand tool menu or by selecting "Open Hardware Manager" from the "Flow" menu.
2. From the Vivado TCL command interpreter as described [here](./vivado_command_line.md#hardware-manager).

## Digilent Adept

If you are running windows, there is a light-weight tool named "Adept" that you can use to download your bitstream to your board.
You can access the Adept tool from the [Digilent website](https://digilent.com/shop/software/digilent-adept/) (Digilent manufactures the Nexys DDR board that you are using in this class).
Older instructions for accessing the tool can be found from the [ECEN 220](https://ecen220wiki.groups.et.byu.net/resources/tool_resources/ToolsUseOptions/#download-to-your-board-using-adept-2-windows-only
) lab web page.

## OpenOCD

There is an open source tool named [OpenOCD](https://openocd.org/) that can be used to download bitstreams to your board on Linux and Mac computers.
Instructions for downloading using OpenOCD can be found [here](https://github.com/byu-cpe/BYU-Computing-Tutorials/wiki/Program-7-Series-FPGA-from-a-Mac-or-Linux-Without-Xilinx).