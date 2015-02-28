function [Sg, Mg] = stiff_global_gauss(M, regions, order, bforder)

gaussdata;
if nargin < 4
  bforder = 2;
end
if nargin < 3
  order = 6;
end

G = GAUSS{order};
X = G(:, 1); Y = G(:, 2); W = G(:, 3);

% Number of gauss points
npoints = length(W);
nfun = 3 * bforder;

CSe = cell(M.num_triangles, 1);
CMe = cell(M.num_triangles, 1);
SgL = zeros(M.num_triangles*(nfun^2), 3);
MgL = zeros(M.num_triangles*(nfun^2), 3);
ind_l = 0;

% Organize the values of the basis functions and their gradients into
% an matrix/array.
BF = zeros(nfun, npoints);
BFg = zeros(2, nfun, npoints);

for ind_BF = 1:nfun
  for ind_point = 1:npoints
    u = X(ind_point);
    v = Y(ind_point);
    BF(ind_BF, ind_point) = bf_node(ind_BF, u, v);
    BFg(:, ind_BF, ind_point) = bf_gradnode(ind_BF, u, v);
  end
end

for ind_triangle = 1:M.num_triangles
  tri = M.elements{M.triangles(ind_triangle)};
  nnodes = length(tri.nodes);
  
  % Corner points of the triangle tri.
  P = M.nodes(tri.nodes, 2:3);
  x1 = P(1, 1); y1 = P(1, 2);
  x2 = P(2, 1); y2 = P(2, 2);
  x3 = P(3, 1); y3 = P(3, 2);
  
  sigma = regions{tri.physical}.sigma;
  if isfield(tri, 'nu')
      nu = tri.nu;
  else
    nu = regions{tri.physical}.nu;
    if length(nu) == 1
        nu = nu*ones(npoints, 1);
    end
  end

  % The Jacobian term for the transformation of the gradients.
  Jterm = inv(tri.Je)*inv(tri.Je');
  invJ = inv(tri.Je);
  
  % Element stiffness- and mass matrices
  Se = zeros(3 * bforder);
  Me = zeros(3 * bforder);

  % Compute element stiffnes- and mass matrices.
  for ind_point = 1:npoints
    FVALUE = BF(:, ind_point)*BF(:, ind_point)';
    FGRADVALUE = BFg(:, :, ind_point)' * Jterm * BFg(:, :, ind_point);

    Me = Me + abs(det(tri.Je)) * W(ind_point) * sigma * FVALUE;
    Se = Se + abs(det(tri.Je)) * W(ind_point) * nu(ind_point) * FGRADVALUE;    
  end
  CSe{ind_triangle} = Se;
  CMe{ind_triangle} = Me;
  
  % Assemble list of contributions to the elements of the global stiffness
  % and mass matrices.
  for ind_row = 1:nfun
  	globrow = tri.nodes(ind_row);
    for ind_col = 1:nfun
        ind_l = ind_l + 1;
     	  globcol = tri.nodes(ind_col);        
          SgL(ind_l, 1:3) = [globrow, globcol, Se(ind_row, ind_col)];
          MgL(ind_l, 1:3) = [globrow, globcol, Me(ind_row, ind_col)];
    end
  end
end

SgL(find(SgL(:, 1)==0), :) = [];
MgL(find(MgL(:, 1)==0), :) = [];

% Convert the lists to a sparse matrices.
Sg = sparse(SgL(:, 1), SgL(:, 2), SgL(:, 3), M.num_nodes, M.num_nodes);
Mg = sparse(MgL(:, 1), MgL(:, 2), MgL(:, 3), M.num_nodes, M.num_nodes);
