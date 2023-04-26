---
OS 
---

## 	OS   Development  Introduction



**qOS  1.0.0** 



OS Dev Based on 30 Days OS !

qOS  1.0.0    手册指南   (建议使用 typero 打开.md 文件)



开始时间：  2023-04-17

结束时间：Unknow

完成度： 未完成



**说明：**

- ​	基于《30 天自制操作系统 》, 《x86 汇编语言》,  《操作系统真相还原》进行开发 
- ​	替换本书中的编译套件 改用 gcc 交叉编译工具  
- ​	使用dd， diskpart  工具进行虚拟磁盘创建
- ​    使用 bochs 进行内核中断调试



> ​				Cross Compiler   x86_elf-i386



## 环境搭建

​		**gcc  :     交叉编译工具**

​			![image-20230417170833819](C:\Users\11508\AppData\Roaming\Typora\typora-user-images\image-20230417170833819.png)





**Bochs  配置文件**

- [ ]  	运行 bochs虚拟机 ：

  ```cmd
  D:\Application\Bochs\Bochs-2.7\bochsdbg.exe -q -f ./bochsrs 
  ```

- [ ] ​     bochs 配置文件 :

  ```ASN.1
  # Debugger Mode
  magic_break: enabled=1
  
  # Display Mod
  config_interface: win32config
  display_library: win32, options="gui_debug"
  ```

  

**Diskpart ：**

```cmd
create vdisk file=D:\Project\OS\Customed\30DaysOS\VDisk\vdisk.vhd maximum=10 type=fixed
```



 **nasm伪指令解析** ：

```assembly
Message ：db "Hello OS World !", 0x00
Line_OF_MESSAGE : db $ - Message

# 如直接访问 Message ， 返回的为 ‘H’ 在程序段中的偏移地址 ！
# 若想访问存在地址中的值则需要 [Line_OF_MESSAGE]
```



Makefile 模板  Version 3.0

```makefile
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

```



##  实模式



***实模式内存布局***

| 起始    | 结束    | 大小       |                             用途                             |
| ------- | ------- | ---------- | :----------------------------------------------------------: |
| `FFFF0` | `FFFFF` | `16 B`     | `BIOS` 入口地址，此地址也属于`BIOS`代码，这`16`字节的内容是为了执行跳转指令 |
| `F0000` | `FFFEF` | `64KB-16B` | 系统`BIOS`的地址范围实际上是`F000-FFFFF`，上面是入口地址，所以单独列出 |
| `C8000` | `EFFFF` | `160KB`    |            映射硬件适配器的`ROM`或内存映射式`I/O`            |
| `C0000` | `C7FFF` | `32KB`     |                       显示适配器`BIOS`                       |
| `B8000` | `BFFFF` | `32KB`     |                      文本模式显示适配器                      |
| `B0000` | `B7FFF` | `32KB`     |                        黑白显示适配器                        |
| `A0000` | `AFFFF` | `64KB`     |                        彩色显示适配器                        |
| `9FC00` | `9F000` | `1KB`      |       `EBDA(Extended BIOS Data Area)` 扩展`BIOS`数据区       |
| `07E00` | `9FBFF` | `≈608KB`   |                 可区域用（程序默认堆栈空间）                 |
| `07C00` | `07DFF` | `512B`     |                    `MBR`被`BIOS`加载区域                     |
| `00500` | `07BFF` | `≈30KB`    |                           可区域用                           |
| `00400` | `004FF` | `256B`     |                       `BIOS Data Area`                       |
| `00000` | `003FF` | `1KB`      |             `Interrupt Vector Table` 中断向量表              |



实模式地址BIOS初始化 可以地址为 1M



#### 实模式内存分配



- bootloader  0 磁道 0 面 1 扇区	大小：1扇区	装载到 0X07C00 物理地址
- setup            0 磁道 0 面 2 扇区    大小：2扇区   装载到  0X00500 物理地址



**setup 负责读取 kernel 内核至内存区， 并进入保护模式设置GDT， LDT， IDT**





#### BIOS 中断例程 

​													**----中断向量表**



![image-20230421180314625](C:\Users\11508\AppData\Roaming\Typora\typora-user-images\image-20230421180314625.png)



![image-20230421180403931](C:\Users\11508\AppData\Roaming\Typora\typora-user-images\image-20230421180403931.png)



​		

**清屏 **

**中断 int 10h，AH = 06H / 07H**

| 寄存器 | 说明                             | 值                            |
| ------ | -------------------------------- | ----------------------------- |
| AH     | 功能编码                         | 向上滚屏：06H，向下滚屏 : 07H |
| BH     | 空白区域的缺省属性               |                               |
| AL     | 滚动行数                         | 0：清窗口                     |
| CH、CL | 滚动区域左上角位置：Y坐标，X坐标 | 行， 列                       |
| DH、DL | 滚动区域右下角位置：Y坐标，X坐标 | 行， 列                       |



**设置光标**

**中断 int 10h， AH=2**

| 寄存器 |  说明  | 值   |
| ------ | :----: | ---- |
| BH     | 第几页 |      |
| DH     |  行号  |      |
| DL     |  列号  |      |



**读磁盘**

**中断 int 13h**

```assembly
        # ES：BX 指向读入内存地址
        # AH  选择子程序  0x02 读磁盘  0x03 写磁盘
        # CH  读取柱面号
        # DH  读取磁头号
        # CL  读取扇区号
        # DL  驱动器号（硬盘从0x80开始,软盘从0x00开始）
        
        MOV AX, SETUP_BASE_ADDRESS
        SHR AX, 0X04
        MOV ES, AX
        MOV BX, 0X0000 

        MOV AH, 0X02            ; 0X02 Read Disk, 0X03 Write Disk
        MOV AL, 0X02                ; 读取扇区数
                    
        MOV CH, 0X00                ; 读取柱面号
        MOV DH, 0X00                ; 读取磁头号
        MOV CL, 0X02                ; 读取扇区号
        MOV DL, 0X80                ; 驱动器号（硬盘从0x80开始,软盘从0x00开始）
        
```



#### 实模式程序



​	**Bootloader早期版本**

```assembly
;BootLoader MBR File 
;载入 0 面 0 磁道 1 扇区到 0x7c00 位置
;Loader Address 0x7c00

;MBR For The Next File


;Initialization The Segment Register ! 

[ORG 0X7C00]
[SECTION .text]
[BITS 16]

MOV AX, CS
MOV DS, AX
MOV ES, AX
MOV SS, AX
MOV GS, AX
MOV FS, AX

XCHG BX, BX
;Call Test Func
CALL print

;Endless Loop
JMP $

;Test func
print :
        MOV AX, 0XB800
        MOV ES, AX
        MOV AX, 0X0000
        MOV DS, AX

        MOV DI, 0X0000
        MOV SI, Message
        
        _try:
                MOV AL, [DS : SI]
                CMP AL, 0X00
                JE _end
                MOV [ES : DI], AL
                INC DI
                MOV BYTE [ES : DI], 00000111B
                INC DI
                INC SI
                JMP _try
        _end:
                RET 


Message: DB "Hello OS WORLD !", 0x00

;Fill The Rest Of Memory ! 
TIMES 510 - ($ - $$) DB 0X00
DW 0XAA55
```



#### 	**qOS1.0.0 底层函数调用约定**



- 标准阅读 ： cdecl 调用约定

- 入栈方式 ：从右往左

  ```c
  # c function declare !
  # 从右往左进行传参
  # _r 先入栈  _l 后入栈
  
  int _call(int _l int _r);
  
  ```

​				

- 平栈方式 ： 外平栈  （恢复栈帧）

  

  **！确保函数调用前后堆栈指针 esp， ebp 值与之前相同**

  ```c++
  int _call (int _l int _r);
  # 	_call(10, 20)
  ```

  ```assembly
  PUSH 20
  PUSH 10
  # PUSH address
  
  CALL _add
  ADD ESP, 8
  
  _add:
  		; Allocate Stack Memory
  		PUSH EBP
  		MOV EBP, ESP
  		
  		...
  		
  		MOV ESP, EBP
  		POP EBP
  		RET					
  ```


## 

## 保护模式



​	**脱离实模式（8086）后将无法使用BIOS提供的中断**

​	

#### 全局描述符表GDT

​		 全局描述符   大小为 8Byte

​		

​			![image-20230426145625741](C:\Users\11508\AppData\Roaming\Typora\typora-user-images\image-20230426145625741.png)



##### 	进入保护模式





## 底层硬件IO操作 

脱离实模式（8086）后将无法使用BIOS提供的中断

即直接通过 in ，out指令访问底层硬件驱动

​		

#### LAB 28  方式读取磁盘



