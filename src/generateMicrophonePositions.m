function [poses_ini, poses_fin] = generateMicrophonePositions(config, tracks, tracks_config)
    
    %% fetch configuration values
    mic_positions_type = config.mic_positions_type;
    nm = config.num_of_microphones;
    m_ub = config.mic_ub;
    m_lb = config.mic_lb;
    drift_distance = config.drift_distance;
    drift_duration = config.drift_duration;
    tracks_file = config.tracks_file;
    tracks_config_file = config.tracks_config_file;
    mic_num_groups = config.mic_num_groups;
    mic_ave_depth = config.mic_ave_depth;

    
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
    end
    
    % generate microphone positions
    if strcmp(mic_positions_type, 'synthetic')
        mics = generatePositions(nm, m_ub, m_lb);
        % generate gaussian random noise to account for drifting in microphone
        % positions
        mics_drift = addGaussianNoise(mics, drift_distance);
        
    elseif strcmp(mic_positions_type, 'tracks') 
        [mics, mics_drift] = extractPositionsFromTracks(tracks, tracks_config, drift_duration);
        
        % extract a subset of the microphone if number of microphone
        % specified in configuration is less than number of microphones in 
        % tracks raise error if number of microphones
        if nm < size(mics, 2)
            mic_ids = randperm(nm);
            mics = mics(:, mic_ids);
            mics_drift = mics_drift(:, mic_ids);
        elseif nm > size(mics, 2)
            error("Not enough microphones in the track file.")
        end
        
        % find zero-means position for x-y-z plane, since generated sources
        % locations assume zero-means
        mics_drift = mics_drift - mean(mics, 2);
        mics = mics - mean(mics, 2);
         
        % adjust depth to as specified by configuration
        mics_drift = mics_drift + [0 0 mic_ave_depth]';
        mics = mics + [0 0 mic_ave_depth]';
        
    elseif strcmpi(mic_positions_type, 'planar_groups')
        [mics, mics_drift] = extractPositionsFromTracks(tracks, tracks_config, drift_duration);
        
        % extract a subset of the microphone if number of microphone
        % specified in configuration is less than number of microphones in 
        % tracks raise error if number of microphones
        if nm < size(mics, 2)
            mic_ids = randperm(nm);
            mics = mics(:, mic_ids);
            mics_drift = mics_drift(:, mic_ids);
        elseif nm > size(mics, 2)
            error("Not enough microphones in the track file.")
        end
        
        % find zero-means position for x-y-z plane, since generated sources
        % locations assume zero-means
        mics_drift = mics_drift - mean(mics, 2);
        mics = mics - mean(mics, 2);
        
        
        % adjust depth to as specified by configuration for each planar
        % group
        ng = mic_num_groups;
        
        % assign some random groups
        order = randperm(nm);
        group_size = ceil(nm / ng);
        
        % adjust the depth of each group
        for i = 1:ng
            mics_id = order(max(1, (i-1) * group_size): min(nm, i * group_size));
            depths = repmat([0 0 mic_ave_depth(i)]', [1, length(mics_id)]);
            mics(:, mics_id) = mics(:, mics_id) + depths;
            mics_drift(:, mics_id) = mics_drift(:, mics_id) + depths;
        end
        
        
    else
        error('Undefined data type for microphone configuration');
    end
    
    poses_ini = mics;
    poses_fin = mics_drift;
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% addGaussianNoise(tdoa, noise_level)a
% @decription: add Gaussian noise to position data.
% @param1 poses: position data
% @param2 noise_level: the coefficent of the random normal noise
% @return1 poses_with_gn: 3xn matrix with the [x; y; z] positions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function poses_with_gn = addGaussianNoise(poses, noise_level)
    % check vector dimensions
    if isvector(noise_level) && (numel(noise_level) == 3)
        noise_level = reshape(noise_level, [3 1]); % change to column vector
    else
        error("noise level must be a 3x1 vector");
    end
    [h, w] = size(poses);
    poses_with_gn = poses + normrnd(zeros(h, w), repmat(noise_level, [1, w]));
end