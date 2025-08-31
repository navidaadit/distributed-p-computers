% =========================================================================
% writememory_with_retry
% Author: Navid Anjum Aadit (UC Santa Barbara, OPUS LAB)
% -------------------------------------------------------------------------
% Reliable Ethernet write with bounded retry.
%
% Inputs
%   fpga_mem   : AXI manager handle
%   address    : base address
%   data       : vector of words to write
%   burstType  : 'Fixed' or 'Increment'
%   maxRetries : maximum retry attempts
%   fpgaID     : identifier used in messages
% =========================================================================
function writememory_with_retry(fpga_mem, address, data, burstType, maxRetries, fpgaID)
success = false;
attempts = 0;
while ~success && attempts < maxRetries
    try
        writememory(fpga_mem, address, data, 'BurstType', burstType);
        success = true;
    catch
        attempts = attempts + 1;
        fprintf('Write memory attempt %d to FPGA %d failed. Retrying...\n', attempts, fpgaID);
    end
end
if ~success
    error('Failed to write to FPGA %d after %d attempts, please reprogram.', fpgaID, maxRetries);
end
end
