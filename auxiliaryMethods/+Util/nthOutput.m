function varargout = nthOutput(n, func)
    % varargout = nthOutput(n, func)
    %   Returns output arguments n(1), ..., n(end) of func.
    %
    % Written by
    %   Alessandro Motta <alessandro.motta@brain.mpg.de>
    
    varargout = cell(1, max(n));
    [varargout{:}] = func();
    varargout = varargout(n);
end

