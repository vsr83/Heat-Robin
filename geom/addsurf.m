function I = addsurf(fid, I, loops)
  I(4) = I(4) + 1;
  s = sprintf('Plane Surface(%d) = {', I(4));                                   

  nloops = length(loops);

  for ind_loop = 1:nloops
    if ind_loop == nloops
      s = sprintf('%s%d};', s, loops(ind_loop));                                
    else
      s = sprintf('%s%d, ', s, loops(ind_loop));                                
    end
  end
  fprintf(fid, '%s\n', s);                                                      
end
