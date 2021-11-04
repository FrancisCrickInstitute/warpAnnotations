function [ correctedVariableNames ] = makeVarName( names )
%MAKEVARNAME Subtitutes spaces with underlines for variable names used in
%Matlab tables
%finding the problematic variable names
isVar=cellfun(@isvarname,names);
if all(isVar)
    correctedVariableNames=names;
    if length(correctedVariableNames)==1
        correctedVariableNames=correctedVariableNames{1};
    end
    return
end
problematicNames= find(~isVar);
correctedVariableNames=names;
for i=1:length(problematicNames)
    correctedVariableNames{problematicNames(i)}=strrep(names{problematicNames(i)},' ','_');
end
assert(all(cellfun(@isvarname,correctedVariableNames)),'problem still exists')
if length(correctedVariableNames)==1
    correctedVariableNames=correctedVariableNames{1};
end
end

