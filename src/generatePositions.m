function poses = generatePositions(n, ub, lb)
% generatePositions
% @decription: generate n random positions in a unit cube.
% @param1 n: number of positions
% @param2 ub: upperbound of [x; y; z]. [1 1 1]' by default
% @param3 lb: lowerbound of [x; y; z]. [0 0 0]' by default
% @return1 poses: 3xn matrix with the [x; y; z] positions

    if ~exist('ub', 'var')
        ub = [1 1 1]';
    end
    
    % check vector dimensions
    if isvector(ub) && (numel(ub) == 3)
        ub = reshape(ub, [3 1]); % change to column vector
    else
        error("upperbound must be a 3x1 vector");
    end
    
    
    if ~exist('lb', 'var')
        lb = [0 0 0]';
    end
    
    % check vector dimensions
    if isvector(lb) && (numel(lb) == 3)
        lb = reshape(lb, [3 1]); % change to column vector
    else
        error("lowerbound must be a 3x1 vector");
    end
    
    scale = diag(ub - lb);
    center = (ub + lb) / 2;
    centers = repmat(center, [1, n]);
    
    unit_poses = rand(3, n) - repmat([1/2 1/2 1/2]', [1,n]);

    poses = scale * unit_poses + centers;
end
