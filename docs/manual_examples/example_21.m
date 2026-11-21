% Example 21. Time derivative with bounded physical parameters.
A = {{[0 0 0],eye(2)},   {[1 0 0],2*eye(2)}, ...
     {[1 1 0],3*eye(2)}, {[0 2 0],4*eye(2)}, ...
     {[1 1 1],5*eye(2)}, {[0 0 3],6*eye(2)}};
bounds = [-2 4;3 6;1 8];
dotbounds = [-1 5;-3 2;-7 3];
poly = rolmipvar(A,'A',bounds);
dotpoly = diff(poly,'dpoly',bounds,dotbounds);
