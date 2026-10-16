function T = rolmipopt_exptable(vertices, degree)
% ROLMIPOPT_EXPTABLE  Tabela de expoentes homogeneos, memorizada.
%   T = rolmipopt_exptable(v,d) retorna a matriz (nchoosek(v+d-1,d) x v)
%   com os expoentes na MESMA ordem do generate_homogeneous_exponents do
%   ROLMIP original, porem gerada iterativamente (com prealocacao) e
%   armazenada em cache persistente: cada par (v,d) e construido uma unica
%   vez por sessao.

persistent cache
if isempty(cache)
    cache = struct();
end

key = sprintf('k%d_%d', vertices, degree);
if isfield(cache, key)
    T = cache.(key);
    return
end

if vertices <= 1
    T = degree;              % identico ao original (escalar)
    cache.(key) = T;
    return
end
if degree == 0
    T = zeros(1, vertices);
    cache.(key) = T;
    return
end

P = rolmipopt_pascal(vertices + degree);
m = P(vertices + degree, degree + 1);   % nchoosek(v+d-1, d)
T = zeros(m, vertices);

% Geracao iterativa na ordem canonica: primeiro expoente decrescente.
row = 1;
e = zeros(1, vertices);
e(1) = degree;
while true
    T(row,:) = e;
    row = row + 1;
    % proximo expoente (ordem do algoritmo recursivo original):
    % decrementa a primeira posicao possivel a partir da direita
    j = find(e(1:end-1) > 0, 1, 'last');
    if isempty(j)
        break
    end
    e(j) = e(j) - 1;
    s = sum(e(j+1:end)) + 1;   % redistribui tudo para a posicao j+1
    e(j+1:end) = 0;
    e(j+1) = s;
end
T = T(1:row-1, :);
cache.(key) = T;
end
