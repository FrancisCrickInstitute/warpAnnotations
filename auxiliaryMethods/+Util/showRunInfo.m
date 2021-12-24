function showRunInfo(info)
    % Written by
    %   Alessandro Motta <alessandro.motta@brain.mpg.de>
    isDirtyStr = {'', ' (dirty)'};
    
    fprintf('%s\n', info.filename);
    
    for curRepoId = 1:numel(info.git_repos)
        curRepo = info.git_repos{curRepoId};
        curDirty = ~isempty(curRepo.diff);
        curDirty = isDirtyStr{1 + curDirty};
        
        fprintf('%s %s%s\n', curRepo.remote, curRepo.hash, curDirty);
    end
    
    fprintf('%s@%s. MATLAB %s. %s\n', ...
        info.user, info.hostname, ...
        info.matlab_version, info.time);
    fprintf('\n');
end
