`timescale 1ns / 1ps

module unpack_pbits #(
    parameter DATA_WIDTH = 256,   // FMC interface data width
    parameter TOTAL_NUM_PBITS = 1024  // Total number of pbits
) (
    input wire clk,
    input wire [DATA_WIDTH-1:0] m_axis_rx_tdata,
    input wire m_axis_rx_tlast,
    output wire [TOTAL_NUM_PBITS-1:0] pbits
);
    localparam FRAME_COUNT = TOTAL_NUM_PBITS / DATA_WIDTH;

    reg [DATA_WIDTH-1:0] data_buffer[FRAME_COUNT-1:0];
    reg [DATA_WIDTH-1:0] temp_buffer;  // Temporary buffer to reduce fanout
    integer frame_index = 0;
    integer temp_frame_index = 0;


    logic m_axis_rx_tvalid = 1;

    always @(posedge clk) begin
        if (m_axis_rx_tvalid) begin
            temp_buffer <= m_axis_rx_tdata;  // Load data into temp buffer first
            temp_frame_index  <= frame_index;
            data_buffer[temp_frame_index] <= temp_buffer;  // Transfer temp buffer to data buffer
            if (m_axis_rx_tlast) begin
                // If it's the last frame, reset the frame_index
                frame_index <= 0;
            end else begin
                // If not the last frame, increment frame_index
                frame_index <= frame_index + 1;
            end
        end
    end

    // Assigning pbits using combinational logic
    generate
        genvar i;
        for(i=0; i<FRAME_COUNT; i=i+1) 
        begin : pbits_assign
            assign pbits[i*DATA_WIDTH +: DATA_WIDTH] = data_buffer[i];
        end
    endgenerate

endmodule
