clear,clc
tic


I= imread('C:\Users\Lenovo\Desktop\Dersler\Sample\1.jpg');
I= imresize(I,1);
bandWidth=10;

%Converting values to doubles for accurate processing
bandWidth=bandWidth/255; % 255 for 8 bit (2^n)-1=S
I = im2double(I);

%Forms a vector of grey values 
X = reshape(I,size(I,1)*size(I,2),3);

%Initialization

clusterNum=0;                               %Cluster Number
stoppingThreshold=1e-3*bandWidth;           %Stopping Threshold choosen bandwidth/1000
clusterCenters=[];                          %Empty Vector that holds Cluster Centers
visitedPoints=zeros(size(X,1),1);           %Zeros vector to keep track of visited points
initPointIndxs=1:size(X,1);                 %All points accepted as potential cluster centers
initPoints=size(X,1);                       %Number of initialization points
clusterVotes    = zeros(1,size(X,1)); 



while initPoints
   
    tempInd = ceil( (initPoints-1e-6)*rand);%Random seed point
    startingInd=initPointIndxs(tempInd);
    myMean=X(startingInd,:);                  %Starting Mean
    myMembers=[];                               %Members of this cluster
    thisClusterVotes=zeros(1,size(X,1));      %Votes to resolve conflicts
    
    while 1
        
        A=repmat(myMean,size(X,1),1);
        sqDistToAll= sum((A -X).^2,2);      % Subtract cluster center pos from all points.
        inCluster=find(sqDistToAll<bandWidth^2);                     % Look for points that have smaller distance than bandwidth
        thisClusterVotes(inCluster) = thisClusterVotes(inCluster)+1; % Update cluster votes.
        
        
        myOldMean=myMean;                                           %Save old mean                             
        myMean=mean(X(inCluster,:),1);                                %Calculate new mean
        myMembers=[myMembers ;inCluster];                             %Add new members
        visitedPoints(myMembers)=1;                                 %Mark visited points.
        
      
        
        %Stopping criteria
        
        if(norm(myMean-myOldMean)<stoppingThreshold)
            
            mergeWith=0;
            for cN=1:clusterNum
                distToOther=norm(myMean-clusterCenters(cN,:));
                if(distToOther<2*bandWidth)
                   mergeWith=cN;
                   break;
                end
                
            end
            
            if mergeWith > 0
                
               clusterCenters(mergeWith,:)=0.5*(myMean+clusterCenters(mergeWith,:));
                
               clusterVotes(mergeWith,:)=clusterVotes(mergeWith,:)+ thisClusterVotes;
                
            else
                clusterNum=clusterNum+1;
                clusterCenters=[clusterCenters ;myMean];
                clusterVotes(clusterNum,:)=thisClusterVotes;
                
            end
            
            break; 
        end 
    end
    
    initPointIndxs=find(visitedPoints == 0);
    initPoints=length(initPointIndxs);
    
    
    
end

[val data2cluster]=max(clusterVotes,[],1);                %Assigning a point to a cluster with most votes

cluster2dataCell=cell(clusterNum,1);

for cN=1:clusterNum;
   myMembers=find(data2cluster==cN);
   cluster2dataCell{cN}=myMembers;
    
end

% Reconstruction of image


for i = 1:length(cluster2dataCell)                                              % Replace Image Colors With Cluster Centers
X(cluster2dataCell{i},:) = repmat(clusterCenters(i,:),size(cluster2dataCell{i},2),1); 

end
Ims = reshape(X,size(I,1),size(I,2),3);                                         % Segmented Image

imshow(Ims);




toc


