function drawarc(startp, middlep, endp, lcolor)

if nargin < 4
    lcolor = 'k';
end

%plot(startp(1), startp(2), 'rx');
%plot(endp(1), endp(2), 'b^');
%plot(middlep(1), middlep(2), 'go');

pstart = startp - middlep;
pend = endp - middlep;

r0 = norm(pstart);
r1 = norm(pend);

phi1 = atan2(pstart(2), pstart(1));
phi0 = atan2(pend(2), pend(1));

if phi0 < 0
  phi0 = phi0 + 2*pi;
end
if phi1 < 0
  phi1 = phi1 + 2*pi;
end

if phi0 > phi1
  tmp = phi0;
  phi0 = phi1;
  phi1 = tmp;
end
if phi1 - phi0 > pi
  phi1 = phi1 - 2*pi;
  tmp = phi0;
  phi0 = phi1;
  phi1 = tmp;
end

%r0+r1;

%if r0+r1 < 0.04

  dphi = (phi1 - phi0)/50;
  phi = phi0:dphi:phi1;
  plot(middlep(1) + r0*cos(phi), middlep(2) + r0*sin(phi), lcolor, 'LineWidth', 2);
%end