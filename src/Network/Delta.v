module Delta #
( parameter HIDDEN = "yes"
, parameter NP     = 4
, parameter NC     = 4
, parameter NN     = 4
, parameter WI     = 4
, parameter WF     = 4
)
( input                          iMode
, input                          iValid_AS_Accum1
, output                         oReady_AS_Accum1
, input  [NC*($clo2(NP)+WF)-1:0] iData_AS_Accum1
, input                          iValid_AS_Weight
, output                         oReady_AS_Weight
, input           [NN*NC*WF-1:0] iData_AS_Weight
, input                          iValid_AS_Delta0
, output                         oReady_AS_Delta0
, input         [NN*(WI+WF)-1:0] iData_AS_Delata0
, output                         oValid_BM_Delta0
, input                          iReady_BM_Delta0
, output                [WD-1:0] oData_BM_Delta0
, output                         oValid_BM_Delta1
, input                          iReady_BM_Delta1
, output                [WD-1:0] oData_BM_Delta1
, input                          iRST
, input                          iCLK
);

localparam WD =
    (HIDDEN == "yes") ? NC * ($clog2(NN) + WI + WF) : NC * (WI + WF);

endmodule
