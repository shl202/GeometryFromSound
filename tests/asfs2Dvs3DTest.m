clear;

% add source code folder
addpath('../src');
addpath('../data');

% error tolerances of this test
error_tolerance = 2.5^2; % meters

load config_default.mat;
config = config_default;
config.num_of_sources = 20;
config.src_num_of_clusters = config.num_of_sources;
config.drift = 0; % no noise

data = generateTDOAData(config);

locations2 = asfs2D(data.tdoas, config.speed_of_sound);
locations3 = asfs(data.tdoas, config.speed_of_sound);

if locations2.isValid
    mics_comp2 = locations2.mics;
    [lse2, R, T, isValid2] = leastSquareFitting2D(mics_comp2, data.gt.mics(1:2, :));
    micsRT2 = R * mics_comp2 + T;
   
    
    mics_comp3 = locations3.mics;
    [lse3, R, T, isValid3] = leastSquareFitting3D(mics_comp3, data.gt.mics);
    micsRT3 = R * mics_comp3 + T;
    [lse3, R, T, isValid3] = leastSquareFitting2D(micsRT3(1:2, :), data.gt.mics(1:2, :));
    
    [h, w] = size(mics_comp2);
    mse2 = 1/w * lse2;
    mse3 = 1/w * lse3;

    figure;
    sz = 35;
    myscatter2(micsRT2, sz*1.5, 'r', 'x'); hold on;
    myscatter2(micsRT3(1:2,:), sz, 'g', '^'); 
    myscatter2(data.gt.mics(1:2, :), sz, 'k', 'o');
    %myscatterlines2(micsRT2, data.gt.mics(1:2,:));
    %myscatterlines2(micsRT3(1:2,:), data.gt.mics(1:2,:));
    %figure;
    %myscatter2(micsRT2, mics_gt(1:2, :));
    mse2
    mse3

    assert(mse3 <= mse2);
else
    assert(false)
end
