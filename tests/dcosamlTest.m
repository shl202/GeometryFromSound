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
%config.mic_positions_source = 'tracks';
config.mic_positions_type = 'synthetic';
config.num_of_sources = 20;
config.num_of_microphones = 17;
config.mic_ub = [150 150 0]';
config.mic_lb = [-150 -150 -1]';
config.src_num_of_clusters = config.num_of_sources;
config.drift_distance = [0.0 0.0 0]; % no noise

data = generateTDOAData(config);

tdoas = data.tdoas;
speed_of_sound = config.speed_of_sound;
locations = dcosaml(data.tdoas, config.speed_of_sound);
%rank = 5;
%tods = computeTODs(tdoas, rank);
%locations = computeSAMLocationsFromTOFs(tdoas, tods, speed_of_sound, rank);
%locations = refineSAMLocations(locations, tdoas, tods, speed_of_sound);

if locations.isValid
    mics_comp = locations.mics;
    [lse, R, T, isValid] = leastSquareFitting3D(mics_comp, data.gt.mics);
    micsRT = R * mics_comp + T;
   
    [h, w] = size(mics_comp);
    rmse = sqrt(1/w * lse);

    figure;
    myscatter2(micsRT, 35, 'g', '^'); hold on;
    myscatter2(data.gt.mics, 35, 'k', 'o');
    %myscatterlines3(micsRT, data.gt.mics);
    rmse

    assert(rmse < error_tolerance);
else
    assert(false)
end
