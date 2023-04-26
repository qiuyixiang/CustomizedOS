# Makefile Project Management

# Copyright (c) @qiuyixiang

# Brief Description
# Language Architecture : x86, 8086 (IA_32)
# Main Programming language : C and Assembly


# CustomizedOS version 0.1.1
# For Protected-Mode 
# Created on 2023-04-26


####################### Main Path #######################

FLOPPY_DISK_PATH 		=			./VDisk/floppy.img
HARD_DISK_PATH			=			./VDisk/vdisk.vhd
# Wirte Destination
DISK_PATH				=			$(HARD_DISK_PATH)

CONFIG_PATH			    =			./config/
BIN_PATH			    =			./bin/
BOOT_PATH			    =			./boot/
KERNEL_PATH				=	        ./kernel/
LIB_PATH	            =           $(BIN_PATH)lib


####################### Tool Chains #######################
nasm				 =			nasm.exe
make				 =			make.exe
dd					 =			dd.exe
gcc					 =			x86_64-elf-gcc.exe
objcopy				 =			x86_64-elf-objcopy.exe
objdump			     =			x86_64-elf-objdump.exe
g++					 =			x86_64-elf-g++.exe
ld 				 	 =			x86_64-elf-ld.exe
bochs				 =			D:\Application\Bochs\Bochs-2.7\bochsdbg.exe


####################### Create File #######################

# bootloader 
bootloader.bin : $(BOOT_PATH)bootloader.asm Makefile
		$(nasm) $(BOOT_PATH)bootloader.asm -o $(BIN_PATH)bootloader.bin

# setup
setup.bin : $(BOOT_PATH)setup.asm Makefile
		$(nasm) $(BOOT_PATH)setup.asm -o $(BIN_PATH)setup.bin

create : 
		$(make) bootloader.bin
		$(make) setup.bin


####################### Write To Disk #######################	
write :
# bootloader 
		$(dd) if=$(BIN_PATH)bootloader.bin of=$(DISK_PATH) bs=512 count=1 seek=0
# setup
		$(dd) if=$(BIN_PATH)setup.bin of=$(DISK_PATH) bs=512 count=2 seek=1


####################### Final Instruction #######################	

run : 
# Create File
		$(make) create
# Write to disk
		$(make) write
# Run Application
		$(bochs) -q -f $(CONFIG_PATH)bochsrc 