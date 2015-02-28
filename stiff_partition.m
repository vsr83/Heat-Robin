function [SC, MC, part, freenodes, inds, permfull] = ...
         stiff_partition(M, part, Sg, Mg)

num_partitions = length(part);

% Divide nodes of the mesh M into partitions according to physical list.
% If two partitions are associated to a given node, the node is given to
% the partition with higher priority. If two partitions associated to 
% a node have equal priority, the node is made free. This is appropriate
% for the node in the intersection of two symmetry lines.

nodespart = zeros(M.num_nodes, 2);
physlistt = [];
for ind_node = 1:M.num_nodes
    nodephys = M.nodephys{ind_node};
    
    for ind_part = 1:num_partitions
        physlist = part{ind_part}.physlist;
        
        if ~isempty(intersect(physlist, nodephys)) 
            if part{ind_part}.priority > nodespart(ind_node, 2)
                nodespart(ind_node, :) = [ind_part, part{ind_part}.priority];
            elseif part{ind_part}.priority == nodespart(ind_node, 2)
                nodespart(ind_node, :) = [0 0];
            end
        end
    end
end

% Initialize the permutation matrix used for rearraging the degrees of 
% freedom.
permfull = sparse(M.num_nodes, M.num_nodes);

% Free nodes are the nodes not associated to any Physical Line or Physical
% Surface. They are given the lowest indices. The remaining degrees of
% freedom are first sorted according to partition number. Nodes within
% each partition are sorted according to the rule given in part{}.sorting.

freenodes = find(nodespart(:, 1) == 0);
for ind_node = 1:length(freenodes)
    permfull(ind_node, freenodes(ind_node)) = 1;
end

ind0 = length(freenodes);

% The array inds contains the first and last DoF number of each partition.
inds = zeros(num_partitions + 1, 2);
inds(1, 1) = 1;
inds(1, 2) = ind0;

ind0 = ind0 + 1;

for ind_part = 1:num_partitions
    part{ind_part}.nodes = find(nodespart(:, 1) == ind_part);
    part{ind_part}.num_nodes = length(part{ind_part}.nodes);

    nodes = part{ind_part}.nodes;
    nodes = [nodes, 0*nodes, 0*nodes];
    nodes(:, 3) = M.nodeorder(nodes(:, 1)) * part{ind_part}.sort_BForder;

    p = M.nodes(nodes(:, 1), 2:3);
    p(:, 1) = p(:, 1) - part{ind_part}.sort_origin(1);
    p(:, 2) = p(:, 2) - part{ind_part}.sort_origin(2);
    
    switch part{ind_part}.sorting
        case 1 % Angle
            nodes(:, 2) = atan2(p(:, 2), p(:, 1));
        case 2 % Radial
            nodes(:, 2) = abs(p(:, 1).^2 + p(:, 2).^2);
        case 3
            nodes(:, 2) = p(:, 1);
        case 4
            nodes(:, 2) = p(:, 2);
        otherwise
    end
    nodes = sortrows(nodes, [3 2]);
    part{ind_part}.permlist = nodes(:, 1);

    for ind_node = 1:part{ind_part}.num_nodes
        permfull(ind0 + ind_node - 1, nodes(ind_node, 1)) = 1;
    end
    
    part{ind_part}.nodes = nodes;
    ind1 = ind0 + part{ind_part}.num_nodes;
    inds(ind_part + 1, :) = [ind0, ind1-1];
    ind0 = ind1;
end

% Construct the sorted global stiffness and mass matrices.

Sg_resorted = permfull*Sg*permfull';
Mg_resorted = permfull*Mg*permfull';

% Divide the new global matrices into cell arrays.

SC = cell(num_partitions + 1);
MC = cell(num_partitions + 1);

for ind_partr = 1:num_partitions+1
    for ind_partc = 1:num_partitions+1
        SC{ind_partr, ind_partc} = ...
        Sg_resorted(inds(ind_partr, 1):inds(ind_partr, 2), ...
                    inds(ind_partc, 1):inds(ind_partc, 2));
        MC{ind_partr, ind_partc} = ...
        Mg_resorted(inds(ind_partr, 1):inds(ind_partr, 2), ...
                    inds(ind_partc, 1):inds(ind_partc, 2));
    end
end
