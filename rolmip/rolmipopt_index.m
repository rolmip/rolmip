function idx = rolmipopt_index(E)
% ROLMIPOPT_INDEX  Posicao (1-based) de expoentes na ordem canonica do ROLMIP.
%
%   idx = rolmipopt_index(E), com E (m x v) matriz cujas linhas sao
%   expoentes homogeneos (mesmo grau), retorna o vetor m x 1 com a posicao
%   de cada linha na tabela gerada por GENERATE_HOMOGENEOUS_EXPONENTS.
%
%   Substitui a funcao interna 'gethash' do ROLMIP original (busca linear
%   com find/histc/repmat, custo O(m_tab*v) por consulta) por avaliacao
%   combinatoria fechada em O(v) por linha:
%   o numero de expoentes que precedem E na ordem canonica e
%       sum_i C(d_i - E(i) - 1 + v - i, v - i),
%   onde d_i e o grau restante (identidade da "hockey stick").
%   Todos os binomios vem da tabela de Pascal exata (ROLMIPOPT_PASCAL),
%   mantida em cache local para reduzir o custo por chamada.

persistent P nmax
[m, v] = size(E);
if v <= 1
    idx = ones(m,1);
    return
end

need = sum(E(1,:)) + v;
if isempty(P) || nmax < need
    P = rolmipopt_pascal(need + 8);
    nmax = need + 8;
end

if m == 1
    % caminho escalar rapido (uso tipico do construtor/diff)
    idx = 1;
    d = sum(E);
    for i = 1:v-1
        e = E(i);
        if d > e
            idx = idx + P(d - e + v - i, v - i + 1);
        end
        d = d - e;
    end
    return
end

d = sum(E, 2);              % grau restante por linha
idx = ones(m,1);
np = size(P,1);
for i = 1:v-1
    rem = v - i;
    e = E(:,i);
    k = d - e - 1 + rem;    % contribuicao = C(k, rem) quando d > e
    mask = d > e;
    if any(mask)
        idx(mask) = idx(mask) + P((rem)*np + k(mask) + 1);  % P(k+1, rem+1)
    end
    d = d - e;
end
end
