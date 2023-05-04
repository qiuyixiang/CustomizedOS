#  Make File Project Configuration
#  Manage Create Dependce Files

# Create on 2023-5-4
# For Customized OS 0.1.2
# Last Version Of Formal Version


############### File Path ################

HARD_DISK				=			./vdisk/Harddisk.vhd
FLOPPY_DISK             =           ./vdisk/Floppy.img

# Choice of Disk  Path
DISK_PATH               =           $(HARD_DISK)
BIN_PATH                =           ./bin/
LIB_PATH                =           $(BIN_PATH)lib 
BOOT_PATH               =           ./boot/
CONFIG_PATH             =           ./config/
KERNEL_PATH             =           ./kernel/

############### Tool Path ################

nasm				 =			nasm.exe
make				 =			make.exe
dd					 =			dd.exe
gcc					 =			x86_64-elf-gcc.exe
objcopy				 =			x86_64-elf-objcopy.exe
objdump			     =			x86_64-elf-objdump.exe
g++					 =			x86_64-elf-g++.exe
ld 				 	 =			x86_64-elf-ld.exe
bochs				 =			D:\Application\Bochs\Bochs-2.7\bochsdbg.exe

############### Create File ################

# bootloader
bootloader.bin :  $(BOOT_PATH)bootloader.asm Makefile
		$(nasm) $(BOOT_PATH)bootloader.asm -o $(BIN_PATH)bootloader.bin

# setup
setup.bin : $(BOOT_PATH)setup.asm Makefile
		$(nasm) $(BOOT_PATH)setup.asm -o $(BIN_PATH)setup.bin

# kernel

DEPENDENCE_FILE  =    $(KERNEL_PATH)kernel_main.c

# Create All Files
create : 
		$(make) bootloader.bin
		$(make) setup.bin


############### Write File ################

write :
# bootloader 	(第1个扇区)
		$(dd) if=$(BIN_PATH)bootloader.bin of=$(DISK_PATH) bs=512 count=1 seek=0
# setup			(第2-5个扇区)
		$(dd) if=$(BIN_PATH)setup.bin of=$(DISK_PATH) bs=512 count=4 seek=1


############### Run Application ################

run :
# create
		$(make) create
# write 
		$(make) write
# setup debugger
		$(bochs) -q -f  $(CONFIG_PATH)bochsrc