function phys = stator_getphys(S, slotsurf)

phys = [];
[nsurf, tmp] = size(slotsurf);

for ind_surf = 1:nsurf
  slot = slotsurf(ind_surf, 1);
  surf = slotsurf(ind_surf, 2);
  phys = [phys; S.slot{slot}.physical(surf)];
end
