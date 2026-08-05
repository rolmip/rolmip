function [varargout] = poly_struct(varargin)
% Procedure to compose the polynomial structs to use the parser.
%
% [poly] = poly_struct(M,label,vertices,degree) returns the polynomial structure
% for a variable set M, with a given label and given the number of 
% vertices and the degree (degree = 0 if constant). The variables
% M1, M2, ... , MN can be concatenated in M (M = [M1 M2 ... MN]) or
% disposed in cells (M{1} = M1, ... , M{N} = MN).
%
% [poly] = poly_struct(M,label,'scalar') returns a scalar. Note that 
% M has to have dimension 1x1.
%
% [poly,M] = poly_struct(rows,cols,label,vertices,degree) internally 
% defines a set of rows X cols symmetric matrix variables M with a given
% label and given the number of vertices and the degree.
%
% [poly,M] = poly_struct(rows,cols,label,parametr,vertices,degree)
% defines a variable: symmetric if parametr = 'symmetric'; full if parametr
% = 'full'; symmetric toeplitz if parametr = 'toeplitz'; symmetric hankel 
% if parametr = 'hankel'; and skew-symmetric if parametr = 'skew'.
%
% [poly,M] = poly_struct(label,'scalar') internally defines a scalar
% variable.
%
% Special cases (important to use with the lmifiles command): 
%    poly_struct(eye(n),label) returns the identity matrix with a label
%    poly_struct(zeros(n,m),label) returns the zero matrix with a label

scalar = false;
if (nargin == 2)
    M = varargin{1};
    label = varargin{2};
    vertices = 0;
    degree = 0;
    if (strcmp(label,'scalar'))
        label = M;
        scalar = true;
    end
elseif (nargin == 3)
    M = varargin{1};
    if (length(M) > 1)
        error('M has to be a scalar');
        poly = [];
        return
    end
    label = varargin{2};
    vertices = 0;
    degree = 0;
    if (strcmp(varargin{3},'scalar'))
        scalar = true;
    else
        error('Invalid third argument');
        poly = [];
        return
    end
elseif (nargin == 4)
    M = varargin{1};
    label = varargin{2};
    vertices = varargin{3};
    degree = varargin{4};
elseif (nargin == 5)
    rows = varargin{1};
    cols = varargin{2};
    label = varargin{3};
    vertices = varargin{4};
    degree = varargin{5};
    parametr = 'symmetric';
elseif (nargin == 6)
    rows = varargin{1};
    cols = varargin{2};
    label = varargin{3};
    parametr = varargin{4};
    vertices = varargin{5};
    degree = varargin{6};
end

if (nargin >= 5)
    %Define the variable
    if (vertices > 0)
        numcoefs = (factorial(vertices + degree - 1))/(factorial(degree)*factorial(vertices-1));
    else
        numcoefs = 1;
    end
    for cont=1:numcoefs
        M{cont} = sdpvar(rows,cols,parametr);
    end
end

if ((nargin == 2) && (scalar))
    M = sdpvar(1,1);
end
    

poly.label = label;
poly.vertices = vertices;
if (degree > 0) %Not a constant
    numcoefs = (factorial(vertices + degree - 1))/(factorial(degree)*factorial(vertices-1));
    if (~iscell(M))
        [order,tam] = size(M);
        tam = tam/numcoefs;
        [exponents] = generate_homogeneous_exponents(vertices,degree);
        for cont=1:size(exponents,1)
            poly.data(cont).exponent = exponents(cont,:);
            poly.data(cont).value = M(:,(cont-1)*tam+1:cont*tam);
        end
    else
        if (iscell(M{1}))
            [exponents] = generate_homogeneous_exponents(vertices,degree);
            for cont=1:length(M)
                if (sum(M{cont}{1}) == degree)
                    poly.data(cont).exponent = M{cont}{1};
                    poly.data(cont).value = M{cont}{2};
                    
                    contexp = 1;
                    ind = 1:size(exponents,1);
                    while ((contexp <= size(exponents,2)) && (sum(isnan(ind)) < length(ind)-1))
                        aux = find(~isnan(ind));
                        indtakeoff = find(exponents(aux,contexp)~=M{cont}{1}(contexp));
                        ind(indtakeoff) = nan;
                        contexp = contexp + 1;
                    end
                    exponents(find(~isnan(ind)),:) = [];
                else
                    error('At least one exponent of the polynomial does not have the chosen degree');
                    poly = [];
                    return
                end
            end
            contpoly = length(poly.data) + 1;
            for cont=1:size(exponents,1)
                poly.data(contpoly).exponent = exponents(cont,:);
                poly.data(contpoly).value = zeros(size(M{1}{2}));
                contpoly = contpoly + 1;
            end
                
        else
            if (length(M) ~= numcoefs)
                error('Invalid number of monomials entered');
                poly = [];
                return
            else
                [exponents] = generate_homogeneous_exponents(vertices,degree);
                for cont=1:size(exponents,1)
                    poly.data(cont).exponent = exponents(cont,:);
                    poly.data(cont).value = M{cont};
                end
            end
        end
    end
else %Constant
    if (vertices == 0)
        poly.data(1).exponent = 0;
        if (iscell(M))
            poly.data(1).value = M{1};
        else
            poly.data(1).value = M;
        end
    else
        exponent = [1 zeros(1,vertices-1)];
        for cont=1:vertices
            poly.data(cont).exponent = exponent;
            if (iscell(M))
                poly.data(cont).value = M{1};
            else
                poly.data(cont).value = M;
            end
            exponent = circshift(exponent,[0 1]);
        end
    end
end



%Determine the field opcode: if the polynomials are variables (V),
%constants (C), predefined identity or zeros matrices (P), scalar
%variable (S) or scalar constant (K)
%The type matrix composition (M) may appear through the construct_lmi_terms
if (sum(sum(isnan(double(poly.data(1).value)))) > 0)
%if (isnan(double(poly.data(1).value(1,1))))
    if (scalar)
        poly.opcode{1} = strcat(poly.label,'#S1');
    else
        for cont=1:length(poly.data)
            poly.opcode{cont} = strcat(strcat(poly.label,'#V'),num2str(cont));
        end
    end
else
    if (scalar)
        poly.opcode{1} = strcat(poly.label,'#K1');
    elseif ((nargin == 2) && (sum(sum(M)) == 0))
        %Zero matrix
        poly.opcode{1} = strcat(poly.label,'#P1');
    elseif ((nargin == 2) && (size(M,1) == size(M,2)) && (sum(sum(M-eye(length(M)))) == 0))
        %Identity matrix
        poly.opcode{1} = strcat(poly.label,'#P1');
    else
        for cont=1:length(poly.data)
            poly.opcode{cont} = strcat(strcat(poly.label,'#C'),num2str(cont));
        end
    end
end

varargout{1} = poly;
if (nargout == 2)
    varargout{2} = M;
end

rolmip('setvar',poly);

return