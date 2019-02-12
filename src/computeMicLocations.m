function [correspondences, sample, locations] = computeMicLocations(data, config, mode)   
% computeMicLocations 
% @description: wrapper function for 2D ASFS, 3D ASFS and 3D DCOSAML
%               algorithms, which computes the microphone locations from 
%               time difference of arrival data
% 
% @usage: [correspondences, sample, locations] = computeMicLocations(data, config, mode)
% @param1: data, data struct which contains a matrix of time difference of 
%          arrive data.
% @param2: config,  a configuration struct in which one of its field
%          specify the speed of sound
% @param3: mode, a string which specify which algorithm to call.
%          availible modes are: ["asfs2D", "asfs3D", and "dcosaml"]
% @return1: correspondences, replace holder variable for when
%           correspondences needs to be correlated.
% @return2: sample, replace holder variable for when RANSAC is used to
%           remove outlier.
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


	
    if strcmpi(mode, 'asfs2D')
        correspondences.isValid = true;
        sample.isValid = true;
		try
			locations = asfs2D(data.tdoas, config.speed_of_sound);
        catch ME
            warning(ME.message);
            warning("locations has been set to invalid");
            locations.isValid = false; 	
		end
			
    elseif strcmpi(mode, 'asfs') || strcmpi(mode, 'asfs3D')
        correspondences.isValid = true;
        sample.isValid = true;
		try
			locations = asfs(data.tdoas, config.speed_of_sound);
        catch ME
			warning(ME.message);
            warning("locations has been set to invalid");
            locations.isValid = false;  
		end
		
		
    elseif strcmpi(mode, 'dcosaml')
        correspondences.isValid = true;
        sample.isValid = true;
		try
			locations = dcosaml(data.tdoas, config.speed_of_sound);
		catch ME
            warning(ME.message);
            warning("locations has been set to invalid");
            locations.isValid = false;     
        end
	else 
        error([mode ' is not supported.'])
    end
	
end