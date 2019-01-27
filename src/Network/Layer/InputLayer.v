module InputLayer #
( parameter NC    = 7
, parameter NN    = 6
, parameter WF    = 5
, parameter BURST = "yes"
)
( input                 iValid_AM_Input
, output                oReady_AM_Input
, input     [NC*WF-1:0] iData_AM_Input
, output                oValid_BM_State0
, input                 iReady_BM_State0
, output    [NC*WF-1:0] oData_BM_State0
, output                oValid_BM_State1
, input                 iReady_BM_State1
, output    [NC*WF-1:0] oData_BM_State1
, input                 iValid_AS_Weight
, output                oReady_AS_Weight
, input  [NC*NN*WF-1:0] iData_AS_Weight
, input                 iValid_AS_Delta0
, output                oReady_AS_Delta0
, input     [NN*WF-1:0] iData_AS_Delta0
, input                 iRST
, input                 iCLK
);

wire             wvld_s0;
wire             wrdy_s0;
wire [NC*WF-1:0] wdata_s0;
wire             wvld_s1;
wire             wrdy_s1;
wire [NC*WF-1:0] wdata_s1;
wire             wvld;

Broadcaster #
( .WIDTH0(NC*WF)
, .WIDTH1(NC*WF)
, .BURST(BURST)
) broadcaster0
( .iValid_AM(iValid_AM_Input)
, .oReady_AM(oReady_AM_Input)
, .iData_AM({iData_AM_Input, iData_AM_Input})
, .oValid_BM0(oValid_BM_State0)
, .iReady_BM0(iReady_BM_State0)
, .oData_BM0(oData_BM_State0)
, .oValid_BM1(wvld_s0)
, .iReady_BM1(wrdy_s0)
, .oData_BM1(wdata_s0)
, .iRST(iRST)
, .iCLK(iCLK)
);

Broadcaster #
( .WIDTH0(NC*WF)
, .WIDTH1(NC*WF)
, .BURST(BURST)
) broadcaster1
( .iValid_AM(wvld_s0)
, .oReady_AM(wrdy_s0)
, .iData_AM({wdata_s0, wdata_s0})
, .oValid_BM0(oValid_BM_State1)
, .iReady_BM0(iReady_BM_State1)
, .oData_BM0(oData_BM_State1)
, .oValid_BM1(wvld_s1)
, .iReady_BM1(wrdy_s1)
, .oData_BM1(wdata_s1)
, .iRST(iRST)
, .iCLK(iCLK)
);

//Sink
assign wvld = wvld_s1 && iValid_AS_Weight && iValid_AS_Delta0;
assign {wrdy_s1, oReady_AS_Weight, oReady_AS_Delta0} = {3{wvld}};

endmodule
