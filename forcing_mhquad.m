function [F, ab] = forcing_mhquad(M, MasterNodes, regions, num_eta)

nmaster = length(MasterNodes);
ff = zeros(nmaster, num_eta);

for ind_master = 1:nmaster
     nodetri = M.nodetri{MasterNodes(ind_master)};
    
    for ind_tri = 1:length(nodetri)
      tri = M.elements{M.triangles(nodetri(ind_tri))};
      ind_node = find(tri.nodes == MasterNodes(ind_master));
      if length(ind_node) ~= 1
        error 'Node not found!';
      end
      if ind_node < 4
        ff(ind_master, :) = ff(ind_master, :) ...
                          + tri.area * regions{tri.physical}.Js / 3;
      else
        ff(ind_master, :) = ff(ind_master, :) ...
                          + tri.area * regions{tri.physical}.Js / 12;
      end
    end
end
F =  ff;
