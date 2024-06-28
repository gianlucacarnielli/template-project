function editApp()

fList = dir(fullfile(currentProject().RootFolder,"code","ui"));
filename = {fList.name};

% Open all MLAPP files
for file = filename(contains(filename,".mlapp"))
    edit(file{1})
end