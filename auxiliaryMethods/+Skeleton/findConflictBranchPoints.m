function CskelFinal = findConflictBranchPoints(myDir, taskID, projectName, seedNode)
%   Author:
%       Jakob Straehle <jakob.straehle@brain.mpg.de>
%   Modified by:
%       Sahil Loomba <sahil.loomba@brain.mpg.de>
%   Description:
%       myDir = Input dir with all skeletons to be rescoped
%       taskID = String: taskID of the skeletons, should be common for all
%       projectName = String: Name of the dataset to which the tracings belong, should be the starting name of tracings. eg. 'YH_st126_MT_updated_1708'
%       seedNode: 1x3 array with seed postition for tracings

% do default rescop on skels
%myDir = '/tmpscratch/sahilloo/primate/skels/' % individual skels and output of RESCOP stored here
%taskID = '5b4c579e2900003501f55c9e';
%projectName = 'YH_st126_MT4_updated_1708';
%seedNode = [17718, 14158, 3031]; % starting point of tracings as seen in webknossos

outputFile = fullfile(myDir,['consensusSkel_' taskID '.nml']);
orthoFlag = true;
distThresh = 3000;
index_skel = 1;
[~,consensusSkel] = calculateRescopConsensusSkeleton(...
    myDir, '', outputFile, '', orthoFlag, index_skel,distThresh,false);
consensusSkel.write(outputFile);

%% Load Consensus Skeleton (As coming form RESCOP) and original Hiwi Tracings; all corrected for TPA done by Sahil
Cskel = skeleton(fullfile(myDir,['consensusSkel_',taskID,'.nml']));% consensus skeleton from RESCOP
Cskel.verbose = false;

Util.log('read individual skeletons from tracers')
SkelList = dir(fullfile(myDir,[projectName '__',taskID,'__*']));
Trskel = skeleton(fullfile(myDir,SkelList(1).name));
for i = 2:length(SkelList)
    newskel = skeleton(fullfile(myDir,SkelList(i).name));
    Trskel = Trskel.addTreeFromSkel( newskel);
end

%% Delete duplicate nodes in consensus skeleton

% TREE ID OF THE CONSENSUS SKELETON. SHOULD BE 1 everywhere. If not change

% the Cskel to only have one Tree
CtreeID = 1;

[~,tempID] = unique(Cskel.nodes{CtreeID},'rows');
uniqueNodeID = Cskel.nodesNumDataAll{CtreeID}(tempID,1);
nodesToKill = setdiff(Cskel.nodesNumDataAll{CtreeID}(:,1),uniqueNodeID);
[IDtoIdx,~] = Cskel.nodeId2Idx(CtreeID);
nodeIDxtoKill =  full(IDtoIdx(nodesToKill));
Cskel = Cskel.deleteNodes(CtreeID,  nodeIDxtoKill , 1);

Util.log('Add seed comment')
seedName = 'Seed_Syn';
SeednodeIDx = cell2mat( Cskel.getNodesWithCoords(seedNode+[1 1 1], CtreeID) );
SeednodeID = Cskel.nodesNumDataAll{CtreeID}(SeednodeIDx,1);

Cskel = Cskel.setComments(CtreeID, SeednodeIDx, seedName);

% add task ID to name
Cskel.names{CtreeID} = [Cskel.names{CtreeID},' - ',taskID];

% % write fixed consensus skeleton to file

% Cskel.write(fullfile(myDir,['consensusSkel_FIXED_',taskID,'.nml']))

%% Calculate Edge Degree and Load for each node of Consensus skeleton
EdgeList = Cskel.edges{CtreeID}; % Edge List are Idx not IDs

Neighbors = Cskel.getNeighborList(CtreeID); % Edge List are Idx not IDs

DistMAT = Cskel.getShortestPaths(CtreeID); % Gives distances between every NodeIdx

CDskel = Cskel.directedEdgeList(CtreeID,SeednodeIDx);

% calculate the number of children nodes after each node 

DG = digraph(CDskel.edges{CtreeID}(:,1),CDskel.edges{CtreeID}(:,2));

V = [];

for nodeIdx = 1:size(CDskel.nodes{CtreeID},1)

V(nodeIdx,1) = length(bfsearch(DG,nodeIdx))-1;

end



Util.log('Calculate for each node of the Consensus Skeleton its degree and Load ...')

% number of nodes attached to it Away from the seed)

CNodeIDandDegree = [Cskel.nodesNumDataAll{CtreeID}(:,1) , Cskel.calculateNodeDegree{CtreeID} , V];

clear CDskel

% for Sanity Check

% SanityCheckLookup = [CNodeIDandDegree,Cskel.nodesNumDataAll{CtreeID}(  full(IDtoIdx(CNodeIDandDegree(:,1) )), [3:5])]
% [~,id] = sort(Cskel.nodesNumDataAll{CtreeID}(:,[1]))
% A = Cskel.nodesNumDataAll{CtreeID}(:,[1,3:5])
% 
% % [~,id] = sort(CDskel.nodesNumDataAll{CtreeID}(:,[1]))
% B = CDskel.nodesNumDataAll{CtreeID}(:,[1,3:5])

%%  Calculate length of Branches defined by either ending or branchpoint

BPnodeID = CNodeIDandDegree( find(CNodeIDandDegree(:,2)>= 3 ) , 1);

% length(CNodeIDandDegree( find(CNodeIDandDegree(:,2)>= 3 ) , 1))
% length(CNodeIDandDegree( find(CNodeIDandDegree(:,2)== 1 ) , 1))

[IDtoIdx,~] = Cskel.nodeId2Idx(CtreeID);

EdgeListSimple = [];

for thisBP = BPnodeID'

    thisBPIdx = full(IDtoIdx(thisBP));    
    LocalBranchSeedIDx = Neighbors{thisBPIdx};

    for SeedIDx = LocalBranchSeedIDx

       FirstNodeIDalongBranch = Cskel.nodesNumDataAll{CtreeID}(SeedIDx);

        contSignal=true; 
        currentNode = SeedIDx;
        nextNodeIdx=setdiff(Neighbors{currentNode}, thisBPIdx);

        if length(nextNodeIdx) == 1
            while contSignal
               if  length(Neighbors{nextNodeIdx})==2
                   oldNode=currentNode;
                    currentNode=nextNodeIdx;
                    nextNodeIdx=Neighbors{nextNodeIdx}(Neighbors{nextNodeIdx}~=oldNode);
                else
                    currentNode=nextNodeIdx;
                    contSignal=false;
                end
            end
        end
       
    EdgeListSimple = [EdgeListSimple; [thisBP, Cskel.nodesNumDataAll{CtreeID}(currentNode,1), FirstNodeIDalongBranch] ];   % growing List of ID of 1 Start , 2 End 3 first Branch ID along the Way from start to End and length of the segment
    end
end


% sort branches (ID closest to seed first) and remove the other direction
seedIDx = Cskel.getNodesWithComment('Seed', CtreeID, 'partial');
% 1 Start Node ID, 2 End Node ID, 3 First node after Start 
EdgeListSimpleSorted = [];
 for i = 1:size(EdgeListSimple,1)    
     startdist = floor(DistMAT( full(IDtoIdx(EdgeListSimple(i,1))) , seedIDx )  );
     enddist = floor(DistMAT(  full(IDtoIdx(EdgeListSimple(i,2))) , seedIDx )   );

     if startdist < enddist
       EdgeListSimpleSorted = [EdgeListSimpleSorted; EdgeListSimple(i,:)];
     end
 end
clear EdgeListSimple


% 4. Length between Start and End in nm
% Calculate Physical length of each Branch definde by StartID, Stop ID and Length in nm
for i = 1:size(EdgeListSimpleSorted,1)
EdgeListSimpleSorted(i,4) = floor(DistMAT(full(IDtoIdx(EdgeListSimpleSorted(i,1))) , full(IDtoIdx(EdgeListSimpleSorted(i,2)))   ));
end

% 5. Degree of End Node
% add of each Pair of edges the degree of the second edge
EdgeListSimpleSorted(:,5) = CNodeIDandDegree(full(IDtoIdx(EdgeListSimpleSorted(:,2))) ,2 ) ;

%% for all nodes determine how many Hiwis found it (were in proximity < unqThr nm)
% 6. Degree of uniqueness of End Point 
EdgeListSimpleSorted(:,6) = NaN(size(EdgeListSimpleSorted,1),1);

% NodeDegree of Tracer Skeletons
        TracerDegreeList =    Trskel.calculateNodeDegree;
RESCOP_splitList = [];
% uniqueness Distance Treshold (nm)
unqThr = 1000;

for i = 1:size(EdgeListSimpleSorted,1)
      
        EndingNodeIdx =  full (  IDtoIdx(EdgeListSimpleSorted(i,2)   )   ); % turn ID into IDx     
        xyz = Cskel.nodesNumDataAll{CtreeID}(EndingNodeIdx,3:5);
        Txyz = [];
        allDists = [];
        for treeIdx = 1:size(Trskel.nodes,1)
            [ nodeIdx, ~ ] =   Trskel.getClosestNode(xyz, treeIdx , 0 ); % important is not to ignore itself
            Txyz(treeIdx,:) = [Trskel.nodesNumDataAll{treeIdx}(nodeIdx,[3:5,1]), TracerDegreeList{treeIdx}(nodeIdx)] ;
        end
        
        allDists = bsxfun(@minus, Txyz(:,[1:3]), xyz);
        allDists = bsxfun(@times, allDists, Cskel.scale);
        allDists = sqrt(sum(allDists .^ 2, 2));  % distance of closes single tracers in nm.
       
        EdgeListSimpleSorted(i , 6) =  sum(allDists < unqThr);   
       
   
        % report for endings (node degree == 1 ) whether the closest nodes
        % of hiwis are continuous. IF yes add to list as potential splits
        % introduced by RESCOP
        if EdgeListSimpleSorted(i,5) == 1 &&    all( Txyz( allDists < unqThr ,5)>=2 )% find those endings where all Hiwis in close proximity see a continuity, in order to find spots where RESCOP introduced splits
            IDXYZ = [EdgeListSimpleSorted(i,2),xyz];
            RESCOP_splitList = [RESCOP_splitList; IDXYZ];
        end
end

%% Trace back unique Endings to Branchpoint in Consensus skeleton closest to seed that gives off unique Branch.

%EdgeListSimple : 

% 1 NodeID of BranchStart; 
% 2 NodeID of BranchEnd;
% 3 Node ID just after Branch Start
% 4 Length of Branch Start to End in nm; 
% 5 Degree of Branch End Node(1= Ending); 
% 6 vote how many Hiwis also were within 1µm of the Ending node (2).
% 7 Node ID of BP giving off a non unique Branch closest to Seed

consThr = 1; % Threshold of consensus, that will be manually checked % number of hiwis agreeing on this position which we would not trust

EdgeListSimpleSorted(:,7) = NaN(size(EdgeListSimpleSorted,1),1);
EdgeListSimpleSorted(:,8) = NaN(size(EdgeListSimpleSorted,1),1);

% walk back along tree toward seed until a branchpoint is reached that is
% no longer unique
EndingINDEXLIst =  find(EdgeListSimpleSorted(:,6) == consThr & EdgeListSimpleSorted(:,5) == 1) ;
for endIndex = EndingINDEXLIst'
            childNodeINDEX = endIndex;
            childNodeID = EdgeListSimpleSorted(endIndex,2);
          
            parentNodeID = EdgeListSimpleSorted(endIndex,1);
            parentNodeINDEX = find( EdgeListSimpleSorted(:,2) == parentNodeID );
            
            contSignal=true;    
            while contSignal
                if  EdgeListSimpleSorted(parentNodeINDEX,6) == consThr
                    childNodeINDEX = parentNodeINDEX;
                    childNodeID = EdgeListSimpleSorted(childNodeINDEX,2);
                    parentNodeID = EdgeListSimpleSorted(childNodeINDEX,1);
                    parentNodeINDEX =  find( EdgeListSimpleSorted(:,2) == parentNodeID );
                else
                    contSignal=false;
                end
            end
            if ~isempty(parentNodeINDEX) % if isempty the loss of uniqueness happened between the first and second branchpoint of the consensus skeleton
            
            QueryBranchpointID = EdgeListSimpleSorted(parentNodeINDEX,2);
            QueryNonUniqueNodeIDonBranch = EdgeListSimpleSorted(childNodeINDEX,3);          
           
            % pointing into the direction of ChildeNODEID!!!!
            EdgeListSimpleSorted(endIndex,7) = QueryBranchpointID; % BranchPoints most close to Seed what are the first to differ from the majority of tracers  
            EdgeListSimpleSorted(endIndex,8) = QueryNonUniqueNodeIDonBranch; % BranchPoints most close to Seed what are the first to differ from the majority of tracers  
end
end

%% For All Endings in Hiwi Tracings see if they Mark a stop.

loadThr = 20; % number of nodes beyond a certain node that are considered to be a missed continuity
SeednodeIDx = Cskel.getNodesWithComment(seedName, CtreeID );

PotentialEndingQureyList = [];
% Calculate Node Degree
for TRtrID = 1:size(Trskel.nodes,1)
    % node ID and Degree for Hiwi Traced Skeletons
    Loc_NodeIDandDegree = [Trskel.nodesNumDataAll{TRtrID}(:,1) , Trskel.calculateNodeDegree{TRtrID}];
    % local transformation of ID to Index
    Loc_ID2Idx = Trskel.nodeId2Idx(TRtrID);
    
    % find all endings in Tracer Skeleton
    EndingNodeIDList = Loc_NodeIDandDegree(find(Loc_NodeIDandDegree(:,2)==1), 1);
    EndingNodeIdxList = full(Loc_ID2Idx(EndingNodeIDList));

    for thNodeIdx = EndingNodeIdxList'
        % current Coordinates of Ending in Hiwi Tracing
        xyz = Trskel.nodesNumDataAll{TRtrID}(thNodeIdx,[3:5]);
        % corresponding Coordinates, ID and degree of node in Consensus Skeleton
        [ nodeIdx, ~ ] =   Cskel.getClosestNode(xyz, CtreeID , 0 ); % important is not to ignore itself
        CxyzID = [Cskel.nodesNumDataAll{CtreeID}(nodeIdx,[1,3:5]), DistMAT(nodeIdx,SeednodeIDx)]; % ID, X, Y, Z, Dist to Seed

        % calculate Distance of Hiwi Ending and
        locDist = bsxfun(@minus, CxyzID(2:4), xyz);
        locDist = bsxfun(@times, locDist, Cskel.scale);
        locDist = sqrt(sum(locDist .^ 2, 2));  % distance of closes single tracers in nm.

        if locDist >1000; warning('For Consensus Node ID %d Distance is larger than 1 µm',CxyzID(1)); end
        Condition_check = 0;
        %  only proceed if the corresponding node in the Consensus skeleton  is of degree 2 and has a large amount of nodes after it
        if CNodeIDandDegree(nodeIdx,2) >= 2
            if [CNodeIDandDegree(nodeIdx,3) >= loadThr]; % make sure that load at the point in the consensus skeleton is high enough
                    PotentialEndingQureyList = [PotentialEndingQureyList; CxyzID]; % Consensus Skeleton Node ID of questionable Continuation
            end
        elseif CNodeIDandDegree(nodeIdx,2) ==1
            % in case of degree node move up the tree an see whether the
            % parent nodes are connected to a larger downstream branch. If
            % yes mark the first parent with a marked increase in load are
            % new seed
            summedLoad = [];

            contSignal=true;
            ParentNodeIdx = [];
            startNodeIdx = nodeIdx;
            cc = 1;
            while   contSignal  && cc <=5
                linIndx = sub2ind(size(DistMAT) , Neighbors{startNodeIdx}, repmat(SeednodeIDx, size(Neighbors{startNodeIdx})  ) );
                [~,locParentID] =  min(DistMAT(linIndx) );
                ParentNodeIdx(cc) = Neighbors{startNodeIdx}(locParentID);
                startNodeIdx =  ParentNodeIdx(cc);
                cc = cc +1;
            end

           LoadVec = CNodeIDandDegree(ParentNodeIdx,3);
            if [max(LoadVec) >= loadThr]; % using this we make sure not to include real endings
               ThisContIdx =  ParentNodeIdx( find(diff(LoadVec)>1, 1, 'first')  ); % find the parent where nodes number increases more than expected 
                CxyzID = [Cskel.nodesNumDataAll{CtreeID}(ThisContIdx,[1,3:5]), DistMAT(ThisContIdx,SeednodeIDx)]; % ID, X, Y, Z, Dist to Seed
                                
                PotentialEndingQureyList = [PotentialEndingQureyList; CxyzID]; % Consensus Skeleton Node ID of questionable Continuation; X Y Z ; Distance of the node to seed
            end
        end
    end
end
PotentialEndingQureyList = unique(PotentialEndingQureyList,'rows');

% Reduce Continuation Query points by finding Distance based clusters.
%% LIST OF INTERESTING POINTS THAT WE WERE ABLE TO COME UP WITH:
% Branchpoint ID in Consensus skeleton closest to Seed that give off a branch
% traced by only N = consThr tracers:
%       unique(EdgeListSimpleSorted(~isnan(EdgeListSimpleSorted(:,7)),7))

% First node along that unique Branch that will be queried
%       unique(EdgeListSimpleSorted(~isnan(EdgeListSimpleSorted(:,8)),8))

% Ending ID in Consensus skeleton traced by only N = consThr tracers:
%       EdgeListSimpleSorted( find(EdgeListSimpleSorted(:,6) == consThr & EdgeListSimpleSorted(:,5) == 1) ,2);

% Branchpoint ID in Consensus skeleton traced by only N = consThr tracers:
%       EdgeListSimpleSorted( find(EdgeListSimpleSorted(:,6) == consThr & EdgeListSimpleSorted(:,5) > 2) ,2);
        % not necessary to check that beacause, if a tracer decides to mark
        % a branchpoint he will pay a lot of attention and it will be most
        % likely correct.
  

%   ID of Nodes on a continuous branch of the Consensus Skeleton where a single Hiwi decided to stop  
%       PotentialEndingQureyList(:,1) 

%% add comments to the Fixed Consensusskelete as nodes of interest for HIwis to check.

CskelFinal = Cskel;
CskelFinal = CskelFinal.clearComments(CtreeID);
% add seed comment again
SeednodeIDx = cell2mat( CskelFinal.getNodesWithCoords(seedNode+[1 1 1], CtreeID) );
CskelFinal = CskelFinal.setComments(CtreeID, SeednodeIDx, seedName);

% AddComments to first point into a unique Branch Beginnings of Branches

if any( ~isnan(EdgeListSimpleSorted(:,8)) )
    for NodeIdx = full(IDtoIdx(  unique(EdgeListSimpleSorted(~isnan(EdgeListSimpleSorted(:,8)),8))  ))';
        Oldmsg = CskelFinal.nodesAsStruct{CtreeID}(NodeIdx).comment;
        Newmsg = ['SKELETON CHECK:_Is this Branch correct?_',Oldmsg];
        CskelFinal = CskelFinal.setComments(CtreeID,NodeIdx,Newmsg);
    end
end

% AddComments to continuations of a single Hiwi
% first get rid of successive nodes
if ~isempty(PotentialEndingQureyList)
    SeednodeIDx = Cskel.getNodesWithComment(seedName, CtreeID );
    F_NeighborsPerIdx = CskelFinal.getNeighborList(CtreeID);
    NodeIdxList = full(IDtoIdx(  PotentialEndingQureyList(:,1)  ))';
    DistanceToSomaList = PotentialEndingQureyList(:,5);
    % find pairs of neighboring nodes
    nodeRMLIst = [];
    for NodeIdx = NodeIdxList
        A = num2cell( repmat(NodeIdx,length(NodeIdxList),1) );
        PairedNode = NodeIdxList(find(cell2mat(cellfun(@ismember, A  ,F_NeighborsPerIdx(NodeIdxList), 'UniformOutput',  false))));
        if ~isempty(PairedNode)
            for PrdNode = PairedNode
                nodeRMLIst = [nodeRMLIst;[NodeIdx,PrdNode]];
            end
        end
    end
    % choose node closest to seed
    if  ~isempty(nodeRMLIst)
        for i = 1:size(nodeRMLIst,1)
            thispair =  nodeRMLIst(i,[1:2]);
           linInd = sub2ind( size(DistMAT), thispair, [SeednodeIDx,SeednodeIDx]);
            [~,ID] = min(DistMAT(linInd));
            nodeRMLIst(i,3) = thispair(ID);
        end
        % update nodeIDx List
        NodeIdxList = setdiff(NodeIdxList,  reshape(nodeRMLIst(:,1:2),1,[])  );
        NodeIdxList = [NodeIdxList,unique(nodeRMLIst(:,3))'];
    end

    for NodeIdx = NodeIdxList;
        Oldmsg = CskelFinal.nodesAsStruct{CtreeID}(NodeIdx).comment;
        Newmsg = ['SKELETON CHECK:_Is this continuation correct?_',Oldmsg];
        CskelFinal = CskelFinal.setComments(CtreeID,NodeIdx,Newmsg);
    end
end

% % Add Comments to 
% if ~isempty(RESCOP_splitList)
%     for NodeIdx = full(IDtoIdx(  RESCOP_splitList(:,1) ))';
%         Oldmsg = CskelFinal.nodesAsStruct{CtreeID}(NodeIdx).comment;
%         Newmsg = ['SKELETON CHECK:_Could a continuation have been missed here?_',Oldmsg];
%         CskelFinal = CskelFinal.setComments(CtreeID,NodeIdx,Newmsg);
%     end
% end

%% Final Skeleton fix; delete all stupid single node branchpoints that are a result of RESCOP jitter

F_NodeDegreePerIdx = CskelFinal.calculateNodeDegree{CtreeID};
F_NeighborsPerIdx = CskelFinal.getNeighborList(CtreeID);
nodeIDxtoKill = [];

for nodeIdx = find((F_NodeDegreePerIdx==1))'
    parentNodeIdx = F_NeighborsPerIdx{nodeIdx};
    % change query comments in case of degree change due to deletion of
    % small nodes
    if F_NodeDegreePerIdx( parentNodeIdx )>=3
        nodeIDxtoKill = [nodeIDxtoKill,nodeIdx];
    end
end

% make sure soma seed is not deleted
SeednodeIDx = CskelFinal.getNodesWithComment('Seed', CtreeID, 'partial');
nodeIDxtoKill = setdiff(nodeIDxtoKill,SeednodeIDx);

% delete nodes
CskelFinal = CskelFinal.deleteNodes(CtreeID,  nodeIDxtoKill , 1);
% CskelFinal.write(fullfile(myDir,['consensusSkel_FIXED_2',taskID,'.nml']))

%% recalculate degrees and adjust comments if necessay after eating away small BPs 

F_NodeDegreePerIdx = CskelFinal.calculateNodeDegree{CtreeID};
F_NeighborsPerIdx = CskelFinal.getNeighborList(CtreeID);
% go through all comments 
for nodeIdx = CskelFinal.getNodesWithComment('Is this Branch correct?', CtreeID, 'partial')'  
 if all(F_NodeDegreePerIdx(F_NeighborsPerIdx{nodeIdx}) <= 2) 
Oldmsg = strsplit(CskelFinal.nodesAsStruct{CtreeID}(nodeIdx).comment,'_');
Oldmsg{find( ~cellfun(@isempty, strfind(Oldmsg, 'Is this Branch correct?' ) ))} = 'Is this continuation correct?';           
Newmsg = strjoin(Oldmsg,'_');
 CskelFinal = CskelFinal.setComments(CtreeID,nodeIdx,Newmsg);
 end
end

CskelFinal.verbose = false;
%%

% write fixed consensus skeleton to file

outdir = fullfile(myDir,'AllTasksForSkelProofread')
if ~exist(outdir)
    mkdir(outdir)
end

CskelFinal.write(fullfile(outdir,['consensusSkel_ForSkelProofRead_',taskID,'.nml']))
end
