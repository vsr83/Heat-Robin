tic
r0 = 0.0725;                     % Outer radius of the rotor
Tenv = 20;                       % Temperature of the environment
meshfile = 'arkkio_rotor.msh';   % Filename of the mesh file
num_gauss = 12;                  % Number of gauss points
bforder = 1;                     % Order of the basis functions. 
dt = 1;                          % Time step size (in seconds)
num_timesteps = 10000;           % Number of time steps
visualize = false;               % Draw results during computation

% To obtain semi-reasonable results, a coefficient of convection was 
% taken from: 
% Howey, Childs, Holmes -  Air-Gap Convection in Rotating Electrical Machines
hconvection = 130;               % W/Km^2

% Analytical solution can be obtained easily when the whole rotor is given
% homogenous thermal conductivity and loss density.
analytical_test = false;

% Data structures related to the rotor slots are stored in data file 
% regiondata generated by code/arkkio_rotor.m
load regiondata;

if ~exist('M')
    disp 'Loading mesh file'
    toc    
    M = readmesh(meshfile);
end

slotarea = mesh_physarea(M, R.phys_wedges(1)) ...
         + mesh_physarea(M, R.phys_slots(1));
% At one percent slip, the loss per unit length is approximately 1kW/m.
% Thus, the loss density per unit length
Ptot = 1000;
peddy = (Ptot/(R.Q*slotarea));

% https://en.wikipedia.org/wiki/Heat_capacity                  (Iron)
% https://en.wikipedia.org/wiki/List_of_thermal_conductivities (Steel)
regions{R.phys_coresurface}.nu = 50;
regions{R.phys_coresurface}.sigma = 3.54e6;
regions{R.phys_coresurface}.type = 1;
regions{R.phys_coresurface}.Js = 0;
regions{R.phys_coresurface}.nl = false;

% https://en.wikipedia.org/wiki/Heat_capacity                  (Aluminium)
% https://en.wikipedia.org/wiki/List_of_thermal_conductivities (Aluminium)
clear reg_rbar
reg_rbar.nu = 204;
reg_rbar.sigma = 2.42e6;
reg_rbar.type = 1;
reg_rbar.Js = peddy;
reg_rbar.nl = false;

if analytical_test 
    regions{R.phys_coresurface} = reg_rbar;
end
    
reg_wedge = reg_rbar;
for ind_bar = 1:R.Q
    regions{R.phys_slots(ind_bar)} = reg_rbar;
    regions{R.phys_wedges(ind_bar)} = reg_wedge;
end

regions{R.phys_innerboundary}.type = 3;   % Gamma

disp 'Building the global stiffness and mass matrices.'
toc
if ~exist('Sg')
  [Sg, Mg] = stiff_global_gauss(M, regions, num_gauss, bforder);
end

disp 'Sorting the degrees of freedom.'
toc
if ~exist('SC')
    part = cell(1, 1);
    part{1}.name     = 'Rotor-Airgap Interface';
    part{1}.type     = 1;
    part{1}.physlist = R.phys_innerboundary;
    part{1}.priority = 1;
    part{1}.sorting  = 1;
    part{1}.sort_origin  = [0, 0];
    part{1}.sort_BForder = false;
    part{1}.sort_invert  = false;

    [SC,MC,part,freenodes,inds,permfull] = stiff_partition(M, part, Sg, Mg);
    
    S_FF = SC{1, 1}; S_FI = SC{1, 2};
    S_IF = SC{2, 1}; S_II = SC{2, 2};
    M_FF = MC{1, 1}; M_FI = MC{1, 2};
    M_IF = MC{2, 1}; M_II = MC{2, 2};
end

numF = length(SC{1, 1}); % The number of free nodes outside Gamma.
numI = length(SC{2, 2}); % The number of free nodes on Gamma.
nfun = 3*bforder;        % The number of nodes on each triangle.

disp 'Computing forcing vector.'
toc
F = forcing_mhquad(M, freenodes, regions, 1);

disp 'Computing line integrals.'
toc
G  = sparse(numI, numI);
G2 = sparse(numI, numI);
for ind_node = 1:numI
    ind_prev = mod(ind_node-2, numI)+1;
    ind_next = mod(ind_node, numI)+1;
    
    node_prev = part{1}.nodes(ind_prev, 1);
    node      = part{1}.nodes(ind_node, 1);
    node_next = part{1}.nodes(ind_next, 1);
    
    len_prev= norm(M.nodes(node_prev, 2:3) - M.nodes(node, 2:3))
    len_next= norm(M.nodes(node_next, 2:3) - M.nodes(node, 2:3));
           
    G(ind_node, ind_node) = hconvection*(len_prev/3 + len_next/3);
    G(ind_node, ind_next) = hconvection*(len_next)/6;
    G(ind_node, ind_prev) = hconvection*(len_prev)/6;
end

disp 'Assembly and solution.'
toc
TT = zeros(numF + numI, num_timesteps);
T0 = ones(numF + numI, 1)*Tenv;
Tmin = zeros(num_timesteps, 2);
Tavg = zeros(num_timesteps, 2);
Tmax = zeros(num_timesteps, 2);

for timestep = 1:num_timesteps
    A = [M_FF, M_FI; M_IF, M_II];
    B = [S_FF, S_FI; S_IF S_II+G];
    c = [F;G*ones(numI, 1)*Tenv];

    T = (A + dt*B)\(dt*c + A*T0);
    
    TT(:, timestep) = T;
    Tgamma = T(numF + (1:numI));
    
    Tmin(timestep, 1) = min(T);
    Tavg(timestep, 1) = sum(T)/(numI+numF);
    Tmax(timestep, 1) = max(T);

    Tmin(timestep, 2) = min(Tgamma);
    Tavg(timestep, 2) = sum(Tgamma)/numI;
    Tmax(timestep, 2) = max(Tgamma);

    % Values on the interface Gamma
    Tgamma = T(numF + (1:numI));
    disp(sprintf('\nTimestep %d/%d', timestep, ...
        num_timesteps));
    disp(sprintf('Global Min/Max Temperature       : %.3fC / %.3fC', ...
                min(T), max(T)));
    disp(sprintf('Min/Avg/Max Interface Temp: %.3fC / %.3fC / %.3fC', ...
                 min(Tgamma), sum(Tgamma)/numI, max(Tgamma)));
    
    T0 = T;
    if mod(timestep, 200) == 0 && visualize
        figure(1);
        drawsolution(T, M, freenodes);
        drawnow;
        colormap hot
        
        figure(2);
        clf
        hold on
        plot(dt*(1:timestep), Tmin(1:timestep, 1), 'b', 'LineWidth', 2);
        plot(dt*(1:timestep), Tavg(1:timestep, 1), 'g', 'LineWidth', 2);
        plot(dt*(1:timestep), Tmax(1:timestep, 1), 'r', 'LineWidth', 2);
        plot(dt*(1:timestep), Tmin(1:timestep, 2), 'b--', 'LineWidth', 2);
        plot(dt*(1:timestep), Tavg(1:timestep, 2), 'g--', 'LineWidth', 2);
        plot(dt*(1:timestep), Tmax(1:timestep, 2), 'r--', 'LineWidth', 2);
        xlim([0, num_timesteps]);
        xlabel 'Time (s)'
        ylabel 'Temperature (C)'
        drawnow;
    end
end


% Values on the interface Gamma
Tgamma = T(numF + (1:numI));
disp 'Post-processing:.'
toc
disp ' '
disp 'Global:'
disp(sprintf('Min/Max Temperature       : %.3fC / %.3fC', ...
              min(T), max(T)));
disp ' '
disp 'Interface:'
disp(sprintf('Min/Avg/Max Interface Temp: %.3fC / %.3fC / %.3fC', ...
              min(Tgamma), sum(Tgamma)/numI, max(Tgamma)));
disp(sprintf('Reference Temperature     : %.3fC', Tref0));
