function I = addlinepoint(fid, I, x, y, m)
  I = addpoint(fid, I, x, y, m);
  I = addline(fid, I, I(1)-1, I(1));
end

