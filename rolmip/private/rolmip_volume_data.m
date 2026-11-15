function [factors,subspace,bernstein] = rolmip_volume_data(P,subspace)
% Validate fixed coefficients (adapted from affineProjectionData).
bernstein = [];
polynomialDegree = 0;
if isa(P,'rolmipvar')
    degree = get_degree(P);
    if all(degree == 0)
        matrices = coeffs(P);
    elseif isscalar(degree) && degree == 1
        [~,exponents] = coeffs(P);
        vertexCount = numel(exponents{1}{1});
        matrices = cell(1,vertexCount);
        for i = 1:vertexCount
            alpha = zeros(1,vertexCount);
            alpha(i) = 1;
            matrices{i} = evalpar(P,{alpha});
        end
    elseif isscalar(degree) && degree > 1 && isequal(struct(P).vertices,2)
        polynomialDegree = degree;
        [matrices,exponents] = coeffs(P);
    else
        error('ROLMIP:VolumeDegree', ...
            'Use a constant or affine P on one simplex, or a polynomial P on a two-vertex simplex.');
    end
elseif iscell(P)
    matrices = P(:).';
elseif isnumeric(P) && ismatrix(P)
    matrices = {P};
else
    error('ROLMIP:VolumeInput','Use a numeric matrix, a cell of matrices, or a fixed rolmipvar.');
end
if isempty(matrices) || isempty(matrices{1})
    error('ROLMIP:VolumeInput','P cannot be empty.');
end
n = size(matrices{1},1);
if isempty(subspace)
    subspace = 1:n;
else
    validateattributes(subspace,{'numeric'}, ...
        {'vector','real','finite','integer','positive','<=',n},'rolmip_volume','subspace');
    subspace = full(double(subspace(:).'));
    if numel(unique(subspace)) ~= numel(subspace)
        error('ROLMIP:VolumeSubspace','Coordinates in subspace must be distinct.');
    end
end

if polynomialDegree > 0
    bernstein = zeros(n*n,polynomialDegree+1);
    present = false(1,polynomialDegree+1);
else
    factors = cell(size(matrices));
end
for i = 1:numel(matrices)
    A = matrices{i};
    if ~isnumeric(A) || ~isreal(A) || ~isequal(size(A),[n n]) || any(~isfinite(A(:)))
        error('ROLMIP:VolumeCoefficient', ...
            'Vertex %d must be a fixed finite real %d-by-%d matrix. Use value(P) after synthesis.',i,n,n);
    end
    A = full(double(A));
    scale = max(abs(A(:)));
    if ~isequal(A,A.')
        scaled = A/scale;
        if norm(scaled-scaled.','fro') > 1e-10*norm(scaled,'fro')
            error('ROLMIP:VolumeSymmetry','Vertex %d must be symmetric.',i);
        end
        A = A/2 + A.'/2;
    end
    if polynomialDegree > 0
        exponent = exponents{i}{1};
        validateattributes(exponent,{'numeric'}, ...
            {'row','numel',2,'real','finite','integer','nonnegative'});
        if sum(exponent) ~= polynomialDegree || present(exponent(2)+1)
            error('ROLMIP:VolumeExponents','Expected distinct homogeneous monomials on a two-vertex simplex.');
        end
        % With t = alpha(2), convert A*(1-t)^(d-k)*t^k to Bernstein form.
        k = exponent(2);
        logBinomial = gammaln(polynomialDegree+1) - gammaln(k+1) ...
            - gammaln(polynomialDegree-k+1);
        if logBinomial <= -log(realmin)
            bernstein(:,k+1) = A(:)*exp(-logBinomial);
        else
            % Keep entries representable even if the scale alone underflows.
            bernstein(:,k+1) = sign(A(:)).*exp(log(abs(A(:)))-logBinomial);
        end
        present(k+1) = true;
    else
        factors{i} = vertexFactor(A,i);
    end
end
if polynomialDegree > 0
    factors = {vertexFactor(reshape(bernstein(:,1),n,n),1), ...
               vertexFactor(reshape(bernstein(:,end),n,n),2)};
    checkPolynomialSPD(bernstein,n);
end
end

function R = vertexFactor(A,index)
[R,flag] = chol(A);
if flag ~= 0
    error('ROLMIP:VolumePositiveDefinite','Vertex %d must be positive definite.',index);
end
end

function checkPolynomialSPD(bernstein,n)
% Positive definite Bernstein matrices certify the entire subinterval.
% Subdivide when the coefficient test is inconclusive.
pending = {bernstein};
for step = 1:10000
    if isempty(pending)
        return
    end
    coefficients = pending{end};
    pending(end) = [];
    for j = 2:size(coefficients,2)-1
        [~,flag] = chol(reshape(coefficients(:,j),n,n));
        if flag ~= 0
            [left,right] = rolmip_bernstein_split(coefficients);
            [~,flag] = chol(reshape(left(:,end),n,n));
            if flag ~= 0
                error('ROLMIP:VolumePositiveDefinite','P is not positive definite at an interior parameter.');
            end
            pending(end+1:end+2) = {right,left};
            break
        end
    end
end
if ~isempty(pending)
    error('ROLMIP:VolumePolynomialAccuracy', ...
        'Unable to verify positive definiteness on the entire interval. Check conditioning of P.');
end
end
