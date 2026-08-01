###############################################################################
# 时钟定义
###############################################################################
# 主时钟100MHz (10ns周期)，从外部晶振输入
create_clock -period 10.000 -name clk -waveform {0.000 5.000} [get_ports clk]
set cpu_clk [get_clocks clk]

# 若时钟引脚非专用时钟输入，可取消注释以下行
# set_property CLOCK_DEDICATED_ROUTE BACKBONE [get_nets clk]

###############################################################################
# 引脚分配 (PACKAGE_PIN)
###############################################################################
# ----------------------- 系统时钟与复位 -----------------------
set_property PACKAGE_PIN K21 [get_ports clk]   
set_property PACKAGE_PIN T2  [get_ports rstn]  # btn0 (低有效复位)

# ----------------------- BASE SRAM 地址线 -----------------------
set_property PACKAGE_PIN T19 [get_ports {BASERAM_a[0]}]
set_property PACKAGE_PIN V18 [get_ports {BASERAM_a[1]}]
set_property PACKAGE_PIN T18 [get_ports {BASERAM_a[2]}]
set_property PACKAGE_PIN V17 [get_ports {BASERAM_a[3]}]
set_property PACKAGE_PIN U17 [get_ports {BASERAM_a[4]}]
set_property PACKAGE_PIN R20 [get_ports {BASERAM_a[5]}]
set_property PACKAGE_PIN R23 [get_ports {BASERAM_a[6]}]
set_property PACKAGE_PIN T23 [get_ports {BASERAM_a[7]}]
set_property PACKAGE_PIN U22 [get_ports {BASERAM_a[8]}]
set_property PACKAGE_PIN Y22 [get_ports {BASERAM_a[9]}]
set_property PACKAGE_PIN AB24 [get_ports {BASERAM_a[10]}]
set_property PACKAGE_PIN AA23 [get_ports {BASERAM_a[11]}]
set_property PACKAGE_PIN Y21 [get_ports {BASERAM_a[12]}]
set_property PACKAGE_PIN Y20 [get_ports {BASERAM_a[13]}]
set_property PACKAGE_PIN AA22 [get_ports {BASERAM_a[14]}]
set_property PACKAGE_PIN W19 [get_ports {BASERAM_a[15]}]
set_property PACKAGE_PIN W21 [get_ports {BASERAM_a[16]}]
set_property PACKAGE_PIN W20 [get_ports {BASERAM_a[17]}]
set_property PACKAGE_PIN W18 [get_ports {BASERAM_a[18]}]
set_property PACKAGE_PIN V19 [get_ports {BASERAM_a[19]}]

# ----------------------- BASE SRAM 数据线 (双向) -----------------------
set_property PACKAGE_PIN L24 [get_ports {BASERAM_dq[0]}]
set_property PACKAGE_PIN L25 [get_ports {BASERAM_dq[1]}]
set_property PACKAGE_PIN M26 [get_ports {BASERAM_dq[2]}]
set_property PACKAGE_PIN M25 [get_ports {BASERAM_dq[3]}]
set_property PACKAGE_PIN N26 [get_ports {BASERAM_dq[4]}]
set_property PACKAGE_PIN P24 [get_ports {BASERAM_dq[5]}]
set_property PACKAGE_PIN P26 [get_ports {BASERAM_dq[6]}]
set_property PACKAGE_PIN P25 [get_ports {BASERAM_dq[7]}]
set_property PACKAGE_PIN AA24 [get_ports {BASERAM_dq[8]}]
set_property PACKAGE_PIN Y23 [get_ports {BASERAM_dq[9]}]
set_property PACKAGE_PIN V21 [get_ports {BASERAM_dq[10]}]
set_property PACKAGE_PIN W24 [get_ports {BASERAM_dq[11]}]
set_property PACKAGE_PIN W23 [get_ports {BASERAM_dq[12]}]
set_property PACKAGE_PIN V22 [get_ports {BASERAM_dq[13]}]
set_property PACKAGE_PIN V23 [get_ports {BASERAM_dq[14]}]
set_property PACKAGE_PIN U21 [get_ports {BASERAM_dq[15]}]
set_property PACKAGE_PIN P21 [get_ports {BASERAM_dq[16]}]
set_property PACKAGE_PIN M21 [get_ports {BASERAM_dq[17]}]
set_property PACKAGE_PIN P23 [get_ports {BASERAM_dq[18]}]
set_property PACKAGE_PIN P19 [get_ports {BASERAM_dq[19]}]
set_property PACKAGE_PIN N19 [get_ports {BASERAM_dq[20]}]
set_property PACKAGE_PIN M20 [get_ports {BASERAM_dq[21]}]
set_property PACKAGE_PIN N24 [get_ports {BASERAM_dq[22]}]
set_property PACKAGE_PIN N21 [get_ports {BASERAM_dq[23]}]
set_property PACKAGE_PIN T22 [get_ports {BASERAM_dq[24]}]
set_property PACKAGE_PIN R22 [get_ports {BASERAM_dq[25]}]
set_property PACKAGE_PIN R21 [get_ports {BASERAM_dq[26]}]
set_property PACKAGE_PIN P20 [get_ports {BASERAM_dq[27]}]
set_property PACKAGE_PIN N22 [get_ports {BASERAM_dq[28]}]
set_property PACKAGE_PIN N23 [get_ports {BASERAM_dq[29]}]
set_property PACKAGE_PIN M24 [get_ports {BASERAM_dq[30]}]
set_property PACKAGE_PIN M22 [get_ports {BASERAM_dq[31]}]

# ----------------------- BASE SRAM 控制信号 -----------------------
set_property PACKAGE_PIN T20 [get_ports BASERAM_oe_n]
set_property PACKAGE_PIN U20 [get_ports BASERAM_we_n]
set_property PACKAGE_PIN U19 [get_ports BASERAM_ce_n]
set_property PACKAGE_PIN L20 [get_ports {BASERAM_be_n[0]}]
set_property PACKAGE_PIN L22 [get_ports {BASERAM_be_n[1]}]
set_property PACKAGE_PIN L23 [get_ports {BASERAM_be_n[2]}]
set_property PACKAGE_PIN K25 [get_ports {BASERAM_be_n[3]}]

# ----------------------- EXT SRAM 地址线 -----------------------
set_property PACKAGE_PIN AF25 [get_ports {EXTRAM_a[0]}]
set_property PACKAGE_PIN AE25 [get_ports {EXTRAM_a[1]}]
set_property PACKAGE_PIN AE26 [get_ports {EXTRAM_a[2]}]
set_property PACKAGE_PIN AD25 [get_ports {EXTRAM_a[3]}]
set_property PACKAGE_PIN AD26 [get_ports {EXTRAM_a[4]}]
set_property PACKAGE_PIN AC22 [get_ports {EXTRAM_a[5]}]
set_property PACKAGE_PIN Y17  [get_ports {EXTRAM_a[6]}]
set_property PACKAGE_PIN AA18 [get_ports {EXTRAM_a[7]}]
set_property PACKAGE_PIN AA17 [get_ports {EXTRAM_a[8]}]
set_property PACKAGE_PIN Y25  [get_ports {EXTRAM_a[9]}]
set_property PACKAGE_PIN AA25 [get_ports {EXTRAM_a[10]}]
set_property PACKAGE_PIN AB26 [get_ports {EXTRAM_a[11]}]
set_property PACKAGE_PIN AB25 [get_ports {EXTRAM_a[12]}]
set_property PACKAGE_PIN AC26 [get_ports {EXTRAM_a[13]}]
set_property PACKAGE_PIN AC24 [get_ports {EXTRAM_a[14]}]
set_property PACKAGE_PIN AF17 [get_ports {EXTRAM_a[15]}]
set_property PACKAGE_PIN AE17 [get_ports {EXTRAM_a[16]}]
set_property PACKAGE_PIN AF18 [get_ports {EXTRAM_a[17]}]
set_property PACKAGE_PIN AE18 [get_ports {EXTRAM_a[18]}]
set_property PACKAGE_PIN AF19 [get_ports {EXTRAM_a[19]}]

# ----------------------- EXT SRAM 数据线 (双向) -----------------------
set_property PACKAGE_PIN AF24 [get_ports {EXTRAM_dq[0]}]
set_property PACKAGE_PIN AE23 [get_ports {EXTRAM_dq[1]}]
set_property PACKAGE_PIN AF23 [get_ports {EXTRAM_dq[2]}]
set_property PACKAGE_PIN AE22 [get_ports {EXTRAM_dq[3]}]
set_property PACKAGE_PIN AF22 [get_ports {EXTRAM_dq[4]}]
set_property PACKAGE_PIN AE21 [get_ports {EXTRAM_dq[5]}]
set_property PACKAGE_PIN AE20 [get_ports {EXTRAM_dq[6]}]
set_property PACKAGE_PIN AF20 [get_ports {EXTRAM_dq[7]}]
set_property PACKAGE_PIN Y26  [get_ports {EXTRAM_dq[8]}]
set_property PACKAGE_PIN W25  [get_ports {EXTRAM_dq[9]}]
set_property PACKAGE_PIN W26  [get_ports {EXTRAM_dq[10]}]
set_property PACKAGE_PIN V24  [get_ports {EXTRAM_dq[11]}]
set_property PACKAGE_PIN V26  [get_ports {EXTRAM_dq[12]}]
set_property PACKAGE_PIN U25  [get_ports {EXTRAM_dq[13]}]
set_property PACKAGE_PIN U26  [get_ports {EXTRAM_dq[14]}]
set_property PACKAGE_PIN U24  [get_ports {EXTRAM_dq[15]}]
set_property PACKAGE_PIN AB16 [get_ports {EXTRAM_dq[16]}]
set_property PACKAGE_PIN AC19 [get_ports {EXTRAM_dq[17]}]
set_property PACKAGE_PIN AB17 [get_ports {EXTRAM_dq[18]}]
set_property PACKAGE_PIN AC18 [get_ports {EXTRAM_dq[19]}]
set_property PACKAGE_PIN AD18 [get_ports {EXTRAM_dq[20]}]
set_property PACKAGE_PIN AC16 [get_ports {EXTRAM_dq[21]}]
set_property PACKAGE_PIN Y15  [get_ports {EXTRAM_dq[22]}]
set_property PACKAGE_PIN AA15 [get_ports {EXTRAM_dq[23]}]
set_property PACKAGE_PIN AD17 [get_ports {EXTRAM_dq[24]}]
set_property PACKAGE_PIN AC17 [get_ports {EXTRAM_dq[25]}]
set_property PACKAGE_PIN AD20 [get_ports {EXTRAM_dq[26]}]
set_property PACKAGE_PIN AB21 [get_ports {EXTRAM_dq[27]}]
set_property PACKAGE_PIN AD21 [get_ports {EXTRAM_dq[28]}]
set_property PACKAGE_PIN AC21 [get_ports {EXTRAM_dq[29]}]
set_property PACKAGE_PIN AA19 [get_ports {EXTRAM_dq[30]}]
set_property PACKAGE_PIN AC23 [get_ports {EXTRAM_dq[31]}]

# ----------------------- EXT SRAM 控制信号 -----------------------
set_property PACKAGE_PIN AB19 [get_ports EXTRAM_oe_n]
set_property PACKAGE_PIN AD19 [get_ports EXTRAM_we_n]
set_property PACKAGE_PIN AD23 [get_ports EXTRAM_ce_n]
set_property PACKAGE_PIN R26  [get_ports {EXTRAM_be_n[0]}]
set_property PACKAGE_PIN R25  [get_ports {EXTRAM_be_n[1]}]
set_property PACKAGE_PIN AD24 [get_ports {EXTRAM_be_n[2]}]
set_property PACKAGE_PIN AB22 [get_ports {EXTRAM_be_n[3]}]

###############################################################################
# I/O 电平标准 (所有信号均为3.3V LVCMOS)
###############################################################################
set_property IOSTANDARD LVCMOS33 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports rstn]
set_property IOSTANDARD LVCMOS33 [get_ports -filter {DIRECTION == "OUT" || DIRECTION == "INOUT"}]

###############################################################################
# 输入/输出延迟约束 (基于10ns SRAM时序，数值需根据实际PCB调整)
###############################################################################
# SRAM读数据输入延迟：时钟到FPGA引脚的数据有效时间
# 典型值 tAA(max)=10ns + PCB走线 + FPGA Tco，此处设17ns作为示例
set ram_input_delay 17
# SRAM输出（地址/控制/写数据）输出延迟：FPGA时钟到引脚输出有效时间
set ram_output_delay 12

# 输入延迟：数据输入
set_input_delay -clock $cpu_clk $ram_input_delay [get_ports {BASERAM_dq[*]}]
set_input_delay -clock $cpu_clk $ram_input_delay [get_ports {EXTRAM_dq[*]}]
# 复位输入（异步，可忽略或设置最小延迟）
set_input_delay -clock $cpu_clk 0 [get_ports rstn] -add_delay

# 输出延迟：地址、控制、数据输出
set_output_delay -clock $cpu_clk $ram_output_delay [get_ports {BASERAM_a[*] BASERAM_oe_n BASERAM_we_n BASERAM_ce_n BASERAM_be_n[*]}]
set_output_delay -clock $cpu_clk $ram_output_delay [get_ports {EXTRAM_a[*] EXTRAM_oe_n EXTRAM_we_n EXTRAM_ce_n EXTRAM_be_n[*]}]
# 双向数据线作为输出时的延迟
set_output_delay -clock $cpu_clk $ram_output_delay [get_ports {BASERAM_dq[*]}]
set_output_delay -clock $cpu_clk $ram_output_delay [get_ports {EXTRAM_dq[*]}]

###############################################################################
# 建议：根据实际板级验证调整以下参数
# - ram_input_delay / ram_output_delay：取决于PCB走线、SRAM器件速度等级
# - 若时钟引脚非专用，请取消注释 CLOCK_DEDICATED_ROUTE 设置
# - 对于inout端口，输出延迟作用于写操作，输入延迟作用于读操作
###############################################################################