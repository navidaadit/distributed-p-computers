% =========================================================================
% readmemory_with_retry
% Author: Navid Anjum Aadit (UC Santa Barbara, OPUS LAB)
% -------------------------------------------------------------------------
% Reliable Ethernet read with bounded retry.
%
% Inputs
%   fpga_mem   : AXI manager handle
%   address    : base address
%   numWords   : number of words to read
%   burstType  : 'Fixed' or 'Increment'
%   maxRetries : maximum retry attempts
%   fpgaID     : identifier used in messages
%
% Output
%   data       : vector of words read
% =========================================================================
function data = readmemory_with_retry(fpga_mem, address, numWords, burstType, maxRetries, fpgaID)
success = false;
attempts = 0;
while ~success && attempts < maxRetries
    try
        data = readmemory(fpga_mem, address, numWords, 'BurstType', burstType);
        success = true;
    catch
        attempts = attempts + 1;
        fprintf('Read memory attempt %d from FPGA %d failed. Retrying...\n', attempts, fpgaID);
    end
end
if ~success
    error('Failed to read from FPGA %d after %d attempts, please reprogram.', fpgaID, maxRetries);
end
end
