function locations = computeSAMLocationsFromTOFs(tdoas, tods, speed_of_sound, rank)
% computeSAMLocationsFromTOFs
%
% @usage: locations = computeSAMLocationsFromTOFs(tdoas, tods, speed_of_speed)
% @description: Computes the source and microphone locations 
% @param1: tdoas, time difference of arrival data 
% @param2: tods, time of departure data
% @param3: speed of sound. (~1500 meter per second underwater)
% @param4: rank, rank of the matrix (5 for 3D and 4 for 2D)
% @return1: locations struct
%               locations.S, S matrix (5 by ns)
%               locations.M, M matrix (5 by nm)
%               locations.srcs, computed source locations (3 x ns) 
%               locations.mics, computed microphone locations (3 x nm);
%               locations.isValid, true if successful computed the source
%                                  and microphone positions, false when 
%                                  Mprimehat is deficient in rank or when
%                                  nearest semi-definite matrix cannot be
%                                  computed for Q matrix;
%
% @citation: Pollefeys, Marc & Nistér, David. (2008). 
%            Direct computation of sound and microphone locations from 
%            time-difference-of-arrival data. 
%            ICASSP, IEEE International Conference on Acoustics, 
%            Speech and Signal Processing - Proceedings. 2445-2448. 
%            10.1109/ICASSP.2008.4518142. 

    if ~(rank == 4 || rank == 5)
        error(["Rank " rank " is not supported. Please use rank 5 for 3D problem and rank 4 for 2D problem"])
    end
    
    % compute time of flight
    tofs = (tdoas.^2 - 2 * tdoas.*tods + tods.^2);
    %tofs = (tdoas.^2 - 2 * tdoas.*tods);
    distances = speed_of_sound^2 * tofs;
    
    % Compute Shat and Mhat matrices
    [U, Sigma, V] = svd(distances, 'econ');
    Shat = (U(:, 1:rank) * Sigma(1:rank, 1:rank))';
    Mhat = V(:, 1:rank)';
    %Shat = (U(:, [1 (7-rank):5])  * Sigma([1 (7-rank):5], [1 (7-rank):5]))';
    %Mhat = V(:, [1 (7-rank):5])';

    % Compute HM and HS matrices
    HM = computeHM(Mhat);
    HS = computeHS(Shat);
    
    %HM * Mhat;
    %Shat' * inv(HS);
    
    %{
    B = [ 
           0 0 0 0 -1/2;
           0 1 0 0 0;
           0 0 1 0 0;
           0 0 0 1 0;
        -1/2 0 0 0 0; 
        ];
    %}
   
    % Compute Mprimehat
    Mprimehat = HS * HM * Mhat;

    % check for problem with rank deficency
    if sum(sum(~isnan(Mprimehat))) 
        % Compute Q Matrix
        Q = computeQ(Mprimehat, rank);

        % Compute HQ Matrix
        [HQ, HQIsValid] = computeHQ(Q, eye(rank-2), zeros(1, rank-2)', rank);

        % Complete the computation if HQ is valid
        % HQ is invalid if we can take the cholesky factorization of Q(2:4, 2:4) 
        if HQIsValid

            % Compute H by combining HQ, HS, HM
            H = HQ * HS * HM;

            % Estimate S and M 
            % (Shat' / H)' = (Shat' * inv(H))'; matlab optimization
            S = (Shat' / H)';  
            M = H * Mhat;

            locations.S = S;
            locations.M = M;
            locations.srcs = -1/2 * S(2:rank-1, :);
            locations.mics = M(2:rank-1, :);
            locations.isValid = true;
        else
            locations.S = NaN;
            locations.M = NaN;
            locations.srcs = NaN;
            locations.mics = NaN;
            locations.isValid = false;
        end
    else
        locations.S = NaN;
        locations.M = NaN;
        locations.srcs = NaN;
        locations.mics = NaN;
        locations.isValid = false;
    end
end


%% Helper Functions
function c = computeCoef(m, rank)
    if rank == 4
        c = [
            m(1)^2;
            2*m(1)*m(2);
            2*m(1)*m(3);
            m(2)^2;
            2*m(2)*m(3);
            m(3)^2;
            2*m(1)*m(4)
        ]';
    elseif rank == 5
        c = [
            m(1)^2;
            2*m(1)*m(2);
            2*m(1)*m(3);
            2*m(1)*m(4);
            m(2)^2;
            2*m(2)*m(3);
            2*m(2)*m(4);
            m(3)^2;
            2*m(3)*m(4);
            m(4)^2;
            2*m(1)*m(5)
        ]';
    end
end

function HM = computeHM(Mhat)
    [h, w] = size(Mhat);
    I = eye(h-1);
    Z = zeros(h-1, 1);
    hMT = ones(1,w) / Mhat;
    HM = [ hMT; [Z I] ];
end

function [HQ, isValid] = computeHQ(Q, R, t, rank)
 
    isValid = true;
    
    % Use nearestSPD() to convert Q to the nearest positive semidefinite
    % matrix
    [K, p] = chol(nearestSPD(Q(2:rank-1, 2:rank-1)));
    
    % check if chol failed (when p > 0)
    if p~=0
        K = NaN;
        isValid = false;
    end
   
    HQ = [
        1              zeros(1, rank-2)           0 ;
        t              R*K                        zeros(rank-2, 1);
        t'*t - Q(1, 1) 2*(t'*K - Q(1,2:rank-1) )  1 
    ];
end

function HS = computeHS(Shat)
    [h, w] = size(Shat);
    I = eye(h-1);
    Z = zeros(1, h-1);
    
    hSprime = ones(1,w) / Shat(2:h, :);
    hS = [0 hSprime]';
    
    HS = inv([ [I; Z] hS ]);  
end

function Q = computeQ(Mprimehat, rank)
    [h, ~] = size(Mprimehat');
    if rank == 4
        coefs = zeros(h, 7);
    elseif rank == 5
        coefs = zeros(h, 11);
    end

    for i=1:h
        coefs(i, :) = computeCoef(Mprimehat(:, i), rank);
    end

    [U, Sigma, V] = svd(coefs);
    rns = find(diag(Sigma) < 0.00001);
    if isempty(rns)
        Qunscaled = V(:, end);
    else
        Qunscaled = V(:, rns(1));
    end
    %Qunscaled = null(coefs)

    Qp = Qunscaled ./ Qunscaled(end) .* -1/2;
    if rank == 4
        Q = [
            Qp(1)  Qp(2) Qp(3) Qp(7);
            Qp(2)  Qp(4) Qp(5) 0;
            Qp(3)  Qp(5) Qp(6) 0;
            Qp(7)  0     0     0
        ];
    elseif rank == 5
        Q = [
            Qp(1)  Qp(2) Qp(3) Qp(4)  Qp(11);
            Qp(2)  Qp(5) Qp(6) Qp(7)  0;
            Qp(3)  Qp(6) Qp(8) Qp(9)  0;
            Qp(4)  Qp(7) Qp(9) Qp(10) 0;
            Qp(11) 0     0     0      0
        ];
    end
end


function [Ahat, chol_num] = nearestSPD(A, max_iterations)
% nearestSPD - the nearest (in Frobenius norm) Symmetric Positive Definite matrix to A
% usage: Ahat = nearestSPD(A)
%
% From Higham: "The nearest symmetric positive semidefinite matrix in the
% Frobenius norm to an arbitrary real matrix A is shown to be (B + H)/2,
% where H is the symmetric polar factor of B=(A + A')/2."
%
% http://www.sciencedirect.com/science/article/pii/0024379588902236
%
% arguments: (input)
%  A - square matrix, which will be converted to the nearest Symmetric
%    Positive Definite Matrix.
%
% Arguments: (output)
%  Ahat - The matrix chosen as the nearest SPD matrix to A.

    %if nargin ~= 1
    %  error('Exactly one argument must be provided.')
    %end
    if ~exist('max_iterations', 'var')
       max_iterations = 5; 
    end
    
    
    % test for a square matrix A
    [r,c] = size(A);
    if r ~= c
      error('A must be a square matrix.')
    elseif (r == 1) && (A <= 0)
      % A was scalar and non-positive, so just return eps
      Ahat = eps;
      return
    end

    % symmetrize A into B
    B = (A + A')/2;

    % Compute the symmetric polar factor of B. Call it H.
    % Clearly H is itself SPD.
    [U,Sigma,V] = svd(B);
    H = V*Sigma*V';

    % get Ahat in the above formula
    Ahat = (B+H)/2;

    % ensure symmetry
    Ahat = (Ahat + Ahat')/2;

    % test that Ahat is in fact PD. if it is not so, then tweak it just a bit.
    p = 1;
    k = 0;
    while (p ~= 0 && k < max_iterations)
      [R,p] = chol(Ahat);
      k = k + 1;
      if p ~= 0
        % Ahat failed the chol test. It must have been just a hair off,
        % due to floating point trash, so it is simplest now just to
        % tweak by adding a tiny multiple of an identity matrix.
        mineig = min(eig(Ahat));
        Ahat = Ahat + (-mineig*k.^2 + eps(mineig))*eye(size(A));
      end
    end
    chol_num = p;
end