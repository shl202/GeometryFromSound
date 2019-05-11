% generateConfig
% @description: this script updates the default configuration matrix for
%               the system.
% @usage: update the configuration parameters in this file and then run:
%         >> generateConfig
%

clear;


%% Configuration for data generation

% Sound sources
config_default.num_of_sources = 20;
config_default.src_ub = [1500 1500 0]';
config_default.src_lb = [-1500 -1500 -1500]';
config_default.src_num_of_clusters = 20;
config_default.src_cluster_radius = 20;

% Microphones
config_default.mic_positions_source = 'tracks';
config_default.tracks_file = 'tracks_Mar23.mat';
config_default.tracks_config_file = 'tracks_Mar23_config.mat';
% either sythetic, or tracks
if strcmp(config_default.mic_positions_source, 'sythetic')
    tracks_config = NaN;
    config_default.num_of_microphones = 10;
    config_default.mic_ub = [100 100 0]';
    config_default.mic_lb = [-100 -100 -100]';
    config_default.mic_ave_depth = -10;
    config_default.drift_distance = [10 10 0]; % drift of the AUV distance
    config_default.drift_duration = 240;       % only used for tracks
    
elseif strcmp(config_default.mic_positions_source, 'tracks')
    addpath('../data');
    file = load(config_default.tracks_config_file);
    tracks_config = file.tracks_config;
    config_default.num_of_microphones = length(tracks_config.good_tracks);
    config_default.mic_ub = NaN;
    config_default.mic_lb = NaN;
    config_default.mic_ave_depth = -10;
    config_default.drift_distance = [10 10 0]; % only used for sythetic
    config_default.drift_duration = 240;       % in seconds
else
    error('Undefined data type for microphone configuration.')
end

%config_default.correspondence_noise = 0; % percentage of correlation noise(outliers)

config_default.speed_of_sound = 1500; % speed of sound under water.
%config_default.tod_scale = 5; % span of time when sound source left from the source.


%% Configurations for input data type
config_default.input_data_type = 'time_difference_of_arrival'; % ns x nm matrix
%config_default.input_data_type = 'time_measurement'; % nm lists of timestampes
%config_default.input_data_type = 'time_of_flight'; % ns x nm matrix 


%% Configurations for matching correspondences 
%config_default.correspondence_error_threshold = 0.20; % maximum error tolerated for correspondence noises.


%% Configurations for source and microphone positions estimation algorithm

% Either Thrun (2D) or Pollefeys&Nister (3D)

% 2D
%config_default.algorithm = 'Thrun'; 

% 3D
%config_default.algorithm = 'Pollefeys&Nister'; 
%config_default.minimal_case.num_of_sources = 5;
%config_default.minimal_case.num_of_microphones = 10;
%config_default.ransac_iterations = 25; % iterations of ransac to run for eliminating finding offset.
%config_default.ransac_error_tolerance = 0.01; % error tolerance of ransac to determine which sets of time of departures are consistent.
%config_default.min_flight_time = 0; % minimum time acceptable for a sound to leave from a source and reach a microphone. (in seconds)
%config_default.max_flight_time = Inf; % maximum time acceptable for a sound to leave from a source and reach a microphone. (in seconds)

% Remove the existing configuration
delete('config_default.mat');

% Save the new configuration to "config_default.mat" file
save('config_default.mat', 'config_default');

% Let the user know the configutation has been saved/updated
disp('Default Configuration has been saved/updated.');
disp(config_default);