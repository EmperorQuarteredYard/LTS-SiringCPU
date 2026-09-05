本项目(Siring-Long Term Servering,骑鳞芯片-LTS)主要在FPGA:xc7a200tfbg676-1上开发
## 参数描述
单发射五级流水线CPU

设计周期为25MHZ，主要性能瓶颈与ALU的乘法运算、高扇出设计有关，解决任意一个问题，频率可达50MHZ
当采用同步RAM时，IPC约为0.9;采用异步RAM时，IPC为0.45或更低，具体取决于设置的等待周期

支持24条指令：
lu12i.w, pcaddu12i, addi.w, add.w, sub.w, slt,
and, andi, or, ori, xor,
sll.w, slli.w, srli.w,
ld.b, ld.w, st.b, st.w,
b, bl, beq, bne, jirl,
mul.w
支持EXTRAM、BASERAM，暂不支持UART操作
## 如何开始
由于本项目当前没有用到任何IP核，可以导入/src下的所有设计文件，/constraints下的约束文件，/testbench下的任意仿真文件进行仿真，推荐使用main.sv及其内置的指令设定代码。注意，当仿真时，请取消注释src/define.vh的ENVIRONMENT_SIMULATE定义行