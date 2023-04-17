# MakeFile Project Script
# Manage file Complie And Assemble !
# Create on 2023-04-17
# Has Linked To Git Remote Storage !!!
# Author : @qiuyixiang -user


##### Main Path

DISK_PATH			=			./VDisk/vdisk.vhd
CONFIG_PATH			=			./config/
BIN_PATH			=			./bin/
OBJ_PATH			=			$(BIN_PATH)obj/
BOOT_PATH			=			./boot/



##### Tool Chain

nasm				=			nasm.exe
make				=			make.exe
dd					=			dd.exe
gcc					=			x86_64-elf-gcc.exe
objcopy				=			x86_64-elf-objcopy.exe
objdump				=			x86_64-elf-objdump.exe
g++					=			x86_64-elf-g++.exe
bochs				=			D:\Application\Bochs\Bochs-2.7\bochsdbg.exe


##### Create File

# bootloader
bootloader.bin :  $(BOOT_PATH)bootloader.asm MakeFile
		$(nasm) $(BOOT_PATH)bootloader.asm -o $(BIN_PATH)bootloader.bin


create :
		$(make) bootloader.bin


##### Write To Disk
write :
# bootloader
		$(dd) if=$(BIN_PATH)bootloader.bin of=$(DISK_PATH) bs=512 count=1 



##### Run Application
run :
# Create 
	$(make) create

# Write 
	$(make) write

# install
	$(bochs) -q -f  $(CONFIG_PATH)bochsrc.bxrc