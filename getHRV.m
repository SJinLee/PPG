function [xx,yy,RR_locs,RR] = getHRV(peak_locs)
    RR = diff(peak_locs);
    RR_locs = peak_locs(1:end-1) - peak_locs(1);
    
    xx = 0:RR_locs(end);
    yy = spline(RR_locs,RR,xx);
end
