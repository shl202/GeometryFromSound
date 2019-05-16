# GeometryFromSound
This code implements three algorithms that estimate the relative positions of a group of acoustic receivers using difference of arrival (TDOA) data from ambient noise. 
* 2D Affine Structure from sound (ASFS) [1]
* 3D Affine Structure from sound (ASFS) which is a trivial generalization of [1]
* Direct computation of Source and Microphone locations (DCOSAML) [2]

The application to this research is the localization of a swarm of free-drifting autonomous underwater explorers (AUEs) using acoustic receivers. These algorithms can estimate relative geometry of the AUEs using the time difference of arrival (TDOA) data from existing ambient noise in the ocean. To test the performance of these algorithms, we use AUE position data collected from deployment in Jaffe et al [3] and craft synthetic TDOA data with generated sound source positions. We found that the 2D affine structure from sound (ASFS) algorithm is, in general, more precise and stable, but its 3D counterpart can be more accurate when the geometry of the sound sources and AUEs is not close to planar. The 3D direct computation of source and microphone locations (DCOSAML) algorithm performs poorly because it does not handle relative drift between the AUEs well. This work was inspired by Naughton et al [4]. 

# Citations
1. @article{Thrun_2005,
	title = {Affine structure from sound},
	volume = {},
	issn = {},
	number = {},
	journal = {Advances in Neural Information Processing Systems 18 Neural Information	Processing Systems},
	author = {Thrun, S.},
	year = {2005},
	pages = {1353-1360}
},

2. @article{Pollefey_2008,
	title = {Direct computation of sound and microphone	locations from time-difference-of-arrival data},
	volume = {},
	issn = {},
	number = {},
	journal = {Acoustics, Speech and Signal Processing, 2008 International Conference on. IEEE},
	author = {Pollefeys, M. and Nister, D.},
	year = {2008},
	pages = {2445-2448}
},

3. @article{Jaffe_2017,
	title = {A swarm of autonomous miniature underwater robot drifters for exploring submesoscale ocean dynamics},
	volume = {8},
	number = {14189},
	journal = {Nature Communications},
	author = {Jaffe, J. S. and Franks, J. S. and Roberts, P. L. D. and Mirza, D. and Schurgers, C. and Kastner, R. and Boch, A.},
	year = {2017},
	pages = {}
},

4. @article{Naughton_2017,
	title = {Self-localization of a deforming swarm of underwater vehicles using impulsive sound sources of opportunity},
	volume = {6},
	issn = {},
	number = {},
	journal = {IEEE Access},
	author = {Naughton, P. and Roux, P. and Schugers, C. and Kastner, R. and Jaffe, J. S. and Roberts, P. L. D},
	year = {2017},
	pages = {1635-1646}
},
