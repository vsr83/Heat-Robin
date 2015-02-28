function S = gmsh_slotgeom(S, filename)

S.filename = filename;

alpha_sm= 2*pi/S.Q;     % Mechanical degrees per slot
alpha_s = pi*S.P/S.Q;   % Electrical degrees per slot

if ~isfield(S, 'alpha0')
    S.alpha0 = 0;
end

if ~isfield(S, 'normsign')
    S.normsign = 1;
end

fid = fopen(filename, 'w');
I = S.Istart;
Ip = S.Ipstart;

fprintf(fid, 'mg = 1;\n');
I = addpoint(fid, I, S.xoff+0, 0, 0.1);
%I = addpoint(fid, I, S.xoff-S.gapr, 0, S.gapm);
%I = addpoint(fid, I, S.xoff+S.gapr, 0, S.gapm);
%I = addarc(fid, I, I(1)-1, I(1)-2, I(1)); 
%I = addarc(fid, I, I(1), I(1)-2, I(1)-1); 

addcomment(fid, 'gaploop');
%I = addloop(fid, I, [I(2)-1 I(2)]); gaploop = I(3);
%Ip = addphysline(fid, Ip, [I(2)-1 I(2)]); S.phys_airgapline = Ip;
S.Istart = I;
S.Ipstart = Ip;


innerlines = [];
S.boundarylines = [];
I = addpoint(fid, I, S.xoff, 0, 2e-3);centerpoint = I(1);
S.centerpoint = I(1);

for ind_slot = 1:S.Q
  alpha_m = ind_slot * alpha_sm + S.alpha0;

  alpha_midm = alpha_m + S.midangle;
  nu = [cos(alpha_midm) sin(alpha_midm)]*S.normsign;
  tu = -[-sin(alpha_midm) cos(alpha_midm)];

  [npoints, tmp] = size(S.slot_points);
  [nlines, tmp]  = size(S.slot_lines);
  [nloops]       = length(S.slot_loops);
  [nsurf]        = length(S.slot_surfaces);

  S.slot{ind_slot} = {};

  p = S.ri * [cos(alpha_m), sin(alpha_m)];
  I = addpoint(fid, I, p(1) + S.xoff, p(2), S.mi/2);


  if ind_slot > 1
    if isfield(S, 'slot_startpoint')
      I = addarc(fid, I, I(1) + S.slot_endpoint, S.centerpoint, ...
                 I(1) + S.slot_startpoint);
    else
      I = addarc(fid, I, startpoint+S.slot_endpoint, S.centerpoint, I(1));
    end
    innerlines = [innerlines; I(2)];
    S.boundarylines = [S.boundarylines; I(2)];
  end
  startpoint = I(1);
  startline = I(2);

  for ind_point = 1:npoints
    p = p + S.slot_points(ind_point, 1)*tu + S.slot_points(ind_point, 2)*nu;
    I = addpoint(fid, I, p(1) + S.xoff, p(2), S.mi*S.slot_points(ind_point, 3));
  end  
  endpoint = I(1);

  for ind_line = 1:nlines
    startindex = S.slot_lines(ind_line, 1);
    endindex   = S.slot_lines(ind_line, 2);
    centerindex= S.slot_lines(ind_line, 3);

    if centerindex == 0
      I = addline(fid, I, startpoint + startindex, startpoint + endindex);
    else
      I = addarc(fid, I, startpoint + startindex, startpoint + centerindex, startpoint + endindex);
    end
  end
  innerlines = [innerlines; -(sign(S.inner_lines))...
                            .*(startline + abs(S.inner_lines))];
  S.boundarylines = [S.boundarylines; startline+S.slot_boundary_lines];

  startloop = I(3);
  for ind_loop = 1:nloops
    loop = S.slot_loops{ind_loop};
    loop = loop + sign(loop)*startline;

    I = addloop(fid, I, loop);
  end
  S.slot{ind_slot}.surfaces = [];
  for ind_surf = 1:nsurf
    surf = S.slot_surfaces{ind_surf} + startloop;
    I = addsurf(fid, I, surf);
    S.slot{ind_slot}.surfaces(ind_surf) = I(4);
  end
end
I = addarc(fid, I, startpoint+S.slot_endpoint, S.centerpoint, centerpoint+1);
innerlines = [innerlines; I(2)];
S.boundarylines = [S.boundarylines; I(2)];

if S.ro > 0
    I = addpoint(fid, I, S.xoff-S.ro, 0, S.mo*3);
    I = addpoint(fid, I, S.xoff+S.ro, 0, S.mo*3);
    I = addarc(fid, I, I(1)-1, S.centerpoint, I(1));
    I = addarc(fid, I, I(1), S.centerpoint, I(1)-1);
    S.outerlines = [I(2)-1 I(2)]
else
    S.outerlines = [];
end
S.innerlines = innerlines;

addcomment(fid, 'loop_innerlines');
I = addloop(fid, I, S.innerlines); S.loop_innerlines = I(3);
addcomment(fid, 'loop_boundarylines');
I = addloop(fid, I, S.boundarylines); S.loop_boundarylines = I(3);
addcomment(fid, 'loop_outerlines');
if S.normsign == 1
    I = addloop(fid, I, S.outerlines); S.loop_outerlines = I(3);
    I = addsurf(fid, I, [S.loop_outerlines, S.loop_boundarylines]);
    S.coresurface = I(4);
    I = addsurf(fid, I, [S.loop_boundarylines]);
    S.coresurface2 = I(4);
else
    I = addloop(fid, I, S.outerlines); S.loop_outerlines = I(3);
    I = addsurf(fid, I, [S.loop_boundarylines, S.loop_outerlines]);
    S.coresurface = I(4);
    I = addsurf(fid, I, [S.loop_outerlines]);
    S.coresurface2 = I(4);
end
% Add physical groups

addcomment(fid, 'Core Surface');
Ip = addphyssurf(fid, Ip, [S.coresurface, S.coresurface2]); S.phys_coresurface = Ip;
%if S.normsign == 1
    %addcomment(fid, 'Outer boundary'); 
    %Ip = addphysline(fid, Ip, S.outerlines); S.phys_outerboundary = Ip;
%end
addcomment(fid, 'Inner boundary of the -');
%Ip = addphysline(fid, Ip, S.innerlines); S.phys_innerboundary = Ip;

addcomment(fid, 'SLOTS');
for ind_slot = 1:S.Q
  surflist = S.slot{ind_slot}.surfaces;
  nsurf = length(surflist);
  
  phys = [];
  for ind_surf = 1:nsurf
    Ip = addphyssurf(fid, Ip, surflist(ind_surf));
    phys(ind_surf) = Ip;
  end
  S.slot{ind_slot}.physical = phys;
end

%addcomment(fid, 'Half of the air gap');
%I = addsurf(fid, I, [S.loop_innerlines gaploop]);
%Ip = addphyssurf(fid, Ip, I(4));
%S.phys_airgap = Ip;
Ip = addphysline(fid, Ip, S.innerlines); S.phys_innerboundary = Ip;

fclose(fid); 

end

