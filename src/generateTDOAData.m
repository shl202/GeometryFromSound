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
    mic_positions_source = config.mic_positions_source;
    ns = config.num_of_sources;
    s_ub = config.src_ub;
    s_lb = config.src_lb;
    s_nc = config.src_num_of_clusters;
    s_cr = config.src_cluster_radius;
    nm = config.num_of_microphones;
    m_ub = config.mic_ub;
    m_lb = config.mic_lb;
    %tod_scale = config.tod_scale;
    drift_distance = config.drift_distance;
    drift_duration = config.drift_duration;
    %cor_noise = config.correspondence_noise;
    sos = config.speed_of_sound;
    tracks_file = config.tracks_file;
    tracks_config_file = config.tracks_config_file;
    mic_ave_depth = config.mic_ave_depth;
    
    if (strcmp(mic_positions_source, 'tracks') && (all(~isnan(tracks_file))) && all((~isnan(tracks_config_file))))
        if ~exist('tracks', 'var') || ~exist('tracks_config', 'var')
            %addpath should be done at a higher level to avoid being called
            %multiple times
            %addpath('../data');
            tracks_file = load(tracks_file);
            tracks = tracks_file.tracks;
            tracks_config_file = load(tracks_config_file);
            tracks_config = tracks_config_file.tracks_config;
        end
    end
    
    % generate src positions
    cc = generatePositions(s_nc, s_ub, s_lb); % cluster centroids
    srcs = [];
    for i=1:s_nc
        c_ub = min(cc(:,i) + s_cr, s_ub);
        c_lb = max(cc(:,i) - s_cr, s_lb);
        if i <= rem(ns, s_nc)
            cluster_poses = generatePositions(ceil(ns/s_nc), c_ub, c_lb);
        else 
            cluster_poses = generatePositions(floor(ns/s_nc), c_ub, c_lb);
        end
        srcs = [srcs cluster_poses];
    end
    
    %for i=1:rem(ns, s_nc) 
    %    srcs = [srcs generatePositions(1, s_ub, s_lb)];
    %end
    
    % generate microphone positions
    if strcmp(mic_positions_source, 'synthetic')
        mics = generatePositions(nm, m_ub, m_lb);
        % generate gaussian random noise to account for drifting in microphone
        % positions
        mics_drift = addGaussianNoise(mics, drift_distance);
        
    elseif strcmp(mic_positions_source, 'tracks') 
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
        
        %{
        valid_positions = false;
        % make sure the extracted positions are valid
        while ~valid_positions
            valid_positions = true;
            % extract random positions from tracks
            positions = extractPositionsFromTracks(tracks, tracks_config);
            mics = zeros(3,nm);
            for i = 1:length(tracks_config.good_tracks)
                % if there is an missing position, get another set of
                % positions from tracks
                if isempty(positions{i})
                    valid_positions = false;
                    break;
                end
                mics(:, i) = positions{i}(1, :)';
            end
        end
        %}
    else
        error('Undefined data type for microphone configuration');
    end
    

    
    % generate time of departures
    tods_gt = drift_duration * generateTODs(ns);
    
    % generate time difference of arrival data
    % without gaussian noise
    tofs_gt = timeOfFlights(srcs, mics, sos);
    tdoas_gt = tods_gt + tofs_gt;
    
    % with gaussian noise
    % Assuming relative drift between the time a sound source reaches
    % different microphones is negligiable.
    % Assuming uniform linear drift over time, tod can be used to compute
    % the percentage of drift along drift path.
    
    tofs_drift = timeOfFlights(srcs, mics_drift, sos);
    tofs_gn = tofs_gt + tods_gt/drift_duration .* (tofs_drift - tofs_gt);
    tdoas_gn = tods_gt + tofs_gn;
    
    tdoas_i1s = tdoas_gn(:, 1);
    tdoas_gn_anchored = tdoas_gn - tdoas_i1s;
    
    % generate correspondences
    %[correspondences, cor_ids] = generateCorrespondences(tdoas_gn, cor_noise);
    %tdoas_gn_cn = [tdoas_gn; correspondences];
      
    % time at which microphone 1 (anchor) receives the signal from source
    %tdoa_i1s = tdoas_gn_cn(:, 1);
    
    % set the times of m_i0s to 0
    %tdoas_gn_cn = tdoas_gn_cn - tdoa_i1s;
    
    % update the tods_gt to reflect the time offset
    toffset_gt = tods_gt - tdoas_i1s(1:ns);
    
    % update the tods_gt and srcs_gt for correspondances
    %tods = [tods_gt; tods_gt(cor_ids)];
    %srcs = [srcs srcs(:, cor_ids)];
    
    time_measurements = cell(nm, 1);
    for j=1:nm
        time_measurements{j} = sort(tdoas_gn(:, j));
    end
    
    %% generate output
    data.tms = time_measurements;
    data.tdoas = tdoas_gn_anchored;
    data.tofs = tofs_gn;
    ground_truth.srcs = srcs;
    % using the median mic positions as the gt
    ground_truth.mics = (mics + mics_drift)/2;    
    ground_truth.mics_drift = mics_drift;
    ground_truth.tods = tods_gt;
    ground_truth.toffset = toffset_gt;
    ground_truth.tofs = tofs_gt;
    ground_truth.tdoas = tdoas_gt;
    data.gt = ground_truth;
 
end


%% Helper Functions

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% addGaussianNoise(tdoa, noise_level)
% @decription: add Gaussian noise to position data.
% @param1 poses: position data
% @param2 noise_level: the coefficent of the random normal noise
% @return1 poses_with_gn: 3xn matrix with the [x; y; z] positions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function poses_with_gn = addGaussianNoise(poses, noise_level)
    [h, w] = size(poses);
    poses_with_gn = zeros(h, w);
    for i =1:w
        poses_with_gn(:, i) = poses(:, i) + randNormDrift(noise_level);
        %poses_with_gn(:, i) = poses(:, i) + randNormCircle(noise_level);
    end
end

function noise = randNormDrift(noise_level)
    noise = [ normrnd(0, noise_level(1));
              normrnd(0, noise_level(2));
              normrnd(0, noise_level(3));
    ];        
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% generatePositions
% @decription: generate n random positions in a unit cube.
% @param1 n: number of positions
% @param2 ub: upperbound of [x; y; z]. [1 1 1]' by default
% @param3 lb: lowerbound of [x; y; z]. [0 0 0]' by default
% @return1 poses: 3xn matrix with the [x; y; z] positions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function poses = generatePositions(n, ub, lb)
    if ~exist('ub', 'var')
        ub = [1 1 1]';
    end
    if ~exist('lb', 'var')
        lb = [0 0 0]';
    end
    scale = diag(ub - lb);
    center = (ub + lb) / 2;
    poses = zeros(3, n);
    for i = 1:n
        poses(:, i) = scale * (randomPosition() - [1/2 1/2 1/2]') + center;
    end
end

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
% timeOfFlights
% @description: compute the time of flight.
% @param1 srcs: positions of sound sources
% @param2 mics: positions of microphones
% @param3 speed_of_sound: speed of sound
% @return1 tofs: s x m matrix of tof data.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function tofs = timeOfFlights(srcs, mics, speed_of_sound) 
    ns = size(srcs, 2);
    nm = size(mics, 2);
    tofs = zeros(ns, nm);
    for i = 1:ns
        for j = 1:nm
            tofs(i, j) = timeOfFlight(srcs(:,i), mics(:, j), speed_of_sound);
        end
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% generateCorrespondences
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% randomPosition
% @description: generate 1 random 3D position in a unit cube.
% @return1 rand_pos: generate a random 3x1 vector of [x; y; z]
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function rand_pos = randomPosition()
    rand_pos = [rand(); rand(); rand()];
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