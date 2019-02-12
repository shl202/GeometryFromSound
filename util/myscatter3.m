function myscatter3(ps, size, color, marker)
% wrapper for scatter3 function
%
    if ~exist('size', 'var') || isempty(size)
        size = 25;
    end

    if ~exist('color', 'var') || isempty(color)
        color = 'b';
    end
    
    if ~exist('marker', 'var') || isempty(marker)
        marker = 'o';
    end
    
    x = ps(1, :)';
    y = ps(2, :)';
    z = ps(3, :)';
    
    scatter3(x, y, z, size, color, marker);
end