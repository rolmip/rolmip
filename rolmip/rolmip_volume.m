function [volume,info] = rolmip_volume(P,varargin)
%ROLMIP_VOLUME Volume and optional plot of a quadratic region.
%   V = ROLMIP_VOLUME(P) measures {x : x'*P*x <= 1}. P can be a real
%   symmetric positive definite matrix, a cell of such vertex matrices, or
%   a fixed constant or affine ROLMIPVAR on one simplex. Polynomial
%   ROLMIPVAR of any degree on a two-vertex simplex is supported for the
%   full region and cuts. P must be positive definite for every parameter.
%   After synthesis, pass VALUE(P) to supply fixed coefficients. The
%   inequality must hold for all parameters, so the region is an intersection.
%
%   Name-value options:
%     'subspace'  Coordinate indices in the requested order (default 1:n).
%                  A scalar selects that coordinate alone.
%     'reduction' 'projection' (default) or 'cut'. Projection eliminates
%                  the omitted coordinates using one common lift for all
%                  vertices. Cut fixes the omitted coordinates to zero.
%     'plot'      0 (default) or 1. Draw the region in 2D or 3D.
%     'color'     RGB triplet in [0,1] or a MATLAB color name (e.g. 'red').
%                  Default [0.11 0.45 0.66].
%     'FaceAlpha' Opacity of the 3D surface, from 0 (invisible) to
%                  1 (opaque, default). Applies to 3D plots only.
%     'drawVertices' 0 (default) or 1. Overlay the dotted contours of the
%                  individual vertex ellipsoids, projected or cut on the
%                  same coordinates as the region. Applies to 2D plots
%                  with multiple vertices only.
%     'NumDirections' Default 360 in 2D (even, >=8), 1000 in 3D and above.
%                     Only used for intersections of multiple ellipsoids.
%     'Solver'    YALMIP conic solver for projections with omitted
%                  coordinates (default: let YALMIP select a solver).
%     'Seed'      Local sampling seed in dimension >=3 (default 1).
%
%   [V,INFO] returns the method, selected coordinates, boundary points
%   (columns of boundaryX, in the order of subspace), their feasible lifts
%   (boundaryZ, in the original coordinates), and the plot handle, if any.
%   In 2D, INFO.contour is INFO.boundaryX with the first point repeated
%   at the end. It is available even with plotting disabled:
%     [~,info] = rolmip_volume(P,'subspace',[1 2]);
%     plot(info.contour(1,:),info.contour(2,:)); axis equal
%   The single-ellipsoid formula uses no solver or quadrature. In this case,
%   boundary points are generated for the plot or for the 2D INFO output.
%   For intersections,
%   1D measures the interval, 2D uses angular quadrature, and dimension >=3
%   uses spherical Monte Carlo; INFO.standardError measures sampling error
%   only. A plot of an intersection is an inscribed approximation.
%   For polynomial P, INFO.radialMaxRelativeGap reports the largest
%   relative gap between the numerical Bernstein bounds for the directional
%   maxima (target 1e-10). This is separate from the integration error.
%
%   Example 1 (2D): projection of a two-vertex region onto (x1,x3).
%     P = {[4 0 1; 0 2 0; 1 0 1], [1 0 0; 0 2 1; 0 1 4]};
%     V = rolmip_volume(P,'subspace',[1 3],'plot',1,'drawVertices',1);
%     % This projection uses YALMIP and a conic solver.
%
%   Example 2 (3D): plot the full two-vertex region.
%     P = rolmipvar({diag([4 1 2]),diag([1 4 2])},'P',2,1);
%     V = rolmip_volume(P,'plot',1,'color',[0.55 0.28 0.70],'FaceAlpha',0.4);

parser = inputParser;
addParameter(parser,'subspace',[]);
addParameter(parser,'reduction','projection');
isToggle = @(x) isscalar(x) && ...
    (islogical(x) || (isnumeric(x) && isreal(x) && ismember(x,[0 1])));
addParameter(parser,'plot',false,isToggle);
addParameter(parser,'drawVertices',false,isToggle);
addParameter(parser,'color',[0.11 0.45 0.66]);
addParameter(parser,'FaceAlpha',1,@(x) isnumeric(x) && isscalar(x) && ...
    isreal(x) && isfinite(x) && x>=0 && x<=1);
addParameter(parser,'NumDirections',[],@(x) isempty(x) || ...
    (isnumeric(x) && isreal(x) && isscalar(x) && isfinite(x) && x>=2 && x==fix(x)));
addParameter(parser,'Solver','',@(x) ischar(x) || (isstring(x) && isscalar(x)));
addParameter(parser,'Seed',1,@(x) isnumeric(x) && isreal(x) && isscalar(x) ...
    && isfinite(x) && x>=0 && x<=2^32-1 && x==fix(x));
parse(parser,varargin{:});
options = parser.Results;
if isnumeric(options.color)
    validateattributes(options.color,{'numeric'}, ...
        {'vector','numel',3,'real','finite','>=',0,'<=',1},mfilename,'color');
    color = full(double(options.color(:).'));
else
    color = validatestring(options.color, ...
        {'red','green','blue','cyan','magenta','yellow','black','white', ...
         'r','g','b','c','m','y','k','w'},mfilename,'color');
end
reduction = validatestring(options.reduction,{'projection','cut'},mfilename,'reduction');
[factors,subspace,bernstein] = rolmip_volume_data(P,options.subspace);
n = size(factors{1},1);
dimension = numel(subspace);
if options.plot && ~ismember(dimension,[2 3])
    error('ROLMIP:VolumePlotDimension','Plotting requires two or three selected coordinates.');
end

unitBallLogVolume = dimension/2*log(pi) - gammaln(dimension/2+1);
info = struct('subspace',subspace,'reduction',reduction, ...
    'nVertices',numel(factors),'nOptimizationProblems',0, ...
    'standardError',NaN,'boundaryX',[],'boundaryZ',[],'contour',[],'plotHandle',[]);
omitted = setdiff(1:n,subspace,'stable');
needsLift = strcmp(reduction,'projection') && ~isempty(omitted);
if needsLift && ~isempty(bernstein)
    error('ROLMIP:VolumePolynomialProjection', ...
        'For polynomial P, use the full region or select reduction cut.');
end

if numel(factors) == 1
    R = factors{1};
    if needsLift
        [U,T] = projectedFactor(R,subspace);
        logScale = sum(log(abs(diag(T))));
    else
        % For a cut, the precision is P(subspace,subspace).
        if dimension == n
            T = R;
        else
            [~,T] = qr(R(:,subspace),0);
        end
        logScale = -sum(log(abs(diag(T))));
    end
    volume = exp(unitBallLogVolume + logScale);
    info.method = 'ellipsoid formula';
    if options.plot || (dimension == 2 && nargout > 1)
        if dimension == 2
            theta = (0:359)*2*pi/360;
            unit = [cos(theta);sin(theta)];
        else
            [x,y,z] = sphere(40);
            unit = [x(:).';y(:).';z(:).'];
        end
        if needsLift
            info.boundaryX = T.'*unit;
            info.boundaryZ = R\(U*unit);
        elseif dimension == n
            info.boundaryZ = T\unit;
            info.boundaryX = info.boundaryZ(subspace,:);
        else
            info.boundaryX = T\unit;
            info.boundaryZ = zeros(n,size(unit,2));
            info.boundaryZ(subspace,:) = info.boundaryX;
        end
    end
else
    [volume,info] = rolmip_radial_volume(factors,info,omitted,needsLift, ...
        options,unitBallLogVolume,bernstein);
end

if dimension == 2 && ~isempty(info.boundaryX)
    info.contour = [info.boundaryX info.boundaryX(:,1)];
end
if options.plot
    info.plotHandle = drawRegion(info,volume,color,double(options.FaceAlpha));
    if options.drawVertices && dimension == 2 && numel(factors) > 1
        drawVertexContours(ancestor(info.plotHandle,'axes'),factors,subspace,needsLift,color);
    end
end
end

function [U,T] = projectedFactor(R,subspace)
% Q=S'*(P\S)=W'*W is the projected shape. Factor W directly.
dimension = numel(subspace);
S = sparse(subspace,1:dimension,ones(1,dimension),size(R,1),dimension);
W = R.'\full(S);
[U,T] = qr(W,0);
end

function drawVertexContours(ax,factors,subspace,needsLift,color)
theta = linspace(0,2*pi,361);
unit = [cos(theta);sin(theta)];
for i = 1:numel(factors)
    R = factors{i};
    if needsLift
        [~,T] = projectedFactor(R,subspace);
        border = T.'*unit;
    else
        [~,T] = qr(R(:,subspace),0);
        border = T\unit;
    end
    line(ax,border(1,:),border(2,:),'Color',color, ...
        'LineStyle',':','LineWidth',1.5,'DisplayName',sprintf('Vertex %d',i));
end
end

function handle = drawRegion(info,volume,color,faceAlpha)
points = info.boundaryX;
dimension = size(points,1);
figureHandle = figure('Name','ROLMIP quadratic region','Color','w');
ax = axes('Parent',figureHandle);
if dimension == 2
    handle = patch(ax,points(1,:),points(2,:),color, ...
        'FaceAlpha',0.25,'EdgeColor',color,'LineWidth',1.5);
else
    if strcmp(info.method,'ellipsoid formula')
        gridSize = sqrt(size(points,2));
        handle = surf(ax,reshape(points(1,:),gridSize,gridSize), ...
            reshape(points(2,:),gridSize,gridSize), ...
            reshape(points(3,:),gridSize,gridSize), ...
            'FaceColor',color,'EdgeColor','none');
    else
        % Convex hull is unchanged by positive coordinate scaling.
        scaled = points./max(abs(points),[],2);
        faces = convhull(scaled(1,:),scaled(2,:),scaled(3,:));
        handle = trisurf(faces,points(1,:),points(2,:),points(3,:), ...
            'Parent',ax,'FaceColor',color,'EdgeColor','none');
    end
    set(handle,'FaceAlpha',faceAlpha);
    zlabel(ax,sprintf('x_{%d}',info.subspace(3)));
    view(ax,3);
    camlight(ax,'headlight');
end
xlabel(ax,sprintf('x_{%d}',info.subspace(1)));
ylabel(ax,sprintf('x_{%d}',info.subspace(2)));
axis(ax,'equal');
grid(ax,'on');
if dimension == 2
    measure = 'Area';
else
    measure = 'Volume';
end
title(ax,sprintf('%s = %.5g (%s)',measure,volume,info.method));
end
