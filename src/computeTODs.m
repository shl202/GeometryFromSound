function tods = computeTODs(tdoas)
% computeTODs
% @description: compute the time of departure using time difference of 
%               arrival data
% @usage: tods = computeTODs(tdoas)
% @param1 tdoas: time difference of arrival data
% @return1 tods: time of departure (aka offset)
% @citation: Pollefeys, Marc & Nistér, David. (2008). 
%            Direct computation of sound and microphone locations from 
%            time-difference-of-arrival data. 
%            ICASSP, IEEE International Conference on Acoustics, 
%            Speech and Signal Processing - Proceedings. 2445-2448. 
%            10.1109/ICASSP.2008.4518142. 
%

    [h, w] = size(tdoas);
    tods = zeros(h, 1);
    
    %A = tdoas .^ 2;
    %B = tdoas .* (-2);
    C = 1/w * sum(tdoas, 2);
    tdoasZeroMean = tdoas - C;
    
    % Computation works better with zero-means data
    A = tdoasZeroMean .^ 2;
    B = tdoasZeroMean .* (-2);
    
    % minimal case is 5 srcs x 10 mics
    group_size = 5;
    groups = assignRandomGroup(h, group_size);

    [num_of_groups, ~] = size(groups);

    for i = 1: num_of_groups
        abar = A(groups(i, :), :);
        bbar = B(groups(i, :), :);
        abbar = [abar; bbar];
        X = ones(1, w) / abbar;
        for j = 1:group_size
            tods(groups(i,j)) = X(1, j  + group_size ) / X(1, j);
        end
    end
    tods = tods + C;
end


%% Helper Functions

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% assignRandomGroup
% @description: assign elements into random groups with size of group_size
% @param1 elements: number of elements that needs a group
% @param2 group_size: the size of each group
% @return1 assignments: the assigned group numbers for all elements
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function assignments = assignRandomGroup(elements, group_size)
    % needs to assert group_size < elements
    if group_size > elements
        error('number of elements must be >= to group_size'); 
    end
    w = group_size;
    h = ceil(elements/group_size);
    remainder = mod(elements, w);
    if remainder == 0
        offset = 0;
    else
        offset = w - mod(elements, w);
    end
    
    randlist = randperm(elements)';
    
    assignments = zeros(h, w);
    for i = 1:h
        if i == h
            for j = 1:w
                assignments(i, j) = randlist((i-1) * w + j - offset);
            end
        else
            for j = 1:w
                assignments(i, j) = randlist((i-1) * w + j);
            end
        end
    end
end