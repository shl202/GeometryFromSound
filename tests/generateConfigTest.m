% Test if generateConfig script generates a config_default.mat file
clear;

addpath('../');

generateConfig;

assert(isfile('config_default.mat'));

delete('config_default.mat');