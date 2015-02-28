function I = addarc2(fid, I, ind1, ind2, ind3)
  I(2) = I(2) + 1;
  fprintf(fid, 'Ellipse(%d) = {%d, %d, %d, %d};\n', I(2), ind1, ind2, ind2, ind\
3);                                                                             
end

