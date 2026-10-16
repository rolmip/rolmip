function [exponents] = generate_homogeneous_exponents(vertices,degree)
% [exponents] = generate_homogeneous_exponents(vertices,degree)
% Gera os expoentes de um polinomio homogeneo, na mesma ordem da versao
% original do ROLMIP.
%
% ROLMIPopt: a geracao recursiva com concatenacao repetida foi substituida
% por construcao iterativa prealocada e memoizada (ROLMIPOPT_EXPTABLE) --
% cada tabela (vertices,degree) e construida uma unica vez por sessao.

exponents = rolmipopt_exptable(vertices, degree);
return
