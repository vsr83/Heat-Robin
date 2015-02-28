function addregion(fid, name, phys)
  s = sprintf('%s = Region[{', name);  
  nphys = length(phys);
  
  for ind_phys = 1:nphys
    s = sprintf('%s%d', s, phys(ind_phys));
    if ind_phys == nphys
      s = sprintf('%s}];', s);
    else
      s = sprintf('%s, ', s);
    end
  end
  disp(s)
  fprintf(fid, '%s\n', s);
end
