classdef TriggersEvent < matlab.unittest.internal.constraints.NegatableConstraint & handle
%TRIGGERSEVENT Return true if tested function triggers input event.
% Credits: Tim Johns, Benjamin Lewis, Lewis Lea, Nadia Shivarova.
%
%   Copyright 2022 The MathWorks, Inc.

    properties (SetAccess = immutable)
        EventSource
        EventName (1,1) string = ""        
    end % properties (SetAccess = immutable)
    
    properties (Access = private)
        TestPassed (1,:) logical = logical.empty(1,0)
        EvaluatedFunction
    end % properties (Access = private)

    methods       
        function this = TriggersEvent(src, eventName)        
            this.EventSource = src;
            this.EventName = eventName;      
        end % constructor
        
        function tf = satisfiedBy(this, fcnToCall)           
            tf = this.evaluateConstraint(fcnToCall);
        end % satisfiedBy
        
        function diag = getDiagnosticFor(this, fcn)
            diag = this.getGenericDiagnosticFor(fcn, false);         
        end % getDiagnosticFor
    end % methods
    
    methods (Access = protected)     
        function diag = getNegativeDiagnosticFor(this, fcn)        
            diag = this.getGenericDiagnosticFor(fcn, true);           
        end
        
        function diag = getGenericDiagnosticFor(this, fcn, isNegated)           
            this.evaluateConstraint(fcn);
            
            if isNegated
                posStr = " not ";
                negStr = " ";
            else
                posStr = " ";
                negStr = " not ";
            end
            
            fcnName = func2str(fcn);
            
            if this.TestPassed
                str = "Event " + this.EventName + " was" + posStr + "triggered by " + fcnName;
            elseif ~this.TestPassed
                str = "Event " + this.EventName + " was" + negStr + "triggered by " + fcnName;
            else
                str = "The test has not been run yet";
            end
            
            diag = matlab.unittest.diagnostics.StringDiagnostic(str);            
        end
        
        function tf = evaluateConstraint(this, fcnToCall)         
            % If function has already been evaluated with this function
            % handle, don't re-evaluate.
            if ~isempty(this.EvaluatedFunction) && ...
                    isequal(this.EvaluatedFunction, fcnToCall)
                tf = this.TestPassed;
                return
            end

            % Default state is to assume fail
            tf = false;
            
            % Add a listener to the event source for the desired event
            listener(this.EventSource, this.EventName, @onEventFired);
           
            % Run the function
            fcnToCall();
            
            % Store the result
            this.TestPassed = tf;
            this.EvaluatedFunction = fcnToCall;
            
            function onEventFired(~,~)
                tf = true;
            end           
        end % evaluateConstraint      
    end % methods (Access = protected)    
end % classdef