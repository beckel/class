function f = accuracy_random_guess(sCR)

if (iscell(sCR))
    f = 1 / size(sCR{1}.confusion,1);
else
    f = 1 / size(sCR.confusion,1);
end