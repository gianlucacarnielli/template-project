if isMATLABReleaseOlderThan("R2021b")
    error('To use this project the MATLAB release must be at least R2021b.')
end

% Clear workspace
clc; clear;

% Display welcome message
disp('Welcome! To get started open the <a href="matlab: openDoc">documentation</a>.')