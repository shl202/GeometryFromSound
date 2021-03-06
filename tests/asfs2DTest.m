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
config.num_of_sources = 10;
config.src_num_of_clusters = config.num_of_sources;
config.drift = 0; % no noise

data = generateTDOAData(config);

locations = asfs2D(data.tdoas, config.speed_of_sound);

if locations.isValid
    mics_comp = locations.mics;
    [lse, R, T, isValid] = leastSquareFitting2D(mics_comp, data.gt.mics(1:2,:));
    micsRT = R * mics_comp + T;
   
    [h, w] = size(mics_comp);
    rmse = sqrt(1/w * lse);

    figure;
    myscatter2(micsRT, 35, 'r', 'x'); hold on;
    myscatter2(data.gt.mics(1:2, :), 35, 'g', 'o');
    myscatterlines2(micsRT, data.gt.mics(1:2,:));

    rmse

    assert(rmse < error_tolerance);
else
    assert(false)
end
