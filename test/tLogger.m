classdef tLogger < matlab.uitest.TestCase
    %TLOGGER Test harness for the Logger UI component.
    %
    %   Copyright 2024 The MathWorks, Inc.

    properties (Access = private)
        DataModel (1,1) Model
        Comp (:,1) Logger = Logger.empty
    end % properties (Access = private)

    properties (Constant, GetAccess = private)
        TestFolder = fullfile(currentProject().RootFolder, "test", "data")
    end % properties (Constant, GetAccess = private)

    methods (TestClassSetup)
        function launchComp(t)
            %LAUNCHCOMP Initialization tasks.
            fig = uifigure;
            t.DataModel = Model;
            t.Comp = Logger(fig);
            addlistener(t.DataModel, "LoadingEnded", @(~,e) t.Comp.updateText(e));
            addlistener(t.DataModel, "SavingEnded", @(~,e) t.Comp.updateText(e));

            % Create component instance
            t.addTeardown(@delete, fig)
        end % launchComp
    end % methods (TestMethodSetup)

    methods (Test)
        function testDataLoading(t)
            testfile = char(fullfile(t.TestFolder, 'testdata.xlsx'));
            loadData(t.DataModel, testfile);
            t.verifyEqual(['Data loaded from: ' testfile], t.Comp.Label.Text);
        end % testDataLoading
    end % methods(Test)
end % classdef