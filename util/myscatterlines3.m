function myscatterlines3(ps1, ps2)
% myscatterline3
% @description: draw lines between two 3D points sets
% @usage: myscatterlines3(ps1, ps2)
% @param1: ps1, first 3 x n point set
% @param2: ps2, second 3 x n point set
%
    assert(all(size(ps1) == size(ps2)))
    
    x = [ps1(1,:)' ps2(1, :)'];
    y = [ps1(2,:)' ps2(2, :)'];
    z = [ps1(3,:)' ps2(3, :)'];
    for i = 1:length(ps1)
        line(x(i, :)', y(i, :)', z(i,:)')
    end
end