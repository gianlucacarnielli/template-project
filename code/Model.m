classdef Model < handle
    %MODEL To handle the loading and analysis of the data, and the export
    %process.

    events (NotifyAccess = private)
        AnalysisEnded
        AnalysisStarted
        SavingEnded
        LoadingEnded
        LoadingStarted
    end % events (NotifyAccess = private)

    properties (SetAccess = private)
        BestFitCoefs (:,2) = double.empty(0,2)
        BestFitVals (:,1) double = double.empty(0,1)
        Data (:,2) table = table.empty(0,2)
    end % properties (SetAccess = private)

    properties (Access = private)
        Chooser
    end % properties (Access = private)

    methods
        function obj = Model(chooser)
            arguments
                chooser Chooser = DefaultChooser
            end
            obj.Chooser = chooser;
        end % constructor

        function analyzeData(obj)
            notify(obj,"AnalysisStarted")
            % Get coefficients of a line fit through the data.
            obj.BestFitCoefs = polyfit(obj.Data.X,obj.Data.Y, 1);
            out.data = obj.BestFitCoefs;

            % Get the estimated yFit value for each of those 1000 new x locations.
            obj.BestFitVals = polyval(obj.BestFitCoefs, obj.Data.X);
            notify(obj, "AnalysisEnded", NotifyData(out))
        end % analyzeData

        function out = loadData(obj, filename)
            arguments
                obj
                filename {mustBeEmptyOrFile} = []
            end

            notify(obj, "LoadingStarted")
            try
                if isempty(filename)
                    [filename, path] = obj.Chooser.chooseFile({'*.xlsx';'*.xls';'*.csv'});
                    if isequal(filename,0)
                        out.exitflag = -1; % cancel option
                    else
                        filename = fullfile(path,filename);
                    end
                end
                if ~isequal(filename,0)
                    obj.Data = readtable(filename);
                    % Check file is of correct type
                    assert(isequal({'X','Y'}, obj.Data.Properties.VariableNames))
                    out.path = filename;
                    out.exitflag = 1; % success
                    out.data = obj.Data; % for report generation
                end
            catch
                out.exitflag = 0; % error
            end
            notify(obj, "LoadingEnded", NotifyData(out));
        end % loadData

        function out = saveResults(obj)
            try
                [file,path] = obj.Chooser.chooseSave('Save','results');
                if isequal(file,0) || isequal(path,0)
                    out.exitflag = 0;
                else
                    data = obj.BestFitCoefs;
                    save(fullfile(path,file), "data")
                    out.exitflag = 1;
                    out.path = fullfile(path,file);
                end
            catch
                out.exitflag = 2;
            end
            notify(obj, "SavingEnded", NotifyData(out));
        end % saveResults
    end % methods
end % classdef

function mustBeEmptyOrFile(file)
if ~isempty(file)
    mustBeFile(file)
end
end % mustBeEmptyOrFile