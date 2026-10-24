function polyout = polya(varargin)
% Implementacao do Teorema de Polya, usada para reduzir o conservadorismo
% na verificacao de positividade polinomial.
%
% [polyout] = polya(polyin,d) aplica a relaxacao de Polya de grau d sobre o
% polinomio polyin. A entrada d e um vetor, em que a i-esima posicao
% corresponde ao grau da relaxacao aplicada ao i-esimo simplexo.
%
% [polyout] = polya(polyin) aplica a relaxacao de Polya de grau 1 sobre
% todos os simplexos de polyin.
%
%ROLMIPopt: a multiplicacao repetida pelo polinomio '1' foi substituida
%pela expansao multinomial em passada unica (POLYLIFT). O valor do
%polinomio e identico; apenas o custo muda. Com rolmipopt('codegen','on')
%usa-se o caminho original (produtos via OPERATION_POLY_CODEGEN).

if ((nargin > 2) || (nargin < 1))
    error('Input error. Type ''help polya'' for more details');
else
    polyin = varargin{1};
    numsimplexes = length(polyin.data(1).exponent);
    if (nargin == 2)
        d = varargin{2};
    else
        d = ones(1,numsimplexes);
    end

    if (length(d) > numsimplexes)
        error('The size of d cannot be higher than the number of simplexes of polyin');
    end

    if (polyin.vertices == 0)
        warning('The input is not a polynomial');
    end
end

if strcmp(rolmipopt('codegen'), 'on')
    % Caminho original (preserva opcodes para o LMIFILES)
    auxvet = [1 zeros(1,numsimplexes-1)];
    polyout = polyin;
    for cont = 1:length(d)
        clear M;
        vertone = [1 zeros(1,polyin.vertices(cont)-1)];
        for contmon = 1:polyin.vertices(cont)
            for contsimp=1:numsimplexes
                M{contmon}{contsimp} = [0];
            end
            M{contmon}{cont} = vertone;
            M{contmon}{numsimplexes+1} = 1;
            vertone = circshift(vertone,[0 1]);
        end
        aux = rolmipvar(M,'1',auxvet*polyin.vertices(cont),auxvet);
        for contpolya = 1:d(cont)
            polyout = polyout*aux;
        end
        auxvet = circshift(auxvet,[0 1]);
    end
    return
end

polyout = polyin;
for cont = 1:length(d)
    if (d(cont) > 0) && (polyin.vertices(cont) > 0)
        polyout = polylift(polyout, cont, d(cont));
    end
end

return
