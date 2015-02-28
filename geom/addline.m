function I = addline(fid, I, ind1, ind2)
  I(2) = I(2) + 1;
  fprintf(fid, 'Line(%d) = {%d, %d};\n', I(2), ind1, ind2);                     
end
