
################################################################
# This is a generated script based on design: design_1
#
# Though there are limitations about the generated script,
# the main purpose of this utility is to make learning
# IP Integrator Tcl commands easier.
################################################################

namespace eval _tcl {
proc get_script_folder {} {
   set script_path [file normalize [info script]]
   set script_folder [file dirname $script_path]
   return $script_folder
}
}
variable script_folder
set script_folder [_tcl::get_script_folder]

################################################################
# Check if script is running in correct Vivado version.
################################################################
set scripts_vivado_version 2024.1
set current_vivado_version [version -short]

if { [string first $scripts_vivado_version $current_vivado_version] == -1 } {
   puts ""
   if { [string compare $scripts_vivado_version $current_vivado_version] > 0 } {
      catch {common::send_gid_msg -ssname BD::TCL -id 2042 -severity "ERROR" " This script was generated using Vivado <$scripts_vivado_version> and is being run in <$current_vivado_version> of Vivado. Sourcing the script failed since it was created with a future version of Vivado."}

   } else {
     catch {common::send_gid_msg -ssname BD::TCL -id 2041 -severity "ERROR" "This script was generated using Vivado <$scripts_vivado_version> and is being run in <$current_vivado_version> of Vivado. Please run the script in Vivado <$scripts_vivado_version> then open the design in Vivado <$current_vivado_version>. Upgrade the design by running \"Tools => Report => Report IP Status...\", then run write_bd_tcl to create an updated script."}

   }

   return 1
}

################################################################
# START
################################################################

# To test this script, run the following commands from Vivado Tcl console:
# source design_1_script.tcl


# The design that will be created by this Tcl script contains the following 
# module references:
# BRAM_write_shift_regs_wrapper

# Please add the sources of those modules before sourcing this Tcl script.

# If there is no project opened, this script will create a
# project, but make sure you do not have an existing project
# <./myproj/project_1.xpr> in the current working folder.

set list_projs [get_projects -quiet]
if { $list_projs eq "" } {
   create_project project_1 myproj -part xcvu9p-flga2104-2L-e
   set_property BOARD_PART xilinx.com:vcu118:part0:2.4 [current_project]
}


# CHANGE DESIGN NAME HERE
variable design_name
set design_name design_1

# If you do not already have an existing IP Integrator design open,
# you can create a design using the following command:
#    create_bd_design $design_name

# Creating design if needed
set errMsg ""
set nRet 0

set cur_design [current_bd_design -quiet]
set list_cells [get_bd_cells -quiet]

if { ${design_name} eq "" } {
   # USE CASES:
   #    1) Design_name not set

   set errMsg "Please set the variable <design_name> to a non-empty value."
   set nRet 1

} elseif { ${cur_design} ne "" && ${list_cells} eq "" } {
   # USE CASES:
   #    2): Current design opened AND is empty AND names same.
   #    3): Current design opened AND is empty AND names diff; design_name NOT in project.
   #    4): Current design opened AND is empty AND names diff; design_name exists in project.

   if { $cur_design ne $design_name } {
      common::send_gid_msg -ssname BD::TCL -id 2001 -severity "INFO" "Changing value of <design_name> from <$design_name> to <$cur_design> since current design is empty."
      set design_name [get_property NAME $cur_design]
   }
   common::send_gid_msg -ssname BD::TCL -id 2002 -severity "INFO" "Constructing design in IPI design <$cur_design>..."

} elseif { ${cur_design} ne "" && $list_cells ne "" && $cur_design eq $design_name } {
   # USE CASES:
   #    5) Current design opened AND has components AND same names.

   set errMsg "Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 1
} elseif { [get_files -quiet ${design_name}.bd] ne "" } {
   # USE CASES: 
   #    6) Current opened design, has components, but diff names, design_name exists in project.
   #    7) No opened design, design_name exists in project.

   set errMsg "Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 2

} else {
   # USE CASES:
   #    8) No opened design, design_name not in project.
   #    9) Current opened design, has components, but diff names, design_name not in project.

   common::send_gid_msg -ssname BD::TCL -id 2003 -severity "INFO" "Currently there is no design <$design_name> in project, so creating one..."

   create_bd_design $design_name

   common::send_gid_msg -ssname BD::TCL -id 2004 -severity "INFO" "Making design <$design_name> as current_bd_design."
   current_bd_design $design_name

}

common::send_gid_msg -ssname BD::TCL -id 2005 -severity "INFO" "Currently the variable <design_name> is equal to \"$design_name\"."

if { $nRet != 0 } {
   catch {common::send_gid_msg -ssname BD::TCL -id 2006 -severity "ERROR" $errMsg}
   return $nRet
}

set bCheckIPsPassed 1
##################################################################
# CHECK IPs
##################################################################
set bCheckIPs 1
if { $bCheckIPs == 1 } {
   set list_check_ips "\ 
xilinx.com:ip:blk_mem_gen:8.4\
mathworks.com:ip:ethernet_mac_hub_gmii:1.0\
mathworks.com:ip:udp_axi_manager:2.0\
xilinx.com:ip:xlconstant:1.1\
xilinx.com:ip:clk_wiz:6.0\
xilinx.com:ip:proc_sys_reset:5.0\
"

   set list_ips_missing ""
   common::send_gid_msg -ssname BD::TCL -id 2011 -severity "INFO" "Checking if the following IPs exist in the project's IP catalog: $list_check_ips ."

   foreach ip_vlnv $list_check_ips {
      set ip_obj [get_ipdefs -all $ip_vlnv]
      if { $ip_obj eq "" } {
         lappend list_ips_missing $ip_vlnv
      }
   }

   if { $list_ips_missing ne "" } {
      catch {common::send_gid_msg -ssname BD::TCL -id 2012 -severity "ERROR" "The following IPs are not found in the IP Catalog:\n  $list_ips_missing\n\nResolution: Please add the repository containing the IP(s) to the project." }
      set bCheckIPsPassed 0
   }

}

##################################################################
# CHECK Modules
##################################################################
set bCheckModules 1
if { $bCheckModules == 1 } {
   set list_check_mods "\ 
BRAM_write_shift_regs_wrapper\
"

   set list_mods_missing ""
   common::send_gid_msg -ssname BD::TCL -id 2020 -severity "INFO" "Checking if the following modules exist in the project's sources: $list_check_mods ."

   foreach mod_vlnv $list_check_mods {
      if { [can_resolve_reference $mod_vlnv] == 0 } {
         lappend list_mods_missing $mod_vlnv
      }
   }

   if { $list_mods_missing ne "" } {
      catch {common::send_gid_msg -ssname BD::TCL -id 2021 -severity "ERROR" "The following module(s) are not found in the project: $list_mods_missing" }
      common::send_gid_msg -ssname BD::TCL -id 2022 -severity "INFO" "Please add source files for the missing module(s) above."
      set bCheckIPsPassed 0
   }
}

if { $bCheckIPsPassed != 1 } {
  common::send_gid_msg -ssname BD::TCL -id 2023 -severity "WARNING" "Will not continue with creation of design due to the error(s) above."
  return 3
}

##################################################################
# DESIGN PROCs
##################################################################



# Procedure to create entire design; Provide argument to make
# procedure reusable. If parentCell is "", will use root.
proc create_root_design { parentCell } {

  variable script_folder
  variable design_name

  if { $parentCell eq "" } {
     set parentCell [get_bd_cells /]
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2090 -severity "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2091 -severity "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj


  # Create interface ports
  set sys_clock [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:diff_clock_rtl:1.0 sys_clock ]
  set_property -dict [ list \
   CONFIG.FREQ_HZ {300000000} \
   ] $sys_clock


  # Create ports
  set J_ram [ create_bd_port -dir O -from 31 -to 0 J_ram ]
  set bram_read_clk [ create_bd_port -dir O -type clk bram_read_clk ]
  set clock1_0 [ create_bd_port -dir O -type clk clock1_0 ]
  set clock2_0 [ create_bd_port -dir O -type clk clock2_0 ]
  set h_ram [ create_bd_port -dir O -from 31 -to 0 h_ram ]
  set reset [ create_bd_port -dir I -type rst reset ]
  set_property -dict [ list \
   CONFIG.POLARITY {ACTIVE_HIGH} \
 ] $reset
  set reset_ref_counter_value_0 [ create_bd_port -dir O -from 0 -to 0 reset_ref_counter_value_0 ]
  set reset_tictoc_value_0 [ create_bd_port -dir O -from 0 -to 0 reset_tictoc_value_0 ]
  set s_ram [ create_bd_port -dir I -from 31 -to 0 s_ram ]
  set s_write_enb [ create_bd_port -dir I -from 0 -to 0 s_write_enb ]
  set tictoc_counter_limit_value_0 [ create_bd_port -dir O -from 31 -to 0 tictoc_counter_limit_value_0 ]
  set phy_rxd_0 [ create_bd_port -dir I -from 7 -to 0 phy_rxd_0 ]
  set phy_rxdv_0 [ create_bd_port -dir I phy_rxdv_0 ]
  set phy_rxer_0 [ create_bd_port -dir I phy_rxer_0 ]
  set phy_txd_0 [ create_bd_port -dir O -from 7 -to 0 phy_txd_0 ]
  set phy_txen_0 [ create_bd_port -dir O phy_txen_0 ]
  set phy_txer_0 [ create_bd_port -dir O phy_txer_0 ]
  set axi_clk [ create_bd_port -dir I -type clk -freq_hz 125000000 axi_clk ]
  set_property -dict [ list \
   CONFIG.CLK_DOMAIN {design_1_gig_ethernet_pcs_pma_0_0_clk125_out} \
   CONFIG.PHASE {0} \
 ] $axi_clk
  set rxclk_en_0 [ create_bd_port -dir I rxclk_en_0 ]
  set txclk_en_0 [ create_bd_port -dir I txclk_en_0 ]
  set ref_clk_0 [ create_bd_port -dir I -type clk -freq_hz 125000000 ref_clk_0 ]
  set_property -dict [ list \
   CONFIG.PHASE {0} \
 ] $ref_clk_0
  set phy_rxclk_0 [ create_bd_port -dir I phy_rxclk_0 ]
  set frozen_value_0 [ create_bd_port -dir I -from 0 -to 0 frozen_value_0 ]
  set weight_load_done_value_0 [ create_bd_port -dir I -from 0 -to 0 weight_load_done_value_0 ]
  set flip_counter_value_slv_0 [ create_bd_port -dir I -from 79 -to 0 flip_counter_value_slv_0 ]
  set J_read_addr [ create_bd_port -dir I -from 16 -to 0 J_read_addr ]
  set s2_write_enb [ create_bd_port -dir I -from 0 -to 0 s2_write_enb ]
  set s2_ram [ create_bd_port -dir I -from 31 -to 0 s2_ram ]
  set s2_write_addr [ create_bd_port -dir I -from 19 -to 0 s2_write_addr ]
  set s_write_addr [ create_bd_port -dir I -from 19 -to 0 s_write_addr ]
  set read_state_counter_value_0 [ create_bd_port -dir O -from 31 -to 0 read_state_counter_value_0 ]
  set active_state_counter_value_0 [ create_bd_port -dir O -from 31 -to 0 active_state_counter_value_0 ]
  set h_read_trigger_value_0 [ create_bd_port -dir O -from 0 -to 0 h_read_trigger_value_0 ]
  set j_read_trigger_value_0 [ create_bd_port -dir O -from 0 -to 0 j_read_trigger_value_0 ]
  set num_sweeps_neg_value_0 [ create_bd_port -dir O -from 31 -to 0 num_sweeps_neg_value_0 ]
  set num_sweeps_pos_value_0 [ create_bd_port -dir O -from 31 -to 0 num_sweeps_pos_value_0 ]
  set num_sweeps_pos_per_batch_value_0 [ create_bd_port -dir O -from 31 -to 0 num_sweeps_pos_per_batch_value_0 ]
  set ignore_state_counter_value_0 [ create_bd_port -dir O -from 31 -to 0 ignore_state_counter_value_0 ]
  set division_factor_value_0 [ create_bd_port -dir O -from 31 -to 0 division_factor_value_0 ]
  set ce_value_0 [ create_bd_port -dir O -from 0 -to 0 ce_value_0 ]
  set ce_comm_value_0 [ create_bd_port -dir O -from 0 -to 0 ce_comm_value_0 ]
  set division_factor_comm_value_0 [ create_bd_port -dir O -from 31 -to 0 division_factor_comm_value_0 ]
  set h_read_addr [ create_bd_port -dir I -from 14 -to 0 h_read_addr ]
  set clock3_0 [ create_bd_port -dir O -type clk clock3_0 ]

  # Create instance: BRAM_J, and set properties
  set BRAM_J [ create_bd_cell -type ip -vlnv xilinx.com:ip:blk_mem_gen:8.4 BRAM_J ]
  set_property -dict [list \
    CONFIG.Byte_Size {8} \
    CONFIG.Enable_32bit_Address {false} \
    CONFIG.Enable_A {Always_Enabled} \
    CONFIG.Enable_B {Always_Enabled} \
    CONFIG.Memory_Type {Simple_Dual_Port_RAM} \
    CONFIG.Operating_Mode_A {NO_CHANGE} \
    CONFIG.Port_B_Clock {100} \
    CONFIG.Port_B_Enable_Rate {100} \
    CONFIG.Read_Width_B {32} \
    CONFIG.Register_PortB_Output_of_Memory_Primitives {true} \
    CONFIG.Use_Byte_Write_Enable {true} \
    CONFIG.Write_Depth_A {100000} \
    CONFIG.Write_Width_A {32} \
    CONFIG.Write_Width_B {32} \
    CONFIG.use_bram_block {Stand_Alone} \
  ] $BRAM_J


  # Create instance: BRAM_h, and set properties
  set BRAM_h [ create_bd_cell -type ip -vlnv xilinx.com:ip:blk_mem_gen:8.4 BRAM_h ]
  set_property -dict [list \
    CONFIG.Byte_Size {8} \
    CONFIG.Enable_32bit_Address {false} \
    CONFIG.Enable_A {Always_Enabled} \
    CONFIG.Enable_B {Always_Enabled} \
    CONFIG.Memory_Type {Simple_Dual_Port_RAM} \
    CONFIG.Operating_Mode_A {NO_CHANGE} \
    CONFIG.Port_B_Clock {100} \
    CONFIG.Port_B_Enable_Rate {100} \
    CONFIG.Read_Width_B {32} \
    CONFIG.Register_PortB_Output_of_Memory_Primitives {true} \
    CONFIG.Use_Byte_Write_Enable {true} \
    CONFIG.Write_Depth_A {25000} \
    CONFIG.Write_Width_A {32} \
    CONFIG.Write_Width_B {32} \
    CONFIG.use_bram_block {Stand_Alone} \
  ] $BRAM_h


  # Create instance: BRAM_s_pos, and set properties
  set BRAM_s_pos [ create_bd_cell -type ip -vlnv xilinx.com:ip:blk_mem_gen:8.4 BRAM_s_pos ]
  set_property -dict [list \
    CONFIG.Enable_32bit_Address {false} \
    CONFIG.Enable_A {Always_Enabled} \
    CONFIG.Enable_B {Use_ENB_Pin} \
    CONFIG.Memory_Type {Simple_Dual_Port_RAM} \
    CONFIG.Operating_Mode_A {NO_CHANGE} \
    CONFIG.Port_B_Clock {100} \
    CONFIG.Port_B_Enable_Rate {100} \
    CONFIG.Read_Width_B {32} \
    CONFIG.Register_PortB_Output_of_Memory_Primitives {true} \
    CONFIG.Use_Byte_Write_Enable {false} \
    CONFIG.Write_Depth_A {1000000} \
    CONFIG.Write_Width_A {32} \
    CONFIG.Write_Width_B {32} \
    CONFIG.use_bram_block {Stand_Alone} \
  ] $BRAM_s_pos


  # Create instance: axi_interconnect_0, and set properties
  set axi_interconnect_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect:2.1 axi_interconnect_0 ]
  set_property CONFIG.NUM_MI {1} $axi_interconnect_0


  # Create instance: ethernet_mac_hub_gmii, and set properties
  set ethernet_mac_hub_gmii [ create_bd_cell -type ip -vlnv mathworks.com:ip:ethernet_mac_hub_gmii:1.0 ethernet_mac_hub_gmii ]
  set_property -dict [list \
    CONFIG.IPADDR1 {192} \
    CONFIG.IPADDR2 {168} \
    CONFIG.IPADDR3 {0} \
    CONFIG.IPADDR4 {1} \
    CONFIG.MACADDR {0x000A3502218A} \
    CONFIG.NUM_AXIS_CHANNELS {1} \
    CONFIG.UDP_DSTPORT_FORCH1 {50101} \
    CONFIG.UDP_DSTPORT_FORCH2 {50103} \
    CONFIG.UDP_DSTPORT_FORCH3 {50102} \
  ] $ethernet_mac_hub_gmii


  set_property -dict [ list \
   CONFIG.POLARITY {ACTIVE_HIGH} \
 ] [get_bd_pins /ethernet_mac_hub_gmii/ref_reset]

  # Create instance: udp_axi_manager_0, and set properties
  set udp_axi_manager_0 [ create_bd_cell -type ip -vlnv mathworks.com:ip:udp_axi_manager:2.0 udp_axi_manager_0 ]

  # Create instance: xlconstant_1, and set properties
  set xlconstant_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 xlconstant_1 ]
  set_property CONFIG.CONST_VAL {0} $xlconstant_1


  # Create instance: clk_wiz_0, and set properties
  set clk_wiz_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:clk_wiz:6.0 clk_wiz_0 ]
  set_property -dict [list \
    CONFIG.CLKIN1_JITTER_PS {33.330000000000005} \
    CONFIG.CLKOUT1_JITTER {148.617} \
    CONFIG.CLKOUT1_PHASE_ERROR {84.323} \
    CONFIG.CLKOUT1_REQUESTED_OUT_FREQ {15} \
    CONFIG.CLKOUT2_JITTER {148.617} \
    CONFIG.CLKOUT2_PHASE_ERROR {84.323} \
    CONFIG.CLKOUT2_REQUESTED_OUT_FREQ {15} \
    CONFIG.CLKOUT2_REQUESTED_PHASE {120} \
    CONFIG.CLKOUT2_USED {true} \
    CONFIG.CLKOUT3_JITTER {148.617} \
    CONFIG.CLKOUT3_PHASE_ERROR {84.323} \
    CONFIG.CLKOUT3_REQUESTED_OUT_FREQ {15} \
    CONFIG.CLKOUT3_REQUESTED_PHASE {240} \
    CONFIG.CLKOUT3_USED {true} \
    CONFIG.CLKOUT4_JITTER {101.573} \
    CONFIG.CLKOUT4_PHASE_ERROR {84.323} \
    CONFIG.CLKOUT4_REQUESTED_OUT_FREQ {100} \
    CONFIG.CLKOUT4_REQUESTED_PHASE {0} \
    CONFIG.CLKOUT4_USED {true} \
    CONFIG.CLKOUT5_JITTER {101.475} \
    CONFIG.CLKOUT5_PHASE_ERROR {77.836} \
    CONFIG.CLKOUT5_REQUESTED_OUT_FREQ {100} \
    CONFIG.CLKOUT5_REQUESTED_PHASE {0} \
    CONFIG.CLKOUT5_USED {false} \
    CONFIG.CLKOUT6_JITTER {101.475} \
    CONFIG.CLKOUT6_PHASE_ERROR {77.836} \
    CONFIG.CLKOUT6_REQUESTED_OUT_FREQ {100.000} \
    CONFIG.CLKOUT6_REQUESTED_PHASE {0.000} \
    CONFIG.CLKOUT6_USED {false} \
    CONFIG.CLKOUT7_JITTER {148.617} \
    CONFIG.CLKOUT7_PHASE_ERROR {84.323} \
    CONFIG.CLKOUT7_REQUESTED_OUT_FREQ {100.000} \
    CONFIG.CLKOUT7_REQUESTED_PHASE {0.000} \
    CONFIG.CLKOUT7_USED {false} \
    CONFIG.CLK_IN1_BOARD_INTERFACE {default_sysclk1_300} \
    CONFIG.CLK_OUT1_PORT {clock1} \
    CONFIG.CLK_OUT2_PORT {clock2} \
    CONFIG.CLK_OUT3_PORT {clock3} \
    CONFIG.CLK_OUT4_PORT {bram_read_clk} \
    CONFIG.CLK_OUT5_PORT {bram_read_clk} \
    CONFIG.CLK_OUT6_PORT {clk_out6} \
    CONFIG.CLK_OUT7_PORT {clk_out7} \
    CONFIG.MMCM_CLKFBOUT_MULT_F {3.000} \
    CONFIG.MMCM_CLKIN1_PERIOD {3.333} \
    CONFIG.MMCM_CLKIN2_PERIOD {10.0} \
    CONFIG.MMCM_CLKOUT0_DIVIDE_F {60.000} \
    CONFIG.MMCM_CLKOUT1_DIVIDE {60} \
    CONFIG.MMCM_CLKOUT1_PHASE {120.000} \
    CONFIG.MMCM_CLKOUT2_DIVIDE {60} \
    CONFIG.MMCM_CLKOUT2_PHASE {240.000} \
    CONFIG.MMCM_CLKOUT3_DIVIDE {9} \
    CONFIG.MMCM_CLKOUT3_PHASE {0.000} \
    CONFIG.MMCM_CLKOUT4_DIVIDE {1} \
    CONFIG.MMCM_CLKOUT4_PHASE {0.000} \
    CONFIG.MMCM_CLKOUT5_DIVIDE {1} \
    CONFIG.MMCM_CLKOUT5_PHASE {0.000} \
    CONFIG.MMCM_CLKOUT6_DIVIDE {1} \
    CONFIG.MMCM_CLKOUT6_PHASE {0.000} \
    CONFIG.MMCM_DIVCLK_DIVIDE {1} \
    CONFIG.NUM_OUT_CLKS {4} \
    CONFIG.OPTIMIZE_CLOCKING_STRUCTURE_EN {false} \
    CONFIG.PHASESHIFT_MODE {WAVEFORM} \
    CONFIG.PRIM_IN_FREQ {300.000} \
    CONFIG.PRIM_SOURCE {Differential_clock_capable_pin} \
  ] $clk_wiz_0


  # Create instance: sender_proc_sys_reset, and set properties
  set sender_proc_sys_reset [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 sender_proc_sys_reset ]

  # Create instance: BRAM_s_neg, and set properties
  set BRAM_s_neg [ create_bd_cell -type ip -vlnv xilinx.com:ip:blk_mem_gen:8.4 BRAM_s_neg ]
  set_property -dict [list \
    CONFIG.Enable_32bit_Address {false} \
    CONFIG.Enable_A {Always_Enabled} \
    CONFIG.Enable_B {Use_ENB_Pin} \
    CONFIG.Memory_Type {Simple_Dual_Port_RAM} \
    CONFIG.Operating_Mode_A {NO_CHANGE} \
    CONFIG.Port_B_Clock {100} \
    CONFIG.Port_B_Enable_Rate {100} \
    CONFIG.Read_Width_B {32} \
    CONFIG.Register_PortB_Output_of_Memory_Primitives {true} \
    CONFIG.Use_Byte_Write_Enable {false} \
    CONFIG.Write_Depth_A {1000000} \
    CONFIG.Write_Width_A {32} \
    CONFIG.Write_Width_B {32} \
    CONFIG.use_bram_block {Stand_Alone} \
  ] $BRAM_s_neg


  # Create instance: BRAM_write_0, and set properties
  set block_name BRAM_write_shift_regs_wrapper
  set block_cell_name BRAM_write_0
  if { [catch {set BRAM_write_0 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $BRAM_write_0 eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  # Create interface connections
  connect_bd_intf_net -intf_net CLK_IN1_D_0_1 [get_bd_intf_ports sys_clock] [get_bd_intf_pins clk_wiz_0/CLK_IN1_D]
  connect_bd_intf_net -intf_net axi_interconnect_0_M00_AXI [get_bd_intf_pins axi_interconnect_0/M00_AXI] [get_bd_intf_pins BRAM_write_0/s_axi]
  connect_bd_intf_net -intf_net ethernet_mac_hub_gmii_m0_axis [get_bd_intf_pins ethernet_mac_hub_gmii/m0_axis] [get_bd_intf_pins udp_axi_manager_0/s_axis]
  connect_bd_intf_net -intf_net udp_axi_manager_0_axi4m [get_bd_intf_pins axi_interconnect_0/S00_AXI] [get_bd_intf_pins udp_axi_manager_0/axi4m]
  connect_bd_intf_net -intf_net udp_axi_manager_0_m_axis [get_bd_intf_pins ethernet_mac_hub_gmii/s0_axis] [get_bd_intf_pins udp_axi_manager_0/m_axis]

  # Create port connections
  connect_bd_net -net BRAM_h_doutb [get_bd_pins BRAM_h/doutb] [get_bd_ports h_ram]
  connect_bd_net -net BRAM_s1_doutb [get_bd_pins BRAM_s_neg/doutb] [get_bd_pins BRAM_write_0/s_memory_2_rdata]
  connect_bd_net -net BRAM_s_doutb [get_bd_pins BRAM_s_pos/doutb] [get_bd_pins BRAM_write_0/s_memory_rdata]
  connect_bd_net -net J_BRAM_doutb [get_bd_pins BRAM_J/doutb] [get_bd_ports J_ram]
  connect_bd_net -net Net1 [get_bd_ports reset] [get_bd_pins clk_wiz_0/reset] [get_bd_pins sender_proc_sys_reset/ext_reset_in]
  connect_bd_net -net addra_0_1 [get_bd_ports s2_write_addr] [get_bd_pins BRAM_s_neg/addra]
  connect_bd_net -net addra_0_2 [get_bd_ports s_write_addr] [get_bd_pins BRAM_s_pos/addra]
  connect_bd_net -net addrb_0_1 [get_bd_ports J_read_addr] [get_bd_pins BRAM_J/addrb]
  connect_bd_net -net addrb_0_2 [get_bd_ports h_read_addr] [get_bd_pins BRAM_h/addrb]
  connect_bd_net -net clk_wiz_0_bram_read_clk [get_bd_pins clk_wiz_0/bram_read_clk] [get_bd_ports bram_read_clk] [get_bd_pins BRAM_J/clkb] [get_bd_pins BRAM_h/clkb] [get_bd_pins BRAM_s_pos/clka] [get_bd_pins BRAM_s_neg/clka]
  connect_bd_net -net clk_wiz_0_clock1 [get_bd_pins clk_wiz_0/clock1] [get_bd_ports clock1_0]
  connect_bd_net -net clk_wiz_0_clock2 [get_bd_pins clk_wiz_0/clock2] [get_bd_ports clock2_0]
  connect_bd_net -net clk_wiz_0_clock3 [get_bd_pins clk_wiz_0/clock3] [get_bd_ports clock3_0]
  connect_bd_net -net dina_0_1 [get_bd_ports s_ram] [get_bd_pins BRAM_s_pos/dina]
  connect_bd_net -net dina_0_2 [get_bd_ports s2_ram] [get_bd_pins BRAM_s_neg/dina]
  connect_bd_net -net ethernet_mac_hub_gmii_axis_aresetn [get_bd_pins ethernet_mac_hub_gmii/axis_aresetn] [get_bd_pins udp_axi_manager_0/axis_aresetn]
  connect_bd_net -net ethernet_mac_hub_gmii_phy_txd [get_bd_pins ethernet_mac_hub_gmii/phy_txd] [get_bd_ports phy_txd_0]
  connect_bd_net -net ethernet_mac_hub_gmii_phy_txen [get_bd_pins ethernet_mac_hub_gmii/phy_txen] [get_bd_ports phy_txen_0]
  connect_bd_net -net ethernet_mac_hub_gmii_phy_txer [get_bd_pins ethernet_mac_hub_gmii/phy_txer] [get_bd_ports phy_txer_0]
  connect_bd_net -net flip_counter_value_slv_0_1 [get_bd_ports flip_counter_value_slv_0] [get_bd_pins BRAM_write_0/flip_counter_value_slv]
  connect_bd_net -net frozen_value_0_1 [get_bd_ports frozen_value_0] [get_bd_pins BRAM_write_0/frozen_value]
  connect_bd_net -net gig_ethernet_pcs_pma_0_userclk2_out [get_bd_ports axi_clk] [get_bd_pins ethernet_mac_hub_gmii/axis_aclk] [get_bd_pins udp_axi_manager_0/aclk] [get_bd_pins udp_axi_manager_0/axis_aclk] [get_bd_pins BRAM_J/clka] [get_bd_pins BRAM_h/clka] [get_bd_pins BRAM_s_pos/clkb] [get_bd_pins BRAM_s_neg/clkb] [get_bd_pins axi_interconnect_0/ACLK] [get_bd_pins axi_interconnect_0/S00_ACLK] [get_bd_pins axi_interconnect_0/M00_ACLK] [get_bd_pins sender_proc_sys_reset/slowest_sync_clk] [get_bd_pins BRAM_write_0/axi_aclk]
  connect_bd_net -net phy_rxclk_0_1 [get_bd_ports phy_rxclk_0] [get_bd_pins ethernet_mac_hub_gmii/phy_rxclk]
  connect_bd_net -net phy_rxd_0_1 [get_bd_ports phy_rxd_0] [get_bd_pins ethernet_mac_hub_gmii/phy_rxd]
  connect_bd_net -net phy_rxdv_0_1 [get_bd_ports phy_rxdv_0] [get_bd_pins ethernet_mac_hub_gmii/phy_rxdv]
  connect_bd_net -net phy_rxer_0_1 [get_bd_ports phy_rxer_0] [get_bd_pins ethernet_mac_hub_gmii/phy_rxer]
  connect_bd_net -net BRAM_write_0_active_state_counter_value [get_bd_pins BRAM_write_0/active_state_counter_value] [get_bd_ports active_state_counter_value_0]
  connect_bd_net -net BRAM_write_0_ce_comm_value [get_bd_pins BRAM_write_0/ce_comm_value] [get_bd_ports ce_comm_value_0]
  connect_bd_net -net BRAM_write_0_ce_value [get_bd_pins BRAM_write_0/ce_value] [get_bd_ports ce_value_0]
  connect_bd_net -net BRAM_write_0_division_factor_comm_value [get_bd_pins BRAM_write_0/division_factor_comm_value] [get_bd_ports division_factor_comm_value_0]
  connect_bd_net -net BRAM_write_0_division_factor_value [get_bd_pins BRAM_write_0/division_factor_value] [get_bd_ports division_factor_value_0]
  connect_bd_net -net BRAM_write_0_h_memory_addr [get_bd_pins BRAM_write_0/h_memory_addr] [get_bd_pins BRAM_h/addra]
  connect_bd_net -net BRAM_write_0_h_memory_wdata [get_bd_pins BRAM_write_0/h_memory_wdata] [get_bd_pins BRAM_h/dina]
  connect_bd_net -net BRAM_write_0_h_memory_wen [get_bd_pins BRAM_write_0/h_memory_wen] [get_bd_pins BRAM_h/wea]
  connect_bd_net -net BRAM_write_0_h_read_trigger_value [get_bd_pins BRAM_write_0/h_read_trigger_value] [get_bd_ports h_read_trigger_value_0]
  connect_bd_net -net BRAM_write_0_ignore_state_counter_value [get_bd_pins BRAM_write_0/ignore_state_counter_value] [get_bd_ports ignore_state_counter_value_0]
  connect_bd_net -net BRAM_write_0_j_memory_addr [get_bd_pins BRAM_write_0/j_memory_addr] [get_bd_pins BRAM_J/addra]
  connect_bd_net -net BRAM_write_0_j_memory_wdata [get_bd_pins BRAM_write_0/j_memory_wdata] [get_bd_pins BRAM_J/dina]
  connect_bd_net -net BRAM_write_0_j_memory_wen [get_bd_pins BRAM_write_0/j_memory_wen] [get_bd_pins BRAM_J/wea]
  connect_bd_net -net BRAM_write_0_j_read_trigger_value [get_bd_pins BRAM_write_0/j_read_trigger_value] [get_bd_ports j_read_trigger_value_0]
  connect_bd_net -net BRAM_write_0_num_sweeps_neg_value [get_bd_pins BRAM_write_0/num_sweeps_neg_value] [get_bd_ports num_sweeps_neg_value_0]
  connect_bd_net -net BRAM_write_0_num_sweeps_pos_per_batch_value [get_bd_pins BRAM_write_0/num_sweeps_pos_per_batch_value] [get_bd_ports num_sweeps_pos_per_batch_value_0]
  connect_bd_net -net BRAM_write_0_num_sweeps_pos_value [get_bd_pins BRAM_write_0/num_sweeps_pos_value] [get_bd_ports num_sweeps_pos_value_0]
  connect_bd_net -net BRAM_write_0_read_state_counter_value [get_bd_pins BRAM_write_0/read_state_counter_value] [get_bd_ports read_state_counter_value_0]
  connect_bd_net -net BRAM_write_0_reset_ref_counter_value [get_bd_pins BRAM_write_0/reset_ref_counter_value] [get_bd_ports reset_ref_counter_value_0]
  connect_bd_net -net BRAM_write_0_reset_tictoc_value [get_bd_pins BRAM_write_0/reset_tictoc_value] [get_bd_ports reset_tictoc_value_0]
  connect_bd_net -net BRAM_write_0_s_memory_2_addr [get_bd_pins BRAM_write_0/s_memory_2_addr] [get_bd_pins BRAM_s_neg/addrb]
  connect_bd_net -net BRAM_write_0_s_memory_2_ren [get_bd_pins BRAM_write_0/s_memory_2_ren] [get_bd_pins BRAM_s_neg/enb]
  connect_bd_net -net BRAM_write_0_s_memory_addr [get_bd_pins BRAM_write_0/s_memory_addr] [get_bd_pins BRAM_s_pos/addrb]
  connect_bd_net -net BRAM_write_0_s_memory_ren [get_bd_pins BRAM_write_0/s_memory_ren] [get_bd_pins BRAM_s_pos/enb]
  connect_bd_net -net BRAM_write_0_tictoc_counter_limit_value [get_bd_pins BRAM_write_0/tictoc_counter_limit_value] [get_bd_ports tictoc_counter_limit_value_0]
  connect_bd_net -net ref_clk_0_1 [get_bd_ports ref_clk_0] [get_bd_pins ethernet_mac_hub_gmii/ref_clk]
  connect_bd_net -net rst_ps8_0_199M_peripheral_aresetn [get_bd_pins sender_proc_sys_reset/peripheral_aresetn] [get_bd_pins udp_axi_manager_0/aresetn] [get_bd_pins axi_interconnect_0/ARESETN] [get_bd_pins axi_interconnect_0/S00_ARESETN] [get_bd_pins axi_interconnect_0/M00_ARESETN] [get_bd_pins BRAM_write_0/axi_aresetn]
  connect_bd_net -net rxclk_en_0_1 [get_bd_ports rxclk_en_0] [get_bd_pins ethernet_mac_hub_gmii/rxclk_en]
  connect_bd_net -net txclk_en_0_1 [get_bd_ports txclk_en_0] [get_bd_pins ethernet_mac_hub_gmii/txclk_en]
  connect_bd_net -net wea_0_1 [get_bd_ports s_write_enb] [get_bd_pins BRAM_s_pos/wea]
  connect_bd_net -net wea_0_2 [get_bd_ports s2_write_enb] [get_bd_pins BRAM_s_neg/wea]
  connect_bd_net -net weight_load_done_value_0_1 [get_bd_ports weight_load_done_value_0] [get_bd_pins BRAM_write_0/weight_load_done_value]
  connect_bd_net -net xlconstant_0_dout1 [get_bd_pins xlconstant_1/dout] [get_bd_pins ethernet_mac_hub_gmii/phy_col] [get_bd_pins ethernet_mac_hub_gmii/phy_crs] [get_bd_pins ethernet_mac_hub_gmii/ref_reset]

  # Create address segments
  assign_bd_address -offset 0x00000000 -range 0x000100000000 -target_address_space [get_bd_addr_spaces udp_axi_manager_0/axi4m] [get_bd_addr_segs BRAM_write_0/s_axi/reg0] -force


  # Restore current instance
  current_bd_instance $oldCurInst

  validate_bd_design
  save_bd_design
}
# End of create_root_design()


##################################################################
# MAIN FLOW
##################################################################

create_root_design ""


