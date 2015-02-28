function I = addpoint(fid, I, x, y, m)
  I(1) = I(1) + 1;
  fprintf(fid, 'Point(%d) = {%f, %f, 0, mg*%f};\n', I(1), x, y, m);                
end
