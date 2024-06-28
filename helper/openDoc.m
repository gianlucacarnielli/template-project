function openDoc()

% Open documentation landing page
LandingPage = fullfile(currentProject().RootFolder, 'documentation', ...
    'LiveScriptsAndHTML', 'Introduction.html');

if exist(LandingPage, "file")
    web(LandingPage)
else
    buildDocumentation()
end