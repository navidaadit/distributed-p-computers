% =========================================================================
% get_triu_adjacency
% Author: Navid Anjum Aadit (UC Santa Barbara, OPUS LAB)
% -------------------------------------------------------------------------
% Builds indexing for the upper-triangular part of a symmetric adjacency/
% coupling matrix and a compact neighbor list with fixed width per node.
%
% Inputs
%   J_org             : original symmetric adjacency/coupling (sparse ok)
%   max_num_neighbors : maximum neighbors per node
%
% Outputs
%   triu_adjacency    : [num_pbits x max_num_neighbors] index table
%   J_indices         : index matrix mapping (i,j) -> flat upper-tri index
% =========================================================================
function [triu_adjacency, J_indices] = get_triu_adjacency(J_org, max_num_neighbors)

num_pbits = size(J_org, 1);
use_sparse = num_pbits > 100000;

if ~issparse(J_org)
    J_org = sparse(J_org);
end

J = triu(J_org);                    % keep upper triangle

counter = 1;
zero_counter = [];
triu_adjacency = zeros(num_pbits, max_num_neighbors);

if use_sparse
    J_indices = sparse(num_pbits, num_pbits);
else
    J_indices = zeros(num_pbits, num_pbits);
end

for i = 1:num_pbits
    n_neighbors = 1;

    % Existing links in lower half-column (mapped by J_indices)
    col_list = J(1:i, i);
    nz_col = find(col_list);
    for idx = 1:length(nz_col)
        j = nz_col(idx);
        triu_adjacency(i, n_neighbors) = J_indices(j, i);
        n_neighbors = n_neighbors + 1;
    end

    % New links in row i (strict upper triangle)
    row_list = J(i, i+1:end);
    nz_row = find(row_list);
    for idx = 1:length(nz_row)
        j = i + nz_row(idx);
        triu_adjacency(i, n_neighbors) = counter;
        J_indices(i, j) = counter;
        counter = counter + 1;
        n_neighbors = n_neighbors + 1;
    end

    % Pad to max_num_neighbors with a repeatable placeholder
    for k = n_neighbors:max_num_neighbors
        if isempty(zero_counter)
            triu_adjacency(i, k) = counter;
            zero_counter = counter;
            counter = counter + 1;
        else
            triu_adjacency(i, k) = zero_counter;
            zero_counter = [];
        end
    end
end
end
