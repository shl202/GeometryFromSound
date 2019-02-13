function myscatterlines2(ps1, ps2)
% myscatterline2
% @description: draw lines between two 2D points sets
% @usage: myscatterlines2(ps1, ps2)
% @param1: ps1, first 2 x n point set
% @param2: ps2, second 2 x n point set
%
    assert(all(size(ps1) == size(ps2)))
    
    x = [ps1(1,:)' ps2(1, :)'];
    y = [ps1(2,:)' ps2(2, :)'];
    for i = 1:length(ps1)
        line(x(i, :)', y(i, :)')
    end
end