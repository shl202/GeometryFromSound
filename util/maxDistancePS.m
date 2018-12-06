function max_dist = maxDistancePS(ps)
% maxDistance
% @description: find the maximum distance between any two points in a given
%               pointset.
% @usage: dist = maxDistancePS(ps)
% @param1: ps, a point set of d x n points, where d is the dimension and n
%          is the number of points.
% @return: the maximum distance found between any two points in the point
%          set.
%
    max_dist = 0;
    for i = 1:size(ps, 2)
        for j = (i+1):size(ps, 2)
            dist = norm(ps(:, i) - ps(:, j));
            if dist > max_dist
                max_dist = dist;
            end
        end
    end
end
