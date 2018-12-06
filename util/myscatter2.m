function myscatter2(ps1, ps2, axis, c1, c2)
    % Populate optional parameter and check for empty inputs
    if ~exist('axis', 'var') || isempty(axis)
        axis = 'xy';
    end

    if ~exist('c1', 'var') || isempty(c1)
        c1 = 'r';
    end

    if ~exist('c2', 'var') || isempty(c2)
        c2 = 'g';
    end

    if strcmpi(axis, 'xy')
        X1 = ps1(1,:);
        Y1 = ps1(2,:);
        X2 = ps2(1,:);
        Y2 = ps2(2,:);
    elseif strcmpi(axis, 'xz')
        X1 = ps1(1,:);
        Y1 = ps1(3,:);
        X2 = ps2(1,:);
        Y2 = ps2(3,:);
    elseif strcmpi(axis, 'yz')
        X1 = ps1(2,:);
        Y1 = ps1(3,:);
        X1 = ps2(2,:);
        Y1 = ps2(3,:);
    else
        error('Invalid Axis')
    end
    c1 = repmat(toRGBTriplet(c1), [numel(X1) 1]); 
    c2 = repmat(toRGBTriplet(c2), [numel(X2) 1]); 
    c = [c1; c2];

    % distinguish size in case of complete overlap
    sz1 = repmat(20, [numel(X1) 1]); 
    sz2 = repmat(50, [numel(X2) 1]); 
    sz = [sz1; sz2];

    X = [X1 X2];
    Y = [Y1 Y2];

    scatter(X, Y, sz, c);
end