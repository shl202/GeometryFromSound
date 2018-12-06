function [] = myscatter3(ps1, ps2, c1, c2)
    % Populate optional parameter if neceesary
    if ~exist('c1', 'var')
        c1 = 'b';
    end

    if ~exist('c2', 'var')
        c2 = 'r'; 
    end

    %figure
    X1 = ps1(1, :)';
    Y1 = ps1(2, :)';
    Z1 = ps1(3, :)';
    sz1 = repmat(25, length(ps1), 1);
    %c1 = repmat(1, length(ps1), 1);
    %scatter3(X, Y, Z)
    %axis([-50 50 -50 50 -50 50]);

    %figure
    X2 = ps2(1, :)';
    Y2 = ps2(2, :)';
    Z2 = ps2(3, :)';
    sz2 = repmat(25, length(ps2), 1);
    %c2 = repmat(9, length(ps2), 1);


    X = [X1;X2];
    Y = [Y1;Y2];
    Z = [Z1;Z2];
    sz = [sz1; sz2];
    c = [c1; c2];
    %scatter3(X, Y, Z, sz, c)

    xmin = min(X);
    xmax = max(X);
    ymin = min(Y);
    ymax = max(Y);
    zmin = min(Z);
    zmax = max(Z);
    
    scatter3(X1, Y1, Z1, sz1, c1, 'o'); hold on
    scatter3(X2, Y2, Z2, sz2, c2, 'o');
    axis([xmin xmax ymin ymax zmin zmax]);
end