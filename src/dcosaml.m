function locations = dcosaml(tdoas, speed_of_sound)
% dcosaml
% @description: Direct Computation of source and microphone locations from 
%               time difference of arrival data.
% @usage: locations = dcosaml(tdoas, speed_of_sound)
% @param1: tdoas, a matrix of time difference of arrive data.
% @param2: speed_of_sound
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
%

    % Check if we have enough sound sources and microphones
    [ns, nm] = size(tdoas);  
    if ~((ns >=5 && nm >= 10) || (ns >=10 && nm >=5))
        error("Insufficient number of sound sources and microphones");
    end
    
    counter = 0;
    tods = computeTODs(tdoas);
    locations = computeSAMLocationsFromTOFs(tdoas, tods, speed_of_sound);
    locations = refineSAMLocations(locations, tdoas, tods, speed_of_sound);
    while (~locations.isValid) && (counter < 5)
        tods = computeTODs(tdoas);
        locations = computeSAMLocationsFromTOFs(tdoas, tods, speed_of_sound);
        locations = refineSAMLocations(locations, tdoas, tods, speed_of_sound);
    end
end