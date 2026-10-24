function [varargout] = insert_simplex(varargin)
% Procedimento para inserir um novo simplexo em uma variavel polinomial ja
% existente.
%
% [poly] = insert_simplex(poly,vertices)
% Insere, na variavel poly, os simplexos com os numeros de vertices dados
% (vetor linha).
%
% [poly] = insert_simplex(label,vertices)
% Insere os novos simplexos no polinomio com o rotulo dado.
%
%ROLMIPopt: a insercao e feita por anexacao direta dos expoentes (grau
%zero, convencao [0] do ROLMIP), sem desmontar e reconstruir o polinomio
%pelo construtor como na versao original. Como os novos simplexos tem um
%unico monomio (grau zero), a ordem canonica dos dados nao se altera.

if (nargin ~= 2)
    error('Input error. Type ''help insert_simplex'' for more details');
end

if ischar(varargin{1})
    label = varargin{1};
    poly = rolmip('getvar',label);
    if isempty(poly)
        error('The informed label does not correspond to any polynomial');
    end
    if (~isa(poly,'rolmipvar'))
        poly = rolmipvar(poly);
    end
else
    poly = varargin{1};
end

vertices = varargin{2};
numsimplex = length(poly.data(1).exponent);
numnew = length(vertices);

if (numnew > 0)
    for cont=1:length(poly.data)
        for continsert=1:numnew
            poly.data(cont).exponent{numsimplex+continsert} = 0;
        end
    end
    poly.vertices = [poly.vertices vertices(:).'];
end

varargout{1} = poly;

return
