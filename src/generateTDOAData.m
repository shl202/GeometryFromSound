function data = generateTDOAData(config, tracks, tracks_config)
% generateTDOAData
% @description: generate a sxm matrix of time-difference-of-arrival data
%               points with s sources and m microphones.
% @usage: [tdoas, tms, ground_truth] = generateTDOAData(config)
% @param1 config: configurations for generating TDOA data.
%                 see generateConfig.m for more detail.
% @return1 data: a struct that holds, 
%                -  tdoas: time-differenece-of-arrival data
%                -  tms: time measurements for each microphone
%                -  gts: ground_truth, struct of ground_truth which includes:
%                        - srcs (source positions)
%                        - mics (microphone positions)
%                        - tods (time of departures)
%                        - tdoas (time difference of arrival without noise)
%                            
%
    %% verify input parameter
    if ~exist('config', 'var')
        load config_default.mat config_default;
        config = config_default;
    end
    
    %% fetch configuration values
    ns = config.num_of_sources;
    nm = config.num_of_microphones;
    mic_positions_type = config.mic_positions_type;
    drift_distance = config.drift_distance;
    drift_duration = config.drift_duration;
    sos = config.speed_of_sound;
    tracks_file = config.tracks_file;
    tracks_config_file = config.tracks_config_file;
    
    % check if we need to load track files
    if strcmpi(mic_positions_type, 'tracks') || strcmpi(mic_positions_type, 'planar_groups')
        if ~exist('tracks', 'var') || ~exist('tracks_config', 'var')  
            if all(~isnan(tracks_file)) && all(~isnan(tracks_config_file))
        
                %addpath should be done at a higher level to avoid being called
                %multiple times
                %addpath('../data');
                tracks_file = load(tracks_file);
                tracks = tracks_file.tracks;
                tracks_config_file = load(tracks_config_file);
                tracks_config = tracks_config_file.tracks_config;
            end
        end
        
        % generate microphone positions
        [mics, mics_drift] = generateMicrophonePositions(config, tracks, tracks_config);
    else
        % generate microphone positions
        [mics, mics_drift] = generateMicrophonePositions(config);
    end
    
    % using the medium mic positions as the gt
    mics_gt = (mics + mics_drift)/2;
    
    % generate sound source positions
    srcs = generateSourcePositions(config);
    
    % generate time of departures
    tods_gt = drift_duration * generateTODs(ns);
    

    % compute time of flights with and without noise
    tofs_gt = timeOfFlights(srcs, tods_gt, mics_gt, mics_gt, drift_duration, sos);
    tofs_gn = timeOfFlights(srcs, tods_gt, mics, mics_drift, drift_duration, sos);
    
    % compute time difference of arrival data
    tdoas_gt = tofs_gt - tofs_gt(:, 1);
    tdoas_gn = tofs_gn - tofs_gn(:, 1);
    
    % compute time offset (aka time of departure of sound source relative 
    % to detection time of microphone 1)
    toffset_gt =  -1 *(tofs_gt(:, 1));
    
    % sort to simulate time measurement
    time_measurements = cell(nm, 1);
    for j=1:nm
        time_measurements{j} = sort(tdoas_gn(:, j));
    end
    
    %% generate output
    data.tms = time_measurements;
    data.tdoas = tdoas_gn;
    data.tofs = tofs_gn;
    ground_truth.srcs = srcs;
    ground_truth.mics = mics_gt;    
    ground_truth.mics_drift = mics_drift;
    ground_truth.tods = tods_gt;
    ground_truth.toffset = toffset_gt;
    ground_truth.tofs = tofs_gt;
    ground_truth.tdoas = tdoas_gt;
    data.gt = ground_truth;
 
end


%% Helper Functions

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% generateTODs
% @description: generate s time of departure data points.
% @param1 s: number of sources
% @return1 tods: sx1 vector with randomly generated time of departure data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function tods = generateTODs(s)
    tods = zeros(s, 1);
    for i = 1:s
        tods(i) = rand();
    end
    tods = sort(tods);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% generateCorrespondences (TODO)
% @description: generate noises from correspondence errors.
% @param1 tdoas: time difference of arrival data (gt).
% @param2 cor_noise: correspondence noise level.
% @return1 correspondences: noisy tdoa correspondences.
% @return2 srcs: the true src of the noisy correspondences.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [correspondences, src_ids] = generateCorrespondences(tdoas, cor_noise)
    [ns, nm] = size(tdoas);
    correspondences = [];
    src_ids = []; % ids of the truth source of the correspondence
    cor_index = 0;
    for i = 1:ns  
        % The total possible number of correspondence is be ns^nm. Here we
        % assume up to nm correspondence remains after signal processing 
        % techniques are applied to the raw data. (linearly proportional
        % instead of exponetially proportional)
        ncor = randi(nm);
        for r = 1:ncor
            cor_index = cor_index + 1;
            for j = 1:nm
                % (ncor+1)/ncor adjust for the fact there's no noise in the
                % ground truth measurement, so the total amount of
                % correspondence noise is truly equal to cor_noise
                if (ncor+1)/ncor * randi(100) < cor_noise
                    % bad correspondence
                    offset = [-nm:-1, 1:nm];
                    wrong_i = min(max(1, i+offset(randi(2*nm))), ns);
                    correspondences(cor_index, j) = tdoas(wrong_i, j);
                else
                    % Proper correspondence
                    correspondences(cor_index, j) = tdoas(i, j);
                end
            end
            % check and discard duplicate correspondences
            if isequal(correspondences(cor_index, :), tdoas(i, :))
                correspondences(cor_index, :) = [];
                cor_index = cor_index -1;
            else
                src_ids(cor_index) = i;
            end
        end
    end
end