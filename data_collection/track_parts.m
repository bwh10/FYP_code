%%This function:
%1.Computes the optimised assignment according to the Hungarian algorithm
%2.Outputs a tracking label based on the old tracking label

%new_labels:
% Columns -> Parts
% Rows -> Person
%       Part1   Part2 ...   Overall_detection
%Person1
%Person2
% .
% .
% .

function [ final_label, final_cost, new_labels, assoc_cost ] = track_parts( costMat, old_labels )

    %Declare global accumulative variables
    global max_ID;

    [num_ppl_new,num_ppl_old,num_parts]=size(costMat);
    
    if ((costMat(1,1,1)<0) | (isnan(costMat))) %No association to do
        if (costMat(1,1)<=-1) %Ppl detected in new frame
            num_parts=costMat(1,2);
            new_labels=(1:(-1*costMat(1,1)))';
            max_ID=max(new_labels);
            final_label=new_labels;
            final_cost=-1.1*ones(-1*costMat(1,1),1); %Really New detections
            new_labels=repmat(new_labels,1,num_parts);
            assoc_cost=2.*ones(-1*costMat(1,1),1);  %No associations
            assoc_cost=repmat(assoc_cost,1,num_parts);
            %max_ID=repmat(max_ID,1,num_parts); 
        else
            new_labels=[];
            assoc_cost=[];
            final_label=[];
            final_cost=[];
        end
    
    else
        for i=1:num_parts
            row_association(:,i)=munkres(costMat(:,:,i));   
        end
        
        %Initialise new_label vector
        new_labels=zeros(num_ppl_new,num_parts);
        
        %Initialise cost association to new detections
        assoc_cost=zeros(num_ppl_new,num_parts);
        for i=1:num_ppl_new
            for j=1:num_parts
                if (row_association(i,j)~=0)
                    assoc_cost(i,j)=costMat(i,row_association(i,j),j);
                else
                    assoc_cost(i,j)=2; %Not assigned
                end
            end
        end
        
        %Valid associations to old labels
        for  i=1:num_parts
            new_labels(row_association(:,i)>0,i)=old_labels(row_association(row_association(:,i)>0,i),i);
        end
        
        %Handle Null associations by introducing new labels that has not
        %been assinged to avoid confusion
        if (max_ID<max(max(old_labels)))
            max_ID=max(max(old_labels));
        end
        
        max_ID=max(max(new_labels));
        for i=1:num_parts
            new_labels(new_labels(:,i)==0,i)=[max_ID+1:max_ID+sum(new_labels(:,i)==0)];
        end
         
        %Do a final majority vote to determine the actual label number
        [ final_label, final_cost, new_labels ] = vote( new_labels,assoc_cost);
        
        %Do a final weighted voting to determine the actual label number
        %weights=[0.1219 0.00927 0.1208 0.1146 0.1094 0.0927 0.1115 0.1 0.1365]; %Determined empirically 
        %[ final_label, final_cost, new_labels ] = w_vote( new_labels,assoc_cost,weights);
    end
     
end
