function h = homogenize(varargin)
%homogization
%
% Author: Alexandre Felipe
% 2014, Dec, 8
%
%  Given a list of elements, returns the
%  same list represented with the same degrees.

  vertices = 0;
  homogeneous = 1;
  if(nargin == 1)
    in = varargin{1};
  else
    in = varargin;
  end
  %  Check the number of vertices
  
  for i = 1:nargin
    if(isa(in{i}, 'rolmipvar'))
      if(vertices ~= in{i}.vertices)
        if(vertices == 0)
          vertices = in{i}.vertices;
        elseif(in{i}.vertices ~= 0)
          error('Unable to homogenize variables on simplexes with different number of variables.')
        end
      end
    end
  end
  if vertices == 0
    for i = 1:nargin
        if(isa(in{i}, 'rolmipvar'))
            h{i} = in{i};
        else
            h{i} = rolmipvar(in{i}, '<>');
        end
    end
    return
  end
  one = rolmipvar(ones(1, vertices), '1', vertices, 1);
  
  %  Find the maximum degree
  for i = 1:nargin
    if(~isa(varargin{i}, 'rolmipvar'))
      h{i} = rolmipvar(in{i}, '<>', vertices, 0);
      in_coefs(i) = 0;
    else
      in_coefs(i) = length(in{i}.data);
      h{i} = in{i};
    end
  end
  ncoefs = max(in_coefs);
  %if(all(ncoefs == in_coefs))
  %  return; % it is already homogeneous.
  %end
  % multiply the terms of lower degree by 1 = sum(alpha) 
  % in order to get all terms with the same degree.
  for i = 1:nargin
    while(length(h{i}.data) < ncoefs)
      h{i} = h{i} * one;
    end
    % disp(['homogenize.m: ',  h{i}.label, ' has ', num2str(h{i}.vertices), ' vertices'])
    
    if(length(h{i}.data) ~= ncoefs)
        error('The polynomial forms are not the same.')
    end
  end
  
end
