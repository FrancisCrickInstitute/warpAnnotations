function KLEEv4_exportSurfaceToAmira_v2(mss_isfs,mss_outputfile,kl_surfColors,kl_xyzpermutation,kn_enforceOwn)

    if nargin<4
        kl_xyzpermutation=[1 2 3];
    end
    if nargin<5
        kn_enforceOwn=0;
    end
    mss_nIsfs = size(mss_isfs,2);

    fid = fopen(mss_outputfile,'w');
    
    fprintf(fid,'# HyperSurface ASCII\n\n\n');
    fprintf(fid,'\tMaterials { \n');
    mss_nIsfs_real=0;
    for mss_c=1:mss_nIsfs
        if isfield(mss_isfs{mss_c},'vertices')
            mss_nIsfs_real=mss_nIsfs_real+1;
            if nargin<3 || isempty(kl_surfColors)
                kl_thisColor = mh_getColor(mss_c+1);
            else
                kl_thisColor = kl_surfColors(mss_c,:);
            end
            fprintf(fid,'\t\t{\n\t\tcolor %.2f %.2f %.2f,\n\t\tName \"%s\" }\n',kl_thisColor,sprintf('col%d',mss_c));
            mss_vertOffsets(mss_c+1) = size(mss_isfs{mss_c}.vertices,1);
        end
    end
        
    fprintf(fid,'\n\t}');
    
    fprintf(fid,'\n\tVertices %d\n',sum(mss_vertOffsets));
    for mss_c=1:mss_nIsfs
        if isfield(mss_isfs{mss_c},'vertices')
            fprintf(fid,'\t\t %.4f %.4f %.4f\n',mss_isfs{mss_c}.vertices(:,kl_xyzpermutation)');
            fprintf(1,'.');
        end
    end
    
    fprintf(fid,'\n\tPatches %d\n',mss_nIsfs_real);
    
    for mss_c=1:mss_nIsfs
        if isfield(mss_isfs{mss_c},'vertices')
            fprintf(fid,'\n{\tInnerRegion %s\n\t\tOuterRegion %s\n',sprintf('col%d',mss_c),sprintf('col%d',mss_c));
            fprintf(fid,'\t\tTriangles %d\n',size(mss_isfs{mss_c}.faces,1));
            fprintf(fid,'\t\t %d %d %d\n',mss_isfs{mss_c}.faces(:,1:3)'+sum(mss_vertOffsets(1:mss_c)));
            fprintf(fid,'\n}');
            fprintf(1,'.');
        end
    end

%    fprintf(fid,'\n}\n');
    fprintf(fid,'\n');
    fclose(fid);
    if kn_enforceOwn==1
        system(sprintf('chown mhelmsta:bmo %s',mss_outputfile));
    end






end