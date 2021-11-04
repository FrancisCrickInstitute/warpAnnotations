function subtasks = getErrorSummary(job)
% Function will return indices of tasks that thre an error

    errorCell = {job.Tasks(:).Error};
    stateCell = {job.Tasks(:).State};
    workerCell = cellfun(@(x)x.Host, {job.Tasks(:).Worker}, 'uni', 0);
    idxError = find(~cellfun(@isempty, errorCell) | ~cellfun(@(x)strcmp(x,"finished"), stateCell));
    [uniqueErrors, idx1, idx2] = unique({job.Tasks(idxError).ErrorMessage});
    uniqueErrorCounts = accumarray(idx2,1);
    subtasks = {};
    display('Error summary:');
    for i=1:length(uniqueErrors)
	subtasks{end+1} = job.Tasks(idxError(idx2==i));
	uniqueStates = unique(stateCell(idxError(idx2==i)));
    	[uniqueWorkers, idx3, idx4] = unique(workerCell(idxError(idx2==i)));
    	uniqueWorkerCounts = accumarray(idx4,1);
	display(['Occurences: ', num2str(uniqueErrorCounts(i)), ', Message: ', uniqueErrors{i}, ', States: ', uniqueStates{:}]);
	for j=1:length(uniqueWorkers)
    	    display(['-> Occurences: ', num2str(uniqueWorkerCounts(j)), ', Workers: ' uniqueWorkers{j}]);
	end
    end

end

