module OutputLayer #
( parameter NP    = 7
, parameter NC    = 6
, parameter WF    = 5
, parameter BURST = "yes"
)
( input                             iMode
, input                             iValid_AM_State0
, output                            oReady_AM_State0
, input                 [NP*WF-1:0] iData_AM_State0
, input                             iValid_AS_State1
, output                            oReady_AS_State1
, input                 [NP*WF-1:0] iData_AS_State1
, output                            oValid_BM_Output
, input                             iReady_BM_Output
, output [NC*($clog2(NP)+1+WF)-1:0] oData_BM_Output
, output                            oValid_BM_Weight
, input                             iReady_BM_Weight
, output             [NP*NC*WF-1:0] oData_BM_Weight
, output                            oValid_BM_Delta0
, input                             iReady_BM_Delta0
, output                [NC*WF-1:0] oData_BM_Delta0
, input                             iValid_AS_Teacher
, output                            oReady_AS_Teacher
, input  [NC*($clog2(NP)+1+WF)-1:0] iData_AS_Teacher
, input                             iRST
, input                             iCLK
);

wire                            wvld_Accum0;
wire                            wrdy_Accum0;
wire [NC*($clog2(NP)+1+WF)-1:0] wdata_Accum0;
wire                            wvld_Accum1;
wire                            wrdy_Accum1;
wire [NC*($clog2(NP)+1+WF)-1:0] wdata_Accum1;
wire                            wvld_WeightBias;
wire                            wrdy_WeightBias;
wire       [NC*NP*WF+NC*WF-1:0] wdata_WeightBias;
wire                            wvld_Delta1;
wire                            wrdy_Delta1;
wire                [NC*WF-1:0] wdata_Delta1;

ForwardMaccum #
( .NP(NP)
, .NC(NC)
, .WF(WF)
, .BURST(BURST)
) fm
( .iMode(iMode)
, .iValid_AM_WeightBias(wvld_WeightBias)
, .oReady_AM_WeightBias(wrdy_WeightBias)
, .iData_AM_WeightBias(wdata_WeightBias)
, .iValid_AM_State0(iValid_AM_State0)
, .oReady_AM_State0(oReady_AM_State0)
, .iData_AM_State0(iData_AM_State0)
, .oValid_BM_Accum0(wvld_Accum0)
, .iReady_BM_Accum0(wrdy_Accum0)
, .oData_BM_Accum0(wdata_Accum0)
, .oValid_BM_Accum1(wvld_Accum1)
, .iReady_BM_Accum1(wrdy_Accum1)
, .oData_BM_Accum1(wdata_Accum1)
, .iRST(iRST)
, .iCLK(iCLK)
);

Neuron #
( .HIDDEN("no")
, .NP(NP)
, .NC(NC)
, .WF(WF)
, .BURST(BURST)
) ne
( .iMode(iMode)
, .iValid_AM_Accum0(wvld_Accum0)
, .oReady_AM_Accum0(wrdy_Accum0)
, .iData_AM_Accum0(wdata_Accum0)
, .oValid_BM_State0(oValid_BM_Output)
, .iReady_BM_State0(iReady_BM_Output)
, .oData_BM_State0(oData_BM_Output)
, .oValid_BM_State1()
, .iReady_BM_State1(1'b0)
, .oData_BM_State1()
, .iRST(iRST)
, .iCLK(iCLK)
);

BiasWeight #
( .NP(NP)
, .NC(NC)
, .WF(WF)
, .BURST(BURST)
) bw
( .iMode(iMode)
, .iLR(8'b1000_0000)
, .iValid_AS_State1(iValid_AS_State1)
, .oReady_AS_State1(oReady_AS_State1)
, .iData_AS_State1(iData_AS_State1)
, .iValid_AS_Delta1(wvld_Delta1)
, .oReady_AS_Delta1(wrdy_Delta1)
, .iData_AS_Delta1(wdata_Delta1)
, .oValid_BM_WeightBias(wvld_WeightBias)
, .iReady_BM_WeightBias(wrdy_WeightBias)
, .oData_BM_WeightBias(wdata_WeightBias)
, .oValid_BM_Weight(oValid_BM_Weight)
, .iReady_BM_Weight(iReady_BM_Weight)
, .oData_BM_Weight(oData_BM_Weight)
, .iRST(iRST)
, .iCLK(iCLK)
);

Delta #
( .HIDDEN("no")
, .NP(NP)
, .NC(NC)
, .WF(WF)
, .BURST(BURST)
) de
( .iValid_AS_Accum1(wvld_Accum1)
, .oReady_AS_Accum1(wrdy_Accum1)
, .iData_AS_Accum1(wdata_Accum1)
, .iValid_AS_Accum2(iValid_AS_Teacher)
, .oReady_AS_Accum2(oReady_AS_Teacher)
, .iData_AS_Accum2(iData_AS_Teacher)
, .oValid_BM_Delta0(oValid_BM_Delta0)
, .iReady_BM_Delta0(iReady_BM_Delta0)
, .oData_BM_Delta0(oData_BM_Delta0)
, .oValid_BM_Delta1(wvld_Delta1)
, .iReady_BM_Delta1(wrdy_Delta1)
, .oData_BM_Delta1(wdata_Delta1)
, .iRST(iRST)
, .iCLK(iCLK)
);

endmodule
