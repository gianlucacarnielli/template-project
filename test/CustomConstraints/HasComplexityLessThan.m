classdef HasComplexityLessThan < matlab.unittest.constraints.Constraint
%HASCOMPLEXITYLESSTHAN Custom constraint which checks that tested value is
% less than or equal to the maximum complexity (given as input).
%
%   Copyright 2022 The MathWorks, Inc.

    properties (SetAccess = immutable)
        MaxComplexity
    end % properties (SetAccess = immutable)
            
    methods
        function constraint = HasComplexityLessThan(value)
            constraint.MaxComplexity = value;
        end % constructor

        function bool = satisfiedBy(constraint, actual)
            % Return true if actual complexity is less than max value
            bool = ~any(actual > constraint.MaxComplexity);
        end % satisfiedBy

        function diag = getDiagnosticFor(constraint, actual)
            import matlab.unittest.diagnostics.StringDiagnostic
            if constraint.satisfiedBy(actual)
                diag = StringDiagnostic('HasComplexityLessThan passed.');
            else
                diag = StringDiagnostic(sprintf(...
                    'HasComplexityLessThan failed.\nActual complexity: [%s]\nExpected max complexity: %s',...
                    int2str(actual),...
                    int2str(constraint.MaxComplexity)));
            end
        end % getDiagnosticFor
    end % methods
end % classdef