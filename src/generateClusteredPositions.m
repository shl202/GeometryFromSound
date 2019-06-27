function poses = generateClusteredPositions(np, p_ub, p_lb, nc, c_ub, c_lb)
% generatePositionp
% @decription: generate n random positionp in a unit cp_ube.
% @param1 np: number of positions
% @param2 p_ub: upperbound of [x; y; z]. [1 1 1]' by default
% @param3 p_lb: lowerbound of [x; y; z]. [0 0 0]' by default
% @param4 nc: number of clusters
% @param5 c_ub: upperbound of [x; y; z] relative to the centroid of the 
% cluster. [1 1 1]' by default
% @param6 c_lb: upperbound of [x; y; z] relative to the centroid of the 
% cluster. [0 0 0]' by default
% @return1 poses: 3xn matrix with the [x; y; z] positionp

    if ~exist('nc', 'var') || isempty(nc)
        nc = np;
    end
    
    if ~exist('p_ub', 'var')
        p_ub = [1 1 1]';
    end
    
    % check vector dimensions
    if isvector(p_ub) && (numel(p_ub) == 3)
        p_ub = reshape(p_ub, [3 1]); % change to column vector
    else
        error("upperbound must be a 3x1 vector");
    end
    
    
    if ~exist('p_lb', 'var')
        p_lb = [0 0 0]';
    end
    
    % check vector dimensions
    if isvector(p_lb) && (numel(p_lb) == 3)
        p_lb = reshape(p_lb, [3 1]); % change to column vector
    else
        error("lowerbound must be a 3x1 vector");
    end
    
    % if the number of clusters is equal to the number of point, then there
    % are no clusters.
    if np == nc
        poses = generatePositions(nc, p_ub, p_lb);
    else
        
        if ~exist('c_ub', 'var')
            c_ub = [1 1 1]';
        end

        % check vector dimensions
        if isvector(c_ub) && (numel(c_ub) == 3)
            c_ub = reshape(c_ub, [3 1]); % change to column vector
        else
            error("upperbound must be a 3x1 vector");
        end
        
        if ~exist('c_lb', 'var')
            c_lb = [0 0 0]';
        end

        % check vector dimensions
        if isvector(c_lb) && (numel(c_lb) == 3)
            c_lb = reshape(c_lb, [3 1]); % change to column vector
        else
            error("lowerbound must be a 3x1 vector");
        end
         
        
        cc = generatePositions(nc, p_ub, p_lb);
        poses = [];
        for i=1:nc
            ci_ub = min(cc(:,i) + c_ub, p_ub);
            ci_lb = max(cc(:,i) + c_lb, p_lb);
            if i <= rem(np, nc)
                cluster_poses = generatePositions(ceil(np/nc), ci_ub, ci_lb);
            else 
                cluster_poses = generatePositions(floor(np/nc), ci_ub, ci_lb);
            end
            poses = [poses cluster_poses]
        end
    end
end
