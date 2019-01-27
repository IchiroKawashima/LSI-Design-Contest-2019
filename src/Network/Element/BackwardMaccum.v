module BackwardMaccum #
( parameter NN    = 7
, parameter NC    = 11
, parameter WF    = 5
, parameter BURST = "yes"
)
( input                             iValid_AM_Weight
, output                            oReady_AM_Weight
, input              [NC*NN*WF-1:0] iData_AM_Weight
, input                             iValid_AM_Delta0
, output                            oReady_AM_Delta0
, input                 [NN*WF-1:0] iData_AM_Delta0
, output                            oValid_BM_Accum2
, input                             iReady_BM_Accum2
, output [NC*($clog2(NN)-1+WF)-1:0] oData_BM_Accum2
, input                             iRST
, input                             iCLK
);

wire                   [NC-1:0] wvld_wsn;
wire                   [NC-1:0] wrdy_wsn;
wire [NC*($clog2(NN)-1+WF)-1:0] wdata_wsn;

Maccum #
( .SIZE_A(NN)
, .SIZE_B(NC)
, .WIDTH(WF)
, .BURST(BURST)
) maccum
( .iValid_AM_W(iValid_AM_Weight)
, .oReady_AM_W(oReady_AM_Weight)
, .iData_AM_W(iData_AM_Weight)
, .iValid_AM_S(iValid_AM_Delta0)
, .oReady_AM_S(oReady_AM_Delta0)
, .iData_AM_S(iData_AM_Delta0)
, .oValid_BM_WS(wvld_wsn)
, .iReady_BM_WS(wrdy_wsn)
, .oData_BM_WS(wdata_wsn)
, .iRST(iRST)
, .iCLK(iCLK)
);

CombinerN #
( .SIZE(NC)
, .WIDTH($clog2(NN)-1+WF)
) combinerNA
( .iValid_AS(wvld_wsn)
, .oReady_AS(wrdy_wsn)
, .iData_AS(wdata_wsn)
, .oValid_BM(oValid_BM_Accum2)
, .iReady_BM(iReady_BM_Accum2)
, .oData_BM(oData_BM_Accum2)
);

endmodule
