function [correspondences, sample, locations] =  ransacMicLocations(data, config, algorithm, minCase, T, K, L)
% ransacMicLocations 
% @description: compute microphone locations using RANSAC to remove
%               outliers.
% 
% @usage: [correspondences, sample, locations] = ransacMicLocations(data, config, algorithm, minCase, T, K, L)
% @param1: data, data struct which contains a matrix of time difference of 
%          arrive data.
% @param2: config,  a configuration struct in which one of its field
%          specify the speed of sound
% @param3: algorithm, a string which specify which algorithm to call.
%          availible algorithms are: ["asfs2D", "asfs3D", and "dcosaml"]
% @param4: minCase, minimum number of sources needed to reliably complete
%          the computation.
% @param5: T, threshold of rmse difference between sound sources.
% @param6: K, minimum number of consistent source sources needed for 
%          successful completion of RANSAC.
% @param7: L, number of ransac iterations.
% @return1: correspondences, replace holder variable for when
%           correspondences needs to be correlated.
% @return2: sample, set of consistent data found after RANSAC is used to
%           remove outlier.
%               sample.srcs, srcs in the sample.
%               sample.tdoas, tdoas in the sample.
% @return3: locations,
%               locations.C, C matrix in ASFS (2x2 or 3x3)
%               locations.S, S matrix used in DCOSAML (5 by ns)
%               locations.M, M matrix used in DCOSAML (5 by nm)
%               locations.srcs, computed source locations (2 x ns) 
%               locations.mics, computed microphone locations (2 x nm);
%               locations.isValid, true if successful computed the source
%                                  and microphone positions, false when 
%                                  Mprimehat is deficient in rank or when
%                                  nearest semi-definite matrix cannot be
%                                  computed for Q matrix;
%   

    if ~exist('minCase', 'var')
        minCase = 10;
    end
    
    if ~exist('T', 'var')
        T = 300/4;
    end
    
    if ~exist('K', 'var')
        K = floor(0.8 * size(data.tdoas, 1));
    end
    
    if ~exist('L', 'var')
        L = size(data.tdoas, 1);
    end 
    
    [inliers, isValid] = findInliers(data, config, algorithm, minCase, T, K, L);
    sample.isValid = isValid;
    if isValid
        sample.srcs = inliers;    
        sample.tdoas = data.tdoas(inliers, :);
        [correspondences, ~, locations] = computeMicLocations(sample, config, algorithm);
    else
        [correspondences, ~, locations] = computeMicLocations(data, config, algorithm);
    end 
    
    % DEBUG
    %if ~locations.isValid
    %    locations 
    %end
end


%% Helper Functions
function [inliers, isValid] =  findInliers(data, config, algorithm, minCase, T, K, L)
    [ns, nm] = size(data.tdoas);
    inliers = [];
    
    if ns < minCase
        error("Not enough sound sources to perform RANSAC.")
    end
     
    it = 0;
    
    while it < L
        rs = randperm(ns); % random sources
        head = rs(1:minCase);
        tail = rs(minCase+1:end);
        
        % make hypothesis
        initSample.tdoas = data.tdoas(head, :);
        [~, ~, islocs] = computeMicLocations(initSample, config, algorithm);

        % list of sources consistent with the initial sources
        consisSrcs = head;
        
        if areLocationsReasonable(islocs.mics)
            % verify consistency with remaining sources
            for j=1:length(tail)
                veriSample.tdoas = [data.tdoas(consisSrcs, :); data.tdoas(tail(j), :)];
                [~, ~, vslocs] = computeMicLocations(veriSample, config, algorithm);
                [lse, ~, ~, ~] = leastSquareFitting3D(islocs.mics, vslocs.mics);
                rmse = sqrt(1/nm * lse);
                if rmse < T
                    consisSrcs = [consisSrcs tail(j)];
                end
            end


            % find size of consisSrcs
            if length(consisSrcs) > K
                inliers = consisSrcs;
                it = L; 
            end
        end
        
        it = it + 1;
    end
    
    if isempty(inliers)
        isValid = false;
    else
        isValid = true;
    end
end