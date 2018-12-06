function rgb_triplet = toRGBTriplet(option)
    switch option
        case {'red', 'r'}
            rgb_triplet = [1 0 0];
        case {'green', 'g'}
            rgb_triplet = [0 1 0];
        case {'blue', 'b'}
            rgb_triplet = [0 0 1];
        case {'yellow', 'y'}
            rgb_triplet = [1 1 0];
        case {'magenta', 'm'}
            rgb_triplet = [1 0 1];
        case {'cyan', 'c'}
            rgb_triplet = [0 1 1];
        case {'white', 'w'}
            rgb_triplet = [1 1 1];
        case {'black', 'k'}
            rgb_triplet = [0 0 0];
        otherwise
            warning("Color option is not recognized. Display as white instead");
            rgb_triplet = [1 1 1];
    end
end
