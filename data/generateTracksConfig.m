tracks_config.num_tracks = 18;
tracks_config.good_tracks = [1 2 3 4 5 6 7 8 9 11 12 13 14 15 16 17 18]';
tracks_config.bad_tracks = [10]';
tracks_config.time_max = 2.491372451334606e+05;
tracks_config.time_min = 2.311131807907711e+05;

save('tracks_Mar23_config.mat', 'tracks_config');