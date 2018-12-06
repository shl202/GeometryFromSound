function [lse, Rhat, That, isValid] = leastSquareFitting3D(ps1, ps2)
% Computes the least square error of 2 3D point sets
% input: ps1, ps2, where ps is a point set (matrix) of [p1, p2, p3, .... pn] 
%        where pn = [x1n; y1n; z1n]
% output: lse, the least square error of the point set
%         Rhat, Rotation matrix such that ps1 = Rhat * ps2 + That
%         That, Translation matrix such that ps1 = Rhat * ps2 + That
    
    isValid = true;
    [~, w1] = size(ps1);
    [~, w2] = size(ps2);
    if w1 ~= w2
        error('Point sets has different number of points')
    end
    
    c1 = centroid(ps1);
    c2 = centroid(ps2);
    
    qs1 = ps1 - c1;
    qs2 = ps2 - c2;
    
    H = zeros(3, 3);
    %for i=1:w1
    %    H = H + ( qs1(:, i) * qs2(:,i)');
    %end
    
    H = qs1 * qs2'; %???
    
    [U, Sigma, V] = svd(H);
    
    X = V * U';
    
    Rhat = X;
    %{
    if abs(det(X) - 1) < 10^(-6)
        %if any_zero(diag(Sigma)) > 0
        %    disp('mirror case');
        %end
        Rhat = X;
    elseif abs(det(X) - -1) < 10^(-6)
        %disp('det(X) == -1 ')
        %diag(Sigma)
        %any_zero(diag(Sigma))
        if any_zero(diag(Sigma)) > 0
            % reflection case
            Vprime = [V(:,1), V(:,2), -V(:,3)];  
            Xprime = Vprime * U';
            Rhat = Xprime;
        else
            isValid = false;
            %disp('huston we have a problem')
            Vprime = [V(:,1) V(:,2), -V(:,3)];
            X = (Vprime * U')';
            Rhat = X;
        end
    else
        error('Unhandled case in det(X)');
    end
    %}
    
    lse = norm(qs2 - Rhat * qs1);
    That = c2 - Rhat * c1;  
end


function n = any_zero(matrix)
% Find if any zeros exist in a matrix
% input: matrix,
% output: n, the number of zeros found

    n = 0;
    [h, w] = size(matrix);
    for i=1:h
        for j=1:w
            if abs(matrix(i, j)) < 10^-3 % matrix(i, j) == 0
                n = n + 1;
            end
        end
    end 
end