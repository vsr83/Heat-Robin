function drawgeo(filename, rot, lcolor, scale);

if nargin < 3
    lcolor = 'k';
end
if nargin < 4
    scale = 1;
end

points = [];
lines = [];
arcs = [];

rmid = 0.07251;
xoff = 0;
rso = 0.11795;

fid = fopen(filename, 'r');

while ~feof(fid)
  so = readline(fid);    
  so(find(so==' ')) = [];
  s = so;

  for ind_s = 1:length(s)
    c = s(ind_s);

    if (c < '0' || c > '9') && c ~= '.' && c ~= '-'
      s(ind_s) = ' ';
    end 
  end
  
  if strncmp(so, 'Point', 5) == 1
    point = str2num(s);
    
    x = point(2);
    y = point(3)

    if x < 0.5
        %x = x+xoff;
    end
    
    phi = atan2(y, x);
    r = sqrt(x*x+y*y);
 
    if r < rmid
      phi = phi + rot;
    end
%    if r> ri && r < ro
%      phi = phi + dphi*(r-ri)/(gamma*delta);
%      r = ri + (r-ri)/gamma;
%    elseif r >= ro
%      r = r - (gamma)*delta;
%      phi = phi + dphi;
%    end
            
    point(2) = r*cos(phi);
    point(3) = r*sin(phi);
    
    
    points(point(1), :) = point(2:5);
  end
  if strncmp(so, 'Line(', 5) == 1
    line = str2num(s);
    lines(line(1), :) = line(2:3);
  end  
  if strncmp(so, 'Circle', 6) == 1
    line = str2num(s);
    if line(3) ~= 1
      arcs(line(1), :) = [line([2 3 4]) 0];
    end
  end  
  if strncmp(so, 'Ellipse', 7) == 1
    line = str2num(s);
    arcs(line(1), :) = line([2 3 4 5]);
  end  
end

fclose(fid);

lines
hold on
[nlines, tmp] = size(lines);
for ind_line = 1:nlines
  indp = lines(ind_line, 1:2);
  if indp(1) ~= 0
      indp
      points(indp, 1)
      points(indp, 2)
    plot(scale*points(indp, 1), scale*points(indp, 2), lcolor, 'LineWidth', 2);
  end
end
arcs

[narcs, tmp] = size(arcs);
for ind_line = 1:narcs
  indp = arcs(ind_line, 1:4);
     startp = indp(1);
   middlep = indp(2);

  if indp(1) ~= 0
   if indp(4) == 0
       endp = indp(3);
   else
       endp = indp(4);
   end
   disp 'foo'
   drawarc(points(startp, 1:2)*scale, scale*points(middlep, 1:2), scale*points(endp, 1:2), lcolor);
  end
end
phi = 0:0.01:6.29;
rso = 0.075;
rsi = 0.037;
rcu = 0.035;
rfe = 0.033;
delta = 0.45e-3;
%plot(rso*cos(phi), rso*sin(phi), 'k', 'LineWidth', 2);
%plot(rsi*cos(phi), rsi*sin(phi), 'k', 'LineWidth', 2);
%plot(rcu*cos(phi), rcu*sin(phi), 'k', 'LineWidth', 2);
%plot(rfe*cos(phi), rfe*sin(phi), 'k', 'LineWidth', 2);
%plot((rsi-delta)*cos(phi), (rsi-delta)*sin(phi), 'k', 'LineWidth', 1);
%colormap([zeros(63, 2), ones(63, 1)]);


end

function s = readline(fid)
    s = fgets(fid);
    s = s(1:(length(s)-1));
end
