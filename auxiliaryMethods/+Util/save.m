function save(fileName, varargin)
    % Utility function for saving variables to MAT files. It offers the
    % following two advantages over MATLAB's save:
    %   * Will write v7.3 file only if necessary
    %   * Variables can be passed in directly (instead of going via
    %     their names, which confuses the linter)
    %
    % Written by
    %   Manuel Berning <manuel.berning@brain.mpg.de>
    
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

    % save structure
    Util.saveStruct(fileName, toSave);
end
