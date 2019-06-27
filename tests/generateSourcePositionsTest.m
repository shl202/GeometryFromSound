% Test if generateConfig script generates a matrix of source positions file
clear;

addpath('../');
addpath('../src');
addpath('../data');
generateConfig;

load config_default.mat;
poses = generateSourcePositions(config_default);
assert( isequal(size(poses), [3, config_default.num_of_sources]))
