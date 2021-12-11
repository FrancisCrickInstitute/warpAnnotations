function writeNmlSilent(fileName, skel, nodeOffset)
% Write skeleton to file without cluttering MATLAB command prompt

evalc('writeNml(fileName, skel, nodeOffset)');

end
