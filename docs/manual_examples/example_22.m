% Example 22. Derivatives in the barycentric coordinates.
A = {{[2 0],eye(2)}, {[1 1],3*eye(2)}, {[0 2],5*eye(2)}};
poly = rolmipvar(A,'A',2,2);
dpoly = partial(poly,'dAda');
