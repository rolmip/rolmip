function report = rolmip_check(P,varargin)
%ROLMIP_CHECK Diagnose a polynomial without constructing constraints.
% R=ROLMIP_CHECK(P) accepts a rolmipvar or its scalar struct for diagnostics.
% R=ROLMIP_CHECK(P,'lmi',true) also requires real, exactly symmetric,
% square coefficients affine in YALMIP decision variables. Polynomial
% degrees refer to uncertain parameters and need not be one.
% R.issues locates problems by coefficient and simplex (0 means global).
% Nonlinear/extended decision expressions and nonsymmetry are warnings in
% general-polynomial mode and errors in LMI mode. No repair is performed.
% Missing monomials are reported as a warning (sparse support is allowed).
parser=inputParser;addParameter(parser,'lmi',false,@(x)islogical(x)&&isscalar(x));
parse(parser,varargin{:});requireLMI=parser.Results.lmi;
report=struct('valid',false,'lmi_ready',false,'label','','vertices',[], ...
    'degree',[],'dimensions',[],'stored_monomials',0,'expected_monomials',NaN, ...
    'affine',true,'symmetric',true,'real',true,'coefficients',[], ...
    'issues',struct('severity',{},'code',{},'coefficient',{},'simplex',{},'message',{}));
if isa(P,'rolmipvar'),P=struct(P);end
if ~isstruct(P)||~isscalar(P)||~all(isfield(P,{'vertices','data'}))
    issue('error','Structure',0,0,'Expected a rolmipvar or its scalar struct.');return
end
if isfield(P,'label') && ischar(P.label),report.label=P.label;end
v=P.vertices;report.vertices=v;
if ~isnumeric(v)||~isreal(v)||isempty(v)||~isrow(v)||any(~isfinite(v))||any(v<0)||any(v~=fix(v))
    issue('error','Vertices',0,0,'Vertices must be a nonempty row of finite nonnegative integers.');return
end
if ~isstruct(P.data)||isempty(P.data)||~all(isfield(P.data,{'value','exponent'}))
    issue('error','Data',0,0,'Missing coefficient values or exponent cells.');return
end
ns=numel(v);n=numel(P.data);report.stored_monomials=n;
deg=nan(n,ns);rows=nan(n,sum(max(v,1)));infos=cell(1,n);
for k=1:n
    e=P.data(k).exponent;offset=0;
    if ~iscell(e)||numel(e)~=ns
        issue('error','ExponentCells',k,0,'One exponent vector per simplex is required.');
    else
        for j=1:ns
            z=e{j};width=max(1,v(j));
            if ~isnumeric(z)||~isreal(z)||isempty(z)||~isrow(z)||any(~isfinite(z))||any(z<0)||any(z~=fix(z))
                issue('error','ExponentValues',k,j,'Exponents must be finite nonnegative integer rows.');
            elseif numel(z)~=width && ~all(z==0)
                issue('error','ExponentLength',k,j,'Exponent length does not match the simplex.');
            elseif v(j)==0 && any(z~=0)
                issue('error','AbsentSimplexDegree',k,j,'An absent simplex must have degree zero.');
            else
                deg(k,j)=sum(z);
                if all(z==0),z=zeros(1,width);end
                rows(k,offset+(1:width))=z;
            end
            offset=offset+width;
        end
    end
    ci=rolmip_coefficient_info(P.data(k).value);infos{k}=ci;
    if ~ci.supported,issue('error','CoefficientType',k,0,'Coefficients must be nonempty numeric or sdpvar matrices.');end
    if ~ci.finite,issue('error','NonfiniteCoefficient',k,0,'Coefficient data or symbolic basis contains NaN/Inf, or is unsupported.');end
    if k==1,report.dimensions=ci.size;
    elseif ~isequal(ci.size,report.dimensions),issue('error','CoefficientDimensions',k,0,'Coefficient dimensions differ.');end
    report.affine=report.affine&&ci.affine;
    report.symmetric=report.symmetric&&ci.symmetric;
    report.real=report.real&&ci.real;
    severity='warning';if requireLMI,severity='error';end
    if ~ci.affine,issue(severity,'NonAffineDecision',k,0,'Coefficient is nonlinear in decisions or contains an extended YALMIP operator.');end
    if ~ci.symmetric,issue(severity,'NotSymmetric',k,0,'Coefficient is not structurally symmetric and square.');end
    if ~ci.real,issue(severity,'NotReal',k,0,'This LMI diagnostic supports real symmetric coefficients.');end
end
report.coefficients=[infos{:}];
if isfield(P,'dims')&&~isequal(P.dims,report.dimensions)
    issue('error','StoredDimensions',0,0,'Stored dims disagree with coefficient dimensions.');
end
if all(isfinite(deg(:)))
    report.degree=deg(1,:);
    for j=1:ns
        if any(deg(:,j)~=deg(1,j)),issue('error','NotHomogeneous',0,j,'Monomial degrees differ within the simplex.');end
    end
    counts=ones(1,ns);
    for j=1:ns
        if v(j)>1,counts(j)=exp(gammaln(v(j)+deg(1,j))-gammaln(v(j))-gammaln(deg(1,j)+1));end
    end
    report.expected_monomials=round(prod(counts));
end
if all(isfinite(rows(:)))
    if size(unique(rows,'rows'),1)~=n,issue('error','DuplicateMonomial',0,0,'Repeated monomials must be combined before construction.');end
    if n<report.expected_monomials,issue('warning','SparseSupport',0,0,'Some monomials are absent; only stored coefficients are inspected.');end
end
report.valid=~any(strcmp({report.issues.severity},'error'));
report.lmi_ready=report.valid&&report.affine&&report.symmetric&&report.real;
    function issue(severity,code,k,j,message)
        report.issues(end+1)=struct('severity',severity,'code',code,'coefficient',k,'simplex',j,'message',message);
    end
end
