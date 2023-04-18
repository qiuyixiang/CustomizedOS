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

  ​								

​	

## 保护模式



​	**脱离实模式（8086）后将无法使用BIOS提供的中断**

​	

##### 	进入保护模式





## 底层硬件IO操作 

脱离实模式（8086）后将无法使用BIOS提供的中断

即直接通过 in ，out指令访问底层硬件驱动

​		

#### LAB 28  方式读取磁盘



