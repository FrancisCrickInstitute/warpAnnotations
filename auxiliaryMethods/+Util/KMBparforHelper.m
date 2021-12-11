function cluster = KMBparforHelper(mode,func,procs,mem,nworkers)
%KMBPARFORHELPER Abstraction layer for different modes of exection
%   parld sets whether it is parallelized or not
% v4 add -tc function and l -s_rt

if nargin <4 || isempty(mem)
    mem = 12;
end
if nargin <5 || isempty(nworkers)
    nworkers = Inf;
end

disp(['Parfor Helper: Starting ',mode,' Mode ...'])
switch mode
    
    case 'for'
        cluster = [];
        for ii=1:procs
            func(ii);
        end
        
        
    case 'parfor'
        if isempty(gcp('nocreate'))
            cluster = parpool;
        else
            cluster = gcp('nocreate');
            delete(cluster);
            cluster = parpool;
        end
        threads=cluster.NumWorkers;
        parfor thI=1-threads:0
            for th2I=1:ceil(procs/threads)
                ii=th2I*threads+thI;
                if ii<=procs
                    func(ii);
                end
                
            end
        end
        
        
    case {'scheduler','schedulerLocal'}
        if exist('/gaba','dir')
            if isinf(nworkers);
                cluster = Cluster.config( 'priority', 50,'memory', mem, 'time', '12:00:00', 'scheduler', 'slurm');
            else
                cluster = Cluster.config( 'priority', 50,'memory', mem,'taskConcurrency',nworkers, 'time', '12:00:00', 'scheduler', 'slurm');
            end
        else
            if isinf(nworkers)
                cluster = Cluster.config('taskConcurrency',8);
            else
                cluster = Cluster.config('taskConcurrency',nworkers);
            end
        end
        

        if length(procs)==1
            for ii=1:procs
                inputargs{ii} = {ii};
            end
        elseif length(procs)>1
            cc = 1;
            for ii=procs
                inputargs{cc} = {ii};
                cc = cc+1;
            end
        end
        job = Cluster.startJob(func, inputargs, 'cluster', cluster, 'name', 'cubing', 'diary', true);    
        Cluster.waitForJob(job);
end


end



