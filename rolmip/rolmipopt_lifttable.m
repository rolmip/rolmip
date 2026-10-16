function [L, w] = rolmipopt_lifttable(vertices, degree, delta)
% ROLMIPOPT_LIFTTABLE  Tabela de homogeneizacao multinomial, memorizada.
%   [L,w] = rolmipopt_lifttable(v,d,delta):
%     L (m x mf): L(r,s) e a posicao, na tabela de grau d+delta, do
%        expoente T(r,:) + F(s,:), onde T e a tabela de grau d e F a de
%        grau delta;
%     w (1 x mf): pesos multinomiais inteiros exatos
%        w(s) = delta! / prod(F(s,:)!) , calculados por cadeia de binomios
%        exatos (sem fatoriais em double).
%
%   Multiplicar um polinomio por (sum_j alpha_j)^delta = 1 equivale a
%   acumular data(L(r,s)) += w(s)*data(r) -- uma unica passada, em vez das
%   delta multiplicacoes polinomiais completas do homogenize original.

persistent cache
if isempty(cache)
    cache = struct();
end
key = sprintf('k%d_%d_%d', vertices, degree, delta);
if isfield(cache, key)
    L = cache.(key).L;
    w = cache.(key).w;
    return
end

L = rolmipopt_prodtable(vertices, degree, delta);
F = rolmipopt_exptable(vertices, delta);
mf = size(F,1);
P = rolmipopt_pascal(delta + vertices);
w = zeros(1, mf);
for s = 1:mf
    % multinomial via cadeia de binomios: prod_k C(s_k, F(s,k)),
    % s_k = soma acumulada dos expoentes
    acc = 0;
    val = 1;
    for k = 1:size(F,2)
        acc = acc + F(s,k);
        val = val * P(acc+1, F(s,k)+1);
    end
    w(s) = val;
end
cache.(key) = struct('L', L, 'w', w);
end
