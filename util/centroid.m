function c = centroid(ps)
% computes the centroid of the point set
% input: point set (matrix) of [p1, p2, p3, .... pn] 
%        where pn = [xn; yn; zn]
% output: a point where the center of the point set is

    [~, w] = size(ps);
    c = 1/w * sum(ps, 2);
end