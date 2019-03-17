function [correspondences, sample, locations] = computeMicLocations(data, config, algorithm)   
% computeMicLocations 
% @description: wrapper function for 2D ASFS, 3D ASFS and 3D DCOSAML
%               algorithms, which computes the microphone locations from 
%               time difference of arrival data
% 
% @usage: [correspondences, sample, locations] = computeMicLocations(data, config, algorithm)
% @param1: data, data struct which contains a matrix of time difference of 
%          arrive data.
% @param2: config,  a configuration struct in which one of its field
%          specify the speed of sound
% @param3: algorithm, a string which specify which algorithm to call.
%          availible algorithms are: ["asfs2D", "asfs3D", and "dcosaml"]
% @return1: correspondences, replace holder variable for when
%           correspondences needs to be correlated.
% @return2: sample, set of consistent data found after RANSAC is used to
%           remove outlier.
%               sample.srcs, srcs in the sample.
%               sample.tdoas, tdoas in the sample.
% @return3: locations,
%               locations.C, C matrix in ASFS (2x2 or 3x3)
%               locations.S, S matrix used in DCOSAML (5 by ns)
%               locations.M, M matrix used in DCOSAML (5 by nm)
%               locations.srcs, computed source locations (2 x ns) 
%               locations.mics, computed microphone locations (2 x nm);
%               locations.isValid, true if successful computed the source
%                                  and microphone positions, false when 
%                                  Mprimehat is deficient in rank or when
%                                  nearest semi-definite matrix cannot be
%                                  computed for Q matrix;
%   
    % affine structure from sound 2D
    if strcmpi(algorithm, 'asfs2D')
        correspondences.isValid = true;
        sample.isValid = true;
        try
            locations = asfs2D(data.tdoas, config.speed_of_sound);
        catch ME
            warning(ME.message);
            warning("locations has been set to invalid");
            locations.isValid = false;     
        end
    
    % affine structure from sound 3D
    elseif strcmpi(algorithm, 'asfs') || strcmpi(algorithm, 'asfs3D')
        correspondences.isValid = true;
        sample.isValid = true;   
        try
            locations = asfs(data.tdoas, config.speed_of_sound);
        catch ME
            warning(ME.message);
            warning("locations has been set to invalid");
            locations.isValid = false;     
        end
    
    % direct computation of source and microphone locations
    elseif strcmpi(algorithm, 'dcosaml')
        correspondences.isValid = true;
        sample.isValid = true;
        try
            locations = dcosaml(data.tdoas, config.speed_of_sound);
        catch ME
            warning(ME.message);
            warning("locations has been set to invalid");
            locations.isValid = false;     
        end
    
    % affine structure from sound 3D with ransac
    elseif strcmpi(algorithm, 'ransacasfs') || strcmpi(algorithm, 'ransacasfs3D') 
        correspondences.isValid = true; 
        
        [ns, nm] = size(data.tdoas);
        
        % parameters for ransac and asfs3D 
        minCase = 9;
        T = 3; % rmse of microphone position estimates
        Pgood = 3/4; % estimated percentage of sound sources that are good  
        K = floor(Pgood * ns);
        Pfail = 0.005;
        L = ceil(log(Pfail)/log(1-(Pgood^minCase)));
        try
            [~, sample, locations] = ransacMicLocations(data, config, 'asfs3D', minCase, T, K, L);
        catch ME
            warning(ME.message);
            warning("locations has been set to invalid");
            locations.isValid = false;     
        end
    else 
        error([algorithm ' is not supported.'])
    end
end