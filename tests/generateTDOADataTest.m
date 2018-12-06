% Test if generateTDOAData generate a data struct with the appropriate
% fields:
%         - .tdoas : time difference of arrival data
%         - .gt    : ground truth struct
%         - .gt.mics : ground truth microphone positions
%         - .gt.srcs : ground truth source positions

clear;

addpath('../');
addpath('../data');
addpath('../src');

% load default configurations
load config_default.mat;
config = config_default;

data = generateTDOAData(config);

assert(isfield(data, 'tdoas'));
assert(isfield(data, 'gt'));
assert(isfield(data.gt, 'mics'));
assert(isfield(data.gt, 'srcs'));
