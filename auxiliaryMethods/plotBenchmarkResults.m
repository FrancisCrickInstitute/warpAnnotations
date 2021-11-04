function plotBenchmarkResults()
    labels = {'Reading data' 'Normalize stack' 'CPU CNN forward' 'Transfer GPU' 'GPU CNN forward' 'Back from GPU' 'Writing data', ...
        'reshape CPU' 'reshape GPU' 'permute CPU' 'permute GPU' 'Indexing CPU' 'Indexing GPU'}';
    colors = {':r' '--r' ':b' '--b' ':g' '--g' ':c' '-c'};
    sizesToTest = 100:50:600;
    nrVoxel = sizesToTest.^2.*128;
    axLim = {[1e-2 1e2] [1e-2 1e2] [1 1e4] [1e-2 1e2] [1 1e4] [1e-2 1e2] [1e-2 1e2] [1e-5 1e-2] [1e-5 1e-2] [1e-3 1] [1e-3 1] [1e-3 1] [1e-3 1] };
    jm = findJm;
    tasks = jm(1).Jobs(end).Tasks;
    for i=1:length(tasks);
        worker{i} = tasks(i).Worker.Name;
        results(:,:,i) = tasks(i).OutputArguments{1};
    end
    % Just plot measured times for each task
    for i=1:size(results,2)
        figure('Units', 'centimeters', 'Position', [0 0 29.7 21], 'Visible', 'off', ...
            'PaperType', 'A4', 'PaperUnits', 'centimeters', 'PaperPosition', [0 0 29.7 21], 'PaperOrientation', 'portrait');
        hold on;
        for j=1:size(results,3)
            plot(nrVoxel,results(:,i,j), colors{j});
        end
        title(labels{i});
        set(gca, 'YScale', 'log');
        ylim(axLim{i});
        xlabel('volume processed [vx]');
        ylabel('computation time [s]');
        legend(worker, 'Location', 'Best', 'Interpreter', 'none');
        set(gcf,'PaperSize',fliplr(get(gcf,'PaperSize')));
        saveas(gcf, ['/gaba/u/mberning/sync/gpuBenchmark/' num2str(i,'%.2i') '.pdf']);
    end
    % Speedup plots (normalized on each node seperately)
    figure('Units', 'centimeters', 'Position', [0 0 29.7 21], 'Visible', 'off', ...
        'PaperType', 'A4', 'PaperUnits', 'centimeters', 'PaperPosition', [0 0 29.7 21], 'PaperOrientation', 'portrait');
    hold on;
    bar(nrVoxel, squeeze(results(:,3,:)./results(:,5,:)));
    xlabel('volume processed [vx]');
    ylabel('speedup factor for node');
    legend(worker, 'Location', 'Best', 'Interpreter', 'none');
    title('CNN forward pass speedup');
    set(gcf,'PaperSize',fliplr(get(gcf,'PaperSize'))); 
    saveas(gcf, ['/gaba/u/mberning/sync/gpuBenchmark/cnnFwdSpeedup.pdf']);
    % Speedup plots (normalized on gaba01/02 mean CPU speed)
    figure('Units', 'centimeters', 'Position', [0 0 29.7 21], 'Visible', 'off', ...
        'PaperType', 'A4', 'PaperUnits', 'centimeters', 'PaperPosition', [0 0 29.7 21], 'PaperOrientation', 'portrait');
    hold on;
    bar(nrVoxel, squeeze(bsxfun(@times,mean(results(:,3,5:8),3),1./results(:,5,:))));
    xlabel('volume processed [vx]');
    ylabel('speedup factor wrt AMD CPU speed');
    legend(worker, 'Location', 'Best', 'Interpreter', 'none');
    title('CNN forward pass speedup');
    set(gcf,'PaperSize',fliplr(get(gcf,'PaperSize'))); 
    saveas(gcf, ['/gaba/u/mberning/sync/gpuBenchmark/cnnFwdSpeedup2.pdf']);

end

