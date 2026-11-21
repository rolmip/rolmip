function h = homogenize(varargin)
%homogenization
%
%  Dada uma lista de elementos, retorna a mesma lista representada com os
%  mesmos graus (e mesmo numero de simplexos).
%
%ROLMIPopt: a homogeneizacao por multiplicacoes sucessivas pelo polinomio
%'1' foi substituida por POLYLIFT (expansao multinomial exata em passada
%unica). Com rolmipopt('codegen','on') o codigo original e executado
%(HOMOGENIZE_CODEGEN), preservando as strings 'opcode' para o LMIFILES.

if strcmp(rolmipopt('codegen'), 'on')
    rolmipopt_require_opcodes(varargin);
    h = homogenize_codegen(varargin{:});
    return
end

vertices = 0;
if (nargin == 1)
    in = varargin{1};
else
    in = varargin;
end

% Numero de vertices mesclado de todas as entradas
for i = 1:length(in)
    if (isa(in{i}, 'rolmipvar'))
        vertices = check_vertices(in{i}, vertices);
    end
end
if (sum(vertices) == 0)
    for i = 1:length(in)
        if (isa(in{i}, 'rolmipvar'))
            h{i} = in{i};
        else
            h{i} = rolmipvar(in{i}, '<>');
        end
    end
    return
end
ns = length(vertices);

% Conforma cada entrada: constantes viram polinomios de grau zero; todos
% passam a ter ns simplexos com o numero mesclado de vertices.
deg_coefs = zeros(length(in), ns);
for i = 1:length(in)
    if (~isa(in{i}, 'rolmipvar'))  % constante
        h{i} = rolmipvar(in{i}, '<>', 0, 0);
        if (ns > 1)
            h{i} = insert_simplex(h{i}, zeros(1, ns-1));
        end
    else
        h{i} = in{i};
        if (length(h{i}.vertices) < ns)
            h{i} = insert_simplex(h{i}, vertices(length(h{i}.vertices)+1:end));
        end
    end
    % expande simplexos com 0 vertices para o numero mesclado
    for j = 1:ns
        if (h{i}.vertices(j) == 0) && (vertices(j) > 0)
            h{i}.vertices(j) = vertices(j);
            zj = zeros(1, vertices(j));
            for c = 1:length(h{i}.data)
                h{i}.data(c).exponent{j} = zj;
            end
        end
    end
    for j = 1:ns
        deg_coefs(i,j) = sum(h{i}.data(1).exponent{j});
    end
end
maxexp = max(deg_coefs, [], 1);

% Eleva cada entrada ao grau maximo por simplexo (passada unica)
for i = 1:length(in)
    for j = 1:ns
        delta = maxexp(j) - sum(h{i}.data(1).exponent{j});
        if (delta > 0)
            h{i} = polylift(h{i}, j, delta);
        end
    end
end

return

function vertices = check_vertices(atual,vertices)
%Verifica e atualiza o numero corrente de vertices (identico ao original)

if (sum(vertices) == 0)
    vertices = atual.vertices;
else
    if (length(vertices) > length(atual.vertices))
        ind = find(vertices(1:length(atual.vertices)) == 0);
        vertices(ind) = atual.vertices(ind);

        ind = find(vertices(1:length(atual.vertices)).*(atual.vertices) ~= 0);
        if (sum(abs(vertices(ind) - atual.vertices(ind))) ~= 0)
            error('The number of vertices of the defined simplexes must always be the same!');
        end
    else
        ind = find(vertices == 0);
        vertices(ind) = atual.vertices(ind);
        if (length(vertices) < length(atual.vertices))
            vertices = [vertices atual.vertices(length(vertices)+1:end)];
        end

        ind = find(vertices.*atual.vertices ~= 0);
        if (sum(abs(vertices(ind) - atual.vertices(ind))) ~= 0)
            error('The number of vertices of the defined simplexes must always be the same!');
        end
    end
end
