function LMIs = construct_lmi_terms(varargin)
% LMIs = construct_lmi_terms(Term,param)
%Funcao para construir os termos das LMIs. Se 'param' for um simbolo de
%   desigualdade, retorna o conjunto de LMIs. Se 'param' for outra string,
%   retorna os termos matriciais com o rotulo dado por param.
%Entradas: Term  -> celula (Term{i,j}) com o bloco da linha i e coluna j.
%          param -> sinal da desigualdade ('>','<','>=','<=') ou o novo
%                   rotulo da LMI. Se param=='Term', retorna a variavel
%                   homogeneizada Term.
%
%ROLMIPopt:
%  * homogeneizacao dos blocos por POLYLIFT (expansao multinomial em
%    passada unica) em vez de multiplicacoes repetidas pelo polinomio '1';
%  * montagem de cada LMI por concatenacao em bloco (cat) em vez de
%    crescimento incremental elemento a elemento;
%  * lista de restricoes na sintaxe moderna do YALMIP ([LMIs, T>0]) em vez
%    de set();
%  * com rolmipopt('codegen','on') executa-se o codigo original
%    (CONSTRUCT_LMI_TERMS_CODEGEN), que preserva opcodes para o LMIFILES.

if strcmp(rolmipopt('codegen'), 'on')
    rolmipopt_require_opcodes(varargin{1});
    LMIs = construct_lmi_terms_codegen(varargin{:});
    return
end

Term = varargin{1};
if (~iscell(Term))
    Termaux = Term;
    clear Term;
    Term{1} = Termaux;
    clear Termaux;
end

if (nargin == 3)
    vertices = varargin{2};
    param = varargin{3};
elseif (nargin == 2)
    vertices = 0;
    conti = 1;
    contj = 1;
    while ((conti <= size(Term,1)) && (contj <= size(Term,2)))
        if (~isempty(Term{conti,contj}))
            if ((sum(vertices) == 0) || (length(Term{conti,contj}.vertices) > length(vertices)))
                vertices = Term{conti,contj}.vertices;
            end
            ind = find(vertices == 0);
            for cont=1:length(ind)
                if (Term{conti,contj}.vertices(ind) ~= 0)
                    vertices(ind) = Term{conti,contj}.vertices(ind);
                end
            end
        end
        contj = contj + 1;
        if (contj > size(Term,2))
            conti = conti + 1;
            contj = 1;
        end
    end
    param = varargin{2};
end

if ((strcmp(param,'>')) || (strcmp(param,'>=')) || (strcmp(param,'<')) || (strcmp(param,'<=')))
    ineq = param;
    label = [];
else
    ineq = [];
    label = param;
end

%Formato da matriz: triangular, quadrada cheia ou retangular
if (size(Term,1) ~= size(Term,2))
    shape = 3; %retangular
else
    if ((length(Term) > 1) && ((isempty(Term{1,2})) || (isempty(Term{2,1}))))
        shape = 1; %triangular
    else
        shape = 2; %quadrada cheia
    end
end

if ((shape == 3) && ~isempty(ineq))
    error('LMIs are not calculated for rectangular matrices');
end

%Se Term for triangular inferior, transpoe (a implementacao considera
%triangular superior)
if ((shape == 1) && (length(Term) > 1) && (~isempty(Term{2,1})))
    for conti = 1:size(Term,1)
        for contj = conti+1:size(Term,2)
            Term{conti,contj} = Term{contj,conti};
            expr = strcat('(',Term{conti,contj}.label);
            expr = strcat(expr,')''');
            Term{conti,contj}.label = expr;
            for contdata = 1:length(Term{conti,contj}.data)
                Term{conti,contj}.data(contdata).value = (Term{conti,contj}.data(contdata).value)';
            end
        end
    end
end

%Homogeneiza o numero de simplexos em todos os termos
for conti=1:size(Term,1)
    ini = 1;
    if (shape == 1)
        ini = conti;
    end
    for contj = ini:size(Term,2)
        if (length(Term{conti,contj}.vertices) < length(vertices))
            Term{conti,contj} = insert_simplex(Term{conti,contj},vertices(length(Term{conti,contj}.vertices)+1:end));
        end
        %expande simplexos com 0 vertices para o numero mesclado
        for cs = 1:length(vertices)
            if (Term{conti,contj}.vertices(cs) == 0) && (vertices(cs) > 0)
                Term{conti,contj}.vertices(cs) = vertices(cs);
            end
        end
    end
end

%Primeiro passo: determina o maior grau dentre todos os termos
for contsimplex=1:length(vertices)
    for conti=1:size(Term,1)
        ini = 1;
        if (shape == 1)
            ini = conti;
        end
        for contj = ini:size(Term,2)
            deg{contsimplex}(conti,contj) = sum(Term{conti,contj}.data(1).exponent{contsimplex});
        end
    end
    maxdeg(contsimplex) = max(max(deg{contsimplex}));
end

%Segundo passo: homogeneiza os polinomios ate o maior grau (passada unica)
for contsimplex=1:length(vertices)
    if (vertices(contsimplex) > 0)
        for conti=1:size(Term,1)
            ini = 1;
            if (shape == 1)
                ini = conti;
            end
            for contj = ini:size(Term,2)
                delta = maxdeg(contsimplex) - deg{contsimplex}(conti,contj);
                if (delta > 0)
                    Term{conti,contj} = polylift(Term{conti,contj},contsimplex,delta);
                end
            end
        end
    end
end

if (shape == 1)
    %Completa a matriz para torna-la quadrada cheia
    for conti = 1:size(Term,1)
        for contj = conti+1:size(Term,2)
            Term{contj,conti} = Term{conti,contj};
            expr = strcat('(',Term{conti,contj}.label);
            expr = strcat(expr,')''');
            Term{contj,conti}.label = expr;
            for contdata = 1:length(Term{conti,contj}.data)
                Term{contj,conti}.data(contdata).value = (Term{contj,conti}.data(contdata).value)';
            end
        end
    end
end

%Terceiro passo: constroi as LMIs
if (~isempty(ineq))
    LMIs = [];
    nr = size(Term,1);
    nc = size(Term,2);
    for contdata=1:length(Term{1,1}.data)
        blocks = cell(1,nr);
        for conti=1:nr
            rowcell = cell(1,nc);
            for contj = 1:nc
                rowcell{contj} = Term{conti,contj}.data(contdata).value;
            end
            blocks{conti} = cat(2, rowcell{:});
        end
        T = cat(1, blocks{:});

        %ROLMIPopt: o YALMIP moderno rejeita desigualdades estritas; elas
        %sao convertidas em nao estritas com aviso (comportamento efetivo
        %do YALMIP antigo). Desative com warning('off','ROLMIPopt:strict').
        if (strcmp(ineq,'>'))
            if (contdata == 1)
                warning('ROLMIPopt:strict', ...
                    'Desigualdade estrita convertida em nao estrita (>=).');
            end
            LMIs = [LMIs, T>=0];
        elseif (strcmp(ineq,'<'))
            if (contdata == 1)
                warning('ROLMIPopt:strict', ...
                    'Desigualdade estrita convertida em nao estrita (<=).');
            end
            LMIs = [LMIs, T<=0];
        elseif (strcmp(ineq,'>='))
            LMIs = [LMIs, T>=0];
        elseif (strcmp(ineq,'<='))
            LMIs = [LMIs, T<=0];
        end
    end
elseif (strcmp(label,'Term'))
    LMIs = Term;
else
    %Retorna uma estrutura bidimensional com o rotulo dado
    fid = rolmip('getauxfile');
    if (~isempty(fid))
        write_matrix_file(fid,Term,label);
    end
    LMIs.label = label;
    LMIs.vertices = vertices;
    nr = size(Term,1);
    nc = size(Term,2);
    for contdata=1:length(Term{1,1}.data)
        blocks = cell(1,nr);
        for conti=1:nr
            rowcell = cell(1,nc);
            for contj = 1:nc
                rowcell{contj} = Term{conti,contj}.data(contdata).value;
            end
            blocks{conti} = cat(2, rowcell{:});
        end
        LMIs.data(contdata).value = cat(1, blocks{:});
        LMIs.data(contdata).exponent = Term{1,1}.data(contdata).exponent;
        LMIs.opcode{contdata} = strcat(label,strcat('#A',num2str(contdata)));
    end
    rolmip('setvar',LMIs);
end

return
