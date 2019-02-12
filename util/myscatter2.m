function myscatter2(ps, size, color, marker)
% wrapper for scatter function
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
    
    scatter(x, y, size, color, marker);
end