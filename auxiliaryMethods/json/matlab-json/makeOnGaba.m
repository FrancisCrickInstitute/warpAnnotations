function makeOnGaba()

curDir = pwd;

% Change to matlab-json directory
cd(fileparts(mfilename('fullpath')));

% Pass some extra flags
make( ...
    '-I../json-c/include/', ...
    '-L../json-c/lib/', ...
    'LDFLAGS="-Wl,-rpath=''$ORIGIN/../json-c/lib/''"', ...
    'CFLAGS="-std=c99 -fPIC"');

cd(curDir);

end
