module Maccum #
( parameter NP    = 4
, parameter NC    = 4
, parameter WF    = 4
, parameter BURST = "yes"
)
( input                           iValid_AS_WeightBias
, output                          oReady_AS_WeightBias
, input      [NC*NP*WF+NC*WF-1:0] iData_AS_WeightBias
, input                           iValid_AS_State0
, output                          oReady_AS_State0
, input               [NP*WF-1:0] iData_AS_State0
, output                          oValid_BM_Accum0
, input                           iReady_BM_Accum0
, output [NC*($clog2(NP)+WF)-1:0] oData_BM_Accum0
, output                          oValid_BM_Accum1
, input                           iReady_BM_Accum1
, output [NC*($clog2(NP)+WF)-1:0] oData_BM_Accum1
, input                           iRST
, input                           iCLK
);

endmodule
