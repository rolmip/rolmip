function LMIs = construct_lmi_terms(varargin)
% LMIs = construct_lmi_terms(Term,param)
%Function to construct the LMIs terms. If 'param' is an inequality
%   symbol, then the function returns the set of LMIs. If 'param' is other
%   string, then the function returns the matricial terms with label
%   given by param.
%Inputs: Term    -> Struct (Term{i,j}) containing the i-th row and j-th 
%                   column of the LMI.
%        param    -> Signal of the inequality ('>','<','>=','<=') or the
%                    new label of the LMI. If param=='Term', return the
%                    homogeneized variable Term.

Term = varargin{1};
if (~iscell(Term))
    %In this case, Term is a polynomial and not a matrix with polynomials
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
    while ((vertices == 0) && (conti <= size(Term,1)) && (contj <= size(Term,2)))
        if (~isempty(Term{conti,contj}))
            vertices = Term{conti,contj}.vertices;
        else
            vertices = 0;
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



%Define if the matrix is square triangular, full square or rectangular
if (size(Term,1) ~= size(Term,2))
    shape = 3; %rectangular
else
    if ((length(Term) > 1) && ((isempty(Term{1,2})) || (isempty(Term{2,1}))))
        shape = 1; %square triangular
    else
        shape = 2; %full square
    end
end


if ((shape == 3) && ~isempty(ineq))
    %Rectangular matrix, cannot be part of a LMI
    error('LMIs are not calculated for rectangular matrices');
    LMIs = [];
    return
end



%If Term is triangular inferior perform its transpose, since the
%following implementation consider triangular superior matrices
if ((shape == 1) && (length(Term) > 1) && (~isempty(Term{2,1})))
    %Triangular inferior
    for conti = 1:size(Term,1)
        for contj = conti+1:size(Term,2)
            Term{conti,contj} = Term{contj,conti};
            expr = strcat('(',Term{conti,contj}.label);
            expr = strcat(expr,')''');
            Term{conti,contj}.label = expr;
            for contdata = 1:length(Term{conti,contj}.data)
                Term{conti,contj}.data(contdata).value = (Term{conti,contj}.data(contdata).value)';
                expr = strcat('(',Term{conti,contj}.opcode{contdata});
                expr = strcat(expr,')''');
                Term{conti,contj}.opcode{contdata} = expr;
            end
        end
    end
end

if (shape == 1)
    %Optimize the operations for triangular matrices, which is the
    %most common case.
    %First step: determine the highest degree from all the terms
    for conti=1:size(Term,1)
        for contj = conti:size(Term,2)
            deg(conti,contj) = sum(Term{conti,contj}.data(1).exponent);
        end
    end
    maxdeg = max(max(deg));

    if (vertices > 0)
        %one = sum_{i=1}^{vertices} alpha_i = 1
        one = poly_struct(ones(1,vertices),'1',vertices,1);
        
        %Second step: Make the polynomials homogeneous to the highest degree
        for conti=1:size(Term,1)
            for contj = conti:size(Term,2)
                contdeg = deg(conti,contj);
                while (contdeg < maxdeg)
                    Term{conti,contj} = operation_poly(Term{conti,contj},one,'*');
                    contdeg = contdeg + 1;
                end
            end
        end
    end

    %Completing the matrix in order to make it full square
    for conti = 1:size(Term,1)
        for contj = conti+1:size(Term,2)
            Term{contj,conti} = Term{conti,contj};
            expr = strcat('(',Term{conti,contj}.label);
            expr = strcat(expr,')''');
            Term{contj,conti}.label = expr;
            for contdata = 1:length(Term{conti,contj}.data)
                Term{contj,conti}.data(contdata).value = (Term{contj,conti}.data(contdata).value)';
                expr = strcat('(',Term{conti,contj}.opcode{contdata});
                expr = strcat(expr,')''');
                Term{contj,conti}.opcode{contdata} = expr;
            end
        end
    end
    
else %Rectangular or full square 
   %First step: determine the highest degree from all the terms
    for conti=1:size(Term,1)
        for contj = 1:size(Term,2)
            deg(conti,contj) = sum(Term{conti,contj}.data(1).exponent);
        end
    end
    maxdeg = max(max(deg));

    if (vertices > 0)
        %one = sum_{i=1}^{vertices} alpha_i = 1
        one = poly_struct(ones(1,vertices),'1',vertices,1);
        
        %Second step: Make the polynomials homogeneous to the highest degree
        for conti=1:size(Term,1)
            for contj = 1:size(Term,2)
                contdeg = deg(conti,contj);
                while (contdeg < maxdeg)
                    Term{conti,contj} = operation_poly(Term{conti,contj},one,'*');
                    contdeg = contdeg + 1;
                end
            end
        end
    end
end


%Third step: construct the LMIs
if (~isempty(ineq))
    LMIs = set([]);
    
    for contdata=1:length(Term{1,1}.data)
        T = [];
        for conti=1:size(Term,1)
            Taux = [];
            for contj = 1:size(Term,2)
                Taux = [Taux Term{conti,contj}.data(contdata).value];
            end
            T = [T; Taux];
        end

        if (strcmp(ineq,'>'))
            LMIs = LMIs + set(T>0);
        elseif (strcmp(ineq,'<'))
            LMIs = LMIs + set(T<0);
        elseif (strcmp(ineq,'>='))
            LMIs = LMIs + set(T>=0);
        elseif (strcmp(ineq,'<='))
            LMIs = LMIs + set(T<=0);
        end
    end
elseif (strcmp(label,'Term'))
    LMIs = Term;
else
    %In this case, return a bidimensional structure 
    
    %DEVELOP THE CASE WHERE THE DIMENSION OF A VARIABLE DEPENDS ON THE
    %DIMENSIONS OF AN AUXILIAR VARIABLE...
    
    
    fid = rolmip('getauxfile');
    if (~isempty(fid))
        write_matrix_file(fid,Term,label); %Writes 'Term' in the file and sets the LMI
    end
    LMIs.label = label;
    LMIs.vertices = vertices;
    for contdata=1:length(Term{1,1}.data)
        LMIs.data(contdata).value = [];
        LMIs.opcode{contdata} = strcat(label,strcat('#A',num2str(contdata))); 
        for conti=1:size(Term,1)
            Taux = [];
            for contj = 1:size(Term,2)
                Taux = [Taux Term{conti,contj}.data(contdata).value];
            end
            LMIs.data(contdata).value = [LMIs.data(contdata).value; Taux];
            LMIs.data(contdata).exponent = Term{1,1}.data(contdata).exponent;
        end
    end
    rolmip('setvar',LMIs);
end

return