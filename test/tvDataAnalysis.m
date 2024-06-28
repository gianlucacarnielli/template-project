classdef tvDataAnalysis < matlab.uitest.TestCase
    %TVDATAANALYSIS Test harness for the vDataAnalysis UI component.
    %
    %   Copyright 2024 The MathWorks, Inc.

    properties (Access = private)
        DataModel (1,1) Model
        Comp (:,1) vDataAnalysis = vDataAnalysis.empty
    end % properties (Access = private)

    properties (Constant, GetAccess = private)
        TestFolder = fullfile(currentProject().RootFolder, "test", "data")
    end % properties (Constant, GetAccess = private)

    methods (TestClassSetup)
        function launchComp(t)
            %LAUNCHCOMP Initialization tasks.
            fig = uifigure;
            t.DataModel = Model;
            t.Comp = vDataAnalysis(t.DataModel, fig);

            % Create component instance
            t.addTeardown(@delete, fig)
        end % launchComp
    end % methods (TestMethodSetup)

    methods (Test)
        function testLoadWrongFile(t)
            % Check that when the wrong file is selected the UI table and
            % scatter plots are still empty
            loadData(t.DataModel, fullfile(t.TestFolder, "wrongdata.xlsx"));
            t.verifyEmpty(t.Comp.DataTable.Data);
            t.verifyEqual(t.Comp.Scatter.XData, nan)
            t.verifyEqual(t.Comp.Scatter.YData, nan)
        end % testLoadWrongFile

        function testLoadFile(t)
            % Check that when the right file is selected the UI table and
            % scatter plot get populated
            testfile = fullfile(t.TestFolder, "testdata.xlsx");
            testdata = readtable(testfile);

            loadData(t.DataModel, testfile);
            t.verifyEqual(t.Comp.DataTable.ColumnName, {'X';'Y'})
            t.verifyEqual(t.Comp.Scatter.XData, testdata.X')
            t.verifyEqual(t.Comp.Scatter.YData, testdata.Y')
        end % testLoadFile

        function testFitRightData(t)
            % Check that after fitting the right data the fit table and the
            % line plot get populated with the correct values
            testfile = fullfile(t.TestFolder, "testdata.xlsx");
            loadData(t.DataModel, testfile);
            analyzeData(t.DataModel);
            t.verifyEqual(t.Comp.FitTable.Data, t.DataModel.BestFitCoefs);
            t.verifyEqual(t.Comp.Line.YData, t.DataModel.BestFitVals');
        end % testFitRightData
    end % methods(Test)
end % classdef