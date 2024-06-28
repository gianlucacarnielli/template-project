classdef (ConstructOnLoad) NotifyData < event.EventData
   properties
      Data
   end % properties
   
   methods
       function obj = NotifyData(Input)
         obj.Data = Input;
       end % NotifyData
   end % methods
end % classdef