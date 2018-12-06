clear;

addpath('../util');

threshold = 10^(-9);

A = 100 * rand(3, 10);
[~, N] = size(A);
C = 1/N * sum(A, 2);

% center the point set around origin
A = A - C;

T = [10, 10, 10]';
R = [0 -1 0; 
     1  0 0;
     0  0 1]; % rotate 90 degrees along z-axis

 
 % Test translation only
TA = T + A;
[lse, r, t] = leastSquareFitting3D(A, TA);

disp('Translation:');
if( lse > threshold )
    error('LSE Error');
elseif( norm(r - eye(3)) > threshold )
    error('Rotation Matrix Error');
elseif( norm(t - T) > threshold )
    error('Translation Matrix Error');
else
    disp('PASS');
end
    
% Test rotation only
RA = R * A; 
[lse, r, t] = least_square_fitting_3D(A, RA);

disp('Rotation:');
if( lse > threshold )
    error('LSE Error');
elseif( norm(r - R) > threshold )
    error('Rotation Matrix Error');
elseif( norm(t - zeros(3, 1)) > threshold )
    error('Translation Matrix Error');
else
    disp('PASS');
end


% test both Translation and rotation
TRA = R * A + T;
[lse, r, t] = least_square_fitting_3D(A, TRA);

disp('Translation and Rotation:');
if( lse > threshold )
    error('LSE Error');
elseif( norm(r - R) > threshold )
    error('Rotation Matrix Error');
elseif( norm(t - T) > threshold )
    error('Translation Matrix Error');
else
    disp('PASS');
end