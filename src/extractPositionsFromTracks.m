function positions = extractPositionsFromTracks(tracks, tracks_config)
% extractPositionsFromTracks
% @description: extract AUV positions from the sound tracks
% @usage: positions = extractPositionsFromTracks(tracks, tracks_config)
% @param1: tracks; tracks from deployment data. See ../data folder.
% @param2: tracks_config; configuration for tracks
% @param3: tstart; time at which the positions should be extracted from.
%          time 0 represent the begining of the track.
% @param4: duration; amount of time in which the positions are extracted.
% @return1: positions; 3 by number of tracks matrix of AUV positions.
%

    valid_positions = false;
    % make sure the extracted positions are valid
    while ~valid_positions
        valid_positions = true;
        % extract random positions from tracks
        positions_cell_arrays = snipPositionsFromTracks(tracks, tracks_config);
        positions = zeros(3, length(tracks_config.good_tracks));
        for i = 1:length(tracks_config.good_tracks)
            % if there is an missing position, get another set of
            % positions from tracks
            if isempty(positions_cell_arrays{i})
                valid_positions = false;
                break;
            end
            positions(:, i) = positions_cell_arrays{i}(1, :)';
        end
    end
end