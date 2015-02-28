function I = addphysline(fid, I, lines)
  I = I + 1;
  s = sprintf('Physical Line(%d) = {', I);                                      

  nlines = length(lines);

  for ind_line = 1:nlines
    s = sprintf('%s%d', s, lines(ind_line));                                    
    if ind_line == nlines
      s = sprintf('%s};', s);                                                   
    else
      s = sprintf('%s, ', s);                                                   
    end
  end
  fprintf(fid, '%s\n', s);                                                      
end


