function varargout = size(X, varargin)
%SIZE Matrix dimensions, using the stored coefficient dimensions.
if ~isa(X, 'rolmipvar')
    [varargout{1:max(nargout,1)}] = builtin('size', X, varargin{:});
    return
end
d = X.dims;
if ~isempty(varargin)
    if numel(varargin) ~= 1 || nargout > 1
        error('ROLMIP:SizeArguments', 'Use one output with size(P,dim).');
    end
    dim = varargin{1};
    validateattributes(dim, {'numeric'}, {'real','finite','vector','nonempty','integer','positive'}, mfilename, 'dim');
    result = ones(size(dim));
    present = dim <= numel(d);
    result(present) = d(dim(present));
    varargout{1} = result;
elseif nargout <= 1
    varargout{1} = d;
else
    for k = 1:nargout
        if k > numel(d)
            varargout{k} = 1;
        elseif k == nargout
            varargout{k} = prod(d(k:end));
        else
            varargout{k} = d(k);
        end
    end
end
end
