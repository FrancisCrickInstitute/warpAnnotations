function comments = buildCommentTable(nml)
    comments = nml.comments;
    
    % get comments
    comments = struct2table(comments);
    
    % For some reason, webKNOSSOS produces invalid NML files with multiple
    % comments for a single node. Let's just keep the fist comment for each
    % node. Alessandro Motta, 02.11.2017.
   [~, rows] = unique(comments.node, 'stable');
   
    if numel(rows) < size(comments, 1)
        warning('NML contains multiple comments per node.');
        comments = comments(rows, :);
    end
    
    % rename 'content' to 'comment'
    comments.comment = comments.content;
    comments.content = [];
end