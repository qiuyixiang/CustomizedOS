

## 	OS   Development  Introduction



**qOS  1.0.0** 



OS Dev Based on 30 Days OS !

qOS  1.0.0    手册指南   (建议使用 typero 打开.md 文件)



开始时间：  2023-04-17

结束时间：Unknow

完成度： 未完成



​	Manual  目录

[TOC]

------

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
- setup            0 磁道 0 面 2 扇区    大小：4扇区   装载到  0X80000 物理地址



**setup 负责读取 kernel 内核至内存区， 并进入保护模式设置GDT， LDT， IDT**





#### BIOS 中断例程 

​													**----中断向量表**



![image-20230421180314625](C:\Users\11508\AppData\Roaming\Typora\typora-user-images\image-20230421180314625.png)



​		

**清屏 **

**中断 int 10h，AH = 06H / 07H**

| 寄存器 | 说明                             | 值                            |
| ------ | -------------------------------- | ----------------------------- |
| AH     | 功能编码                         | 向上滚屏：06H，向下滚屏 : 07H |
| BH     | 空白区域的缺省属性               |                               |
| AL     | 滚动行数                         | 0：清窗口                     |
| CH、CL | 滚动区域左上角位置：Y坐标，X坐标 | 行， 列  (0X00, 0X00)         |
| DH、DL | 滚动区域右下角位置：Y坐标，X坐标 | 行， 列  (0X18, 0X4F)         |



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
        # AL  读取扇区数
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

## 保护模式



​	**脱离实模式（8086）后将无法使用BIOS提供的中断**

​	

#### 保护模式结构概述

------

##### **全局描述符表GDT**

**全局描述符**   大小为 8Byte  结构 

​			![image-20230426145625741](C:\Users\11508\AppData\Roaming\Typora\typora-user-images\image-20230426145625741.png)

- 段基址（32位），占据描述符的第16～39位和第55位～63位，前者存储低16位，后者存储高16位
- 段界限（20位），占据描述符的第0～15位和第48～51位，前者存储低16位，后者存储高4位。
- 段属性（12位），占据描述符的第39～47位和第49～55位，段属性可以细分为8种：TYPE属性、S属性、DPL属性、P属性、AVL属性、L属性、D/B属性和G属性。

<img src="C:\Users\11508\AppData\Roaming\Typora\typora-user-images\image-20230427141139167.png"  />

**S属性**
S属性存储了描述符的类型

- S=0 时，该描述符对应的段是系统段（System Segment）。
- S=1 时，该描述符对应的段是数据段（Data Segment）或者代码段（Code Segment）





**TYPE属性**



TYPE属性存储段的类型信息，该属性的意义随着S属性不同而不同。
当 S=1 （该段为数据段或代码段）时，需要分为两种情况：



当TYPE属性第三位为0时，代表该段为数据段，第0～2位的作用为：

(Type类型=2，向上扩展，非一致性，可读写，未访问 0010)

| 位   | 作用         | 值为0时        | 值为1时              |
| ---- | ------------ | -------------- | -------------------- |
| 2    | 段的增长方向 | 向上增长       | 向下增长（例如栈段） |
| 1    | 段的写权限   | 只读           | 可读可写             |
| 0    | 段的访问标记 | 该段未被访问过 | 该段已被访问过       |



当TYPE属性第三位为1时，代表该段为代码段，第0～2位的作用为：

| 位   | 作用           | 值为0时        | 值为1时        |
| ---- | -------------- | -------------- | -------------- |
| 2    | 一致代码段标记 | 不是一致代码段 | 是一致代码段   |
| 1    | 段的读权限     | 只能执行       | 可读、可执行   |
| 0    | 段的访问标记   | 该段未被访问过 | 该段已被访问过 |



当 S = 0（该段为系统段）时：

| TYPE的值（16进制） | TYPE的值（二进制） | 解释                          |
| :----------------: | ------------------ | ----------------------------- |
|        0x1         | 0 0 0 1            | 可用286TSS                    |
|        0x2         | 0 0 1 0            | 该段存储了局部描述符表（LDT） |
|        0x3         | 0 0 1 1            | 忙的286TSS                    |
|        0x4         | 0 1 0 0            | 286调用门                     |
|        0x5         | 0 1 0 1            | 任务门                        |
|        0x6         | 0 1 1 0            | 286中断门                     |
|        0x7         | 0 1 1 1            | 286陷阱门                     |
|        0x9         | 1 0 0 1            | 可用386TSS                    |
|        0xB         | 1 0 1 1            | 忙的386TSS                    |
|        0xC         | 1 1 0 0            | 386调用门                     |
|        0xE         | 1 1 1 0            | 386中断门                     |
|        0xF         | 1 1 1 1            | 386陷阱门                     |



**DPL属性**

DPL属性占2个比特，记录了访问段所需要的特权级，特权级范围为0～3，越小特权级越高。



**P属性**
P属性标记了该段是否存在：

P = 0 时，该段在内存中不存在
P = 1 时，该段在内存中存在



**AVL属性**

AVL属性占1个比特，该属性的意义可由操作系统、应用程序自行定义。
Intel保证该位不会被占用作为其他用途。



**L属性**
该属性仅在IA-32e模式下有意义，它标记了该段是否为64位代码段。
当L = 1  时，表示该段是64位代码段。
如果设置了L属性为1，则必须保证D属性为0。



**D/B属性**
D/B属性中的D/B全称 Default operation size / Default stack pointer size / Upper bound。

D/B 为0表示为16位段， D/B位1表示为32位的段

该属性的意义随着段描述符是代码段（Code Segment）、向下扩展数据段（Expand-down Data Segment）还是栈段（Stack Segment）而有所不同。



- 代码段（S属性为1，TYPE属性第三位为1）
  如果对应的是代码段，那么该位称之为D属性（D flag）。如果设置了该属性，那么会被视为32位代码段执行；如果没有设置，那么会被视为16位代码段执行。
- 栈段（被SS寄存器指向的数据段）
  该情况下称之为B属性。如果设置了该属性，那么在执行堆栈访问指令（例如PUSH、POP指令）时采用32位堆栈指针寄存器（ESP寄存器），如果没有设置，那么采用16位堆栈指针寄存器（SP寄存器）。
- 向下扩展的数据段
  该情况下称之为B属性。如果设置了该属性，段的上界为4GB，否则为64KB。



**G属性**
G属性记录了段界限的粒度：

- G = 0 时，段界限的粒度为字节

- G = 1 时，段界限的粒度为4KB

例如，当G = 0 并且描述符中的段界限值为10000 ，那么该段的界限为10000字节，如果G = 1 ，那么该段的界限值为40000KB。

所以说，当G = 0 时，一个段的最大界限值为1MB（因为段界限只能用20位表示，2 20 = 1048576 2^20=1048576220=1048576），最小为1字节（段的大小等于段界限值加1）。
当G = 1  时，最大界限值为4GB，最小为4KB。

在访问段（除栈段）时，如果超出了段的界限，那么会触发常规保护错误（#GP）
如果访问栈段超出了界限，那么会产生堆栈错误（#SS）

##### **段选择子**

按照描述符可访问地址来判断 可访问段描述符数量为 2^13 = 8192 个段描述符

![](C:\Users\11508\AppData\Roaming\Typora\typora-user-images\image-20230427133912243.png)

1. 第0、1位存储了当前的特权级（CPL）

2. 第2位存储了TI值（0代表GDT，1代表LDT）

3. 后13位相当于GDT表中某个描述符的索引，即**段选择子**

   

##### **GDTR寄存器**

CPU切换到保护模式前，需要准备好GDT数据结构，并执行`LGDT`指令，将GDT基地址和界限传入到GDTR寄存器。

GDTR寄存器长度为6字节（48位）所以说，GDT最多只能拥有8192个描述符（`65536 / 8`）。

![](C:\Users\11508\AppData\Roaming\Typora\typora-user-images\image-20230427135915229.png)

1. 前16位为GDT界限

2. 后32位为GDT表的基地址。

   

   

   段描述符拆解
   
   ```sh
   # 00CF9B00 : 0000FFFF
   
   # 0000 0000 1100 1111 1001 1011 0000 0000
   # 0000 0000 0000 0000 1111 1111 1111 1111
   
   # limit :  
   ```
   
   

#### 	进入保护模式

早期版本构造GDT表

​		进入保护模式三大步

```assembly
; GDT (Global Descriptor Table)
GDT_:
; Index = 0 DUMMY
        DW 0X0000 
        DW 0X0000 
        DW 0X0000
        DW 0X0000

; Code Segment
        DW LIMIT_MAXIMUM
        DW BASE_SEGMENT_ADDRESS

        DB 0X00
        DB 1_00_1_1010B
        
        DB 1_1_0_0_1111B
        DB 0X00

; Data Segment
        DW LIMIT_MAXIMUM    
        DW BASE_SEGMENT_ADDRESS

        DB 0X00
        DB 1_00_1_0010B

        DB 1_1_0_0_1111B
        DB 0X00

; Fill The Rest Descriptor
TIMES (GDTR_LIMIT_COUNTS - 3) DQ 0X0000
```



1.   将GDT表加载入gdtr寄存器

   ```assembly
   LGDT [_gdtr_48]
   ```



2. 打开A20地址总线

   ```assembly
           MOV DX, 0X92
           IN AL, DX
   
           OR AL, 00000010B
           OUT DX, AL
   ```

 3. 将Cr0寄存器第一位置为1

    ```assembly
            MOV EAX, CR0
            OR EAX, 0X01
            MOV CR0, EAX
    ```

    

## 底层硬件IO操作 

脱离实模式（8086）后将无法使用BIOS提供的中断

即直接通过 in ，out指令访问底层硬件驱动

​		

#### LAB 28  方式读取磁盘



