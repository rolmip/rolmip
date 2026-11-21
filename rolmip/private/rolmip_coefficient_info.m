function info = rolmip_coefficient_info(M)
% Structural inspection, independent of assigned decision-variable values.
info=struct('supported',false,'finite',false,'real',false,'affine',false, ...
    'symmetric',false,'size',size(M),'variables',[]);
if ~(isnumeric(M) || isa(M,'sdpvar')) || ndims(M)~=2 || isempty(M),return;end
info.supported=true;
if isa(M,'sdpvar')
    B=getbase(M);
    info.finite=all(isfinite(nonzeros(B)));
    info.real=is(M,'real');
    % Graph/extended operators can look linear in YALMIP's auxiliary IDs.
    % This API accepts direct affine expressions, not their graph models.
    info.variables=depends(M);
    info.affine=is(M,'linear') && isempty(intersect(info.variables,yalmip('extvariables')));
    if size(M,1)==size(M,2)
        D=M-M.';
        if isa(D,'sdpvar'),D=getbase(D);end
        info.symmetric=nnz(D)==0;
    end
else
    info.finite=all(isfinite(M(:)));
    info.real=isreal(M);info.affine=true;
    info.symmetric=isequal(M,M.');
end
end
