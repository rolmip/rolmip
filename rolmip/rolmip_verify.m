function report = rolmip_verify(origin,varargin)
%ROLMIP_VERIFY Verify a YALMIP constraint set or a polynomial certificate.
% R=ROLMIP_VERIFY(LMIs,'solver',diagnostics) inspects real SDP blocks,
% elementwise inequalities and equalities at the currently assigned values.
% R.constraints records indices, tags, residuals and failed/unevaluable blocks.
% Other constraint types are reported unsupported, never silently accepted.
% Parametric POINTS require a polynomial ORIGIN; LMIs alone lack this metadata.
% Empty constraints return status empty_set (no affirmative verification).
% R=ROLMIP_VERIFY(ORIGIN) uses values currently assigned in YALMIP.
% R=ROLMIP_VERIFY(ORIGIN,'solver',diagnostics,'abs_tol',1e-8,'rel_tol',1e-8)
% also records OPTIMIZE diagnostics. A warning/failure status from the solver
% is kept separate from certificate acceptance; no optimality is asserted.
% Optional 'points' is a cell of sample points; each point is a cell with
% one barycentric row per simplex, e.g. {{[1 0]}, {[.5 .5]}}.
% For absent simplexes use 1. Samples are diagnostic, never a domain proof.
% A signed coefficient A passes if it is finite, real, symmetric within
% tolerance, and lambda_min((A+A')/2)>=-(abs_tol+rel_tol*max(1,norm(A,2))).
% Symmetry is checked with the Frobenius norm against the same tolerance.
% Coefficient PSD is sufficient on the product of unit simplexes. Failure
% of this sufficient certificate does not prove the polynomial is indefinite.
% Results are floating-point checks, not interval certificates. Do not call
% after clearing YALMIP or use an origin from a different MATLAB session.
parser=inputParser;
isTol=@(x)isnumeric(x)&&isreal(x)&&isscalar(x)&&isfinite(x)&&x>=0;
addParameter(parser,'abs_tol',1e-8,isTol);addParameter(parser,'rel_tol',1e-8,isTol);
addParameter(parser,'points',{},@iscell);addParameter(parser,'solver',[],@(x)isempty(x)||(isstruct(x)&&isscalar(x)));
parse(parser,varargin{:});opt=parser.Results;
solver=struct('provided',false,'problem',NaN,'info','','warning',false);
if ~isempty(opt.solver)
    if ~isfield(opt.solver,'problem')||~isnumeric(opt.solver.problem)|| ...
            ~isscalar(opt.solver.problem)||~isfinite(opt.solver.problem)
        error('ROLMIP:SolverDiagnostics','Solver diagnostics must contain a finite scalar problem code.');
    end
    solver.provided=true;solver.problem=opt.solver.problem;solver.warning=solver.problem~=0;
    if isfield(opt.solver,'info'),solver.info=opt.solver.info;end
end
if isa(origin,'lmi') || isa(origin,'constraint') || (isnumeric(origin)&&isempty(origin))
    if ~isempty(opt.points)
        error('ROLMIP:PointsNeedOrigin','LMIs do not retain polynomial exponents. Use an origin from rolmip_lmi to evaluate points.');
    end
    report=rolmip_verify_constraints(origin,opt,solver);
    return
end
if ~isstruct(origin)||~isscalar(origin)||~isfield(origin,'schema')|| ...
        ~strcmp(origin.schema,'rolmip_lmi_trace_v1')||~all(isfield(origin,{'name','vertices','entries'}))||isempty(origin.entries)
    error('ROLMIP:VerifyInput','Use a YALMIP constraint set or the origin returned by rolmip_lmi.');
end
points=opt.points;v=origin.vertices;
for k=1:numel(points)
    a=points{k};
    if ~iscell(a)||numel(a)~=numel(v),error('ROLMIP:SamplePoint','Each point must contain one row per simplex.');end
    for j=1:numel(v)
        z=a{j};
        if ~isnumeric(z)||~isreal(z)||~isrow(z)||numel(z)~=max(1,v(j))|| ...
                any(~isfinite(z))||any(z<0)||abs(sum(z)-1)>1e-10
            error('ROLMIP:SamplePoint','Points must be finite nonnegative barycentric rows summing to one.');
        end
    end
end
n=numel(origin.entries);values=cell(1,n);records=cell(1,n);
for k=1:n
    entry=origin.entries(k);M=entry.coefficient;
    if isa(M,'sdpvar'),M=value(M);end
    values{k}=M;
    records{k}=inspect(M,opt);
    records{k}.monomial=entry.monomial;
    records{k}.exponents=entry.exponents;
    records{k}.constraint_index=entry.constraint_index;
    records{k}.kind=entry.kind;
    records{k}.tag=entry.tag;
end
coefficients=[records{:}];
samples=struct('point',{},'result',{});
for k=1:numel(points)
    A=zeros(size(values{1}));
    for c=1:n
        weight=1;e=origin.entries(c).exponents;
        for j=1:numel(v)
            if all(e{j}==0),continue;end
            weight=weight*prod(points{k}{j}.^e{j});
        end
        % Do not hide unassigned/nonfinite coefficients even at zero weight.
        A=A+weight*values{c};
    end
    samples(k)=struct('point',{points{k}},'result',inspect(A,opt));
end
passed=all([coefficients.passed]);evaluable=all([coefficients.evaluable]);
samplePassed=[];
if ~isempty(samples),s=[samples.result];samplePassed=all([s.passed]);end
if ~evaluable,status='not_evaluable';
elseif ~passed,status='certificate_failed';
elseif ~isempty(samplePassed)&&~samplePassed,status='sample_check_failed';
elseif solver.warning,status='certificate_passed_solver_warning';
else,status='certificate_passed';end
worst=[];
if evaluable
    [~,index]=min([coefficients.relative_residual]);worst=coefficients(index);
end
report=struct('name',origin.name,'relation',origin.relation,'status',status, ...
    'certificate_passed',passed,'samples_passed',samplePassed,'solver',solver, ...
    'abs_tol',opt.abs_tol,'rel_tol',opt.rel_tol,'coefficients',coefficients, ...
    'samples',samples,'worst',worst,'optimality_checked',false, ...
    'scope','Floating-point coefficient certificate on unit simplexes; sampling is diagnostic only.');
end
function r=inspect(A,opt)
r=struct('evaluable',false,'passed',false,'status','nonfinite_or_unassigned', ...
    'min_eigenvalue',NaN,'relative_residual',NaN,'symmetry_error',NaN, ...
    'relative_symmetry_error',NaN,'scale',NaN,'tolerance',NaN);
if ~isnumeric(A)||isempty(A)||any(~isfinite(A(:))),return;end
if ~isreal(A)||size(A,1)~=size(A,2),r.status='not_real_square';return;end
A=full(double(A));r.scale=max(1,norm(A,2));
r.tolerance=opt.abs_tol+opt.rel_tol*r.scale;
r.symmetry_error=norm(A-A.','fro');r.relative_symmetry_error=r.symmetry_error/r.scale;
if ~all(isfinite([r.scale,r.tolerance,r.symmetry_error]))
    r.status='numerical_failure';return
end
r.min_eigenvalue=min(eig(A/2+A.'/2));r.relative_residual=r.min_eigenvalue/r.scale;
if ~isfinite(r.min_eigenvalue),r.status='numerical_failure';return;end
r.evaluable=true;
if r.symmetry_error>r.tolerance,r.status='not_symmetric';
elseif r.min_eigenvalue < -r.tolerance,r.status='violated';
else,r.status='passed';r.passed=true;end
end
