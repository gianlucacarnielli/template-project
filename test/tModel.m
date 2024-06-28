classdef tModel < matlab.uitest.TestCase & matlab.mock.TestCase
    %TMODEL Test harness for the Model class.
    %
    %   Copyright 2024 The MathWorks, Inc.

    properties (Access = private)
        DataModel       
        Behavior
    end % properties (Access = private)

    properties (Constant, GetAccess = private)
        TestFolder = fullfile(currentProject().RootFolder, "test", "data")
    end % properties (Constant, GetAccess = private)

    methods (TestMethodSetup)
        function launchModel(t)
            %LAUNCHMODEL Initialization tasks.

            % Create mock object to simulate interactive behavior
            [mockChooser, t.Behavior] = t.createMock(?Chooser);

            % Create app instance
            t.DataModel = Model(mockChooser);
            t.addTeardown(@delete, t.DataModel)

        end % launchModel
    end % methods (TestMethodSetup)

    methods (Test)
        function testLoadWrongFileInteractively(t)
            % Check that when an unsupported file type is selected for
            % loading the function returns an exit flag equal to 0
            import matlab.mock.actions.AssignOutputs
            when(withAnyInputs(t.Behavior.chooseFile), ...
                AssignOutputs('wrongdata.xlsx', t.TestFolder, 1)) 
            out = loadData(t.DataModel);
            t.verifyEqual(out.exitflag, 0);
        end % testLoadWrongFile

        function testLoadFileInteractively(t)
            % Check that when a supported file type is selected for
            % loading the function returns an exit flag equal to 1, the
            % path to the selected file. Check also that the Data table
            % gets populated.
            import matlab.mock.actions.AssignOutputs
            when(withAnyInputs(t.Behavior.chooseFile), ...
                AssignOutputs('testdata.xlsx', t.TestFolder, 1)) 
            out = loadData(t.DataModel);
            t.verifyEqual(out.exitflag, 1);
            testfile = fullfile(t.TestFolder,'testdata.xlsx');
            t.verifyEqual(out.path, testfile);
            t.verifyEqual(t.DataModel.Data, readtable(testfile));
        end % testLoadWrongFile

        function testNoFile(t)
            % Check that something which is not a file returns the correct
            % error message
            t.verifyError(@() loadData(t.DataModel, "NotAFile"),'MATLAB:validators:mustBeFile')
        end % testNoFile

        function testWrongFileProgrammatically(t)
            out = loadData(t.DataModel, fullfile(t.TestFolder, "wrongdata.xlsx"));
            t.verifyEqual(out.exitflag, 0);
        end % testWrongFileProgrammatically

        function testLoadFileProgrammatically(t)
            out = loadData(t.DataModel, fullfile(t.TestFolder, "testdata.xlsx"));
            t.verifyEqual(out.exitflag, 1);
            testfile = fullfile(t.TestFolder,'testdata.xlsx');
            t.verifyEqual(out.path, testfile);
            t.verifyEqual(t.DataModel.Data, readtable(testfile));
        end % testLoadFileProgrammatically

        function testDataAnalysis(t)
            loadData(t.DataModel, fullfile(t.TestFolder, "testdata.xlsx"));
            t.verifyThat(@() analyzeData(t.DataModel), ...
                TriggersEvent(t.DataModel, "AnalysisEnded"))
            t.verifyEqual(t.DataModel.BestFitCoefs, [0.98 0.6], AbsTol=0.1)
        end % testDataAnalysis

        function testNoSaveResults(t)
            % Check that when user does not select folder exit flag returns
            % 0

            import matlab.mock.actions.AssignOutputs
            import matlab.unittest.fixtures.TemporaryFolderFixture
            tempFixture = t.applyFixture(TemporaryFolderFixture);

            when(withAnyInputs(t.Behavior.chooseSave), ...
                AssignOutputs(0, tempFixture.Folder, 1))

            % Load and analyze data
            loadData(t.DataModel, fullfile(t.TestFolder, "testdata.xlsx"));
            analyzeData(t.DataModel);

            % Save data
            out = saveResults(t.DataModel);
            t.verifyEqual(out.exitflag,0)
        end % testNoSaveResults

        function testSaveResults(t)
            % Check that results can be exported

            import matlab.mock.actions.AssignOutputs
            import matlab.unittest.constraints.IsFile
            import matlab.unittest.fixtures.TemporaryFolderFixture
            tempFixture = t.applyFixture(TemporaryFolderFixture);

            when(withAnyInputs(t.Behavior.chooseSave), ...
                AssignOutputs('tSavedData.mat', tempFixture.Folder, 1))

            % Load and analyze data
            loadData(t.DataModel, fullfile(t.TestFolder, "testdata.xlsx"));
            analyzeData(t.DataModel);

            % Save data
            out = saveResults(t.DataModel);
            t.verifyEqual(out.exitflag, 1)
            t.verifyThat(fullfile(tempFixture.Folder, "tSavedData.mat"), IsFile, ...
                "Results were not saved in external file.")
        end % testSaveResults

        function testWrongSaving(t)
            % Check that when an exception occurs, e.g., specifying a
            % non-existing folder for storing output data, an exit flag
            % equal to 2 is assigned
            
            import matlab.mock.actions.AssignOutputs

            when(withAnyInputs(t.Behavior.chooseSave), ...
                AssignOutputs('tSavedData.mat', "NotAFolder", 1))

            % Load and analyze data
            loadData(t.DataModel, fullfile(t.TestFolder, "testdata.xlsx"));
            analyzeData(t.DataModel);

            % Save data
            out = saveResults(t.DataModel);
            t.verifyEqual(out.exitflag, 2)
        end % testWrongSaving
    end % methods(Test)
end % classdef