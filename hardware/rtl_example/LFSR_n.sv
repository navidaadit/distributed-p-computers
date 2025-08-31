`timescale 1ns / 1ps
module LFSR_n (clk, LFSR_out);
  parameter RNG_bit_width=2; 
  parameter [RNG_bit_width-1:0] seed = 32'b00100001101100001100011110000001;
  
  input clk;
  output [RNG_bit_width-1:0] LFSR_out;

 
  reg [RNG_bit_width:1] r_LFSR = 0;
  reg  feedback;
 
 
initial r_LFSR = seed;

 
  // Create Feedback Polynomials.  Based on Application Note:
  // http://www.xilinx.com/support/documentation/application_notes/xapp052.pdf
 always @(*)
    begin
      case (RNG_bit_width)
        3: begin
          feedback = r_LFSR[3] ^~ r_LFSR[2];
        end
        4: begin
          feedback = r_LFSR[4] ^~ r_LFSR[3];
        end
        5: begin
          feedback = r_LFSR[5] ^~ r_LFSR[3];
        end
        6: begin
          feedback = r_LFSR[6] ^~ r_LFSR[5];
        end
        7: begin
          feedback = r_LFSR[7] ^~ r_LFSR[6];
        end
        8: begin
          feedback = r_LFSR[8] ^~ r_LFSR[6] ^~ r_LFSR[5] ^~ r_LFSR[4];
        end
        9: begin
          feedback = r_LFSR[9] ^~ r_LFSR[5];
        end
        10: begin
          feedback = r_LFSR[10] ^~ r_LFSR[7];
        end
        11: begin
          feedback = r_LFSR[11] ^~ r_LFSR[9];
        end
        12: begin
          feedback = r_LFSR[12] ^~ r_LFSR[6] ^~ r_LFSR[4] ^~ r_LFSR[1];
        end
        13: begin
          feedback = r_LFSR[13] ^~ r_LFSR[4] ^~ r_LFSR[3] ^~ r_LFSR[1];
        end
        14: begin
          feedback = r_LFSR[14] ^~ r_LFSR[5] ^~ r_LFSR[3] ^~ r_LFSR[1];
        end
        15: begin
          feedback = r_LFSR[15] ^~ r_LFSR[14];
        end
        16: begin
          feedback = r_LFSR[16] ^~ r_LFSR[15] ^~ r_LFSR[13] ^~ r_LFSR[4];
          end
        17: begin
          feedback = r_LFSR[17] ^~ r_LFSR[14];
        end
        18: begin
          feedback = r_LFSR[18] ^~ r_LFSR[11];
        end
        19: begin
          feedback = r_LFSR[19] ^~ r_LFSR[6] ^~ r_LFSR[2] ^~ r_LFSR[1];
        end
        20: begin
          feedback = r_LFSR[20] ^~ r_LFSR[17];
        end
        21: begin
          feedback = r_LFSR[21] ^~ r_LFSR[19];
        end
        22: begin
          feedback = r_LFSR[22] ^~ r_LFSR[21];
        end
        23: begin
          feedback = r_LFSR[23] ^~ r_LFSR[18];
        end
        24: begin
          feedback = r_LFSR[24] ^~ r_LFSR[23] ^~ r_LFSR[22] ^~ r_LFSR[17];
        end
        25: begin
          feedback = r_LFSR[25] ^~ r_LFSR[22];
        end
        26: begin
          feedback = r_LFSR[26] ^~ r_LFSR[6] ^~ r_LFSR[2] ^~ r_LFSR[1];
        end
        27: begin
          feedback = r_LFSR[27] ^~ r_LFSR[5] ^~ r_LFSR[2] ^~ r_LFSR[1];
        end
        28: begin
          feedback = r_LFSR[28] ^~ r_LFSR[25];
        end
        29: begin
          feedback = r_LFSR[29] ^~ r_LFSR[27];
        end
        30: begin
          feedback = r_LFSR[30] ^~ r_LFSR[6] ^~ r_LFSR[4] ^~ r_LFSR[1];
        end
        31: begin
          feedback = r_LFSR[31] ^~ r_LFSR[28];
        end
        32: begin
          feedback = r_LFSR[32] ^~ r_LFSR[22] ^~ r_LFSR[2] ^~ r_LFSR[1];
        end
 
      endcase // case (RNG_bit_width)
    end // always @ (*)
    
    always @(posedge clk)
    begin r_LFSR <= {r_LFSR[RNG_bit_width:1], feedback};
    end
 
  assign LFSR_out = r_LFSR[RNG_bit_width:1];
 
 
endmodule // LFSR