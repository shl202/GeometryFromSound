function graph_rmse(statsset, algorithms, line_types, title_string, ...
    xlabel_string, ylabel_string, legend_location, axis_values)

    % check validity of input parameters
    assert(length(algorithms) == length(line_types));
    if ~exist('title_string', 'var') || isempty(title_string)
        title_string = "";
    end
    
    if ~exist('xlabel_string', 'var') || isempty(xlabel_string)
        xlabel_string = "";
    end
    
    if ~exist('ylabel_string', 'var') || isempty(ylabel_string)
        ylabel_string = "";
    end

    if ~exist('legend_location', 'var') || isempty(legend_location)
        legend_location = "northeast";
    end
    
    x = statsset.xdomain;
    maj = 1:2:length(x);
    
    % extract avaliable algorithms
    aval_algorithms = strings(1, length(statsset.statsArray));
    for i = 1:length(statsset.statsArray)
        aval_algorithms(i) = statsset.statsArray{i}.algorithm;
    end
    
    ymin = inf;
    ymax = 0;
    for i = 1:length(algorithms) 
        aid = find(strcmpi(aval_algorithms, algorithms(i)), 1);
        if ~isempty(aid)
            stats = statsset.statsArray{aid};
            y = stats.mean_rmses;
            rstds = stats.rstds;
            ymin = min(ymin, min(y - rstds));
            ymax = max(ymax, max(y + rstds));
        else
            warning(["No stats were found for algorithm: " + algorithms(i)]);
        end 
    end
    
    % axis values
    if ~exist('axis_values', 'var') || isempty(axis_values)
        xmin = min(x) - 0.1 * (x(2) - x(1));
        xmax = max(x) + 0.1 * (x(2) - x(1));
        ymin = max(0, ymin * 0.9); % rmse can't be less than 0
        ymax = ymax * 1.1;
        axis_values = [xmin xmax ymin ymax];
    end

    
    % create graph
    figure;
    for i = 1:length(algorithms) 
        aid = find(strcmpi(aval_algorithms, algorithms(i)), 1);
        if ~isempty(aid)
            stats = statsset.statsArray{aid};
            y = stats.mean_rmses;
            plot(x, y, char(line_types(i))); hold on;
        end
    end
    
    axis(axis_values);
    xticks(x(maj));
    
    % title and labels
    title(title_string);
    xlabel(xlabel_string);
    ylabel(ylabel_string);
    legend(cellstr(upper(algorithms)), 'Location', legend_location);
end