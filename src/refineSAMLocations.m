function locationsR = refineSAMLocations(locations, tdoas, tods, speed_of_sound)
            
    % Levenberg-Marquardt iterative refinement algorithm
    options = optimoptions('lsqnonlin', 'Algorithm', 'levenberg-marquardt');
    
    M = locations.M;
    S = locations.S;
    T = tods;
    m0 = locations.M;
    s0 = locations.S;
    t0 = tods;
    
      
        function Fm = refine_mics(x)
            A = S';
            C = T - tdoas;
            Fm = sum(sum((1/speed_of_sound * sqrt(A * x) + C).^2));     
        end
        
        %M = lsqnonlin(@refine_mics, m0, [], [], options);

        
        function Ft = refine_tods(x)
           A = NaN;
           C = 1/speed_of_sound * (sqrt(S' * M)) - tdoas;
           %Ft = sum(sum((C + x).^2));  
           Ft = sum(sum((C + x).^2));
        end

        
        %T = lsqnonlin(@refine_tods, t0, [], [], options);
        
        
        function Fs = refine_srcs(x)
            A = M;
            C = T - tdoas;
            %Fs = sum(sum((1/speed_of_sound * sqrt(x' * A) + C).^2));
            Fs = sum(sum((1/speed_of_sound * sqrt(x' * A) + C).^2));
        end

        %S = lsqnonlin(@refine_srcs, s0, [], [], options);
        %m0 = M;
        %s0 = S;
        %t0 = T;

    if ~locations.isValid
        locationsR.M = NaN;
        locationsR.S = NaN;
        locationsR.mics = NaN;
        locationsR.srcs = NaN;
        locationsR.isValid = false;
    else  
        for i = 1:5
            M = lsqnonlin(@refine_mics, m0, [], [], options);
            T = lsqnonlin(@refine_tods, t0, [], [], options);
            S = lsqnonlin(@refine_srcs, s0, [], [], options);
            m0 = M;
            s0 = S;
            t0 = T;
        end

        if isreal(M)
            locationsR.S = S;
            locationsR.M = M;
            locationsR.mics = M(2:4, :);
            locationsR.srcs = S(2:4, :);
            locationsR.isValid = locations.isValid;
        else
            locationsR.M = locations.M;
            locationsR.S = locations.S;
            locationsR.mics = locations.mics;
            locationsR.srcs = locations.srcs;
            locationsR.isValid = locations.isValid;
        end
    end
end