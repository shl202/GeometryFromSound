% Test if generateConfig script generates a matrix of microphone positions
clear;

addpath('../');
addpath('../src');
addpath('../data');
generateConfig;

load config_default.mat;
config_default.mic_positions_type = "tracks";
[poses_ini poses_fin] = generateMicrophonePositions(config_default);

assert( isequal(size(poses_ini), [3, config_default.num_of_microphones]));
assert( isequal(size(poses_fin), [3, config_default.num_of_microphones]));
