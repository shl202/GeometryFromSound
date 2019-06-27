function tofs = timeOfFlights(srcs, tods, mics_ini, mics_fin, duration, speed_of_sound) 
% timeOfFlights
% @description: compute the time of flight.
% @param1 srcs: positions of sound sources
% @param2 tods: time of departures associated with sound sources
% @param3 mics_ini: initial positions of microphones
% @param4 mics_fin: final posiions of the microphones
% @parem5 duration: duration the microphones drifted
% @param6 speed_of_sound: speed of sound
% @return1 tofs: s x m matrix of tof data.

    ns = size(srcs, 2);
    nm = size(mics_ini, 2);
    tofs = zeros(ns, nm);
    drift = mics_fin - mics_ini;
    for i = 1:ns
        mics_curr = tods(i)/duration * drift + mics_ini;
        for j = 1:nm
            tofs(i, j) = timeOfFlight(srcs(:,i), mics_curr(:, j), speed_of_sound);
        end
    end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% timeOfFligt
% @description: compute the time of flight (TOF) given src position, mic p
%               position, and speed of sound
% @return1 tof: time of flight
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function tof = timeOfFlight(src_position, mic_position, speed_of_sound)
    tof = norm(src_position - mic_position) / speed_of_sound;
end