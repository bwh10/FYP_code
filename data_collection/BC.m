%Computes the Bhattacharyya coefficient between 2 histograms
%The histogram inputs into the function are vectors a,b

function BC_coeff=BC(a,b)

    BC_coeff=0;
    
    if (numel(a)~=numel(b))
        disp('Error, vectors a & b are not of the same size!');
    else
        a_norm = a./sum(a);
        b_norm = b./sum(b);
        BC_coeff=sum(sqrt(a_norm.*b_norm));
    end
end