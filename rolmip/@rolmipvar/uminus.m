function Z = uminus(X, Y)
%ROLMIPopt: delega ao builtin quando o(s) argumento(s) nao sao rolmipvar
%(robustez de despacho, necessaria no Octave).
if ~isa(X, 'rolmipvar')
    Z = builtin('uminus', X);
    return
end

%MINUS (overloaded)
%
% Author: Alexandre Felipe
% 2014, Dec, 8
Z = X;
for i = 1:length(X.data)
  Z.data(i).value = -(X.data(i).value);
  Z.opcode{i} = strcat('-', X.opcode{i});
end
Z.label = strcat('-', X.label);
