classdef DVID < handle
    properties
        server;
        uuid;
    end
    
    methods
        function dvid = DVID(server, uuid)
            dvid.server = server;
            dvid.uuid = uuid;
        end
    end
end