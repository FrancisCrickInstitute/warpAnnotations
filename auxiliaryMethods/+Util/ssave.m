function success = ssave(fileName, varargin)
%SSAVE Secure saving that does the same as Util.save but only saves the
% file if it does not exist already. Otherwise a warning is issued.
%
% Utility function for saving variables to MAT files. It offers the
% following two advantages over MATLAB's save:
%   * Will write v7.3 file only if necessary
%   * Variables can be passed in directly (instead of going via
%     their names, which confuses the linter)
%
% save(fileName) saves all variables from the current workspace.
% save(fileName, variables) saves the corresponding variables.
% save(fileName, _ , '-e') throws an error instead of a warning if
%   the file is not saved.
% save(filename, _ , '-append') appends a variable to a file but only if no
%   other variable is overwritten.
%
% Based on code by
%   Manuel Berning <manuel.berning@brain.mpg.de>
%
% Author: Benedikt Staffler <benedikt.staffler@brain.mpg.de>

    [mode, varargin] = parseArgs(varargin{:});

    % no overwrite mode
    if exist(fileName, 'file') && ~mode.append
        if mode.error
            error(['Output file %s already exists and will not ' ...
                'be overwritten.'], fileName);
        else
            warning(['Output file %s already exists and will not ' ...
                'be overwritten.'], fileName);
            success = 0;
            return;
        end
    end
    
    if nargin == 1
        % If no elements are passed to save, normal matlab syntax will save
        % the whole workspace save is invoked from
        variableNames = evalin('caller', 'who');
        for i=1:length(variableNames)
            toSave.(variableNames{i}) = evalin('caller', variableNames{i});
        end
    else
        % build structure
        variableNames = arrayfun( ...
            @inputname, 1 + (1:numel(varargin)), 'UniformOutput', false);
        toSave = cell2struct(varargin(:), variableNames(:));
    end
    
    % append mode
    if mode.append
        if exist(fileName, 'file')
            m = load(fileName);
            f1 = fieldnames(m);
            f2 = fieldnames(toSave);
            idx = cellfun(@(x)any(strcmp(x, f1)), f2);
            if ~any(idx)
                for i = 1:length(f1)
                    toSave.(f1{i}) = m.(f1{i});
                end
            else
                if mode.error
                    error(['Variable ''%s'' already exist in file %s. ' ...
                        'Abort saving.'], f1{idx(1)}, fileName);
                else
                    warning(['Variable ''%s'' already exist in file %s. ' ...
                        'Abort saving.'], f1{idx(1)}, fileName);
                    success = 0;
                    return
                end
            end
        end
    end
    

    % save structure
    Util.saveStruct(fileName, toSave);
    success = 1;
    
end

function [mode, varargin] = parseArgs(varargin)
    args = {'-e', '-append'};
    mode.error = false;
    mode.append = false;
    
    idx = find(cellfun(@ischar, varargin));
    toDel = false(size(idx));
    for i = 1:length(idx)
        this_arg = strcmp(varargin{idx(i)}, args);
        if any(this_arg)
            arg = args{this_arg};
            switch arg
                case '-e'
                    mode.error = true;
                    toDel(i) = true;
                case '-append'
                    mode.append = true;
                    toDel(i) = true;
            end
        end
    end
    varargin(idx(toDel)) = [];
end

