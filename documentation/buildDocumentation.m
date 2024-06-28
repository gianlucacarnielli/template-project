function buildDocumentation

prj = currentProject;
% Extract all mlx files that have been modified with respect to the master
% branch and are in LiveScriptsAndHTML or one of its subfolders.
Files = prj.Files;
Files = Files(~strcmp([Files.SourceControlStatus], "Unmodified"));
FilePaths = [Files.Path];
pathToDocMLX = fullfile(prj.RootFolder, "documentation", "LiveScriptsAndHTML");
FilePaths = FilePaths(contains(FilePaths, pathToDocMLX));
FilePaths = FilePaths(endsWith(FilePaths,".mlx"));

nFiles = numel(FilePaths);

if nFiles == 0
    fprintf('\nNo new documentation files to build.\n');
else
    fprintf('Exporting live scripts (with modified GIT status, if under source control) to HTML...\n\n');
end

% Export each live script to an HTML file in the same folder
for iScript = 1:nFiles
    [Path, FileName] = fileparts(FilePaths(iScript));
    TmpMsg = fprintf('\nExporting %s.mlx...(%i out of %i)\n', ...
        FileName, iScript, nFiles);
    newfilepath = fullfile(Path, FileName+".html");
    export(FilePaths(iScript), newfilepath);
    fprintf(repmat('\b', 1, TmpMsg))

    % If not present already, add exported file to project
    if isempty(findFile(prj, newfilepath))
        prj.addFile(newfilepath);
        newfile = findFile(prj, newfilepath);
        addLabel(newfile,"Classification","Documentation");
    end
    fprintf('<strong>%s.mlx</strong> successfully exported.\n', FileName);
end

fprintf('...done.\n\n');

%% BUILD DOCUMENTATION
builddocsearchdb(fullfile(prj.RootFolder, "documentation", "LiveScriptsAndHTML"))
fprintf('\n<a href="matlab: openDoc">Open</a> documentation.\n');
end