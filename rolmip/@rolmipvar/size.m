function varargout = size(X, varargin)
%size (overloaded)
%ROLMIPopt: delega ao builtin quando o argumento nao e rolmipvar (robustez
%de despacho, necessaria no Octave) e passa a aceitar size(poly,dim).
if ~isa(X, 'rolmipvar')
    [varargout{1:max(nargout,1)}] = builtin('size', X, varargin{:});
    return
end
if ~isempty(varargin)
    d = X.dims;
    varargout{1} = d(varargin{1});
    return
end

%size (overloaded)
%
% Author: Alexandre 
% Updated by Cristiano 10/17/20
% http://octave.org/doxygen/4.0/df/d0f/ov-class_8cc_source.html
if (nargout == 0)
  varargout{1} = X.dims;%length(X.data(1).value);
elseif (nargout == 1)
  varargout{1} = X.dims;%length(X.data(1).value);
elseif (nargout == 2)
  %[m,n] = size(X.data(1).value);
  varargout{1} = X.dims(1);%varargout{1} = m;
  varargout{2} = X.dims(2);%varargout{2} = n;
else
  error("Unexpected number of outputs");
end