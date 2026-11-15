function report = rolmip_verify_constraints(F,opt,solver)
% Verify the actual YALMIP classifications; do not reinterpret elementwise
% constraints as matrix inequalities. No assignment or solver call is made.
if isempty(F),n=0;else,n=length(F);end
blank=struct('index',0,'tag','','kind','unsupported','dimensions',[], ...
    'order',NaN,'evaluable',false,'passed',false,'status','unsupported', ...
    'residual',NaN,'relative_residual',NaN,'min_eigenvalue',NaN, ...
    'symmetry_error',NaN,'scale',NaN,'tolerance',NaN,'worst_element',[], ...
    'message','');
records=repmat(blank,1,n);
for k=1:n
    r=blank;r.index=k;C=F(k);
    try
        r.tag=tag(C);
        if is(C,'sdp'),r.kind='sdp';
        elseif is(C,'elementwise'),r.kind='elementwise';
        elseif is(C,'equality'),r.kind='equality';
        else
            r.message='This constraint type is not supported by direct verification.';
            records(k)=r;continue
        end
        expression=sdpvar(C);
        if isa(expression,'sdpvar'),A=value(expression);else,A=expression;end
        r.dimensions=size(A);
        if ~isnumeric(A)||isempty(A)||any(~isfinite(A(:)))
            r.status='nonfinite_or_unassigned';records(k)=r;continue
        end
        if ~isreal(A)
            r.status='unsupported_complex';r.message='Only real constraints are supported.';
            records(k)=r;continue
        end
        A=full(double(A));
        if strcmp(r.kind,'sdp')
            if size(A,1)~=size(A,2)
                r.status='invalid_sdp_shape';records(k)=r;continue
            end
            r.order=size(A,1);r.scale=max(1,norm(A,2));
            r.symmetry_error=norm(A-A.','fro');
            if ~isfinite(r.symmetry_error),r.status='numerical_failure';records(k)=r;continue;end
            r.min_eigenvalue=min(eig(A/2+A.'/2));r.residual=r.min_eigenvalue;
        else
            r.scale=max(1,max(abs(A(:))));
            if strcmp(r.kind,'equality'),[m,idx]=max(abs(A(:)));r.residual=-m;
            else,[r.residual,idx]=min(A(:));end
            [row,col]=ind2sub(size(A),idx);r.worst_element=[row,col];
        end
        r.tolerance=opt.abs_tol+opt.rel_tol*r.scale;
        r.relative_residual=r.residual/r.scale;
        if ~all(isfinite([r.residual,r.scale,r.tolerance,r.relative_residual]))
            r.status='numerical_failure';records(k)=r;continue
        end
        r.evaluable=true;
        if strcmp(r.kind,'sdp')&&r.symmetry_error>r.tolerance,r.status='not_symmetric';
        elseif r.residual < -r.tolerance,r.status='violated';
        else,r.status='passed';r.passed=true;end
    catch err
        r.evaluable=false;r.passed=false;r.status='evaluation_error';
        r.message=sprintf('%s: %s',err.identifier,err.message);
    end
    records(k)=r;
end
passed=n>0&&all([records.passed]);allEvaluable=n>0&&all([records.evaluable]);
unsupported=find(strcmp({records.status},'unsupported')|strcmp({records.status},'unsupported_complex'));
if n==0,status='empty_set';
elseif ~isempty(unsupported),status='unsupported_constraints';
elseif ~allEvaluable,status='not_evaluable';
elseif ~passed,status='constraints_failed';
elseif solver.warning,status='constraints_passed_solver_warning';
else,status='constraints_passed';end
worst=[];idx=find([records.evaluable]);
if ~isempty(idx),[~,j]=min([records(idx).relative_residual]);worst=records(idx(j));end
report=struct('mode','constraints','status',status,'constraint_count',n, ...
    'constraints_passed',passed,'all_evaluable',allEvaluable,'constraints',records, ...
    'violated_indices',find([records.evaluable]&~[records.passed]), ...
    'unevaluable_indices',find(~[records.evaluable]),'unsupported_indices',unsupported, ...
    'worst',worst,'solver',solver,'abs_tol',opt.abs_tol,'rel_tol',opt.rel_tol, ...
    'optimality_checked',false,'samples_passed',[], ...
    'scope','Assigned-value checks of real SDP, elementwise and equality constraints; no parameter sampling or optimality/integrality check.');
end
