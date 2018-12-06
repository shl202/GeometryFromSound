function [ix, iy] = approximateIntercept(x1, y1, x2, y2)
% approximateIntercept
% @description: approximate the intercepting point two data sets assuming
%               both dataset are approximately linear;
% @param1: x1, x values of dataset 1
% @param2: y1, y values of dataset 1
% @param3: x1, x values of dataset 2
% @param4: y1, y values of dataset 2
% @return1: ix, x value of the intercept
% @return2: ix, y value of the intercept
%

    if ~(length(x1) == length(y1) && length(x2) == length(y2))
       error("Length of input vectors for each dataset must be the consistent.");
    end
    
    if ~iscolumn(x1)
        x1 = x1';
    end
    
    if ~iscolumn(y1)
        y1 = y1';
    end
    
    if ~iscolumn(x2)
        x2 = x2';
    end
    
    if ~iscolumn(y2)
        y2 = y2';
    end
    
    mb1 = polyfit(x1, y1, 1);
    mb2 = polyfit(x2, y2, 1);
    
    m1 = mb1(1);
    b1 = mb1(2);
    m2 = mb2(1);
    b2 = mb2(2);
    
    ix = (b1 - b2) / (m2 - m1);
    iy = m1 * ix + b1;
end