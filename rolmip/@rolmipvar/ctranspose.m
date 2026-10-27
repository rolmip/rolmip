function X=ctranspose(atual)
%ROLMIPopt: delega ao builtin quando o(s) argumento(s) nao sao rolmipvar
%(robustez de despacho, necessaria no Octave).
if ~isa(atual, 'rolmipvar')
    X = builtin('ctranspose', atual);
    return
end

%TRANSPOSE (overloaded)
%
% Author: Alexandre Felipe
% 2014, Dec, 8
X = atual;
if ((~isempty(find(X.label == '+',1))) || (~isempty(find(X.label == '-',1))) || (~isempty(find(X.label == '*',1))))
    %The label corresponds not only to a variable, but to an expression
    pre = '(';
    aft = ')';
else
    pre = '';
    aft = '';
end

for i = 1:length(atual.data)
    X.data(i).value = (atual.data(i).value)';
    X.opcode{i} = strcat(pre,atual.opcode{i}, aft, char(39));
    if isempty(atual.opcode{i}), X.opcode{i} = ''; end
end
X.label = [pre,atual.label,aft, char(39)];


X.dims = size(X.data(1).value);
