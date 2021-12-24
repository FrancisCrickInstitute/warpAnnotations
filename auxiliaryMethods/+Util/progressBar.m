function progressBar(act_step, tot_step)
%PROGRESSBAR(act_step,tot_step) prints the remaining time in a
%computation when act_step steps out of tot_steps have been made.
%
% A "tic" must have been called at the beginnig of the computation. This
% code must be called at the end of the step act_step (and not at the
% beginning).
%
% To reduce the computaton overhead, the code will only be active if
% floor(percentage) has changed in the last step (this can easy be
% removed by deleting the first 'if' condition).
%
% Original version by Nicolas Le Roux <lerouxni@iro.umontreal.ca> (2005)
% Adaptions made by: Thomas Kipf <thomas.kipf@brain.mpg.de> (2015)
% Fix for Windows by: Marcel Beining <marcel.beining@brain.mpg.de> (2017)

persistent nchar

% Percentage completed
old_perc_complete = floor(100*(act_step-1)/tot_step);
perc_complete = floor(100*act_step/tot_step);

if old_perc_complete == perc_complete
else
    
    % Time spent so far
    time_spent = toc;
    
    % Estimated time per step
    est_time_per_step = time_spent/act_step;
    
    % Estimated remaining time. tot_step - act_step steps are still to make
    est_rem_time = (tot_step - act_step)*est_time_per_step;
    str_steps = [' ' num2str(act_step) '/' num2str(tot_step)];
    
    % Correctly print the remaining time
    if (floor(est_rem_time/60) >= 1)
        str_time = ...
            [' ETA: ' num2str(floor(est_rem_time/60)) 'm ' ...
            num2str(floor(rem(est_rem_time,60))) 's'];
    else
        str_time = ...
            [' ETA: ' num2str(floor(rem(est_rem_time,60))) 's'];
    end
    
    % Create the string [***** x    ] act_step/tot_step (1:10:36)
    str_pb = progress_bar(perc_complete);
    str_tot = strcat(str_pb, str_steps, str_time);
    
    % Print it
    print_same_line(str_tot,nchar);
    nchar = numel(str_tot)-1; % save string element number for overwriting next time (windows)
end

if act_step == tot_step
    fprintf('\n');
    fprintf('Total running time: %f seconds. \n', toc);
    nchar = []; % make nchar empty again if function is called second time
end

end


function str_pb = progress_bar(percentage)

str_perc = [' ' num2str(percentage) '%% '];

if percentage < 49
    str_o = char(ones(1, floor(percentage/2))*61);
    str_dots_beg = char(ones(1, max(0, 24 - floor(percentage/2)))*46);
    str_dots_end = char([32 ones(1, 24)*46]);
    str_pb = strcat('[', str_o, str_dots_beg, str_perc, str_dots_end, ']');
else
    str_o_beg = char(ones(1, 24)*61);
    str_o_end = char([32 ones(1, max(0, floor((percentage-50)/2)))*61]);
    str_dots = char(ones(1, 50 - floor(percentage/2))*46);
    str_pb = strcat('[', str_o_beg, str_perc, str_o_end, str_dots, ']');
end

end


function print_same_line(string, nchar)
% This code has been taken from Les Schaffer on comp.soft-sys.matlab
% Hope he will not mind having this sudden fame.
% Send any comment to lerouxni@iro.umontreal.ca
%
% small function to print a string starting from the beginning of the
% actual line

if isunix || ismac
    %%  the ascii code for starting an escape sequence
    esc_code = 27;
    
    %% clear to end of line
    %% ESC [2K
    er = [ char(esc_code) '[' '2' 'K' ];
    
    %% goto beginning of line
    %% ESC [1G
    bl = [ char(esc_code) '[' '1' 'G' ];
    
    new_string = strcat(bl, er, string);
    fprintf(1, new_string);
elseif ispc
    if isempty(nchar)
        new_string = string;
    else
        new_string = strcat(repmat('\b', 1, nchar),string);
    end
    fprintf(1, new_string);
end

end
