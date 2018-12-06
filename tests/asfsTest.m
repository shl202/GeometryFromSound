clear;

% add source code folder
addpath('../src');
addpath('../data');

% error tolerances of this test
error_tolerance = 3; % meters

load config_default.mat;
config = config_default;
config.num_of_sources = 10;
config.num_of_microphones = 10;
config.src_num_of_clusters = config.num_of_sources;
config.correspondence_noise = 0;
config.drift = 0; % no noise

data = generateTDOAData(config);

locations = asfs(data.tdoas, config.speed_of_sound);

if locations.isValid
    mics_comp = locations.mics;
    [lse, R, T, isValid] = leastSquareFitting3D(mics_comp, data.gt.mics);
    micsRT = R * mics_comp + T;
   
    [h, w] = size(mics_comp);
    mse = 1/w * lse;

    figure;
    myscatter3(micsRT, data.gt.mics);
    
    %figure;
    %myscatter2(micsRT2, mics_gt(1:2, :));
    mse

    assert(mse < error_tolerance);
else
    assert(false)
end
