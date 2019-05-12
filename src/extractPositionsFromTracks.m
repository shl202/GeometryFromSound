function [pos_start, pos_end] = extractPositionsFromTracks(tracks, tracks_config, duration)
% extractPositionsFromTracks
% @description: extract AUV positions from the sound tracks
% @usage: positions = extractPositionsFromTracks(tracks, tracks_config)
% @param1: tracks; tracks from deployment data. See ../data folder.
% @param2: tracks_config; configuration for tracks
% @param3: duration; amount of time in which the positions are extracted.
% @return1: pos_start; 3 by number of tracks matrix of AUV positions at the
%           begining of the duration.
% @return2: pos_end; 3 by number of tracks matrix of AUV positions at the
%           end of the duration.
%
    % check for duration variable;
    % 120 seconds by default
    if ~exist('duration', 'var')
        duration = 120;
    end

    %this should be done outside of this function if it is called in a loop
    %addpath('../data');
    good_tracks = tracks_config.good_tracks;

    tmax = 10^10;
    tmin = 0;

    if( isfield(tracks_config, 'time_max') && isfield(tracks_config, 'time_min'))
        tmax = tracks_config.time_max;
        tmin = tracks_config.time_min;
    else
        % find tmax and tmin
        for i=1:length(good_tracks)
            t = tracks(good_tracks(i)).GPS_time;
            indexes = find(t > 0);
            tmax = min(tmax, max(t(indexes)));
            tmin = max(tmin, min(t(indexes)));
        end
    end

    valid_positions = false;
    
    % make sure the extracted positions are valid
    while ~valid_positions
        valid_positions = true;
        % extract random positions from tracks
        tstart = tmin + rand * (tmax - tmin);
        positions_cell_arrays = snipPositionsFromTracks(tracks, tracks_config, tstart, duration);
        pos_start = zeros(3, length(tracks_config.good_tracks));
        pos_end = zeros(3, length(tracks_config.good_tracks));
        for i = 1:length(tracks_config.good_tracks)
            % if there is an missing position, get another set of
            % positions from tracks
            if isempty(positions_cell_arrays{i})
                valid_positions = false;
                break;
            end
            pos_start(:, i) = positions_cell_arrays{i}(1, :)';
            pos_end(:, i) = positions_cell_arrays{i}(end, :)';
        end
    end
end