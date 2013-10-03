%% Helper function for feature selection
function fm  = eval_algo(sFS, C, t, figureOfMerit)
    sCV = sFS;    
    for c = 1:C
        sCV.samples{c} = sFS.samples{c}(t,:);
    end
    [~, fm] = nfold_cross_validation(sCV, figureOfMerit); 
end
