module Neuron #
( parameter HIDDEN = "yes"
, parameter NP     = 4
, parameter NC     = 4
, parameter WF     = 4
)
( input                          iMode
, input                          iValid_AS_Accum0
, output                         oReady_AS_Accum0
, input  [NC*($clo2(NP)+WF)-1:0] iData_AS_Accum0
, output                         oValid_BM_State0
, input                          iReady_BM_State0
, output             [NC*WN-1:0] oData_BM_State0
, output                         oValid_BM_State1
, input                          iReady_BM_State1
, output             [NC*WN-1:0] oData_BM_State1
, input                          iRST
, input                          iCLK
);

localparam WN = (HIDDEN == "yes") ? $clog2(NP) + WF : WF;

endmodule
