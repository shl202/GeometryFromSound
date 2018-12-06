function [correspondences, sample, locations] = computeMicLocations(data, config, mode)   
    if strcmpi(mode, 'asfs2D')
        correspondences.isValid = true;
        sample.isValid = true;
        locations = asfs2D(data.tdoas, config.speed_of_sound);
        
    elseif strcmpi(mode, 'asfs') || strcmpi(mode, 'asfs3D')
        correspondences.isValid = true;
        sample.isValid = true;
        locations = asfs(data.tdoas, config.speed_of_sound);
        
    elseif strcmpi(mode, 'dcosaml')
        correspondences.isValid = true;
        sample.isValid = true;
        locations = dcosaml(data.tdoas, config.speed_of_sound);
    else 
        error([mode ' is not supported.'])
    end
end