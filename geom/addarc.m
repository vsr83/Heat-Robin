function I = addarc(fid, I, ind1, ind2, ind3)
  I(2) = I(2) + 1;
  fprintf(fid, 'Circle(%d) = {%d, %d, %d};\n', I(2), ind1, ind2, ind3);         
end
