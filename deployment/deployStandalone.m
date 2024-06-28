function deployStandalone()

% Check license for MATLAB Compiler
[status,errmsg] = license('checkout','compiler');
if ~status
    error(errmsg)
end

disp('Creation of standalone application started...')

% Create output folder for web app
prj = currentProject;
outdir = fullfile(prj.RootFolder,"deployment","standalone");
if ~isfolder(outdir)
    mkdir(outdir);
end

% Name of executable file
appname = readstruct("deployment.json").appname;
[~, exename] = fileparts(appname);

% Create standalone executable
AddFiles = [
    fullfile(prj.RootFolder,"code","report","temp-report.dotx")
    fullfile(prj.RootFolder,"code","report","ReportDoc.xlsx")];

warning('off','MATLAB:depfun:req:UndeployableSymbol')
compiler.build.standaloneWindowsApplication(...
    fullfile(prj.RootFolder,"code","ui",appname), ...
    ExecutableName = exename, ...
    ExecutableIcon = fullfile(prj.RootFolder,"images","app-icon.png"), ...
    ExecutableSplashScreen = fullfile(prj.RootFolder,"images","matlab.png"), ...
    OutputDir = outdir, ...
    AdditionalFiles = AddFiles);
warning('on','MATLAB:depfun:req:UndeployableSymbol')

fprintf('...complete. Output folder:\n"%s"\n', outdir)
end