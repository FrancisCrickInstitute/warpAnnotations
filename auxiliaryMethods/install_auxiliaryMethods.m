function install_auxiliaryMethods()
%INSTALL_AUXILIARYMETHODS Run setup for the auxiliaryMethods repository.
% Author: Benedikt Staffler <benedikt.staffler@brain.mpg.de>

% go to directory of this file
prevDir = pwd();
thisDir = fileparts(mfilename('fullpath'));
cd(thisDir);

% slurp nml
Util.log('Compiling slurpNml.cpp');
try
    mex -outdir mex/slurpNml/ ...
        mex/slurpNml/slurpNml.cpp mex/slurpNml/pugixml.cpp
catch err
    warning(err.identifier, 'Compilation failed: %s', err.message);
end

% compiling run shell
if ~ispc
    Util.log('Compiling runShell.c');
    try
        mex -outdir mex/runShell/ mex/runShell/runShell.c
    catch err
        warning(err.identifier, '%s', err.message);
    end
end

% eig3S
Util.log('Compiling eig3S.cpp');
try
    mex CXXFLAGS="-std=c++11 -fPIC" -outdir mex/eig3S/ mex/eig3S/eig3S.cpp
catch err
    warning(err.identifier, 'Compilation failed: %s', err.message);
end


% go to original directory
cd(prevDir);

end

