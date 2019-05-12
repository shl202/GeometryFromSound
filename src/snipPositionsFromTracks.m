function positions = snipPositionsFromTracks(tracks, tracks_config, tstart, duration)
% snipPositionsFromTracks
% @description: snip positions from the sound tracks based on the given
% start time and duration
% @usage: positions = snipePositionsFromTracks(tracks, tracks_config,
% tstart, duration)
% @param1: tracks; tracks from deployment data. See ../data folder.
% @param2: tracks_config; configuration for tracks
% @param3: tstart; time at which the positions should be extracted from.
%          time 0 represent the begining of the track.
% @param4: duration; amount of time in which the positions are extracted.
% @return1: positions, a struct of arrays of positions. The number of 
%           arrays is based the number of availible tracks. Each array of
%           postions represent the positions found from that corresponding
%           tract in the given time frame.
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

if ~exist('tstart', 'var')
    tstart = tmin + rand * (tmax - tmin);
end

if (tstart < tmin) || (tstart > tmax)
    error(['Start time is not in the range these tracks [' num2str(tmin) '-' num2str(tmax) ']']);
end

%duration = 120;
tend = tstart + duration;

positions = {zeros(length(good_tracks), 3)};
time_stamps = {zeros(length(good_tracks), 1)};

for i=1:length(good_tracks)
    track_ID = good_tracks(i);
    poses = tracks(track_ID).LS_position;
    t = tracks(track_ID).GPS_time;
    
    % find indexes within desired time frame
    indexes = find((t >= tstart) & (t <= tend) );
    tposes = poses(indexes, :); 
    tt = t(indexes);
    
    % find indexes where positions are not 0s (missing data)
    indexes2 = find(~all(tposes' == 0));
    
    positions{i} = tposes(indexes2, :);
    time_stamps{i} = tt(indexes2);   
end
