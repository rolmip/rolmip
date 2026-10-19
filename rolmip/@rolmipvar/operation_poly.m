function [resul] = operation_poly(poly1,poly2,op)
%[resul] = operation_poly(poly1,poly2,op)
%Executa uma operacao (+, -, *) entre dois polinomios homogeneos.
%
%ROLMIPopt: nucleo reescrito.
%  * Indexacao dos monomios por tabelas combinatorias memoizadas
%    (ROLMIPOPT_PRODTABLE / ROLMIPOPT_INDEX) em vez da busca linear
%    'gethash' (find/histc/repmat) da versao original;
%  * coeficientes numericos identicamente nulos sao pulados na
%    acumulacao (o valor final e o mesmo: soma-se zero);
%  * as strings simbolicas 'opcode' so sao construidas quando
%    rolmipopt('codegen','on') -- nesse caso, o codigo original e
%    executado integralmente (OPERATION_POLY_CODEGEN).
%
%A grade homogenea completa do resultado e criada e preenchida como na
%versao original: a semantica e identica.

if strcmp(rolmipopt('codegen'), 'on')
    rolmipopt_require_opcodes({poly1, poly2});
    resul = operation_poly_codegen(poly1, poly2, op);
    return
end

% --- Alinhamento do numero de simplexos (mesma logica do original) -------
if (length(poly1.vertices) > length(poly2.vertices))
    vertices = zeros(1, length(poly1.vertices));
    for cont=1:length(poly2.vertices)
        if (poly1.vertices(cont) == 0)
            vertices(cont) = poly2.vertices(cont);
        else
            vertices(cont) = poly1.vertices(cont);
        end
    end
    vertices(length(poly2.vertices)+1:end) = ...
        poly1.vertices(length(poly2.vertices)+1:end);
    poly2 = insert_simplex(poly2, poly1.vertices(length(poly2.vertices)+1:end));
elseif (length(poly1.vertices) < length(poly2.vertices))
    vertices = zeros(1, length(poly2.vertices));
    for cont=1:length(poly1.vertices)
        if (poly2.vertices(cont) == 0)
            vertices(cont) = poly1.vertices(cont);
        else
            vertices(cont) = poly2.vertices(cont);
        end
    end
    vertices(length(poly1.vertices)+1:end) = ...
        poly2.vertices(length(poly1.vertices)+1:end);
    poly1 = insert_simplex(poly1, poly2.vertices(length(poly1.vertices)+1:end));
else
    vertices = zeros(1, length(poly1.vertices));
    for cont=1:length(poly1.vertices)
        if (poly1.vertices(cont) == 0)
            vertices(cont) = poly2.vertices(cont);
        else
            vertices(cont) = poly1.vertices(cont);
        end
    end
end
ns = length(vertices);

% --- Bounds (mesma politica do original) ---------------------------------
boundsaux{1} = []; boundsaux{2} = [];
qtd = 0;
if (any(strcmp(fieldnames(poly1),'bounds')) && ~isempty(poly1.bounds))
    boundsaux{1} = poly1.bounds;  qtd = qtd + 1;
end
if (any(strcmp(fieldnames(poly2),'bounds')) && ~isempty(poly2.bounds))
    boundsaux{2} = poly2.bounds;  qtd = qtd + 1;
end
if (qtd >= 1)
    [saux, indb] = sort([size(boundsaux{1},1) size(boundsaux{2},1)]);
    if (qtd == 1)
        resul.bounds = boundsaux{indb(2)};
    else
        if (sum(sum(abs(boundsaux{indb(2)}(1:size(boundsaux{indb(1)},1),:) ...
                - boundsaux{indb(1)}))) ~= 0)
            error('The bounds of both polynomials are different');
        end
        resul.bounds = boundsaux{indb(2)};
    end
end

% --- Graus por simplexo --------------------------------------------------
deg1 = zeros(1,ns); deg2 = zeros(1,ns);
for cs=1:ns
    deg1(cs) = sum(poly1.data(1).exponent{cs});
    deg2(cs) = sum(poly2.data(1).exponent{cs});
end
if (op == '*')
    degree = deg1 + deg2;
else
    degree = deg1;   % soma/subtracao: graus ja homogeneizados (plus/minus)
end

% --- Grade canonica do resultado ----------------------------------------
TR = cell(1,ns);
szR = zeros(1,ns); jumpR = ones(1,ns);
mR = 1;
for cs=1:ns
    TR{cs} = rolmipopt_exptable(vertices(cs), degree(cs));
    szR(cs) = size(TR{cs},1);
    if cs > 1
        jumpR(cs) = jumpR(cs-1)*szR(cs-1);
    end
    mR = mR*szR(cs);
end

% dimensao dos blocos do resultado
v1s = size(poly1.data(1).value); v2s = size(poly2.data(1).value);
if (op == '*')
    if (prod(v1s) == 1)
        dims = v2s;
    elseif (prod(v2s) == 1)
        dims = v1s;
    else
        dims = [v1s(1) v2s(2)];
    end
else
    if (prod(v1s) >= prod(v2s))
        dims = v1s;
    else
        dims = v2s;
    end
end
Z = zeros(dims);

expn = cell(1,ns);
resul.data = repmat(struct('exponent', {cell(1,ns)}, 'value', Z), 1, mR);
resul.opcode = repmat({''}, 1, mR);
contexp = ones(1,ns+1);
for n=1:mR
    for cs=1:ns
        expn{cs} = TR{cs}(contexp(cs),:);
    end
    resul.data(n).exponent = expn;
    contexp(1) = contexp(1) + 1;
    aux = 1;
    while ((aux <= ns) && (contexp(aux) > szR(aux)))
        contexp(aux) = 1;
        contexp(aux+1) = contexp(aux+1) + 1;
        aux = aux + 1;
    end
end

% --- Rotulo (mesmos casos especiais '1'/'-1' do original) ----------------
if ((strcmp(poly1.label,'1') || strcmp(poly1.label,'-1')) && (op == '*'))
    if (strcmp(poly1.label,'1'))
        resul.label = poly2.label;
    else
        resul.label = strcat('-',poly2.label);
    end
elseif ((strcmp(poly2.label,'1') || strcmp(poly2.label,'-1')) && (op == '*'))
    if (strcmp(poly2.label,'1'))
        resul.label = poly1.label;
    else
        resul.label = strcat('-',poly1.label);
    end
else
    resul.label = strcat(strcat(poly1.label,op),poly2.label);
end

% --- Acumulacao ----------------------------------------------------------
m1 = length(poly1.data);
m2 = length(poly2.data);

if (op == '*')
    if prod(v1s) ~= 1 && prod(v2s) ~= 1 && v1s(2) ~= v2s(1)
        error('ROLMIP:ProductDimensions', 'Inner matrix dimensions must agree.');
    end
    finiteInputs = true;
    for k = 1:m1
        value = poly1.data(k).value;
        if isnumeric(value) && any(~isfinite(value(:))), finiteInputs = false; end
    end
    for k = 1:m2
        value = poly2.data(k).value;
        if isnumeric(value) && any(~isfinite(value(:))), finiteInputs = false; end
    end
    % Active support affects work only; retain the complete public grid.
    active1 = true(1,m1); active2 = true(1,m2);
    if finiteInputs
        for c=1:m1
            val=poly1.data(c).value;
            active1(c)=~(isnumeric(val) && ~any(val(:)));
        end
        for c=1:m2
            val=poly2.data(c).value;
            active2(c)=~(isnumeric(val) && ~any(val(:)));
        end
    end
    a1=find(active1); a2=find(active2);
    if ~isempty(a1) && ~isempty(a2)
        r1 = local_ranks(poly1, ns); r2 = local_ranks(poly2, ns);
        budget=rolmipopt('workbytes');
        maps=cell(1,ns); T1=cell(1,ns); T2=cell(1,ns);
        for cs=1:ns
            if vertices(cs)>1 && szR(cs)>1
                T1{cs}=rolmipopt_exptable(vertices(cs),deg1(cs));
                T2{cs}=rolmipopt_exptable(vertices(cs),deg2(cs));
                pairs=size(T1{cs},1)*size(T2{cs},1);
                if 8*pairs <= budget/ns && pairs <= 4*numel(a1)*numel(a2)
                    maps{cs}=rolmipopt_prodtable(vertices(cs),deg1(cs),deg2(cs));
                end
            end
        end
        capacity=max(1,floor(budget/(8*(3*max(vertices)+12))));
        nc=min(numel(a2),capacity);
        nr=max(1,min(numel(a1),floor(capacity/nc)));
        % If columns require chunks, nr=1. Thus accumulation order remains
        % source row then source column, exactly as in the previous kernel.
        for row=1:nr:numel(a1)
            rows=a1(row:min(row+nr-1,numel(a1)));
            for col=1:nc:numel(a2)
                cols=a2(col:min(col+nc-1,numel(a2)));
                IND=ones(numel(rows),numel(cols));
                for cs=1:ns
                    if vertices(cs)>1 && szR(cs)>1
                        if ~isempty(maps{cs})
                            local=maps{cs}(r1(rows,cs),r2(cols,cs));
                        else
                            ia=repmat(r1(rows,cs),numel(cols),1);
                            ib=kron(r2(cols,cs),ones(numel(rows),1));
                            E=T1{cs}(ia,:)+T2{cs}(ib,:);
                            local=reshape(rolmipopt_index(E),numel(rows),numel(cols));
                        end
                        IND=IND+(local-1)*jumpR(cs);
                    end
                end
                for i=1:numel(rows)
                    val1=poly1.data(rows(i)).value;
                    for j=1:numel(cols)
                        k=IND(i,j);
                        resul.data(k).value=resul.data(k).value+val1*poly2.data(cols(j)).value;
                    end
                end
            end
        end
    end
else  % '+' ou '-'
    ind1 = local_totalindex(poly1, ns, jumpR, szR);
    ind2 = local_totalindex(poly2, ns, jumpR, szR);
    for c=1:m1
        k = ind1(c);
        resul.data(k).value = resul.data(k).value + poly1.data(c).value;
    end
    if (op == '+')
        for c=1:m2
            k = ind2(c);
            resul.data(k).value = resul.data(k).value + poly2.data(c).value;
        end
    else
        for c=1:m2
            k = ind2(c);
            resul.data(k).value = resul.data(k).value - poly2.data(c).value;
        end
    end
end

resul.vertices = vertices;

return

%--------------------------------------------------------------------------
function r = local_ranks(poly, ns)
% ranks (1-based) de cada monomio em cada simplexo
m = length(poly.data);
r = ones(m, ns);
for cs=1:ns
    len = length(poly.data(1).exponent{cs});
    if (len <= 1)
        continue
    end
    E = zeros(m, len);
    for c=1:m
        E(c,:) = poly.data(c).exponent{cs};
    end
    r(:,cs) = rolmipopt_index(E);
end
return

%--------------------------------------------------------------------------
function ind = local_totalindex(poly, ns, jumpR, szR)
% indice total (1-based) de cada monomio na grade canonica do resultado
r = local_ranks(poly, ns);
m = length(poly.data);
ind = ones(m,1);
for cs=1:ns
    if (szR(cs) > 1)
        ind = ind + (r(:,cs) - 1)*jumpR(cs);
    end
end
return
