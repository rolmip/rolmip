function polyout = discshift(varargin)
% [polyout] = discshift(polyin,eta,bounds,targetin,targetout)   
% Applies up to eta time-shifts in a discrete-time parameter-varying
% polynomial polyin, contained in the simplex domain targetin. The input
% bounds is an N-by-2 matrix of lower and upper limits on the variation of
% all the N parameters, i.e., dm_i <= a_i(k+1) - a_i(k) <= dM_i. The resultant
% polynomial polyout is a cell structure with eta+1 positions, where
% polyout{n} corresponds to the input polynomial dependent on a(k+n-1) and
% is in the new simplex domain targetout.
%
% The syntax
% [polyout] = discshift(polyin,eta)
% may also be used if the input polynomial depends on only one simplex
% domain, with parameters varying under arbitrary variation rates.
%
% [polyout] = discshift(polyin,eta,bounds)
% This syntax may be used if the input polynomial depends on only one
% simplex domain, but the variation rates of the parameters are bounded.
% If, for instance, dm_1 <= a_1(k+1) - a_1(k) <= dM_1 and
% dm_2 <= a_2(k+1) - a_2(k) <= dM_2, then bounds = [dm_1 dM_1; dm_2 dM_2]
% 
%
% [polyout] = discshift(polyin,eta,bounds,targetin)
% The resultant simplex will be allocated to the first available simplex
% index.
% 
% [polyout] = discshift(polyin,eta,targetin)
% Same as the prior syntax but considering arbitrary variation rates.
%
% [polyout] = discshift(polyin,eta,targetin,targetout)
% This syntax may be used if the variation rates of the parameters are
% arbitrary.
%
% Vertex enumeration uses MPT3 if available, then the cddmex binary.
% For a two-vertex simplex and eta=1, a MATLAB-only fallback is available.

if ((nargin < 2) || (nargin > 5))
    error('Input error. Type ''help discshift'' for more information');
else
    polyin = varargin{1};
    eta = varargin{2};
    if (~isa(polyin,'rolmipvar'))
        error('The first input must be a rolmipvar variable');
    end
    
    if (nargin == 2)
        targetin = 1;
        bounds = [-ones(polyin.vertices(targetin),1) ones(polyin.vertices(targetin),1)];
        targetout = length(polyin.data(1).exponent)+1;
    end
    
    if (nargin == 3)
        if (length(varargin{3}) > 1)
            bounds = varargin{3};
            if (length(polyin.data(1).exponent) == 1)
                targetin = 1;
                targetout = 2;
            else
                error('If the polynomial depends on more than one simplex domain, please inform the simplex to perform the shift operation');
            end
        else
            targetin = varargin{3};
            bounds = [-ones(polyin.vertices(targetin),1) ones(polyin.vertices(targetin),1)];
            targetout = length(polyin.data(1).exponent)+1;
        end
    end
    
    if (nargin >= 4)
        if (length(varargin{3}) > 1)
            bounds = varargin{3};
            targetin = varargin{4};
            if (nargin == 4)
                targetout = length(polyin.data(1).exponent)+1;
            else
                targetout = varargin{5};
            end
        else
            targetin = varargin{3};
            bounds = [-ones(polyin.vertices(targetin),1) ones(polyin.vertices(targetin),1)];
            targetout = varargin{4};
        end 
    end
end

N = polyin.vertices(targetin);
validateattributes(eta,{'numeric'},{'scalar','real','finite','integer','nonnegative'},mfilename,'eta');
validateattributes(bounds,{'numeric'},{'size',[N 2],'real','nonnan'},mfilename,'bounds');
if N == 0 || any(bounds(:,1) > bounds(:,2))
    error('ROLMIP:DiscshiftBounds','Use a nonempty simplex and ordered lower and upper bounds.');
end
eta = double(eta);
steps = eta+1;
V = trajectoryVertices(N,eta,full(double(bounds)));

% Group by time without changing the common vertex index in each slice.
order = reshape(reshape(1:N*steps,steps,N).',[],1);
H = V(:,order).';
polyout = cell(1,steps);
for conteta = 1:steps
    M = H((conteta-1)*N + 1:conteta*N,:);
    polyout{conteta} = simpltransf(polyin,targetin,targetout,M);
    if (conteta > 1)
        polyout{conteta}.label = strcat(strcat(strcat(polyout{conteta}.label,'(k+'),num2str(conteta-1)),')');
    end
end

end

function V = trajectoryVertices(n,eta,bounds)
hasMPT = exist('Polyhedron','class') == 8;
hasCDD = exist(['cddmex.' mexext],'file') == 3;
if ~hasMPT && ~hasCDD && ~(n == 2 && eta == 1)
    error('ROLMIP:DiscshiftBackend', ...
        'discshift needs MPT3 or the cddmex binary for this simplex size and horizon.');
end

% A coordinate of a simplex cannot change by more than one per step.
bounds(:,1) = max(bounds(:,1),-1);
bounds(:,2) = min(bounds(:,2),1);
if eta > 0 && any(bounds(:,1) > bounds(:,2))
    error('ROLMIP:DiscshiftInfeasible','The bounds allow no simplex trajectory.');
end

steps = eta+1;
if hasMPT || hasCDD
    [A,b,Ae,be] = trajectoryConstraints(n,steps,bounds);
end
if hasMPT
    P = Polyhedron('A',A,'b',b,'Ae',Ae,'be',be);
    V = P.V;
elseif hasCDD
    % The installed MEX expects equality indices in a row vector.
    % Its dense C interface reads the full A and B buffers.
    problem = struct('A',[Ae;A],'B',[be;b],'lin',1:steps);
    result = cddmex('extreme',problem);
    if ~isstruct(result) || ~isfield(result,'V') || ~isfield(result,'R') || ~isempty(result.R)
        error('ROLMIP:DiscshiftEnumeration','cddmex did not return a bounded vertex representation.');
    end
    V = result.V;
else
    V = twoVertexTrajectories(bounds);
end

if isempty(V)
    error('ROLMIP:DiscshiftInfeasible','The bounds allow no simplex trajectory.');
end
tolerance = max(1e-9,64*n*eps);
if ~isreal(V) || size(V,2) ~= n*steps || any(~isfinite(V(:))) || ...
        min(V(:)) < -tolerance || max(V(:)) > 1+tolerance
    error('ROLMIP:DiscshiftEnumeration','The vertex enumerator returned invalid simplex trajectories.');
end
% Check one trajectory coordinate at a time to avoid forming A*V'.
totals = zeros(size(V,1),steps);
for coordinate = 1:n
    x = V(:,(coordinate-1)*steps+(1:steps));
    totals = totals + x;
    increments = builtin('diff',x,1,2);
    if any(increments(:) < bounds(coordinate,1)-tolerance) || ...
            any(increments(:) > bounds(coordinate,2)+tolerance)
        error('ROLMIP:DiscshiftEnumeration','A trajectory vertex violates the rate bounds.');
    end
end
if any(abs(totals(:)-1) > tolerance)
    error('ROLMIP:DiscshiftEnumeration','A trajectory vertex violates the simplex sum.');
end
end

function [A,b,Ae,be] = trajectoryConstraints(n,steps,bounds)
eta = steps-1;
delta = builtin('diff',eye(steps),1,1);
% Group constraints by coordinate and interleave the upper/lower rows.
unitBox = kron(eye(steps),[1;-1]);
increments = kron(delta,[1;-1]);
A = kron(eye(n),[unitBox;increments]);
rowsPerCoordinate = 2*steps+2*eta;
b = zeros(n*rowsPerCoordinate,1);
for coordinate = 1:n
    rows = (coordinate-1)*rowsPerCoordinate+(1:rowsPerCoordinate);
    b(rows) = [repmat([1;0],steps,1); ...
               repmat([bounds(coordinate,2);-bounds(coordinate,1)],eta,1)];
end
Ae = kron(ones(1,n),eye(steps));
be = ones(steps,1);
end

function V = twoVertexTrajectories(bounds)
% With alpha_2=1-alpha_1, intersect the unit square with lo <= y-x <= hi.
lo = max(bounds(1,1),-bounds(2,2));
hi = min(bounds(1,2),-bounds(2,1));
if lo > hi
    V = zeros(0,4);
    return
end
corners = [0 0;0 1;1 0;1 1];
differences = corners(:,2)-corners(:,1);
corners = corners(differences>=lo & differences<=hi,:);
d = [lo;hi];
first = [max(0,-d),max(0,d)];
last = [min(1,1-d),min(1,1+d)];
xy = unique([corners;first;last],'rows','stable');
V = [xy,1-xy];
end
