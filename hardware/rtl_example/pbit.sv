`timescale 1ns / 1ps
module pbit (GE, weight_load_DONE, clk, h_n, J_n0, J_n1, J_n2, J_n3, J_n4, J_n5, s_in0, s_in1, s_in2, s_in3, s_in4, s_in5, s_out);

import PSL_pkg :: *;

parameter [RNG_bit_width-1:0] seed = 32'b00100001101100001100011110000011;


input GE;
input clk;
input weight_load_DONE;

input [j_bit_width-1:0] J_n0, J_n1, J_n2, J_n3, J_n4, J_n5;
input [h_bit_width-1:0] h_n;
input s_in0, s_in1, s_in2, s_in3, s_in4, s_in5;
output reg s_out; 

logic [i_bit_width-1:0] Iin;
logic [i_bit_width-1:0] Iin_LUT;
logic [RNG_bit_width-1:0] LUT_out;
logic [RNG_bit_width-1:0] LFSR_out;

// Double-flop synchronization for GE and weight_load_DONE
(* ASYNC_REG = "TRUE" *) reg GE_sync1, GE_sync2;
(* ASYNC_REG = "TRUE" *) reg weight_load_DONE_sync1, weight_load_DONE_sync2;

always @(posedge clk) begin
    GE_sync1 <= GE;
    GE_sync2 <= GE_sync1;
    weight_load_DONE_sync1 <= weight_load_DONE;
    weight_load_DONE_sync2 <= weight_load_DONE_sync1;
end

weight weight_i (.s_in0(s_in0), .s_in1(s_in1), .s_in2(s_in2), .s_in3(s_in3), .s_in4(s_in4), .s_in5(s_in5), .h_n(h_n), .J_n0(J_n0), .J_n1(J_n1), .J_n2(J_n2), .J_n3(J_n3), .J_n4(J_n4), .J_n5(J_n5), .Iin(Iin));
LFSR_n  #(.seed(seed), .RNG_bit_width(RNG_bit_width)) LFSR_i(.clk(clk), .LFSR_out(LFSR_out));
LUT_bias Lut_i (.Iin(Iin_LUT[i_bit_width-2:0]), .Out(LUT_out));


// should this be triggered whenever we have a change in LUT_out, which changes whenever Input to the LUT changes
always @ (posedge clk) begin
    if (GE_sync2 == 1'b1 && weight_load_DONE_sync2 == 1'b1) begin

         if (Iin[i_bit_width-1]==0) begin // positive input
               if (LUT_out == LFSR_out) s_out = 1'b0; // zeroed at tie other than all 1, irrespective of sign of input
               else s_out = (LUT_out > LFSR_out) ? 1'b1 : 1'b0 ;
         end

         else if (Iin[i_bit_width-1]==1) begin //negative input
               if (LUT_out == LFSR_out) s_out = 1'b0; // zeroed at tie other than all 1, irrespective of sign of input
               else s_out = (LUT_out > LFSR_out) ? 1'b0 : 1'b1 ;
         end
    end
end

always@* begin
    if(Iin[i_bit_width-1]==1) Iin_LUT = -Iin; // 2's complement: exact same implementation happens (tested) Iin_LUT = ~Iin + 1'b1;
    else Iin_LUT = Iin;
end

endmodule