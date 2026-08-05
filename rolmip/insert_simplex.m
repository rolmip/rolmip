function [varargout] = insert_simplex(varargin)
% Procedure to insert a new multisimplex variable in an already existent
% polynomial variable
%
% [poly,M] = insert_simplex(poly,vertices)
% Inserts, in the variable poly, the multisimplex with the given number of
% vertices and degrees. Both the vertices and the degrees correspond
% to a row vector.
%
% [poly,M] = insert_simplex(label,vertices)
% Inserts the new multisimplex in the polynomial with the given label.

if (nargin ~= 2)
    error('Input error. Type ''help insert_simplex'' for more details');
    return
end

if ischar(varargin{1})
    label = varargin{1};
    poly = rolmip('getvar',label);
    if isempty(poly)
        error('The informed label does not correspond to any polynomial');
        return
    end
else
    poly = varargin{1};
    label = poly.label;
end

vertices = varargin{2};

newvertices = [poly.vertices vertices];
newdegrees = [];
for cont=1:length(poly.vertices)
    newdegrees = [newdegrees sum(poly.data(1).exponent{cont})];
end
newdegrees = [newdegrees zeros(1,length(vertices))];

numsimplex = length(poly.data(1).exponent);
for cont=1:length(poly.data)
    for contsimplex=1:numsimplex
        M{cont}{contsimplex} = poly.data(cont).exponent{contsimplex};
    end
    for continsert=1:length(vertices)
        M{cont}{numsimplex+continsert} = [0];
    end
    M{cont}{numsimplex+length(vertices)+1} = poly.data(cont).value;
end
[poly,M] = poly_struct(M,label,newvertices,newdegrees);

if (nargout == 1)
    varargout{1} = poly;
elseif (nargout == 2)
    varargout{1} = poly;
    varargout{2} = M;
end

return