module BiasWeight #
( parameter HIDDEN = "yes"
, parameter NP     = 4
, parameter NC     = 4
, parameter WI     = 4
, parameter WF     = 4
)
( input                       iMode
, input                       iValid_AS_State1
, output                      oReady_AS_State1
, input           [NP*WF-1:0] iData_AS_State1
, input                       iValid_AS_Delta1
, output                      oReady_AS_Delta1
, input              [WD-1:0] iData_AS_Delta1
, output                      oValid_BM_WeightBias
, input                       iReady_BM_WeightBias
, output [NC*NP*WF+NC*WF-1:0] oData_BM_WeightBias
, output                      oValid_BM_Weight
, input                       iReady_BM_Weight
, output       [NC*NP*WF-1:0] oData_BM_Weight
, input                       iRST
, input                       iCLK
);

localparam WD =
    (HIDDEN == "yes") ? NC * ($clog2(NN) + WI + WF) : NC * (WI + WF);

endmodule
