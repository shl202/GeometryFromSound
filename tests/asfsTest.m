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
%config.mic_position_source = 'tracks';
configs.mic_positions_source = 'synthetic';
configs.num_of_microphones = 17;
configs.mic_ub = [150 150 0]';
configs.mic_lb = [-150 -150 -150]';
configs.mic_ave_depth = -150/2;
config.num_of_sources = 20;
config.src_num_of_clusters = 20;
%config.drift = 10; % noise

data = generateTDOAData(config);

locations = asfs(data.tdoas, config.speed_of_sound);

if locations.isValid
    mics_comp = locations.mics;
    [lse, R, T, isValid] = leastSquareFitting3D(mics_comp, data.gt.mics);
    micsRT = R * mics_comp + T;
   
    [h, w] = size(mics_comp);
    rmse = sqrt(1/w * lse);

    figure;
    myscatter3(micsRT, 45, 'g', '^'); hold on;
    myscatter3(data.gt.mics, 35, 'k', 'o');
    myscatterlines3(micsRT, data.gt.mics);
    
    %figure;
    %myscatter2(micsRT2, mics_gt(1:2, :));
    rmse

    assert(rmse < error_tolerance);
else
    assert(false)
end
