package PSL_pkg;

    localparam j_bit_width = 6; // single weight bit width
    localparam h_bit_width = 6; // single h bit width
    localparam i_bit_width = 6; // single input bit width

    localparam j_bram_addr_bit_width = 17; // address bit width of J BRAM
    localparam h_bram_addr_bit_width = 15; // address bit width of h BRAM
    localparam s_bram_addr_bit_width = 20; // address bit width of s BRAM

    localparam RNG_bit_width = 32; // LUT_out and xoshiro_out bit width
    localparam num_pbits = 50653; // total actual number of p-bits
    localparam length_J_array = 26734;
    localparam length_h_array = 8442;
    localparam available_clocks = 3;
    localparam W_R_clk_ratio = 3; // ratio between axi write clk and BRAM read clk frequency

    localparam DATA_WIDTH_FMC = 30; // FMC data width in each direction
    localparam DATA_WIDTH_FMCPLUS = 54; // FMC Plus data width in each direction

    // Parameters for communication from FPGA 2 to FPGA 3
    localparam actual_num_pbits_sending_2_3 = 1369; // number of p-bits we want to actually send
    localparam TOTAL_NUM_PBITS_SENDING_2_3 = ((actual_num_pbits_sending_2_3 + DATA_WIDTH_FMC - 1) / DATA_WIDTH_FMC) * DATA_WIDTH_FMC; // total number of p-bits sending (ceiling close to multiple of DATA_WIDTH)

    localparam actual_num_pbits_receiving_3_2 = 1369; // number of p-bits we want to actually receive
    localparam TOTAL_NUM_PBITS_RECEIVING_3_2 = ((actual_num_pbits_receiving_3_2 + DATA_WIDTH_FMC - 1) / DATA_WIDTH_FMC) * DATA_WIDTH_FMC; // total number of p-bits receiving (ceiling close to multiple of DATA_WIDTH)

    // Parameters for communication from FPGA 3 to FPGA 2
    localparam actual_num_pbits_sending_3_2 = 1369; // number of p-bits we want to actually send
    localparam TOTAL_NUM_PBITS_SENDING_3_2 = ((actual_num_pbits_sending_3_2 + DATA_WIDTH_FMC - 1) / DATA_WIDTH_FMC) * DATA_WIDTH_FMC; // total number of p-bits sending (ceiling close to multiple of DATA_WIDTH)

    localparam actual_num_pbits_receiving_2_3 = 1369; // number of p-bits we want to actually receive
    localparam TOTAL_NUM_PBITS_RECEIVING_2_3 = ((actual_num_pbits_receiving_2_3 + DATA_WIDTH_FMC - 1) / DATA_WIDTH_FMC) * DATA_WIDTH_FMC; // total number of p-bits receiving (ceiling close to multiple of DATA_WIDTH)

    // Parameters for communication from FPGA 3 to FPGA 4
    localparam actual_num_pbits_sending_3_4 = 1369; // number of p-bits we want to actually send
    localparam TOTAL_NUM_PBITS_SENDING_3_4 = ((actual_num_pbits_sending_3_4 + DATA_WIDTH_FMCPLUS - 1) / DATA_WIDTH_FMCPLUS) * DATA_WIDTH_FMCPLUS; // total number of p-bits sending (ceiling close to multiple of DATA_WIDTH)

    localparam actual_num_pbits_receiving_4_3 = 1369; // number of p-bits we want to actually receive
    localparam TOTAL_NUM_PBITS_RECEIVING_4_3 = ((actual_num_pbits_receiving_4_3 + DATA_WIDTH_FMCPLUS - 1) / DATA_WIDTH_FMCPLUS) * DATA_WIDTH_FMCPLUS; // total number of p-bits receiving (ceiling close to multiple of DATA_WIDTH)

    // Parameters for communication from FPGA 4 to FPGA 3
    localparam actual_num_pbits_sending_4_3 = 1369; // number of p-bits we want to actually send
    localparam TOTAL_NUM_PBITS_SENDING_4_3 = ((actual_num_pbits_sending_4_3 + DATA_WIDTH_FMCPLUS - 1) / DATA_WIDTH_FMCPLUS) * DATA_WIDTH_FMCPLUS; // total number of p-bits sending (ceiling close to multiple of DATA_WIDTH)

    localparam actual_num_pbits_receiving_3_4 = 1369; // number of p-bits we want to actually receive
    localparam TOTAL_NUM_PBITS_RECEIVING_3_4 = ((actual_num_pbits_receiving_3_4 + DATA_WIDTH_FMCPLUS - 1) / DATA_WIDTH_FMCPLUS) * DATA_WIDTH_FMCPLUS; // total number of p-bits receiving (ceiling close to multiple of DATA_WIDTH)

endpackage : PSL_pkg

//End of partition 3 
