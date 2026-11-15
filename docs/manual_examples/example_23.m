% Example 23. Current and future polynomials on one trajectory simplex.
polyA = rolmipvar({eye(2),3*eye(2)},'A',2,1);
polyout = discshift(polyA,2,[-0.4 0.4;-0.6 0.6]);
triples = [];
for j = 1:numel(polyout)
    C = coeffs(polyout{j});
    triples(:,j) = cellfun(@(M) M(1,1),C).';
end
disp(sortrows(round(triples,8)));
