classdef tcDataModel < matlab.uitest.TestCase & matlab.mock.TestCase
    %TCDATAMODEL Test harness for the cDataModel UI component.
    %
    %   Copyright 2024 The MathWorks, Inc.

    properties (Access = private)
        Behavior
        DataModel (1,1) Model
        Comp (:,1) cDataModel = cDataModel.empty
    end % properties (Access = private)

    properties (Constant, GetAccess = private)
        TestFolder = fullfile(currentProject().RootFolder, "test", "data")
    end % properties (Constant, GetAccess = private)

    methods (TestClassSetup)
        function launchComp(t)
            % Create mock object to simulate interactive behavior
            [mockChooser, t.Behavior] = t.createMock(?Chooser);

            %LAUNCHCOMP Initialization tasks.
            fig = uifigure;
            t.DataModel = Model(mockChooser);
            t.Comp = cDataModel(t.DataModel, fig);

            % Create component instance
            t.addTeardown(@delete, fig)
        end % launchComp
    end % methods (TestMethodSetup)

    methods (Test)
        function testLoadWrongFile(t)
            % Check that when the wrong file is selected the "Fit Data"
            % button is still disabled
            import matlab.mock.actions.AssignOutputs
            when(withAnyInputs(t.Behavior.chooseFile), ...
                AssignOutputs('wrongdata.xlsx', t.TestFolder, 1))

            t.press(t.Comp.LoadDataButton);
            t.verifyFalse(t.Comp.FitDataButton.Enable);
        end % testLoadWrongFile

        function testLoadNoFile(t)
            % Check that when no file is selected the "Fit Data"
            % button is still disabled
            import matlab.mock.actions.AssignOutputs
            when(withAnyInputs(t.Behavior.chooseFile), ...
                AssignOutputs(0, t.TestFolder, 1))

            t.press(t.Comp.LoadDataButton);
            t.verifyFalse(t.Comp.FitDataButton.Enable);
        end % testLoadNoFile

        function testLoadFile(t)
            % Check that when the right file is selected then the fit
            % button gets enabled
            import matlab.mock.actions.AssignOutputs
            when(withAnyInputs(t.Behavior.chooseFile), ...
                AssignOutputs('testdata.xlsx', t.TestFolder, 1))

            t.press(t.Comp.LoadDataButton);
            t.verifyTrue(t.Comp.FitDataButton.Enable);
        end % testLoadFile

        function testFitRightData(t)
            % Check that after fitting the right data the "Save" button is 
            % enabled
            t.press(t.Comp.FitDataButton);
            t.verifyTrue(t.Comp.SaveResultsButton.Enable);
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
            t.press(t.Comp.SaveResultsButton)

            t.verifyThat(fullfile(tempFixture.Folder, "tSavedData.mat"), IsFile, ...
                "Results were not saved in external file.")
        end % testSaveResults
    end % methods(Test)
end % classdef