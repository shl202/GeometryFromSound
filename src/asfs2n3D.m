function locations = asfs2n3D(tdoas, speed_of_sound, rmse_error_threshold)
% asfs2n3D 
% @description: Combines 2D and 3D Affine Structure From Sound algorthims, 
%               to increase the accuracy when computing microphone 
%               locations from time difference of arrival data.
% @usage: locations = asfs2n3D(tdoas, speed_of_sound, rmse_error_threshold)
% @param1: tdoas, a matrix of time difference of arrive data.
% @param2: speed_of_sound
% @rmse_error_threshold: threshold of rooted mean square error at which
%                      2D or 3D solution is used. 
%                      3D solution if 2D vs 3D rmse < rmse_error_threshold 
%                      2D solution if 2D vs 3D rmse > rmse_error_threshold
% @return1: locations,
%               locations.S, S matrix (5 by ns)
%               locations.M, M matrix (5 by nm)
%               locations.srcs, computed source locations (3 x ns) 
%               locations.mics, computed microphone locations (3 x nm);
%               locations.isValid, true if successful computed the source
%                                  and microphone positions, false when 
%                                  Mprimehat is deficient in rank or when
%                                  nearest semi-definite matrix cannot be
%                                  computed for Q matrix;
% @citation: S. Thrun, “Affine structure from sound,” in Advances in
%            Neural Information Processing Systems 18 Neural Information
%            Processing Systems, 2005, pp. 1353–1360.
%

    if ~exist('rmse_error_threshold', 'var')
        rmse_error_threshold = 36.38; % = 300/sqrt(17)/2 
    end
    
    [ns, nm] = size(tdoas);
    locations2 = asfs2D(tdoas, speed_of_sound);
    
    % catch cases where there's enough sound source/microphones for 2D
    % computation but not 3D.
    try
       locations3 = asfs(tdoas, speed_of_sound); 
    catch ME
        warning(ME.message);
        warning("locations has been set to invalid");
        locations3.isValid = false;     
    end

    
    l2ok = locations2.isValid && areLocationsReasonable(locations2.mics);
    l3ok = locations3.isValid && areLocationsReasonable(locations3.mics);
    
    if ~l2ok && ~l3ok
        locations.mics = NaN;
        locations.isValid = false;
    elseif l2ok && ~l3ok
        locations.mics = [locations2.mics; zeros(1, nm)];
        locations.isValid = true;
    elseif ~l2ok && l3ok
        locations.mics = locations3.mics;
        locations.isValid = true;
    else
        mics2 = [locations2.mics; zeros(1, size(tdoas, 2))];
        mics3 = locations3.mics;
        [lse, ~, ~, isValid] = leastSquareFitting3D(mics3, mics2);
        

        if isValid
        	% Since asfs2D is less accurate at times but very stable, and
            % asfs3D is more accurate at times but less stable, we can use
            % the result from asfs2D to check the stability of asfs3D
            % algorithm. Asfs3D is generally more accurate when the
            % locations estimates and be comfirmed to be stable.
            rmse = sqrt(1/nm * lse);
            if rmse < rmse_error_threshold
                locations.mics = mics3;
            else 
                locations.mics = mics2;
            end
        else
            locations.mics = mics2;
        end
        locations.isValid = true;
    end
end