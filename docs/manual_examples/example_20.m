% Example 20. Time derivative on a product of two simplexes.
A = {{[1 0 0],[1 0],eye(2)},   {[1 0 0],[0 1],2*eye(2)}, ...
     {[0 1 0],[1 0],3*eye(2)}, {[0 1 0],[0 1],4*eye(2)}, ...
     {[0 0 1],[1 0],5*eye(2)}, {[0 0 1],[0 1],6*eye(2)}};
poly = rolmipvar(A,'A',[3 2],[1 1]);
dotbounds = {[-1 2;-3 4;-8 6],[-4 1;-6 9]};
dotpoly = diff(poly,'dpoly',dotbounds);
