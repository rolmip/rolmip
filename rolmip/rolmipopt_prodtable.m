function R = rolmipopt_prodtable(vertices, deg1, deg2)
% Product destinations in the validated canonical monomial order.
% Only one orientation is cached. Pair exponents are built in chunks;
% the returned full double matrix itself still requires 8*m1*m2 bytes.
if deg1 > deg2
    R = rolmipopt_prodtable(vertices,deg2,deg1).';
    return
end
key = sprintf('prod_%d_%d_%d',vertices,deg1,deg2);
[R,hit] = rolmipopt_cache('get',key);
if hit,return;end
T1 = rolmipopt_exptable(vertices,deg1);
T2 = rolmipopt_exptable(vertices,deg2);
m1 = size(T1,1); m2 = size(T2,1);
R = zeros(m1,m2);
% Conservative working-set estimate for exponent arrays and index vectors.
chunk = max(1,floor(rolmipopt('workbytes')/(8*(3*size(T1,2)+8))));
for first=1:chunk:numel(R)
    k = (first:min(first+chunk-1,numel(R))).';
    a = mod(k-1,m1)+1; b = floor((k-1)/m1)+1;
    E = T1(a,:)+T2(b,:);
    R(k) = rolmipopt_index(E);
end
rolmipopt_cache('put',key,R);
end
