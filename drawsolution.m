function drawsolution(a, M, freenodes)
%clf
ndof = length(a);
data = zeros(ndof, 3);

nfree = length(freenodes);

for ind_dof = 1:nfree
    ind_dof
  node = freenodes(ind_dof, 1);
  p = M.nodes(node, 2:3);
    
  if M.nodeorder(node) == 1 && a(ind_dof) >= min(a)
    data(ind_dof, :) = [p(1), p(2), a(ind_dof)];
  end
end
data((nfree+1:end), :) = [];

d = 1e-4;
rd = 0.073;
[X, Y] = meshgrid(-rd:d:rd, -rd:d:rd);
Z = griddata(data(:, 1), data(:, 2), data(:, 3), X, Y);

contourf(X, Y, Z);
colorbar

hold on
drawgeo('arkkio_rotor.geo', 0);
%drawgeo('arkkio_stator.geo', 0);
axis equal
r0 = 0.072725;
ro = 0.11795;
ra = 0.01;
theta = 0:0.01:6.29;
%plot(ro*cos(theta), ro*sin(theta), 'k', 'LineWidth', 2);
%plot(ra*cos(theta), ra*sin(theta), 'k', 'LineWidth', 2);
%plot([0, r0*cos(rot)], [0, r0*sin(rot)], 'r--', 'LineWidth', 2);
%plot([0, r0*cos(rot+pi/2)], [0, r0*sin(rot+pi/2)], 'r--', 'LineWidth', 2);

%text(0.03*cos(rot+0.4), 0.03*sin(rot+0.4), '$\Omega_r$', 'Interpreter', 'latex', 'FontSize', 16);
%text(0.1*cos(0.4), 0.1*sin(0.4), '$\Omega_s$', 'Interpreter', 'latex', 'FontSize', 16);


%clf
%h = image(-rd:d:rd, -rd:d:rd, real(Z))
%set(h, 'CDataMapping', 'scaled');
axis equal

