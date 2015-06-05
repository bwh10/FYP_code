%%This function:
%1.Computes the optimised assignment according to the Hungarian algorithm
%2.Outputs a tracking label based on the old tracking label


function [ new_labels, assoc_cost ] = track2( costMat, old_labels )

    [x,y]=size(costMat);
    
    if((x==1) && (y==1) && ((costMat<0) || (isnan(costMat)))) %No association to do
        if (costMat<=-1) %Ppl detected in new frame
            new_labels=(1:(-1*costMat))';
            assoc_cost=2.*ones(-1*costMat,1); %No associations
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
        new_labels(new_labels==0)=[max(new_labels)+1:max(new_labels)+sum(new_labels==0)];
    end
     
end

%        current_max_label=max(old_labels);

%         for i=1:length(row_association)
%             if (row_association(i)>0) %Valid association
%                 new_labels(i)=old_labels(row_association(i));
%             else %Null association
%                 current_max_label=current_max_label+1;
%                 new_labels(i)=current_max_label;
%             end
%         end

