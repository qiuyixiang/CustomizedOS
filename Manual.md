---
OS 
---

## 	OS   Development  Introduction



OS Dev Based on 30 Days OS !

qOS  1.0.0    手册指南   (建议使用 typero 打开.md 文件)



开始时间：  2023-04-17

结束时间：Unknow

完成度： 未完成



#### 说明：

- ​	基于《30 天自制操作系统 》, 《x86 汇编语言》,  《操作系统真相还原》进行开发 
- ​	替换本书中的编译套件 改用 gcc 交叉编译工具  
- ​	使用dd， diskpart  工具进行虚拟磁盘创建
- ​    使用 bochs 进行内核中断调试



> ​				Cross Compiler   x86_elf-i386



## 环境搭建

​		gcc  :     交叉编译工具

​			![image-20230417170833819](C:\Users\11508\AppData\Roaming\Typora\typora-user-images\image-20230417170833819.png)





Bochs  配置文件

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

  

Diskpart ：

```cmd
create vdisk file=D:\Project\OS\Customed\30DaysOS\VDisk\vdisk.vhd maximum=10 type=fixed
```



##  实模式



*实模式内存布局*

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
| `7E00`  | `9FBFF` | `≈608KB`   |                           可区域用                           |
| `7C00`  | `7DFF`  | `512B`     |                    `MBR`被`BIOS`加载区域                     |
| `500`   | `7BFF`  | `≈30KB`    |                           可区域用                           |
| `400`   | `4FF`   | `256B`     |                       `BIOS Data Area`                       |
| `000`   | `3FF`   | `1KB`      |             `Interrupt Vector Table` 中断向量表              |

