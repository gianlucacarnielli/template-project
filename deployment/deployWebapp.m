function deployWebapp()

% Check license for MATLAB Compiler
[status,errmsg] = license('checkout','compiler');
if ~status
    error(errmsg)
end

fprintf('%s\n','Creation of web application started...')

% Create output folder for web app
prj = currentProject;
outdir = fullfile(prj.RootFolder,"deployment","webapp");
if ~isfolder(outdir)
    mkdir(outdir);
end

% Name of ctf file
appname = readstruct("deployment.json").appname;
[~, ctfname] = fileparts(appname);

% Create CTF archive
warning('off','MATLAB:depfun:req:WebAppMultiAppLimitation')
warning('off','MATLAB:depfun:req:UndeployableSymbol')

AddFiles = [
    fullfile(prj.RootFolder,"code","report","temp-report.dotx")
    fullfile(prj.RootFolder,"code","report","ReportDoc.xlsx")];

compiler.build.webAppArchive(...
    fullfile(prj.RootFolder,"code","ui",appname), ...
    ArchiveName = ctfname, ...
    OutputDir = outdir, ...
    AdditionalFiles = AddFiles);
warning('on','MATLAB:depfun:req:WebAppMultiAppLimitation')
warning('on','MATLAB:depfun:req:UndeployableSymbol')
fprintf('%s%s\n','...complete. CTF archive location: ', outdir)

% Copy CTF file in the app folder of local Web App Server
webappdir = readstruct("deployment.json").webappdir;
copyfile(fullfile(outdir, ctfname+".ctf"), webappdir)
fprintf('CTF file deployed to web server folder "%s".\n', webappdir)
end