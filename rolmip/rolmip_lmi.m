function [F,origin] = rolmip_lmi(P,relation,name)
%ROLMIP_LMI Build coefficient LMIs with optional monomial provenance.
% [F,ORIGIN]=ROLMIP_LMI(P,'>=','Stability') constructs P(alpha)>=0.
% Use '<=' for P(alpha)<=0. Form the complete residual P first, e.g.
% A'*X+X*A or X-epsilon*eye(n). Apply POLYA before this call if desired.
% Only real symmetric coefficients affine in decisions are accepted.
% Existing >= / <= operators are unchanged. Tags name each coefficient.
% ORIGIN entries store the signed coefficient constrained to be PSD,
% monomial exponents, dimensions, and an index LOCAL to returned F.
% Constant PSD coefficients generate no constraint but remain in ORIGIN;
% constant indefinite/negative coefficients raise an error (no tolerance).
% A YALMIP variable-containing diagonal matrix can become elementwise
% inequalities; actual YALMIP classification is recorded, not assumed SDP.
% ORIGIN is session-local: do not use after yalmip('clear') or reuse IDs.
narginchk(2,3);
if ~isa(P,'rolmipvar'),error('ROLMIP:TraceInput','P must be a rolmipvar.');end
if isstring(relation)&&isscalar(relation),relation=char(relation);end
if ~ischar(relation)||~any(strcmp(relation,{'>=','<='}))
    error('ROLMIP:TraceRelation','Use >= or <= with a polynomial residual against zero.');
end
if nargin<3,name='LMI';end
if isstring(name)&&isscalar(name),name=char(name);end
if ~ischar(name)||~isrow(name)||isempty(strtrim(name)),error('ROLMIP:TraceName','Provide a nonempty condition name.');end
collecting=rolmip_check_session('active');id=[];
try
r=rolmip_check(P,'lmi',true);
if collecting,id=rolmip_check_session('record',r,relation,name);end
if ~r.lmi_ready
    q=find(strcmp({r.issues.severity},'error'),1);
    e=r.issues(q);
    error('ROLMIP:InvalidLMI','%s: coefficient %d, simplex %d: %s',e.code,e.coefficient,e.simplex,e.message);
end
p=struct(P);sgn=1;if strcmp(relation,'<='),sgn=-1;end
entries=struct('monomial',{},'exponents',{},'order',{},'coefficient',{}, ...
    'constraint_index',{},'kind',{},'tag',{});
F=[];
for k=1:numel(p.data)
    M=p.data(k).value;
    if isnumeric(M),M=double(M);end
    M=sgn*M;
    tagtext=sprintf('%s | monomial %d | exponents %s',name,k,exponent_text(p.data(k).exponent));
    ci=r.coefficients(k);idx=[];
    if ~isa(M,'sdpvar') || isempty(ci.variables)
        if isa(M,'sdpvar'),M=double(M);end
        if min(eig(full(M)))<0
            error('ROLMIP:ConstantInfeasible','%s: constant coefficient is not positive semidefinite.',tagtext);
        end
        kind='constant_psd';
    else
        C=tag(M>=0,tagtext);
        info=lmiinfo(C);
        if ~isempty(info.sdp),kind='sdp';else,kind='elementwise';end
        idx=length(F)+(1:length(C));F=[F,C]; %#ok<AGROW>
    end
    entries(k)=struct('monomial',k,'exponents',{p.data(k).exponent}, ...
        'order',size(M,1),'coefficient',M,'constraint_index',idx,'kind',kind,'tag',tagtext);
end
if nargout>1
    origin=struct('schema','rolmip_lmi_trace_v1','name',name,'relation',relation, ...
        'label',p.label,'vertices',p.vertices,'degree',r.degree,'entries',entries, ...
        'V',0,'L',0,'constraint_count',length(F));
    if ~isempty(F),info=lmiinfo(F);origin.V=numel(getvariables(F));origin.L=sum(info.sdp(:,1));end
end
catch err
    if collecting,rolmip_check_session('failure',err,relation,id);end
    rethrow(err);
end
end
function text=exponent_text(e)
parts=cellfun(@mat2str,e,'UniformOutput',false);text=strjoin(parts,'; ');
end
