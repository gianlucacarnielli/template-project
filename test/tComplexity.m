classdef tComplexity < matlab.unittest.TestCase
%TCOMPLEXITY Test McCabe complexity for all m-files in the project.
%
%   Copyright 2022 The MathWorks, Inc.

    properties (Constant)
        MaxComplexity = 10
    end % properties (Constant)

    properties (TestParameter)
        MFile % List of m-files to be checked
    end % properties (Test Parameter)

    methods (TestParameterDefinition, Static)
        function MFile = getListOfFiles
            % Get list of files and remove first part containing the root 
            % folder of the project.
            list = erase([currentProject().Files.Path], currentProject().RootFolder);

            % Extract only those files that end with ".m"
            MFile = cellstr(list(endsWith(list,[".m" ".mlapp"]))); % Needs to be a cell
        end % getListOfFiles
    end % methods (TestParameterDefinition, Static)

    %% Test Method Block
    methods (Test)
        function testMcCabeComplexity(t, MFile)
            %TESTMCCABECOMPLEXITY Test complexity of MFile

            % Run check of cyclomatic complexity and extract value
            chk = checkcode(fullfile(currentProject().RootFolder, MFile), "-cyc", "-struct");
            cc  = str2double(extractBetween({chk(startsWith({chk.message}, "The McCabe")).message}, "is ", "."));

            % Compose test diagnostic message and run verification using
            % custom constraint "HasComplexityLessThan"
            msg = sprintf('%s has a McCabe complexity greater than %i.', MFile, t.MaxComplexity);
            t.verifyThat(cc, HasComplexityLessThan(t.MaxComplexity), msg)
        end  % testMcCabeComplexity
    end % methods (Test)
end % classdef