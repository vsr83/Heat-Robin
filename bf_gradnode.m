function val = bf_gradnode(ind, u, v)

switch(ind)
  case 1
    val = [-1;-1];
  case 2
    val = [1;0];
  case 3
    val = [0;1];
  case 4
    val = [1-v-2*u; -u];
  case 5
    val = [v; u];
  case 6
    val = [-v; 1-u-2*v];
  otherwise,
    error 'invalid node index'
end
