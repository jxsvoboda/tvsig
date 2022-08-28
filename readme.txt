TV test signal generator (VHDL)
-------------------------------
Jiri Svoboda, 2008

Generate TV synchronization signals and test images. Standard European CCIR with
625 lines, 25 fps, interlaced.

Source code: VHDL
Target device: Xilinx 95xx CPLD family. (9572-PC84)

Input:
	RESET - reset the device
	CLK - 8MHz clock

Output:
	sync - 1=generate sync level, 0=no sync pulse
	image - 1=white,0=black (or blank)

Output is meant to be sent to a composite video output through a simple D/A converter.

The 8 MHz clocking gives enough precision to generate sync pulses
within tolerance of the TV specs. Also it gives a moderate horizontal
resolution of 512 pixels / scanline, i.e. 416 image pixels.

Notation:
	Unlike CCIR, the line numbers are base-0, i.e. 0..624
