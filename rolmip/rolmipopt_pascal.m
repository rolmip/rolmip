function P = rolmipopt_pascal(nmax)
% ROLMIPOPT_PASCAL  Tabela de Pascal memoizada: P(n+1,r+1) = nchoosek(n,r).
%   Coeficientes binomiais inteiros exatos calculados por recorrencia
%   aditiva (sem fatoriais), reutilizados por todas as rotinas de
%   indexacao do ROLMIPopt.

persistent PT
if isempty(PT)
    PT = 1;   % P(1,1) = nchoosek(0,0)
end
if size(PT,1) < nmax + 1
    old = size(PT,1);
    Pn = zeros(nmax+1, nmax+1);
    Pn(1:old,1:old) = PT;
    for n = old:nmax    % linha n <-> nchoosek(n,.)
        Pn(n+1,1) = 1;
        for r = 1:n
            Pn(n+1,r+1) = Pn(n,r) + Pn(n,r+1);
        end
    end
    PT = Pn;
end
P = PT;
end
