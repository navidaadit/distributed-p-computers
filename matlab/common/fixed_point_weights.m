% =========================================================================
% fixed_point_weights
% Author: Navid Anjum Aadit (UC Santa Barbara, OPUS LAB)
% -------------------------------------------------------------------------
% Scales binary J and h by β and quantizes them to fixed-point format [s]a.b.
%
% Inputs
%   fixed_a, fixed_b : fixed-point parameters ([s]a.b)
%   beta             : inverse temperature
%   J_binary         : coupling matrix (binary representation)
%   h_binary         : bias vector (binary representation)
%
% Outputs
%   J_fpga           : fixed-point couplings (fi)
%   h_fpga           : fixed-point biases (fi)
% =========================================================================
function [J_fpga,h_fpga] = fixed_point_weights (fixed_a, fixed_b, beta, J_binary, h_binary)

J_binary = beta*J_binary;
h_binary = beta*h_binary;

nmin = -2^fixed_a;                 % minimum representable value in [s]a.b
pmax = 2^fixed_a - 2^-fixed_b;     % maximum representable value in [s]a.b

if find(J_binary > pmax)
    fprintf('J_binary clipped to %f at beta = %f\n', pmax, beta);
end
if find(J_binary < nmin)
    fprintf('J_binary clipped to %f at beta = %f\n', nmin, beta); 
end
if find(h_binary > pmax)
    fprintf('h_binary clipped to %f at beta = %f\n', pmax, beta);
end
if find(h_binary < nmin)
    fprintf('h_binary clipped to %f at beta = %f\n', nmin, beta); 
end

J_fpga = fi(J_binary, 1, fixed_a+fixed_b+1, fixed_b);
h_fpga = fi(h_binary, 1, fixed_a+fixed_b+1, fixed_b);
end
