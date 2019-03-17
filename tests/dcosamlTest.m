clear;

% add source code folder
addpath('../src');
addpath('../data'); 

% error tolerances of this test
error_tolerance = 3; % meters

load config_default.mat;
config = config_default;
config.mic_positions_source = 'tracks';
config.num_of_sources = 20;
%config.num_of_microphones = 10;
%config.mic_ub = [150 150 0]';
%config.mic_lb = [-150 -150 -150]';
config.src_num_of_clusters = config.num_of_sources;
config.drift = 1.0; % no noise

data = generateTDOAData(config);

locations = dcosaml(data.tdoas, config.speed_of_sound);

if locations.isValid
    mics_comp = locations.mics;
    [lse, R, T, isValid] = leastSquareFitting3D(mics_comp, data.gt.mics);
    micsRT = R * mics_comp + T;
   
    [h, w] = size(mics_comp);
    mse = 1/w * lse;

    figure;
    myscatter3(micsRT, 35, 'g', '^'); hold on;
    myscatter3(data.gt.mics, 35, 'k', 'o');
    %myscatterlines3(micsRT, data.gt.mics);
    mse

    assert(mse < error_tolerance);
else
    assert(false)
end
