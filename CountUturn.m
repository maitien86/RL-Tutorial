% Compute Uturn
function count = CountUturn(file_obs)
    global Uturn;
    OBS = spconvert(load(file_obs));
    [nbobs, maxstates] = size(OBS);
    count = 0;
    for n = 1:nbobs
         path = OBS(n,:);
         lpath = size(find(path),2);
         for j = 2 : lpath - 1
            count = count + Uturn(path(j),path(j+1));
         end
    end
end