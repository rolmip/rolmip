function polyout = polylift(polyin, simplex, delta)
% POLYLIFT  Homogeneizacao multinomial em passada unica (novo no ROLMIPopt).
%
%   polyout = polylift(polyin, simplex, delta) multiplica o polinomio por
%   (sum_j alpha_j)^delta = 1 no simplexo indicado, elevando seu grau em
%   delta sem alterar seu valor. Substitui as delta multiplicacoes
%   sucessivas pelo polinomio '1' do homogenize/construct_lmi_terms
%   originais: cada coeficiente e acumulado uma unica vez com peso
%   multinomial inteiro exato (ROLMIPOPT_LIFTTABLE).
%
%   Observacao: os opcodes do resultado ficam vazios (uso previsto no modo
%   padrao rolmipopt('codegen','off')).

if (delta <= 0)
    polyout = polyin;
    return
end

vertices = polyin.vertices;
ns = length(vertices);
v = vertices(simplex);
if (v <= 1)
    % (alpha_1)^delta = 1: apenas eleva o expoente escalar
    polyout = polyin;
    if (v == 1)
        for c=1:length(polyout.data)
            polyout.data(c).exponent{simplex} = ...
                polyout.data(c).exponent{simplex} + delta;
        end
    end
    return
end

deg = zeros(1,ns);
for cs=1:ns
    deg(cs) = sum(polyin.data(1).exponent{cs});
end

[L, w] = rolmipopt_lifttable(v, deg(simplex), delta);
mf = length(w);

% grade canonica do resultado
degR = deg;  degR(simplex) = deg(simplex) + delta;
TR = cell(1,ns);
szR = zeros(1,ns); jumpR = ones(1,ns);
mR = 1;
for cs=1:ns
    TR{cs} = rolmipopt_exptable(vertices(cs), degR(cs));
    szR(cs) = size(TR{cs},1);
    if cs > 1
        jumpR(cs) = jumpR(cs-1)*szR(cs-1);
    end
    mR = mR*szR(cs);
end

dims = size(polyin.data(1).value);
Z = zeros(dims);
%Create a zero-valued polynomial
expn = cell(1,ns);
contexp = ones(1,ns+1);
for n=1:mR
    for cs=1:ns
        expn{cs} = TR{cs}(contexp(cs),:);
    end
    resul.data(n).exponent = expn;
    resul.data(n).value = Z;
    resul.opcode{n} = '';
    contexp(1) = contexp(1) + 1;
    aux = 1;
    while ((aux <= ns) && (contexp(aux) > szR(aux)))
        contexp(aux) = 1;
        contexp(aux+1) = contexp(aux+1) + 1;
        aux = aux + 1;
    end
end

% ranks dos monomios de origem
m = length(polyin.data);
rsrc = ones(m, ns);
for cs=1:ns
    len = length(polyin.data(1).exponent{cs});
    if (len <= 1)
        continue
    end
    E = zeros(m, len);
    for c=1:m
        E(c,:) = polyin.data(c).exponent{cs};
    end
    rsrc(:,cs) = rolmipopt_index(E);
end

% indice base (todas as parcelas exceto o simplexo elevado)
base = ones(m,1);
for cs=1:ns
    if (cs ~= simplex) && (szR(cs) > 1)
        base = base + (rsrc(:,cs) - 1)*jumpR(cs);
    end
end

for c=1:m
    val = polyin.data(c).value;
    if (isnumeric(val) && ~any(val(:)))
        continue
    end
    rs = rsrc(c,simplex);
    b = base(c);
    for s=1:mf
        k = b + (L(rs,s) - 1)*jumpR(simplex);
        if (w(s) == 1)
            resul.data(k).value = resul.data(k).value + val;
        else
            resul.data(k).value = resul.data(k).value + w(s)*val;
        end
    end
end

resul.label = polyin.label;
resul.vertices = vertices;
if (any(strcmp(fieldnames(polyin),'bounds')))
    resul.bounds = polyin.bounds;
end

polyout = rolmipvar(resul);
return
