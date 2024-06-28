function runAllTests
%RUNALLTESTS Run all tests associated with current project.
%
%   RunAllTests runs all tests defined for the current project and
%   creates a PDF report of the results.
%
%   Copyright 2022-2023 The MathWorks, Inc.

import matlab.unittest.TestRunner
TestFolder = fullfile(currentProject().RootFolder, "test");
Suite = matlab.unittest.TestSuite.fromFolder(TestFolder, IncludingSubfolders=true);

% Create test runner as need to add plugin
Runner = TestRunner.withNoPlugins;

% Create plugin for test report
import matlab.unittest.plugins.TestReportPlugin

ReportsFolder = fullfile(currentProject().RootFolder,'test','reports');
if ~exist(ReportsFolder, 'dir')
    mkdir(ReportsFolder)
end

pdfFile = fullfile(currentProject().RootFolder,'test','reports','TestReport.pdf');
plugin = TestReportPlugin.producingPDF(pdfFile);
Runner.addPlugin(plugin);

% Create a plugin for coverage reports
import matlab.unittest.plugins.CodeCoveragePlugin
import matlab.unittest.plugins.codecoverage.CoverageReport

ReportFolder = fullfile(TestFolder, "reports");
ReportFile = CoverageReport(ReportFolder, MainFile="AppCoverage.html");
SrcFolder = fullfile(currentProject().RootFolder,"code");
Runner.addPlugin(CodeCoveragePlugin.forFolder(SrcFolder, Producing=ReportFile, IncludingSubfolders=true))

disp('Running tests...')
Runner.run(Suite);

end