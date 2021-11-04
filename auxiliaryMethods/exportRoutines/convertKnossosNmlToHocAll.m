function y=convertKnossosNmlToHocAll(aa,filename,overWriteEdges, overWriteThickness,emphasizeNodes,useSplines,resolution)
iirunning=0;
fid=fopen(filename,'w+');
fprintf(fid,'/* created with nml2hocm */\n');
for iii=1:length(aa{1}.nodes)
    a{1}.nodes=aa{1}.nodes{iii};
    a{1}.edges=aa{1}.edges{iii};
    a_sorted=sortrows([a{1,1}.nodes (1:size(a{1,1}.nodes,1))'],3);
    cast(a_sorted(end,:),'uint16')
    a{1,1}.nodes(a_sorted(end,5),4)=1000;
    listS=makeSegmentList(a{1,1},overWriteEdges,emphasizeNodes);
    
    for ii=1:size(listS,1)
        iirunning=iirunning+1;
        y=listS{ii,1}(:,5);
        %     if y(1)==1.5
        %         y(1)=1;
        %     end
        %     if y(end)==1.5;
        %         y(end)=1;
        %     end
        x=1:size(y,1);
        xx=find(y-1.5);
        yy=y(y~=1.5);
        if size(xx,1)<1
            xx=[1 2];
            yy=[27 27];
            
        else if size(xx,1)<2
                if xx(1)==x(1)
                    xx=[xx x(end)];
                    yy=[yy 27];
                else
                    xx=[x(1) xx];
                    yy=[27 yy];
                end
            end
        end
        y=interp1(xx,yy,x);
        if useSplines
            listS{ii,1}(:,5)=y;
        end
        if overWriteThickness
            listS{ii,1}(:,5)=100;
        end
        
        fprintf(fid,'\n{create adhoc%i}\n',iirunning);
        fprintf(fid,'{access adhoc%i}\n',iirunning);
        for jj=1:ii-1
            if listS{jj,1}(1,1)==listS{ii,1}(1,1)
                fprintf(fid,'{connect adhoc%i(0), adhoc%i(0)}\n',iirunning,jj+iirunning-ii);
                break;
            end
            if listS{jj,1}(end,1)==listS{ii,1}(1,1)
                fprintf(fid,'{connect adhoc%i(1), adhoc%i(0)}\n',iirunning,jj+iirunning-ii);
                break;
                
            end
            
        end
        fprintf(fid,'{nseg = 1}\n');
        fprintf(fid,'{strdef color color = "White"}\n');
        fprintf(fid,'{pt3dclear()}\n');
        for jj=listS{ii,1}'
            fprintf(fid,'{pt3dadd(%f,%f,%f,%f)}\n',jj(2)*resolution(1),jj(3)*resolution(2),jj(4)*resolution(3),jj(5)*mean(resolution));
        end
    end
end




fclose(fid);
%y= [min(a{1}.nodes(:,1:2)),max(a{1}.nodes(:,1:2))];
y=0;

end
