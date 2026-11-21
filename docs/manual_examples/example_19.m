% Example 19. Time derivative on a three-vertex simplex.
A = {{[1 0 0],eye(2)}, {[0 1 0],2*eye(2)}, {[0 0 1],3*eye(2)}};
poly = rolmipvar(A,'A',3,1);
dotpoly = diff(poly,'dpoly',repmat([-1 1],3,1));
ex19_coefficients = coeffs(dotpoly);
ex19_rates = cellfun(@(M) M(1,1),ex19_coefficients(1:3:end));
