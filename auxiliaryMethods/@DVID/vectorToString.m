function str = vectorToString(~, vec)
    strParts = arrayfun(@(n) ...
        {sprintf('%d', n)}, vec);
    str = strjoin(strParts, '_');
end