function alr = areLocationsReasonable(locations)
% isLocationsReasonable 
% @description: Sanity Check for if a computed microphone location is
% reasonable
%               
% @usage: alr = areLocationsReasonable(locations)
% @param1: locations, a 3 x nm matrix of microphone positions
% @return1: alr, a boolean value of whether the locations are reasonable.
%
    alr = true;

    %{
    if( maxDistancePS(locations) > 1000 )
        alr = false;
    end
    %}
    
    
    % these checks make sense only where there are more than one
    % microphone/AUEs
    if size(locations, 2) > 1
        
        [~, S, ~] = svd(locations, 'econ');

        % spread way bigger than initial positions
        % based off initial spread of 300 x 300
        if S(1,1) > 1000
            alr = false;
        end

        % spread way smaller than initial positions
        % based off initial spread of 300 x 300
        if S(1, 1) < 100
            alr = false;
        end

        % rank deficiency errors
        if S(1,1) > (S(2,2) * 1000)
            alr = false;
        end
    end
end