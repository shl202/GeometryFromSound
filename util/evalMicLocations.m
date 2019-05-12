function [lse, R, T, isValid] = evalMicLocations(mics, mics_gt, mode)
    if strcmpi(mode, '2D')
        [lse, R, T, isValid] = leastSquareFitting2D(mics(1:2, :), mics_gt(1:2, :));
    elseif strcmpi(mode, '3D')
        [lse, R, T, isValid] = leastSquareFitting3D(mics, mics_gt);
    elseif strcmpi(mode, '3Dto2D')
        [~, R, T, isValid] = leastSquareFitting3D(mics, mics_gt);
        micsRT =  R * mics + T;
        [lse, ~, ~, ~] = leastSquareFitting2D(micsRT(1:2, :), mics_gt(1:2, :));      
    else 
        error(['Evaluation Mode not supported.'])
    end
end