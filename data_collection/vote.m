function [ final_label, final_cost, new_label ] = vote( new_label,assoc_cost )
%Based on all the parts association, do a majority vote to get the final
%label

global max_ID;
global part_deviation;
global part_constant; 

[num_ppl, num_parts]=size(new_label);
vote_threshold  =0.5; %Fraction out of total number of parts including overall detection
vote_thres      =ceil(vote_threshold*num_parts);
final_label     =zeros(num_ppl,1);
final_cost      =zeros(num_ppl,1);

for i=1:num_ppl
    decision_vector=new_label(i,:);
    [label,freq]=mode(decision_vector); %Get the majority vote
    
    %Store the counts of the parts which deviates from the mode for
    %analysis
    idx                     =(decision_vector~=label);
    idx_inv                 =(~idx);
    count                   =part_deviation(idx)+1;
    part_deviation(idx)     =count;
    count                   =part_constant(idx_inv)+1;
    part_constant(idx_inv)  =count;
    
    if (freq<vote_thres) %Most of the parts are not associated to the same person, treat this as a new detection
        max_ID=max_ID+1;
        final_label(i)=max_ID;
        new_label(i,:)=max_ID;
        final_cost(i)=-1*freq; %New detection
    else
        final_label(i)=label;
        new_label(i,:)=label;
        if (assoc_cost(i,1)>1)
            final_cost(i) = -1.1; %Really new detection 
        else
            final_cost(i) = freq;
        end
            
    end
end
end

