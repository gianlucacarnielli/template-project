classdef AnalysisReport < handle

    events (NotifyAccess = private)
        ReportStarted
        ReportProgress
        ReportEnded
        NoReportLicense
    end % events (NotifyAccess = private)

    properties (Constant, Access = private)
        TemplateName = "temp-report.dotx"
        ExcelFile = "ReportDoc.xlsx"
    end % properties (Constant, Access = private)

    properties (GetAccess = private, SetAccess = immutable)
        List
        chapInfo
    end % properties (GetAccess = private, SetAccess = immutable)

    properties (Access = private)
        % This is data that goes into the report which is generated 
        % dynamically
        Ax
        Data
        Coefs
    end % properties (Access = private)

    methods
        function obj = AnalysisReport
            % Import Chapters Info from Excel
            chapInfo = readtable(obj.ExcelFile,'Sheet','Chapters');
            dummy    = splitlines(string(chapInfo.Paragraph{3}));
            for i = 1 : numel(dummy), obj.List{i} = dummy{i}; end
            obj.chapInfo = chapInfo;
        end % constructor

        function run(obj, reportfile)

            arguments
                obj
                reportfile string {mustBeScalarOrEmpty} = string.empty
            end

            % Check license for MATLAB Report Generator
            [status,errmsg] = license('checkout','matlab_report_gen');
            if ~status
                error(errmsg)
            end

            import mlreportgen.dom.*

            try
                notify(obj,"ReportStarted")

                if ismcc || isdeployed
                    % Make sure DOM is compilable
                    makeDOMCompilable();
                end

                if isempty(reportfile)
                    if ismcc || isdeployed
                        folder = templatePath('');
                    else
                        filepath = fullfile(currentProject().RootFolder,"report");
                        if ~isfolder(filepath)
                            mkdir(filepath)
                        end
                        folder = filepath;
                    end
                    dd = datetime;
                    reportName = "Report_" + year(dd) + month(dd) + day(dd) + "_" + hour(dd) + minute(dd) + ".docx";
                    reportfile = fullfile(folder,reportName);
                else
                    [~,reportName] = fileparts(reportfile);
                end

                % If application is deployed, generate path relative to temp directory
                rpt = Document(reportfile,'docx', templatePath(obj.TemplateName));

                holeID  = moveToNextHole(rpt);
                barval = 0; % percentage progress
                while string(holeID)~="#end#"
                    switch holeID
                        case "ProjectName"
                            append(rpt,"Data Analysis - Best Fit");
                        case "Author"
                            append(rpt, "Gianluca Carnielli");
                        case "fileName"
                            append(rpt, reportName);
                        case "Status"
                            append(rpt, "To be reviewed");
                        case "PublishDate"
                            simDate = string(datetime('now','TimeZone','local','Format','d-MMM-y HH:mm'));
                            append(rpt, simDate);
                        case "DocTitle"
                            append(rpt,"Data Analysis Report");
                        case "Coefficients"
                            append(rpt, MATLABTable(obj.Coefs));
                        case "Abstract"
                            append(rpt,obj.chapInfo.Paragraph{1});
                        case "MATLABRelease"
                            append(rpt,obj.chapInfo.Paragraph{2});
                        case "Toolbox"
                            append(rpt,obj.List);
                        case "InputTable"
                            append(rpt, MATLABTable(obj.Data));
                        case "Title1"
                            tempfile = templatePath("plot1.jpg");
                            exportgraphics(obj.Ax, tempfile);
                            plotSimulation(rpt, tempfile, "Linear Fit") 
                        case "MWCopyright"
                            append(rpt,"© 1994-" + year(datetime) + " The MathWorks, Inc.");
                    end
                    holeID  = moveToNextHole(rpt);
                    barval = min(barval + randsample([0.06 0.2 0.1],1),1);
                    notify(obj, "ReportProgress", NotifyData(barval))
                end

                % Close the report (required)
                close(rpt);
                delete(tempfile)
                out.exitflag = 1;
                out.path = reportfile;

                if ismcc || isdeployed
                    % Download report
                    web(rpt.OutputPath)
                end

                notify(obj, "ReportEnded", NotifyData(out))
            catch ME
                out.exitflag = 0;
                out.ME = ME.message;
                notify(obj, "ReportEnded", NotifyData(out))
            end

            function template = templatePath(templatename)
                % Where's my template?
                whoAmI = mfilename('fullpath');
                [fullpath, ~, ~] = fileparts(whoAmI);
                template = fullfile(fullpath, templatename);
            end

            function img = imageBuild(fileName)
                img = Image(fileName);
                img.Style = [img.Style {ScaleToFit}];
            end

            function plotSimulation(rpt,fileName, titleList)
                append(rpt, titleList);
                moveToNextHole(rpt);
                imageObj = imageBuild(fileName);
                append(rpt,imageObj);
            end
        end % run

        function saveOutput(obj, evt)
            switch evt.EventName
                case "PlotUpdated"
                    obj.Ax = evt.Data.data;
                case "LoadingEnded"
                    if evt.Data.exitflag == 1
                        obj.Data = evt.Data.data;
                    end
                case 'AnalysisEnded'
                    obj.Coefs = table(evt.Data.data(1),evt.Data.data(2),...
                        VariableNames=["Slope", "Intercept"]);
            end
        end % saveOutput
    end % methods
end % classdef