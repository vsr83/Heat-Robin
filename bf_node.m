function val = bf_node(ind, u, v)

% The order here is according to 2nd order node ordering for GMsh
switch(ind)
  case 1
    val = 1-u-v;
  case 2
    val = u;
  case 3
    val = v;
  case 4
    val = (1-u-v)*u;
  case 5
    val = u*v;
  case 6
    val = (1-u-v)*v;
  otherwise,
    error 'invalid node index'
end
