`timescale 1ns / 1ps
(* use_dsp = "yes" *) module weight (s_in0, s_in1, s_in2, s_in3, s_in4, s_in5, h_n, J_n0, J_n1, J_n2, J_n3, J_n4, J_n5, Iin);
import PSL_pkg :: *;

output reg[i_bit_width-1:0] Iin;
input [j_bit_width-1:0] J_n0, J_n1, J_n2, J_n3, J_n4, J_n5;
input [h_bit_width-1:0] h_n;
input s_in0, s_in1, s_in2, s_in3, s_in4, s_in5;

// Temporary ports 
// these are defined for sign extension of J's and h. This way there will be no overflow no matter what 
wire [j_bit_width-1+3:0] J_n0_temp, J_n1_temp, J_n2_temp, J_n3_temp, J_n4_temp, J_n5_temp;
wire [h_bit_width-1+3:0] h_temp;


assign J_n0_temp = {{3{J_n0[j_bit_width-1]}},J_n0};
assign J_n1_temp = {{3{J_n1[j_bit_width-1]}},J_n1};
assign J_n2_temp = {{3{J_n2[j_bit_width-1]}},J_n2};
assign J_n3_temp = {{3{J_n3[j_bit_width-1]}},J_n3};
assign J_n4_temp = {{3{J_n4[j_bit_width-1]}},J_n4};
assign J_n5_temp = {{3{J_n5[j_bit_width-1]}},J_n5};
assign h_temp =    {{3{h_n[h_bit_width-1]}},h_n};


reg  [h_bit_width-1+3:0] Iin_temp;
reg  [h_bit_width-1+3:0] nmin = 9'b111100001; //-15.5 in s[4+3][1]
reg  [h_bit_width-1+3:0] pmax = 9'b000011111; //15.5 in s[4+3][1]

always @*  begin

Iin_temp = (s_in0 ? J_n0_temp : -J_n0_temp) + (s_in1 ? J_n1_temp : -J_n1_temp) + (s_in2 ? J_n2_temp : -J_n2_temp) + (s_in3 ? J_n3_temp : -J_n3_temp) + (s_in4 ? J_n4_temp : -J_n4_temp) + (s_in5 ? J_n5_temp : -J_n5_temp) + h_temp;

    if ($signed(Iin_temp) > $signed(pmax))
        Iin <= 6'b011111; //15.5 in s[4][1]
    else if ($signed(Iin_temp) < $signed(nmin))
        Iin <= 6'b100001; //-15.5 in s[4][1]
    else
        Iin <= Iin_temp[i_bit_width-1:0];

end
endmodule