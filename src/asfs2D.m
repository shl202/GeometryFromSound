function locations = asfs2D(tdoas, speed_of_sound)
% asfs2D 
% @description: Affine Structure From Sound, Computes the microphone 
%               locations from time difference of arrival data, retrives
%               only (x, y) information.
%               
% @usage: locations = asfs2D(tdoas, speed_of_sound)
% @param1: tdoas, a matrix of time difference of arrive data.
% @param2: speed_of_sound
% @return1: locations,
%               locations.S, S matrix (5 by ns)
%               locations.M, M matrix (5 by nm)
%               locations.srcs, computed source locations (2 x ns) 
%               locations.mics, computed microphone locations (2 x nm);
%               locations.isValid, true if successful computed the source
%                                  and microphone positions, false when 
%                                  Mprimehat is deficient in rank or when
%                                  nearest semi-definite matrix cannot be
%                                  computed for Q matrix;
% @citation: S. Thrun, “Affine structure from sound,” in Advances in
%            Neural Information Processing Systems 18 Neural Information
%            Processing Systems, 2005, pp. 1353–1360.
%
    % check for minimum tdoas dimension required.
    if ~all(size(tdoas) > [2,2])
        error("Insufficient number of sound sources or microphones");
    end
    
    delta = tdoas' .* speed_of_sound;
    [U, S, V] = svd(delta, 'econ');
    S = S(1:2,1:2);
    U=U(:,1:2);
    V=V(:,1:2);

        function F = C_prime_loss(x)
            C = [x(1:2)';x(3:4)'];
            F =(sum((C*V').*(C*V'))-ones(1,size(V',2)))';
        end


    x0 = [1;1;1;1];

    % options = optimset('display','off');
    % options = optimoptions('lsqnonlin','Display','iter');
    % options = optimoptions('lsqnonlin','FunctionTolerance',1e-16);
    options = optimoptions('lsqnonlin','Algorithm','levenberg-marquardt','display', 'off');
    % options = optimoptions('lsqnonlin','display','off');

    % optns.Algorithm = 'levenberg-marquardt';
    % optns.FunctionTolerance = 1e-16;
    % optns.MaxFunctionEvaluations = 7000;
    % optns = optimoptions(optns,'FunctionTolerance',1e-10);


    [x,resnorm,residual,exitflag,output,lambda,jacobian] = ...
        lsqnonlin(@C_prime_loss,x0,[],[],options);

    C = [x(1:2)';x(3:4)'];
    % matlab optimization
    X =  U*S*inv(C); % = (U*S)/C ;
    %X = (U*S)/C;
    Gamma = C * V';

    alpha = -atan2(X(1,2),X(1,1));

    R = [cos(alpha) -sin(alpha);
        sin(alpha) cos(alpha)];
    
    % Populate output struct
    locations.C = C;
    locations.Gamma = Gamma;
    locations.S = NaN;
    locations.M = NaN;
    locations.srcs = NaN;
    locations.mics = R*X';
    locations.isValid = true;
end