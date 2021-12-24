function idxError = getIdxOfTasksWithError(job)
% Function will return indices of tasks that thre an error

    errorCell = {job.Tasks(:).Error};
    stateCell = {job.Tasks(:).State};
    idxError = find(~cellfun(@isempty, errorCell) | ~cellfun(@(x)strcmp(x,"finished"), stateCell));

end

