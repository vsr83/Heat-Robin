function A = mesh_physarea(M, phys)

A = 0;
for ind_triangle = 1:M.num_triangles
  tphys = M.trianglephys(ind_triangle);
  if phys == tphys
    A = A + M.elements{M.triangles(ind_triangle)}.area;
  end
end