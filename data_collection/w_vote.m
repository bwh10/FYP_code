function [ final_label, final_cost, new_label ] = w_vote( new_label,assoc_cost, weights )
%Based on all the parts association, do a weighted vote to get the final
%label

global max_ID;

[num_ppl, num_parts]=size(new_label);
vote_threshold  =0.333; %Fraction out of total number of parts including overall detection
final_label     =zeros(num_ppl,1);
final_cost      =zeros(num_ppl,1);

for i=1:num_ppl
    decision_vector =new_label(i,:);
    [label,weight]  =decision(decision_vector,weights,vote_threshold);
    
    if (label<vote_threshold) %Most of the parts are not associated to the same person, treat this as a new detection
        max_ID=max_ID+1;
        final_label(i)=max_ID;
        new_label(i,:)=max_ID;
        final_cost(i)=-1*weight; %New detection
    else
        final_label(i)=label;
        new_label(i,:)=label;
        if ((assoc_cost(i,1)>1) || (assoc_cost(i,end)>1))
            final_cost(i) = -1.1; %Really new detection 
        else
            final_cost(i) = weight;
        end
            
    end
end
end

