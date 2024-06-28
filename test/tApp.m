classdef tApp < matlab.uitest.TestCase & matlab.mock.TestCase
    %TAPP Test harness for the data analysis app.
    %
    %   Copyright 2024 The MathWorks, Inc.

    properties (Access = private)
        Behavior
        App launcher
        LoadDataButton
        SaveResultsButton
        FitDataButton
    end % properties (Access = private)

    properties (Constant, GetAccess = private)
        TestFolder = fullfile(currentProject().RootFolder, "test", "data")
    end % properties (Constant, GetAccess = private)

    methods (TestClassSetup)
        function launchApp(t)
            % Create mock object to simulate interactive behavior
            [mockChooser, t.Behavior] = t.createMock(?Chooser);

            %LAUNCHAPP Initialization tasks.
            t.App = launcher(mockChooser);

            t.LoadDataButton = t.App.GridLayout2.Children.LoadDataButton;
            t.SaveResultsButton = t.App.GridLayout2.Children.SaveResultsButton;
            t.FitDataButton = t.App.GridLayout2.Children.FitDataButton;

            % Create component instance
            t.addTeardown(@delete, t.App)
        end % launchComp
    end % methods (TestMethodSetup)

    methods (Test)

        function testLoadFile(t)
            % Check that when the right file is selected then the fit
            % button gets enabled
            import matlab.mock.actions.AssignOutputs
            when(withAnyInputs(t.Behavior.chooseFile), ...
                AssignOutputs('testdata.xlsx', t.TestFolder, 1))

            t.press(t.LoadDataButton);
            t.verifyTrue(t.FitDataButton.Enable);
        end % testLoadFile

        function testFitRightData(t)
            % Check that after fitting the right data the "Save" button is 
            % enabled
            t.press(t.FitDataButton);
            t.verifyTrue(t.SaveResultsButton.Enable);
            t.verifyTrue(t.App.GenerateReportMenu.Enable);
        end % testFitRightData

        function testSaveResults(t)
            % Check that results can be exported

            import matlab.mock.actions.AssignOutputs
            import matlab.unittest.constraints.IsFile
            import matlab.unittest.fixtures.TemporaryFolderFixture
            tempFixture = t.applyFixture(TemporaryFolderFixture);

            when(withAnyInputs(t.Behavior.chooseSave), ...
                AssignOutputs('tSavedData.mat', tempFixture.Folder, 1))

            % Save data
            t.press(t.SaveResultsButton)
            dismissAlertDialog(t,t.App.UIFigure)
            t.verifyThat(fullfile(tempFixture.Folder, "tSavedData.mat"), IsFile, ...
                "Results were not saved in external file.")
        end % testSaveResults

        function testGenerateReport(t)
            % Check that report gets generated

            import matlab.mock.actions.AssignOutputs
            import matlab.unittest.constraints.IsFile
            import matlab.unittest.fixtures.TemporaryFolderFixture
            tempFixture = t.applyFixture(TemporaryFolderFixture);

            tempReportFile = fullfile(tempFixture.Folder,'temp-report.docx');

            when(withAnyInputs(t.Behavior.getReportFile), ...
                AssignOutputs(tempReportFile))

            % Generate Word report
            t.press(t.App.GenerateReportMenu)
            dismissAlertDialog(t,t.App.UIFigure)

            t.verifyThat(tempReportFile, IsFile, ...
                "Results were not saved in external file.")
        end % testGenerateReport
    end % methods(Test)
end % classdef