function R = rolmipopt_prodtable(vertices, deg1, deg2)
% ROLMIPOPT_PRODTABLE  Tabela de indices do produto, memorizada.
%   R = rolmipopt_prodtable(v,d1,d2) retorna a matriz (m1 x m2) tal que
%   R(a,b) e a posicao, na tabela canonica de grau d1+d2, do expoente
%   T1(a,:) + T2(b,:). Com ela, a indexacao do produto de dois polinomios
%   torna-se uma consulta vetorizada -- substitui as chamadas 'gethash'
%   dentro do laco duplo do operation_poly original.

persistent cache
if isempty(cache)
    cache = struct();
end
key = sprintf('k%d_%d_%d', vertices, deg1, deg2);
if isfield(cache, key)
    R = cache.(key);
    return
end

T1 = rolmipopt_exptable(vertices, deg1);
T2 = rolmipopt_exptable(vertices, deg2);
m1 = size(T1,1);
m2 = size(T2,1);
% somas de todos os pares, em bloco
E = kron(T1, ones(m2,1)) + repmat(T2, m1, 1);
idx = rolmipopt_index(E);
R = reshape(idx, m2, m1).';   % R(a,b) <-> par (T1(a), T2(b))
cache.(key) = R;
end
