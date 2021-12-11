function skel = setDescription( skel, descr, varargin )
%SETDESCRIPTION Set the tracing description.
% INPUT descr: string
%           The description text. The description can contain %s to
%           substitute the old description.
%       varargin: Name-value pairs for additional options.
%           'append': logical to append descr to the current description
%           'no_formatting': logical to disable any formatting by sprintf
%               of the descr input (Default: false)
% Author: Benedikt Staffler <benedikt.staffler@brain.mpg.de>

opts.append = false;
opts.no_formatting = false;

if ~isempty(varargin)
    uopts = cell2struct(varargin(2:2:end), varargin(1:2:end), 2);
    opts = Util.setUserOptions(opts, uopts);
end

if ~isfield(skel.parameters, 'experiment') ...
        || ~isfield(skel.parameters.experiment, 'description')
    skel.parameters.experiment.description = '';
end

if opts.append
    old_descr = skel.getDescription();
    descr = [old_descr, ' ', descr];
end

if opts.no_formatting
    skel.parameters.experiment.description = descr;
else
    skel.parameters.experiment.description = sprintf(descr, ...
        skel.parameters.experiment.description);
end

end
