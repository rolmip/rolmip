% Example 24. Shift both independent parameter simplexes.
A = {{[1 0],[1 0],eye(2)},   {[1 0],[0 1],3*eye(2)}, ...
     {[0 1],[1 0],5*eye(2)}, {[0 1],[0 1],7*eye(2)}};
polyA = rolmipvar(A,'A',[2 2],[1 1]);
bounds = [-0.4 0.4;-0.6 0.6];
polyaux = discshift(polyA,1,bounds,1,3);
polyout = discshift(polyaux{2},1,bounds,2,4);
shifted = polyout{2};
