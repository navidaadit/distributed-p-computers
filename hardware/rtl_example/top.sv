`timescale 1ns / 1ps

module top( reset,  sys_clock_clk_n, sys_clock_clk_p, clk_125mhz_p, clk_125mhz_n, phy_sgmii_rx_p, phy_sgmii_rx_n, phy_sgmii_tx_p,   phy_sgmii_tx_n, phy_sgmii_clk_p,  phy_sgmii_clk_n,phy_reset_n,  phy_int_n, phy_mdio, phy_mdc,
forwarded_clk_3_2, received_clk_2_3, s_axis_tx_tdata_3_2, s_axis_tx_tlast_3_2, m_axis_rx_tdata_2_3, m_axis_rx_tlast_2_3, reset_tictoc_in,
forwarded_clk_3_4, received_clk_4_3, s_axis_tx_tdata_3_4, s_axis_tx_tlast_3_4, m_axis_rx_tdata_4_3, m_axis_rx_tlast_4_3, reset_tictoc_out);

import PSL_pkg :: *;

input reset;

input sys_clock_clk_n;
input sys_clock_clk_p;


// Regular design starts here
wire axi_clk;
wire bram_read_clk;
wire bram_read_clk_slow;
wire [num_pbits-1:0] s;

//tictoc counter
input logic reset_tictoc_in;
output logic reset_tictoc_out;
reg reset_tictoc;
wire [31:0] tictoc_counter_limit;

//flip_counter
wire reset_ref_counter;
wire reset_flip_counter;
wire enable_flip_counter;
wire [available_clocks*16-1:0] counter;

wire weight_load_DONE;
wire J_load_DONE;
wire h_load_DONE;


localparam clock_divider_bit_width = 32; //clock divider factor bit width
wire [clock_divider_bit_width-1:0] divider;  // Shared divider value for all clocks
wire ce;         // Shared clock enable signal for all clocks
wire [clock_divider_bit_width-1:0] divider_comm;  // Shared divider value for all clocks
wire ce_comm;         // Shared clock enable signal for all clocks
wire clock1_org, clock2_org, clock3_org, clock4_org, clock5_org;
wire clock1, clock2, clock3, clock4, clock5;

wire [j_bit_width-1:0] J_n [length_J_array-1:0];
wire [h_bit_width-1:0] h_n [length_h_array-1:0];

wire [j_bit_width-1:0]J_ram;
wire [j_bram_addr_bit_width-1:0] J_read_addr;
wire [h_bit_width-1:0]h_ram;
wire [h_bram_addr_bit_width-1:0] h_read_addr;

wire s_ram;
wire [s_bram_addr_bit_width-1:0] s_write_addr;
wire s_write_enb ;

  
wire GE; //global_enable
wire frozen; // flag to detect if p-bits are frozen after TICTOC time is elasped


//wire weight_read_trigger;
wire J_read_trigger;
wire h_read_trigger;



serialize_J sJ ( .axi_clk(axi_clk), .bram_read_clk(bram_read_clk), .J_read_trigger(J_read_trigger), .J_ram(J_ram), .J_read_addr(J_read_addr), .J_n(J_n), .J_load_DONE(J_load_DONE));
serialize_h sH ( .axi_clk(axi_clk), .bram_read_clk(bram_read_clk), .h_read_trigger(h_read_trigger), .h_ram(h_ram), .h_read_addr(h_read_addr), .h_n(h_n), .h_load_DONE(h_load_DONE));
tictoc_counter tc (.reset_tictoc(reset_tictoc), .tictoc_counter_limit(tictoc_counter_limit), .tictoc_clk(axi_clk), .global_enable(GE), .complete(frozen)); // this module doesn't depend on any other module or ref_counter

s_read_out sR (.bram_read_clk(bram_read_clk), .s(s), .s_ram(s_ram), .s_write_addr(s_write_addr), .s_write_enb(s_write_enb));


always @(posedge axi_clk) begin
    reset_tictoc <= reset_tictoc_in;
end
    
// Ethernet related ports
/*
 * Clock: 125MHz LVDS
 * Reset: Push button, active low
 */
input  wire       clk_125mhz_p;
input  wire       clk_125mhz_n;
/*
 * Ethernet: 1000BASE-T SGMII
 */
input  wire       phy_sgmii_rx_p;
input  wire       phy_sgmii_rx_n;
output wire       phy_sgmii_tx_p;
output wire       phy_sgmii_tx_n;
input  wire       phy_sgmii_clk_p;
input  wire       phy_sgmii_clk_n;
output wire       phy_reset_n;
input  wire       phy_int_n;
inout  wire       phy_mdio;
output wire       phy_mdc;

// SGMII interface to PHY
wire phy_gmii_clk_int;
wire phy_gmii_clk_en_int;
wire [7:0] phy_gmii_txd_int;
wire phy_gmii_tx_en_int;
wire phy_gmii_tx_er_int;
wire [7:0] phy_gmii_rxd_int;
wire phy_gmii_rx_dv_int;
wire phy_gmii_rx_er_int;


ethernet_wrapper ETH0 (
    .clk_125mhz_p(clk_125mhz_p),      .clk_125mhz_n(clk_125mhz_n),      .phy_sgmii_rx_p(phy_sgmii_rx_p),
    .phy_sgmii_rx_n(phy_sgmii_rx_n),  .phy_sgmii_tx_p(phy_sgmii_tx_p),  .phy_sgmii_tx_n(phy_sgmii_tx_n),
    .phy_sgmii_clk_p(phy_sgmii_clk_p),.phy_sgmii_clk_n(phy_sgmii_clk_n),.phy_reset_n(phy_reset_n),
    .phy_int_n(phy_int_n),            .phy_mdio(phy_mdio),               .phy_mdc(phy_mdc),
    .phy_gmii_clk_int(phy_gmii_clk_int), .phy_gmii_clk_en_int(phy_gmii_clk_en_int), .phy_gmii_txd_int(phy_gmii_txd_int),
    .phy_gmii_tx_en_int(phy_gmii_tx_en_int), .phy_gmii_tx_er_int(phy_gmii_tx_er_int), .phy_gmii_rxd_int(phy_gmii_rxd_int),
    .phy_gmii_rx_dv_int(phy_gmii_rx_dv_int), .phy_gmii_rx_er_int(phy_gmii_rx_er_int), .reset(reset)
);


// FMC related ports
output logic forwarded_clk_3_2;
input logic received_clk_2_3;     
//sender ports
output logic [DATA_WIDTH_FMC-1:0] s_axis_tx_tdata_3_2;
output logic s_axis_tx_tlast_3_2;
wire [TOTAL_NUM_PBITS_SENDING_3_2-1:0] pbits_packed_3_2;
//receiver ports
input logic [DATA_WIDTH_FMC-1:0] m_axis_rx_tdata_2_3;
input logic m_axis_rx_tlast_2_3;
wire [TOTAL_NUM_PBITS_RECEIVING_2_3-1:0] pbits_unpacked_2_3;

// FMC PLUS related ports
output logic forwarded_clk_3_4;
input logic received_clk_4_3;     
//sender ports
output logic [DATA_WIDTH_FMCPLUS-1:0] s_axis_tx_tdata_3_4;
output logic s_axis_tx_tlast_3_4;
wire [TOTAL_NUM_PBITS_SENDING_3_4-1:0] pbits_packed_3_4;
//receiver ports
input logic [DATA_WIDTH_FMCPLUS-1:0] m_axis_rx_tdata_4_3;
input logic m_axis_rx_tlast_4_3;
wire [TOTAL_NUM_PBITS_RECEIVING_4_3-1:0] pbits_unpacked_4_3;

     

design_1_wrapper wrapper
       (
        .J_ram(J_ram),
        .J_read_addr(J_read_addr),
        .axi_clk(axi_clk),
        .bram_read_clk(bram_read_clk),
        .ce_value_0(ce),
        .ce_comm_value_0(ce_comm),
        .clock1_0(clock1_org),
        .clock2_0(clock2_org),
        .clock3_0(clock3_org),
//        .clock4_0(clock4_org),
//        .clock5_0(clock5_org),
        .division_factor_comm_value_0(divider_comm),
        .division_factor_value_0(divider),
        .flip_counter_value_slv_0(counter),
        .frozen_value_0(frozen),
        .h_ram(h_ram),
        .h_read_addr(h_read_addr),
        .h_read_trigger_value_0(h_read_trigger),
        .j_read_trigger_value_0(J_read_trigger),
        .phy_rxclk_0(phy_gmii_clk_int),
        .phy_rxd_0(phy_gmii_rxd_int),
        .phy_rxdv_0(phy_gmii_rx_dv_int),
        .phy_rxer_0(phy_gmii_rx_er_int),
        .phy_txd_0(phy_gmii_txd_int),
        .phy_txen_0(phy_gmii_tx_en_int),
        .phy_txer_0(phy_gmii_tx_er_int),
        .txclk_en_0(phy_gmii_clk_en_int),
        .rxclk_en_0(phy_gmii_clk_en_int),
        .ref_clk_0(phy_gmii_clk_int),
        .reset(reset),
//        .reset_tictoc_value_0(reset_tictoc_matlab),
        .reset_ref_counter_value_0(reset_ref_counter),
        .s_ram(s_ram),
        .s_write_addr(s_write_addr),
        .s_write_enb(s_write_enb),
        .sys_clock_clk_n(sys_clock_clk_n),
        .sys_clock_clk_p(sys_clock_clk_p),
        .tictoc_counter_limit_value_0(tictoc_counter_limit),
        .weight_load_done_value_0(weight_load_DONE));
        
        
// Instantiate the clock divider
clock_divider #(
    .clock_divider_bit_width(clock_divider_bit_width)  // Pass the localparam value
) clock_div_inst (
    .clock1_org(clock1_org),
    .clock2_org(clock2_org),
    .clock3_org(clock3_org),
//    .clock4_org(clock4_org),
//    .clock5_org(clock5_org),
    .divider1(divider),    // Use the shared divider value
    .divider2(divider),    // Use the shared divider value
    .divider3(divider),    // Use the shared divider value
//    .divider4(divider),    // Use the shared divider value
//    .divider5(divider),    // Use the shared divider value
    .enable1(ce),          // Use the shared ce signal
    .enable2(ce),          // Use the shared ce signal
    .enable3(ce),          // Use the shared ce signal
//    .enable4(ce),          // Use the shared ce signal
//    .enable5(ce),          // Use the shared ce signal
    .clock1(clock1),
    .clock2(clock2),
    .clock3(clock3)
//    .clock4(clock4)
//    .clock5(clock5)
);

clock_divider #(
    .clock_divider_bit_width(clock_divider_bit_width)  // Pass the localparam value
) clock_div_inst_bram (
    .clock1_org(bram_read_clk),
    .divider1(divider_comm),    // Use the shared divider value
    .enable1(ce_comm),          // Use the shared ce signal
    .clock1(bram_read_clk_slow));
       
        
// FPGA 3
`include "pbits_FPGA3.txt"


// sender 3 to 4 (forward)
pack_pbits #(.DATA_WIDTH(DATA_WIDTH_FMCPLUS), .TOTAL_NUM_PBITS(TOTAL_NUM_PBITS_SENDING_3_4)) pk_3_4 (
    .clk(bram_read_clk_slow),
    .pbits(pbits_packed_3_4),
    .s_axis_tx_tdata(s_axis_tx_tdata_3_4),
    .s_axis_tx_tlast(s_axis_tx_tlast_3_4)
);

// sender 3 to 2 (reverse)
pack_pbits #(.DATA_WIDTH(DATA_WIDTH_FMC), .TOTAL_NUM_PBITS(TOTAL_NUM_PBITS_SENDING_3_2)) pk_3_2 (
    .clk(bram_read_clk_slow),
    .pbits(pbits_packed_3_2),
    .s_axis_tx_tdata(s_axis_tx_tdata_3_2),
    .s_axis_tx_tlast(s_axis_tx_tlast_3_2)
);

//receiver 2 to 3 (forward)
unpack_pbits #(.DATA_WIDTH(DATA_WIDTH_FMC), .TOTAL_NUM_PBITS(TOTAL_NUM_PBITS_RECEIVING_2_3)) unpk_2_3 (
    .clk(received_clk_2_3),
    .m_axis_rx_tdata(m_axis_rx_tdata_2_3),
    .m_axis_rx_tlast(m_axis_rx_tlast_2_3),
    .pbits(pbits_unpacked_2_3)
);

//receiver 4 to 3 (reverse)
unpack_pbits #(.DATA_WIDTH(DATA_WIDTH_FMCPLUS), .TOTAL_NUM_PBITS(TOTAL_NUM_PBITS_RECEIVING_4_3)) unpk_4_3 (
    .clk(received_clk_4_3),
    .m_axis_rx_tdata(m_axis_rx_tdata_4_3),
    .m_axis_rx_tlast(m_axis_rx_tlast_4_3),
    .pbits(pbits_unpacked_4_3)
);


// sender 3 to 4 (forward)
ODDR #(
    .DDR_CLK_EDGE("SAME_EDGE"), 
    .SRTYPE("ASYNC")
) oddr_inst_3_4 (
    .Q(forwarded_clk_3_4),  // Output to a pin configured in the constraints
    .C(bram_read_clk_slow),            // Clock input
    .CE(1'b1),          // Clock enable, always enabled
    .D1(1'b1),          // Data inputs for toggling
    .D2(1'b0),
    .R(1'b0),           // Reset, not used
    .S(1'b0)            // Set, not used
);


// sender 3 to 2 (reverse)
ODDR #(
    .DDR_CLK_EDGE("SAME_EDGE"), 
    .SRTYPE("ASYNC")
) oddr_inst_3_2 (
    .Q(forwarded_clk_3_2),  // Output to a pin configured in the constraints
    .C(bram_read_clk_slow),            // Clock input
    .CE(1'b1),          // Clock enable, always enabled
    .D1(1'b1),          // Data inputs for toggling
    .D2(1'b0),
    .R(1'b0),           // Reset, not used
    .S(1'b0)            // Set, not used
);


assign weight_load_DONE = J_load_DONE & h_load_DONE;

 
assign axi_clk = phy_gmii_clk_int;
assign reset_tictoc_out = reset_tictoc_in;


endmodule