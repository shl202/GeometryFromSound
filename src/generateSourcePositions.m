function poses = generateSourcePositions(config)
    source_position_type = config.source_position_type;
    ns = config.num_of_sources;
    s_ub = config.src_ub;
    s_lb = config.src_lb;
    s_nc = config.src_num_of_clusters;
    s_c_ub = config.src_cluster_ub;
    s_c_lb = config.src_cluster_lb;
    
    if strcmpi(source_position_type, 'random')
        poses = generatePositions(ns, s_ub, s_lb);
        
    elseif strcmpi(source_position_type, 'clustered')
        poses = generateClusteredPositions(ns, s_ub, s_lb, s_nc, s_c_ub, s_c_lb);
       
    else
        
        error([source_position_type "is unsupported"])
    end
end