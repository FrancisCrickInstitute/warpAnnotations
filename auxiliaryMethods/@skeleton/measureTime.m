function t = measureTime(obj,tree_index,limit_time)
	
	if nargin <3
		limit_time = 60;
	end
	if nargin <2
		tree_index=1;
	end	
	%measure tracing time for tree
	times = obj.nodesNumDataAll{tree_index}(:,end);
	times = sort(times);
	pauses = find(diff(times)>limit_time*1000);
	risingflank = [1;pauses+1];
	fallingflank = [pauses; length(times)];
	t = sum(times(fallingflank)-times(risingflank))/1000;
end
