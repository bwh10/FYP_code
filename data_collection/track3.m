%%This function:
%1.Computes the optimised assignment according to the Hungarian algorithm
%2.Outputs a tracking label based on the old tracking label

function [ new_labels, assoc_cost ] = track3( costMat, old_labels, old_bb, new_bb )

    %Declare global accumulative variables
    global max_ID;

    [x,y]=size(costMat);
    
    if((x==1) && (y==1) && ((costMat<0) || (isnan(costMat)))) %No association to do
        if (costMat<=-1) %Ppl detected in new frame
            new_labels=(1:(-1*costMat))';
            assoc_cost=2.*ones(-1*costMat,1); %No associations
            max_ID=max(new_labels);
        else
            new_labels=[];
            assoc_cost=[];
        end
    
    else

        row_association=munkres(costMat);        
        
        %Initialise new_label vector
        [new_label_size,~] = size(costMat);
        new_labels=zeros(new_label_size,1);
        
        %Initialise cost association to new detections
        assoc_cost=zeros(new_label_size,1);
        for i=1:new_label_size
            if row_association(i)~=0
                assoc_cost(i)=costMat(i,row_association(i));
            else
                assoc_cost(i)=2; %Not assigned
            end
        end
        
        %Valid associations to old labels
        new_labels(row_association>0)=old_labels(row_association(row_association>0));
        
        %Handle Null associations by introducing new labels that has not
        %been assinged to avoid confusion
        if (max_ID<max(old_labels))
            max_ID=max(old_labels);
        end
        new_labels(new_labels==0)=[max_ID+1:max_ID+sum(new_labels==0)];
    end
     
end
