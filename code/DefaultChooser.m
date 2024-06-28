classdef DefaultChooser < Chooser
    %DEFAULTCHOOSER Default implementation class for abstract Chooser
    %
    %   DefaultChooser is a class that implements Chooser, whos methods
    %   are tested using the mocking framework. The methods to be tested
    %   are the interactive choice actions, like choosing the type of data,
    %   selecting files to load and results to export.
    %
    %   Copyright 2024 The MathWorks, Inc.

    methods (Static)
        function [file, path, status] = chooseFile(FileType, Title)
            %CHOOSEFILE Select file interactively.

            arguments
                FileType cell = {'*.mat;*.xlsx'}
                Title    string = "File Selector"
            end

            [file, path, status] = uigetfile(FileType, Title);
        end % chooseFile

        function [file, status, path] = chooseSave(Title, DefName, FileType)
            %CHOOSESAVE Save file interactively.

            arguments
                Title (1,1)   string
                DefName (1,1) string
                FileType cell = {'*.mat'}
            end

            [file, status, path] = uiputfile(FileType, Title, DefName);
        end % chooseSave

        function file = getReportFile
            file = string.empty;
        end
    end % methods (Static)
end % classdef