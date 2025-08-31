% =========================================================================
% triu_weight_converter
% Author: Navid Anjum Aadit (UC Santa Barbara, OPUS LAB)
% -------------------------------------------------------------------------
% Flattens a symmetric bipolar weight matrix using the precomputed upper-
% triangle index map and returns a serial load vector for FPGA, along with
% the (column) bias vector.
%
% Inputs
%   J_bipolar         : bipolar couplings (symmetric)
%   h_bipolar         : bipolar biases
%   J_indices         : index map from get_triu_adjacency
%   max_num_neighbors : maximum neighbors per node
%
% Outputs
%   J_bipolar_reshaped: serial vector of upper-triangular couplings
%   h_bipolar         : column bias vector
% =========================================================================
function [J_bipolar_reshaped, h_bipolar] = triu_weight_converter(J_bipolar, h_bipolar, J_indices, max_num_neighbors)

Jit = J_indices.';                       % transpose for linear addressing
b = Jit > 0;
J_bipolar_reshaped = zeros(1, ceil(0.5*length(J_bipolar)*max_num_neighbors));
J_bipolar_reshaped(Jit(b)) = J_bipolar(b);

h_bipolar = h_bipolar(:);               % ensure column vector
end
