function I = addloop(fid, I, lines)
  I(3) = I(3) + 1;
  s = sprintf('Line Loop(%d) = {', I(3));                                       

  nlines = length(lines);

  for ind_line = 1:nlines
    if ind_line == nlines
      s = sprintf('%s%d};', s, lines(ind_line));                                
    else
      s = sprintf('%s%d, ', s, lines(ind_line));                                
    end
  end
  fprintf(fid, '%s\n', s);                                                      
end

