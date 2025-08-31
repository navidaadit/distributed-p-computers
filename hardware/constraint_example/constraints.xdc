# General configuration
set_property CFGBVS GND                                [current_design]
set_property CONFIG_VOLTAGE 1.8                        [current_design]
set_property BITSTREAM.GENERAL.COMPRESS true           [current_design]
set_property BITSTREAM.CONFIG.EXTMASTERCCLK_EN {DIV-1} [current_design]
set_property BITSTREAM.CONFIG.SPI_32BIT_ADDR YES       [current_design]
set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 8           [current_design]
set_property BITSTREAM.CONFIG.SPI_FALL_EDGE YES        [current_design]
set_property BITSTREAM.CONFIG.OVERTEMPSHUTDOWN Enable  [current_design]


# 125 MHz
set_property -dict {LOC AY24 IOSTANDARD LVDS} [get_ports clk_125mhz_p]
set_property -dict {LOC AY23 IOSTANDARD LVDS} [get_ports clk_125mhz_n]
create_clock -period 8.000 -name clk_125mhz [get_ports clk_125mhz_p]

## 250 MHz
#set_property -dict {PACKAGE_PIN E12 IOSTANDARD DIFF_SSTL12} [get_ports sys_clock_clk_p]
#set_property -dict {PACKAGE_PIN D12 IOSTANDARD DIFF_SSTL12} [get_ports sys_clock_clk_n]

# 300 MHz
set_property -dict {PACKAGE_PIN G31 IOSTANDARD DIFF_SSTL12} [get_ports sys_clock_clk_p]
set_property -dict {PACKAGE_PIN F31 IOSTANDARD DIFF_SSTL12} [get_ports sys_clock_clk_n]

# Reset button
set_property -dict {LOC L19  IOSTANDARD LVCMOS12} [get_ports reset]

set_false_path -from [get_ports {reset}]
set_input_delay 0 [get_ports {reset}]

# Create the divided clocks (dividing by 1 to have the most conservating timing (15MHz): this means divider = 0 from MATLAB which is default)
create_generated_clock -name clk1_buf -source [get_pins wrapper/clock1_0] -divide_by 1 [get_nets clock_div_inst/clk1_buf]
create_generated_clock -name clk2_buf -source [get_pins wrapper/clock2_0] -divide_by 1 [get_nets clock_div_inst/clk2_buf]
create_generated_clock -name clk3_buf -source [get_pins wrapper/clock3_0] -divide_by 1 [get_nets clock_div_inst/clk3_buf]
create_generated_clock -name clk4_buf -source [get_pins wrapper/clock4_0] -divide_by 1 [get_nets clock_div_inst/clk4_buf]
create_generated_clock -name clk5_buf -source [get_pins wrapper/clock5_0] -divide_by 1 [get_nets clock_div_inst/clk5_buf]

# Create the divided clocks (dividing by 1 to have the most conservating timing (100MHz): this means divider_comm = 0 from MATLAB which is default)
create_generated_clock -name bram_read_clk_buf -source [get_pins wrapper/bram_read_clk] -divide_by 1 [get_nets clock_div_inst_bram/clk1_buf]

# Define asynchronous clock groups
set_clock_groups -asynchronous -group {clock1_design_1_clk_wiz_0_0 clock2_design_1_clk_wiz_0_0 clock3_design_1_clk_wiz_0_0 clock4_design_1_clk_wiz_0_0 clock5_design_1_clk_wiz_0_0 clk1_buf clk2_buf clk3_buf clk4_buf clk5_buf}

# Define physically exclusive clock groups for the BUFGMUX inputs
set_clock_groups -physically_exclusive -group {clock1_design_1_clk_wiz_0_0 clock2_design_1_clk_wiz_0_0 clock3_design_1_clk_wiz_0_0 clock4_design_1_clk_wiz_0_0 clock5_design_1_clk_wiz_0_0} -group {clk1_buf clk2_buf clk3_buf clk4_buf clk5_buf}

# Define asynchronous clock group for BRAM read clock
set_clock_groups -asynchronous -group {bram_read_clk_design_1_clk_wiz_0_0 bram_read_clk_buf}

# Define physically exclusive clock groups for the BUFGMUX inputs
set_clock_groups -physically_exclusive -group {bram_read_clk_design_1_clk_wiz_0_0} -group {bram_read_clk_buf}



# Ethernet
# Gigabit Ethernet SGMII PHY
set_property -dict {LOC AU24 IOSTANDARD LVDS} [get_ports phy_sgmii_rx_p]
set_property -dict {LOC AV24 IOSTANDARD LVDS} [get_ports phy_sgmii_rx_n]
set_property -dict {LOC AU21 IOSTANDARD LVDS} [get_ports phy_sgmii_tx_p]
set_property -dict {LOC AV21 IOSTANDARD LVDS} [get_ports phy_sgmii_tx_n]
set_property -dict {LOC AT22 IOSTANDARD LVDS} [get_ports phy_sgmii_clk_p]
set_property -dict {LOC AU22 IOSTANDARD LVDS} [get_ports phy_sgmii_clk_n]
set_property -dict {LOC BA21 IOSTANDARD LVCMOS18 SLEW SLOW DRIVE 8} [get_ports phy_reset_n]
set_property -dict {LOC AR24 IOSTANDARD LVCMOS18} [get_ports phy_int_n]
set_property -dict {LOC AR23 IOSTANDARD LVCMOS18 SLEW SLOW DRIVE 8} [get_ports phy_mdio]
set_property -dict {LOC AV23 IOSTANDARD LVCMOS18 SLEW SLOW DRIVE 8} [get_ports phy_mdc]

# 625 MHz ref clock from SGMII PHY
#create_clock -period 1.600 -name phy_sgmii_clk [get_ports phy_sgmii_clk_p]

set_false_path -to [get_ports {phy_reset_n phy_mdio phy_mdc}]
set_output_delay 0 [get_ports {phy_reset_n phy_mdio phy_mdc}]
set_false_path -from [get_ports {phy_int_n phy_mdio}]
set_input_delay 0 [get_ports {phy_int_n phy_mdio}]

set_property DIFF_TERM_ADV TERM_100 [get_ports phy_sgmii_rx_p]
set_property DIFF_TERM_ADV TERM_100 [get_ports phy_sgmii_rx_n]
set_property DIFF_TERM_ADV TERM_100 [get_ports phy_sgmii_clk_p]
set_property DIFF_TERM_ADV TERM_100 [get_ports phy_sgmii_clk_n]


####################### FMC PLUS between FPGA 1 and 2 ###################################

create_clock -period 10.000 -name received_clk_2_1 -waveform {0.000 5.000} -add [get_ports received_clk_2_1]
create_generated_clock -name forwarded_clk_1_2 -source [get_pins oddr_inst_1_2/C] -divide_by 1 [get_ports forwarded_clk_1_2]
set fclk [get_clocks -of_objects [get_ports forwarded_clk_1_2]]  

set_clock_groups -asynchronous -group {received_clk_2_1}
set_clock_groups -asynchronous -group {forwarded_clk_1_2}

set_input_delay -clock received_clk_2_1 -max 4.000 [get_ports {m_axis_rx_tdata_2_1[*]}]
set_input_delay -clock received_clk_2_1 -min 1.000 [get_ports {m_axis_rx_tdata_2_1[*]}]
set_input_delay -clock received_clk_2_1 -max 4.000 [get_ports {m_axis_rx_tlast_2_1}]
set_input_delay -clock received_clk_2_1 -min 1.000 [get_ports {m_axis_rx_tlast_2_1}]

## Constraint file for Vivado generated by MATLAB script
## Set the IOSTANDARD for all pins
set_property IOSTANDARD LVCMOS18 [get_ports {m_axis_rx_tdata_2_1[*]}]
set_property IOSTANDARD LVCMOS18 [get_ports {s_axis_tx_tdata_1_2[*]}]

set_property IOSTANDARD LVCMOS18 [get_ports {s_axis_tx_tlast_1_2}]
set_property IOSTANDARD LVCMOS18 [get_ports {m_axis_rx_tlast_2_1}]

#set_property IOSTANDARD LVCMOS18 [get_ports {reset_tictoc_in}]
set_property IOSTANDARD LVCMOS18 [get_ports {reset_tictoc_out}]

set_property IOSTANDARD LVCMOS18 [get_ports {received_clk_2_1}]
set_property IOSTANDARD LVCMOS18 [get_ports {forwarded_clk_1_2}]

set_property PACKAGE_PIN N14 [get_ports {received_clk_2_1}]
set_property PACKAGE_PIN R34 [get_ports {forwarded_clk_1_2}]

set_property PACKAGE_PIN AL31 [get_ports {s_axis_tx_tdata_1_2[0]}]
set_property PACKAGE_PIN AL30 [get_ports {s_axis_tx_tdata_1_2[1]}]
set_property PACKAGE_PIN AK32 [get_ports {s_axis_tx_tdata_1_2[2]}]
set_property PACKAGE_PIN AJ32 [get_ports {s_axis_tx_tdata_1_2[3]}]
set_property PACKAGE_PIN AT40 [get_ports {s_axis_tx_tdata_1_2[4]}]
set_property PACKAGE_PIN AT39 [get_ports {s_axis_tx_tdata_1_2[5]}]
set_property PACKAGE_PIN AT37 [get_ports {s_axis_tx_tdata_1_2[6]}]
set_property PACKAGE_PIN AR37 [get_ports {s_axis_tx_tdata_1_2[7]}]
set_property PACKAGE_PIN AR38 [get_ports {s_axis_tx_tdata_1_2[8]}]
set_property PACKAGE_PIN AP38 [get_ports {s_axis_tx_tdata_1_2[9]}]
set_property PACKAGE_PIN AT36 [get_ports {s_axis_tx_tdata_1_2[10]}]
set_property PACKAGE_PIN AT35 [get_ports {s_axis_tx_tdata_1_2[11]}]
set_property PACKAGE_PIN AP37 [get_ports {s_axis_tx_tdata_1_2[12]}]
set_property PACKAGE_PIN AP36 [get_ports {s_axis_tx_tdata_1_2[13]}]
set_property PACKAGE_PIN AK30 [get_ports {s_axis_tx_tdata_1_2[14]}]
set_property PACKAGE_PIN AK29 [get_ports {s_axis_tx_tdata_1_2[15]}]
set_property PACKAGE_PIN AK33 [get_ports {s_axis_tx_tdata_1_2[16]}]
set_property PACKAGE_PIN AJ33 [get_ports {s_axis_tx_tdata_1_2[17]}]
set_property PACKAGE_PIN AR35 [get_ports {s_axis_tx_tdata_1_2[18]}]
set_property PACKAGE_PIN AP35 [get_ports {s_axis_tx_tdata_1_2[19]}]
set_property PACKAGE_PIN AJ31 [get_ports {s_axis_tx_tdata_1_2[20]}]
set_property PACKAGE_PIN AJ30 [get_ports {s_axis_tx_tdata_1_2[21]}]
set_property PACKAGE_PIN AH34 [get_ports {s_axis_tx_tdata_1_2[22]}]
set_property PACKAGE_PIN AH33 [get_ports {s_axis_tx_tdata_1_2[23]}]
set_property PACKAGE_PIN AJ36 [get_ports {s_axis_tx_tdata_1_2[24]}]
set_property PACKAGE_PIN AJ35 [get_ports {s_axis_tx_tdata_1_2[25]}]
set_property PACKAGE_PIN AH31 [get_ports {s_axis_tx_tdata_1_2[26]}]
set_property PACKAGE_PIN AG31 [get_ports {s_axis_tx_tdata_1_2[27]}]
set_property PACKAGE_PIN AG33 [get_ports {s_axis_tx_tdata_1_2[28]}]
set_property PACKAGE_PIN AG32 [get_ports {s_axis_tx_tdata_1_2[29]}]
set_property PACKAGE_PIN AH35 [get_ports {s_axis_tx_tdata_1_2[30]}]
set_property PACKAGE_PIN AG34 [get_ports {s_axis_tx_tdata_1_2[31]}]
set_property PACKAGE_PIN P34 [get_ports {s_axis_tx_tdata_1_2[32]}]
set_property PACKAGE_PIN P31 [get_ports {s_axis_tx_tdata_1_2[33]}]
set_property PACKAGE_PIN R31 [get_ports {s_axis_tx_tdata_1_2[34]}]
set_property PACKAGE_PIN M33 [get_ports {s_axis_tx_tdata_1_2[35]}]
set_property PACKAGE_PIN N33 [get_ports {s_axis_tx_tdata_1_2[36]}]
set_property PACKAGE_PIN M32 [get_ports {s_axis_tx_tdata_1_2[37]}]
set_property PACKAGE_PIN N32 [get_ports {s_axis_tx_tdata_1_2[38]}]
set_property PACKAGE_PIN L35 [get_ports {s_axis_tx_tdata_1_2[39]}]
set_property PACKAGE_PIN M35 [get_ports {s_axis_tx_tdata_1_2[40]}]
set_property PACKAGE_PIN N35 [get_ports {s_axis_tx_tdata_1_2[41]}]
set_property PACKAGE_PIN N34 [get_ports {s_axis_tx_tdata_1_2[42]}]
set_property PACKAGE_PIN W32 [get_ports {s_axis_tx_tdata_1_2[43]}]
set_property PACKAGE_PIN Y32 [get_ports {s_axis_tx_tdata_1_2[44]}]
set_property PACKAGE_PIN T35 [get_ports {s_axis_tx_tdata_1_2[45]}]
set_property PACKAGE_PIN T34 [get_ports {s_axis_tx_tdata_1_2[46]}]
set_property PACKAGE_PIN W34 [get_ports {s_axis_tx_tdata_1_2[47]}]
set_property PACKAGE_PIN Y34 [get_ports {s_axis_tx_tdata_1_2[48]}]
set_property PACKAGE_PIN U33 [get_ports {s_axis_tx_tdata_1_2[49]}]
set_property PACKAGE_PIN V32 [get_ports {s_axis_tx_tdata_1_2[50]}]
set_property PACKAGE_PIN V34 [get_ports {s_axis_tx_tdata_1_2[51]}]
set_property PACKAGE_PIN V33 [get_ports {s_axis_tx_tdata_1_2[52]}]
set_property PACKAGE_PIN L36 [get_ports {s_axis_tx_tdata_1_2[53]}]


set_property PACKAGE_PIN M36 [get_ports {m_axis_rx_tdata_2_1[0]}]
set_property PACKAGE_PIN T36 [get_ports {m_axis_rx_tdata_2_1[1]}]
set_property PACKAGE_PIN U35 [get_ports {m_axis_rx_tdata_2_1[2]}]
set_property PACKAGE_PIN M38 [get_ports {m_axis_rx_tdata_2_1[3]}]
set_property PACKAGE_PIN N38 [get_ports {m_axis_rx_tdata_2_1[4]}]
set_property PACKAGE_PIN N37 [get_ports {m_axis_rx_tdata_2_1[5]}]
set_property PACKAGE_PIN P37 [get_ports {m_axis_rx_tdata_2_1[6]}]
set_property PACKAGE_PIN K33 [get_ports {m_axis_rx_tdata_2_1[7]}]
set_property PACKAGE_PIN L33 [get_ports {m_axis_rx_tdata_2_1[8]}]
set_property PACKAGE_PIN K34 [get_ports {m_axis_rx_tdata_2_1[9]}]
set_property PACKAGE_PIN L34 [get_ports {m_axis_rx_tdata_2_1[10]}]
set_property PACKAGE_PIN N13 [get_ports {m_axis_rx_tdata_2_1[11]}]
set_property PACKAGE_PIN U15 [get_ports {m_axis_rx_tdata_2_1[12]}]
set_property PACKAGE_PIN V15 [get_ports {m_axis_rx_tdata_2_1[13]}]
set_property PACKAGE_PIN Y12 [get_ports {m_axis_rx_tdata_2_1[14]}]
set_property PACKAGE_PIN AA12 [get_ports {m_axis_rx_tdata_2_1[15]}]
set_property PACKAGE_PIN V12 [get_ports {m_axis_rx_tdata_2_1[16]}]
set_property PACKAGE_PIN W12 [get_ports {m_axis_rx_tdata_2_1[17]}]
set_property PACKAGE_PIN Y13 [get_ports {m_axis_rx_tdata_2_1[18]}]
set_property PACKAGE_PIN AA13 [get_ports {m_axis_rx_tdata_2_1[19]}]
set_property PACKAGE_PIN P14 [get_ports {m_axis_rx_tdata_2_1[20]}]
set_property PACKAGE_PIN R14 [get_ports {m_axis_rx_tdata_2_1[21]}]
set_property PACKAGE_PIN T13 [get_ports {m_axis_rx_tdata_2_1[22]}]
set_property PACKAGE_PIN U13 [get_ports {m_axis_rx_tdata_2_1[23]}]
set_property PACKAGE_PIN Y14 [get_ports {m_axis_rx_tdata_2_1[24]}]
set_property PACKAGE_PIN AA14 [get_ports {m_axis_rx_tdata_2_1[25]}]
set_property PACKAGE_PIN T11 [get_ports {m_axis_rx_tdata_2_1[26]}]
set_property PACKAGE_PIN U11 [get_ports {m_axis_rx_tdata_2_1[27]}]
set_property PACKAGE_PIN V14 [get_ports {m_axis_rx_tdata_2_1[28]}]
set_property PACKAGE_PIN W14 [get_ports {m_axis_rx_tdata_2_1[29]}]
set_property PACKAGE_PIN U16 [get_ports {m_axis_rx_tdata_2_1[30]}]
set_property PACKAGE_PIN V16 [get_ports {m_axis_rx_tdata_2_1[31]}]
set_property PACKAGE_PIN P12 [get_ports {m_axis_rx_tdata_2_1[32]}]
set_property PACKAGE_PIN R12 [get_ports {m_axis_rx_tdata_2_1[33]}]
set_property PACKAGE_PIN T15 [get_ports {m_axis_rx_tdata_2_1[34]}]
set_property PACKAGE_PIN T16 [get_ports {m_axis_rx_tdata_2_1[35]}]
set_property PACKAGE_PIN U12 [get_ports {m_axis_rx_tdata_2_1[36]}]
set_property PACKAGE_PIN V13 [get_ports {m_axis_rx_tdata_2_1[37]}]
set_property PACKAGE_PIN L11 [get_ports {m_axis_rx_tdata_2_1[38]}]
set_property PACKAGE_PIN M11 [get_ports {m_axis_rx_tdata_2_1[39]}]
set_property PACKAGE_PIN M12 [get_ports {m_axis_rx_tdata_2_1[40]}]
set_property PACKAGE_PIN M13 [get_ports {m_axis_rx_tdata_2_1[41]}]
set_property PACKAGE_PIN R13 [get_ports {m_axis_rx_tdata_2_1[42]}]
set_property PACKAGE_PIN T14 [get_ports {m_axis_rx_tdata_2_1[43]}]
set_property PACKAGE_PIN P11 [get_ports {m_axis_rx_tdata_2_1[44]}]
set_property PACKAGE_PIN R11 [get_ports {m_axis_rx_tdata_2_1[45]}]
set_property PACKAGE_PIN N15 [get_ports {m_axis_rx_tdata_2_1[46]}]
set_property PACKAGE_PIN P15 [get_ports {m_axis_rx_tdata_2_1[47]}]
set_property PACKAGE_PIN L13 [get_ports {m_axis_rx_tdata_2_1[48]}]
set_property PACKAGE_PIN L14 [get_ports {m_axis_rx_tdata_2_1[49]}]
set_property PACKAGE_PIN L15 [get_ports {m_axis_rx_tdata_2_1[50]}]
set_property PACKAGE_PIN M15 [get_ports {m_axis_rx_tdata_2_1[51]}]
set_property PACKAGE_PIN K13 [get_ports {m_axis_rx_tdata_2_1[52]}]
set_property PACKAGE_PIN K14 [get_ports {m_axis_rx_tdata_2_1[53]}]

set_property PACKAGE_PIN J12 [get_ports {s_axis_tx_tlast_1_2}]
set_property PACKAGE_PIN K12 [get_ports {m_axis_rx_tlast_2_1}]
#set_property PACKAGE_PIN J11 [get_ports {reset_tictoc_in}]
set_property PACKAGE_PIN K11 [get_ports {reset_tictoc_out}]
