clear;

% add source code folder
addpath('../');
addpath('../src');
addpath('../data');
addpath('../util');



% error tolerances of this test
error_tolerance = 25; % meters

load config_default.mat;
config = config_default;
config.mic_position_source = 'tracks';
%config.num_of_sources = 20;
%config.num_of_microphones = 10;
%config.mic_ub = [150 150 150]';
%config.mic_lb = [-150 -150 -150]';
%config.src_num_of_clusters = config.num_of_sources;
%config.drift = 10; % no noise

data = generateTDOAData(config);

[ns, nm] = size(data.tdoas);

% add bad tdoas data
badTdoas = rand(5, nm);
badTdoas = badTdoas - badTdoas(:, 1);
riggedData.tdoas = [ badTdoas; data.tdoas ];


%[~, ~, locations] = ransacMicLocations(riggedData, config, 'asfs3D');
%[~, ~, locations] = computeMicLocations(riggedData, config, 'ransacasfs3D');
[ns, nm] = size(riggedData.tdoas);

% parameters for ransac and asfs3D 
minCase = 6;
T = 35; % rmse of microphone position estimates
Pgood = 3/4; % estimated percentage of sound sources that are good  
K = 15;
Pfail = 0.001;
L = ceil(log(Pfail)/log(1-(Pgood^minCase)));
[~, sample, locations] = ransacMicLocations(riggedData, config, 'asfs3d', minCase, T, K, L);

if locations.isValid
    mics_comp = locations.mics;
    [lse, R, T, isValid] = leastSquareFitting3D(mics_comp, data.gt.mics);
    micsRT = R * mics_comp + T;
   
    [h, w] = size(mics_comp);
    rmse = sqrt(1/w * lse);

    figure;
    myscatter3(micsRT, 45, 'r', 'x'); hold on;
    myscatter3(data.gt.mics, 35, 'g', 'o');
    myscatterlines3(micsRT, data.gt.mics);
    
    %figure;
    %myscatter2(micsRT2, mics_gt(1:2, :));
    rmse

    assert(rmse < error_tolerance);
else
    assert(false)
end
