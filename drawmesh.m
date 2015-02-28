function drawmesh(M)
    figure(1);
    clf
    hold on
    axis equal
    
    for ind_node=1:M.num_nodes
        s = sprintf('%d', ind_node);
        %text(M.nodes(ind_node, 2), M.nodes(ind_node, 3), s);
    end
    
    
    nodeind = zeros(M.num_triangles, 3);
    for ind_tri = 1:M.num_triangles
        elem = M.elements{M.triangles(ind_tri)};
	nodeind(ind_tri, 1:3) = elem.nodes(1:3);
    end
    
    triplot(nodeind, M.nodes(:, 2), M.nodes(:, 3), 'c', 'LineWidth', 0.5);
end
