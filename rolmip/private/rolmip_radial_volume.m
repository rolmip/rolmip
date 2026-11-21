function [volume,info] = rolmip_radial_volume(factors,info,omitted,needsLift,options,logUnitBall,bernstein)
% Adapted from volumeProjectionRadial. One shared lift per radial direction.
dimension = numel(info.subspace);
n = size(factors{1},1);
count = double(options.NumDirections);
if dimension == 1
    directions = 1;
elseif dimension == 2
    if isempty(count)
        count = 360;
    end
    if count < 8 || mod(count,2) ~= 0
        error('ROLMIP:VolumeDirections','For 2D use an even NumDirections >= 8.');
    end
    theta = (0:count/2-1)*2*pi/count;
    directions = [cos(theta);sin(theta)];
else
    if isempty(count)
        count = 1000;
    end
    if dimension == 3 && options.plot && count < 3
        error('ROLMIP:VolumeDirections','For a 3D plot use at least three directions.');
    end
    stream = RandStream('mt19937ar','Seed',double(options.Seed));
    directions = randn(stream,dimension,count);
    directions = directions./sqrt(sum(directions.^2,1));
end

if needsLift
    [radii,lifts] = projectDirections(factors,directions,info.subspace,omitted,options.Solver);
    info.nOptimizationProblems = size(directions,2);
else
    if isempty(bernstein)
        % A ray with zero omitted coordinates meets the first active ellipsoid.
        inverseRadii = zeros(1,size(directions,2));
        for i = 1:numel(factors)
            alongRay = factors{i}(:,info.subspace)*directions;
            inverseRadii = max(inverseRadii,vecnorm(alongRay,2,1));
        end
    else
        [rows,cols] = ndgrid(info.subspace);
        indices = sub2ind([n n],rows,cols);
        coefficients = bernstein(indices(:),:);
        quadratics = zeros(size(coefficients,2),size(directions,2));
        for k = 1:size(coefficients,2)
            B = reshape(coefficients(:,k),dimension,dimension);
            quadratics(k,:) = sum(directions.*(B*directions),1);
        end
        inverseRadii = zeros(1,size(directions,2));
        gaps = zeros(size(inverseRadii));
        for j = 1:numel(inverseRadii)
            [upper,gaps(j)] = polynomialMaximum(quadratics(:,j).');
            inverseRadii(j) = sqrt(upper);
        end
        info.radialMaxRelativeGap = max(gaps);
    end
    radii = 1./inverseRadii;
    lifts = zeros(n,numel(radii));
    lifts(info.subspace,:) = directions.*radii;
end
if any(~isfinite(radii)) || any(radii <= 0)
    error('ROLMIP:VolumeNumerics','The radial lengths are outside the numerical range.');
end

% Accumulate the radial moments relative to the largest sample.
logScale = logUnitBall + dimension*log(max(radii));
moments = (radii/max(radii)).^dimension;
volume = exp(logScale + log(mean(moments)));
if dimension == 1
    info.method = 'interval';
elseif dimension == 2
    info.method = 'angular quadrature';
else
    info.method = 'spherical Monte Carlo';
    info.standardError = exp(logScale + log(std(moments,0)/sqrt(numel(moments))));
end
if dimension <= 2 || (dimension == 3 && options.plot)
    lifts = [lifts -lifts];
end
info.boundaryZ = lifts;
info.boundaryX = lifts(info.subspace,:);
end

function [upper,relativeGap] = polynomialMaximum(coefficients)
% Bernstein coefficient maxima bound each interval. The sampled midpoint
% and endpoints bound the global maximum from below.
lower = max(coefficients([1 end]));
if ~all(isfinite(coefficients)) || lower <= 0
    error('ROLMIP:VolumeNumerics','Invalid directional polynomial coefficients.');
end
upper = lower;
pending = {coefficients};
for step = 1:10000
    if isempty(pending)
        break
    end
    coefficients = pending{end};
    pending(end) = [];
    bound = max(coefficients);
    if bound-lower <= 1e-10*lower
        upper = max(upper,bound);
    else
        [left,right] = rolmip_bernstein_split(coefficients);
        lower = max(lower,left(end));
        % Explore the more promising half first to improve pruning.
        if max(left) >= max(right)
            pending(end+1:end+2) = {right,left};
        else
            pending(end+1:end+2) = {left,right};
        end
    end
end
if ~isempty(pending)
    error('ROLMIP:VolumePolynomialAccuracy','Unable to bound a directional maximum to the requested accuracy.');
end
upper = max(upper,lower);
relativeGap = (upper-lower)/lower;
end

function [radii,lifts] = projectDirections(factors,directions,subspace,omitted,solver)
if isempty(which('sdpvar')) || isempty(which('optimizer'))
    error('ROLMIP:VolumeYALMIP','Add YALMIP and a conic solver to project this intersection.');
end
n = size(factors{1},1);
% The direction enters as an affine coefficient in d*r. YALMIP compiles
% the model once and substitutes d before solving each numerical SOCP.
d = sdpvar(numel(subspace),1,'full');
r = sdpvar(1,1);
z = sdpvar(n,1,'full');
constraints = [r>=0, z(subspace)==d*r];
for i = 1:numel(factors)
    constraints = [constraints,cone(factors{i}*z,1)]; %#ok<AGROW>
end
if isempty(solver)
    % A fixed conic solver is needed for this parameterized model. Select
    % it using a linear SOCP with the same cones and a fixed direction.
    settings = sdpsettings('verbose',0);
    probe = replace(constraints,d,directions(:,1));
    [~,~,diagnostics,model] = export(probe,-r,settings,[],[],0);
    if ~isempty(diagnostics) && diagnostics.problem ~= 0
        error('ROLMIP:VolumeSolver','Unable to select a conic solver: %s',diagnostics.info);
    end
    solver = model.solver.tag;
end
settings = sdpsettings('solver',char(solver),'verbose',0);
solveRay = optimizer(constraints,-r,settings,d,[r;z(omitted)]);
radii = zeros(1,size(directions,2));
lifts = zeros(n,numel(radii));
worstResidual = 0;
for j = 1:numel(radii)
    [answer,problem] = solveRay(directions(:,j));
    if problem ~= 0
        error('ROLMIP:VolumeSolver','Direction %d: %s',j,yalmiperror(problem));
    end
    if any(~isfinite(answer)) || answer(1) <= 0
        error('ROLMIP:VolumeNumerics','Invalid solution at direction %d.',j);
    end
    point = zeros(n,1);
    point(subspace) = answer(1)*directions(:,j);
    point(omitted) = answer(2:end);
    maxNorm = 0;
    for i = 1:numel(factors)
        maxNorm = max(maxNorm,norm(factors{i}*point));
    end
    if ~isfinite(maxNorm)
        error('ROLMIP:VolumeNumerics','Invalid constraint value at direction %d.',j);
    end
    worstResidual = max(worstResidual,maxNorm-1);
    % Apply any feasibility correction to the entire lift.
    shrink = (1-1e-9)/max(1,maxNorm);
    radii(j) = answer(1)*shrink;
    lifts(:,j) = point*shrink;
end
if worstResidual > 1e-5
    warning('ROLMIP:VolumeResidual', ...
        'Largest radial solver residual %.3g. Consider scaling P or changing solver.',worstResidual);
end
end
