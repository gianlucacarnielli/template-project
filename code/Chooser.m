classdef Chooser < handle
    %CHOOSER Abstract class for UI gestures; used for mock testing.
    %
    %   Chooser is an abstract class which contains methods to be tested using
    %   the mocking framework. The methods to be tested are the interactive
    %   uiconfirm, uigetfile, and uiputfile.
    %
    %   Copyright 2024 The MathWorks, Inc.

    methods (Abstract)
        % Interface to choose a file
        [file, path, status] = chooseFile(varargin)

        % Interface to choose where to save results
        [file, path, status] = chooseSave(varargin)

        % Interface to set report file
        file = getReportFile
    end % methods (Abstract)
end % classdef