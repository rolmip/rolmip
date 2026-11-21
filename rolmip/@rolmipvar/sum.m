function Z = sum(X, varargin)
%SUM (overloaded)
%ROLMIPopt: delega ao builtin quando o argumento nao e rolmipvar.
if ~isa(X, 'rolmipvar')
    Z = builtin('sum', X, varargin{:});
    return
end

%SUM (overloaded)
%
% Author: Cristiano M. Agulhari
% 2016, Nov, 18

Z = 0;
for cont=1:length(X.data)
    Z = Z + X.data(cont).value;
end
