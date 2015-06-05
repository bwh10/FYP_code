function test_accum (idx)
    global accum_var;
    if (idx==1)
        accum_var=0;
    else
        accum_var=accum_var+idx
    end
end