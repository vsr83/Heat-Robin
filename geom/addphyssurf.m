function I = addphyssurf(fid, I, surfs)
  I = I + 1;
  s = sprintf('Physical Surface(%d) = {', I);                                   

  nsurfs = length(surfs);

  for ind_surf = 1:nsurfs
    s = sprintf('%s%d', s, surfs(ind_surf));                                    
    if ind_surf == nsurfs
      s = sprintf('%s};', s);                                                   
    else
      s = sprintf('%s, ', s);                                                   
    end
  end
  fprintf(fid, '%s\n', s);                                                      
end

