function stats = runTrials(configs, iterations, algorithm, eval_algorithm, seed)  
    SEEDMAX = 2^31; % IMIN and IMAX must be less than 2^53.
    if ~exist('seed', 'var')
        % basically generate a random seed if no
        rng('shuffle');
        seed = randi(SEEDMAX);
    end
    
    addpath('../');
    addpath('../src');
    addpath('../util');
    addpath('../data');
    
    % initialize variables
    stats.iterations = iterations;
    stats.algorithm = algorithm;
    stats.eval_algorithm = eval_algorithm;
    stats.seed = seed;
    stats.mean_mses = zeros(length(configs), 1);
    stats.median_mses = zeros(length(configs), 1);
    stats.mean_rmses = zeros(length(configs), 1);
    stats.median_rmses = zeros(length(configs), 1);
    stats.stds = zeros(length(configs), 1);
    stats.rstds = zeros(length(configs), 1);
    stats.num_of_invalid_trials = zeros(length(configs), 1);
    stats.num_of_invalid_correspondences = zeros(length(configs), 1);
    stats.num_of_invalid_samples = zeros(length(configs), 1);
    stats.num_of_invalid_locations = zeros(length(configs), 1);
    stats.num_of_invalid_reconstructions = zeros(length(configs), 1);
    %stats.max_distances = zeros(length(configs), 1);
    
    rng(seed);
    stats.seeds = SEEDMAX * rand(length(configs), iterations);
    
    disp(['Algorithm: ' algorithm]);
    
    % Run the system with all the given configurations
    for c=1:length(configs)
        disp(['Configuration: ' num2str(c)]);
        %distances = zeros(iterations, 1);
        mses = NaN(iterations, 1);
        invalid_cor = 0; % correspondences
        invalid_sam = 0; % samples
        invalid_loc = 0; % locations
        invalid_rec = 0; % reconstructions
        
        % Pre-loading track file to reduce run time from loading. Loading 
        % at each configuration.
        tracks_file = load(configs(c).tracks_file);
        tracks = tracks_file.tracks;
        tracks_config_file = load(configs(c).tracks_config_file);
        tracks_config = tracks_config_file.tracks_config;
        
        % Run the system for given iterations
        for it=1:iterations
            if mod(it, 100) == 0
                disp(['Config: ' num2str(c)]);
                disp(['  Iteration: ' num2str(it)]);
            end
            
            % seeds make sure that we can replicate the generated data.
            rng(stats.seeds(c, it));

            data = generateTDOAData(configs(c), tracks, tracks_config);
            
            %distances(it) = maxDistancePS(data.gt.mics);

            [correspondences, sample, locations] = computeMicLocations(data, configs(c), algorithm);
                  
            if ~correspondences.isValid
                invalid_cor = invalid_cor + 1;
            end
            
            if ~sample.isValid
                invalid_sam = invalid_sam + 1;
            end
            
            if ~locations.isValid
                invalid_loc = invalid_loc + 1;
            end         
            
            
            % check if computed result is valid
            if ( locations.isValid )
                % computed microphone locations
                mics = locations.mics;
                % ground truth microphone locations
                mics_gt = data.gt.mics;
                
                % sanity check of microphone positions
                % We won't have ground truth data on microphone positions,
                % but we can still have the sanity check if we know
                % approximate initial prositions.
                if( ~areLocationsReasonable(locations.mics) )
                    locations.isValid = false;
                    invalid_loc = invalid_loc + 1;
                    mses(it) = NaN;   
                else
                    % compute lse using least Square Fitting for 2D/3D point sets
                    [lse, R, T, RTisValid] = evalMicLocations(mics, mics_gt, eval_algorithm);

                    [h, w] = size(locations.mics);
                    if (RTisValid)
                        mses(it) = 1/w * lse;
                    else
                        invalid_rec = invalid_rec + 1;
                        mses(it) = NaN;
                    end
                end
            end
        end
        
        % tally up the statistics
        validmses = mses(~isnan(mses));  
        %stats.max_distances(c) = max(distances);
        stats.mean_mses(c) = mean(validmses); 
        stats.median_mses(c) = median(validmses);
        stats.mean_rmses(c) = mean(sqrt(validmses));
        stats.median_rmses(c) = median(sqrt(validmses));
        stats.stds(c) = std(validmses);
        stats.rstds(c) = std(sqrt(validmses));
        stats.num_of_invalid_trials(c) = iterations - length(validmses);
        stats.num_of_invalid_correspondences(c) = invalid_cor;
        stats.num_of_invalid_samples(c) = invalid_sam;
        stats.num_of_invalid_locations(c) = invalid_loc;
        stats.num_of_invalid_reconstructions(c) = invalid_loc + invalid_rec;
        %assert(stats.num_of_invalid_trials(c) == stats.num_of_invalid_reconstructions(c))
    end
end