`timescale 1ns / 1ps

module pack_pbits #(
    parameter DATA_WIDTH = 256,   // FMC interface data width
    parameter TOTAL_NUM_PBITS = 1024  // Total number of pbits
) (
    input wire clk,
    input wire [TOTAL_NUM_PBITS-1:0] pbits,
    output reg [DATA_WIDTH-1:0] s_axis_tx_tdata,
    output reg s_axis_tx_tlast
);
    localparam FRAME_COUNT = TOTAL_NUM_PBITS / DATA_WIDTH;

    integer frame_index = 0;
    integer bit_index = 0;  // Tracks the starting bit for each frame

    always @(posedge clk) begin
        // Assign the current frame data by using bit_index instead of multiplication
        s_axis_tx_tdata <= pbits[bit_index +: DATA_WIDTH];

        // Assert tlast on the last frame
        s_axis_tx_tlast <= (frame_index == FRAME_COUNT-1) ? 1'b1 : 1'b0;

        // Increment bit_index by DATA_WIDTH instead of multiplying frame_index
        if (frame_index < FRAME_COUNT-1) begin
            frame_index <= frame_index + 1;
            bit_index <= bit_index + DATA_WIDTH;  // Increment by DATA_WIDTH
        end else begin
            frame_index <= 0;
            bit_index <= 0;  // Reset the bit index for the next cycle
        end
    end
    
endmodule
