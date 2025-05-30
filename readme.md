# microprocessor-rc
## MSc Digital System Lab (also check https://github.com/thomson008/microprocessor-rc/tree/master)
> Verilog project of a simple microprocessor with peripherals such as mouse, VGA display and IR transmitter. Can be run on Xilinx Basys 3 FPGA board with an additional IR module in order to control a RC car. The system was developed for Digital Systems Laboratory course at The University of Edinburgh.

### New features: 
1. Text display
![wx_camera_1743187488432](https://github.com/user-attachments/assets/42e63151-47cb-4ae7-afdd-08404a5033cd)

2. spirit

![Untitled video - Made with Clipchamp](https://github.com/user-attachments/assets/f5b79fc3-719f-4234-ac68-73b6c7e09ed3)

3. asm complier:

https://github.com/sysytwl/DSL_fpga_task-msc-/blob/3ce93e529d50d9ea22bc4acbad2dfa55ad00a96a/program_file/compiler.py#L1


### ip:
1. block ram -> mcu ram
2. block rom -> mcu rom
3. block ram -> vga ram
4. block rom -> vga text tiles(ascii)
5. fifo -> vga data transfer

### cpu: instruction
```cpp
/*------------------------------------------------------------------------------
|    No.|    Name   |            Explain                |     Machine code     | 
|     0 | MOVa addr | Read from memory to A             | 0000 0000  xxxx xxxx |
|     1 | MOVb addr | Read from memory to B             | 0000 0001  xxxx xxxx |
|     2 | sbA addr  | Write to memory from A            | 0000 0010  xxxx xxxx |
|     3 | sbB addr  | Write to memory from B            | 0000 0011  xxxx xxxx |
|     4 | OpA       | ALU Op, and save result in reg A  | xxxx 0100            |
|     5 | OpB       | ALU Op, and save result in reg B  | xxxx 0101            |
| added | Op Addr   | ALU Op, and save result to memory | xxxx 1111  xxxx xxxx |
|     6 |beq bne blt| if A (== or < or > B) GoTo ADDR   | xxxx 0110  xxxx xxxx |
|     7 | JAL addr  | Goto ADDR                         | 0000 0111  xxxx xxxx |
|     8 | NOP       | Go to IDLE                        | 0000 1000            |
|     9 | Halt      | NOP and wait for interrupt        | 0000 1101            |
|    10 | Call addr | Function call                     | 0000 1001  xxxx xxxx |
|    11 | Ret       | Return from function call         | 0000 1010            |
|    12 | lbA       | Dereference A                     | 0000 1011            |
|    13 | lbB       | Dereference B                     | 0000 1100            |
------------------------------------------------------------------------------*/
```
![alt text](image-1.png)

### structure
![alt text](image.png) 
