# MakeFile Project Script
# Manage file Complie And Assemble !
# Create on 2023-04-17
# Has Linked To Git Remote Storage !!!
# Author : @qiuyixiang -user


##### Main Path

FLOPPY_DISK_PATH 		=			./VDisk/test.img
HARD_DISK_PATH			=			./VDisk/vdisk.vhd
DISK_PATH				=			$(HARD_DISK_PATH)

CONFIG_PATH			    =			./config/
BIN_PATH			    =			./bin/
LIB_PATH			    =			$(BIN_PATH)lib/
BOOT_PATH			    =			./boot/
KERNEL_PATH				=	        ./kernel/
					


##### Tool Chain

nasm				 =			nasm.exe
make				 =			make.exe
dd					 =			dd.exe
gcc					 =			x86_64-elf-gcc.exe
objcopy				 =			x86_64-elf-objcopy.exe
objdump			     =			x86_64-elf-objdump.exe
g++					 =			x86_64-elf-g++.exe
ld 				 	 =			x86_64-elf-ld.exe
bochs				 =			D:\Application\Bochs\Bochs-2.7\bochsdbg.exe

##### Create File

# bootloader
bootloader.bin :  $(BOOT_PATH)bootloader.asm MakeFile
		$(nasm) $(BOOT_PATH)bootloader.asm -o $(BIN_PATH)bootloader.bin
	
# setup 
setup.bin : $(BOOT_PATH)setup.asm MakeFile
		$(nasm) $(BOOT_PATH)setup.asm -o $(BIN_PATH)setup.bin

#kernel 
KERNEL_DEPENDENCE = $(KERNEL_PATH)kernel.c $(KERNEL_PATH)kernel.asm $(BIN_PATH)lib/kernelc.o $(BIN_PATH)lib/kernelsm.o \
					$(BIN_PATH)kernel.elf.o

kernelc.o : $(KERNEL_PATH)kernel.c  MakeFile
		$(gcc) -m16 -c $(KERNEL_PATH)kernel.c -o $(BIN_PATH)lib/kernelc.o

kernelsm.o : $(KERNEL_PATH)kernel.asm MakeFile
		$(nasm) -f elf32 $(KERNEL_PATH)kernel.asm -o $(BIN_PATH)lib/kernelsm.o

kernel.elf.o :$(BIN_PATH)lib/kernelc.o $(BIN_PATH)lib/kernelsm.o  MakeFile
		$(ld) -m elf_i386 -s $(BIN_PATH)lib/kernelsm.o $(BIN_PATH)lib/kernelc.o -o $(BIN_PATH)kernel.elf.o

kernel.bin : $(BIN_PATH)kernel.elf.o MakeFile
		$(objcopy) -O binary $(BIN_PATH)kernel.elf.o kernel.bin

kernel :  $(KERNEL_DEPENDENCE)
		$(make) kernelc.o 
		$(make) kernelsm.o  
		$(make) kernel.elf.o  
		$(make) kernel.bin  
create :
		$(make) bootloader.bin
		$(make) setup.bin
		$(make) kernel


##### Write To Disk
write :
# bootloader
		$(dd) if=$(BIN_PATH)bootloader.bin of=$(DISK_PATH) bs=512 count=1 
# setup
		$(dd) if=$(BIN_PATH)setup.bin of=$(DISK_PATH) bs=512 count=2 seek=1		
# kernel 
		$(dd) if=./kernel.bin of=$(DISK_PATH) bs=512 count=2 seek=3

#### Run Application
run :
# Create 
	$(make) create

# Write 
	$(make) write

# install
	$(bochs) -q -f  $(CONFIG_PATH)bochsrc.bxrc


