module Network #
( parameter NI           = 4
, parameter NH0          = 5
, parameter NH1          = 6
, parameter NO           = 7
, parameter WF           = 8
, parameter INIT_FILE_H0 = ""
, parameter INIT_FILE_H1 = ""
, parameter INIT_FILE_O  = ""
, parameter BURST        = "yes"
)
( input                              iMode
, input                     [WF-1:0] iLR
, input                              iValid_AM_Input
, output                             oReady_AM_Input
, input                  [NI*WF-1:0] iData_AM_Input
, output                             oValid_BM_Output
, input                              iReady_BM_Output
, output  [NO*($clog2(NH1)+1+WF)-1:0] oData_BM_Output
, input                              iValid_AS_Teacher
, output                             oReady_AS_Teacher
, input  [NO*($clog2(NH1)+1+WF)-1:0] iData_AS_Teacher
, input                              iRST
, input                              iCLK
);

wire                  wvld_y_i0;
wire                  wrdy_y_i0;
wire      [NI*WF-1:0] wdata_y_i0;
wire                  wvld_y_i1;
wire                  wrdy_y_i1;
wire      [NI*WF-1:0] wdata_y_i1;
wire                  wvld_y_h00;
wire                  wrdy_y_h00;
wire     [NH0*WF-1:0] wdata_y_h00;
wire                  wvld_y_h01;
wire                  wrdy_y_h01;
wire     [NH0*WF-1:0] wdata_y_h01;
wire                  wvld_y_h10;
wire                  wrdy_y_h10;
wire     [NH1*WF-1:0] wdata_y_h10;
wire                  wvld_y_h11;
wire                  wrdy_y_h11;
wire     [NH1*WF-1:0] wdata_y_h11;
wire                  wvld_wh0;
wire                  wrdy_wh0;
wire  [NI*NH0*WF-1:0] wdata_wh0;
wire                  wvld_wh1;
wire                  wrdy_wh1;
wire [NH0*NH1*WF-1:0] wdata_wh1;
wire                  wvld_wo;
wire                  wrdy_wo;
wire  [NH1*NO*WF-1:0] wdata_wo;
wire                  wvld_dh0;
wire                  wrdy_dh0;
wire     [NH0*WF-1:0] wdata_dh0;
wire                  wvld_dh1;
wire                  wrdy_dh1;
wire     [NH1*WF-1:0] wdata_dh1;
wire                  wvld_do;
wire                  wrdy_do;
wire      [NO*WF-1:0] wdata_do;

InputLayer #
( .NC(NI)
, .NN(NH0)
, .WF(WF)
, .BURST(BURST)
) il
( .iMode(iMode)
, .iValid_AM_Input(iValid_AM_Input)
, .oReady_AM_Input(oReady_AM_Input)
, .iData_AM_Input(iData_AM_Input)
, .oValid_BM_State0(wvld_y_i0)
, .iReady_BM_State0(wrdy_y_i0)
, .oData_BM_State0(wdata_y_i0)
, .oValid_BM_State1(wvld_y_i1)
, .iReady_BM_State1(wrdy_y_i1)
, .oData_BM_State1(wdata_y_i1)
, .iValid_AS_Weight(wvld_wh0)
, .oReady_AS_Weight(wrdy_wh0)
, .iData_AS_Weight(wdata_wh0)
, .iValid_AS_Delta0(wvld_dh0)
, .oReady_AS_Delta0(wrdy_dh0)
, .iData_AS_Delta0(wdata_dh0)
, .iRST(iRST)
, .iCLK(iCLK)
);

HiddenLayer #
( .NP(NI)
, .NC(NH0)
, .NN(NH1)
, .WF(WF)
, .BURST(BURST)
, .INIT_FILE(INIT_FILE_H0)
) hl0
( .iMode(iMode)
, .iLR(iLR)
, .iValid_AM_State0(wvld_y_i0)
, .oReady_AM_State0(wrdy_y_i0)
, .iData_AM_State0(wdata_y_i0)
, .iValid_AS_State1(wvld_y_i1)
, .oReady_AS_State1(wrdy_y_i1)
, .iData_AS_State1(wdata_y_i1)
, .oValid_BM_State0(wvld_y_h00)
, .iReady_BM_State0(wrdy_y_h00)
, .oData_BM_State0(wdata_y_h00)
, .oValid_BM_State1(wvld_y_h01)
, .iReady_BM_State1(wrdy_y_h01)
, .oData_BM_State1(wdata_y_h01)
, .iValid_AM_Weight(wvld_wh1)
, .oReady_AM_Weight(wrdy_wh1)
, .iData_AM_Weight(wdata_wh1)
, .oValid_BM_Weight(wvld_wh0)
, .iReady_BM_Weight(wrdy_wh0)
, .oData_BM_Weight(wdata_wh0)
, .iValid_AM_Delta0(wvld_dh1)
, .oReady_AM_Delta0(wrdy_dh1)
, .iData_AM_Delta0(wdata_dh1)
, .oValid_BM_Delta0(wvld_dh0)
, .iReady_BM_Delta0(wrdy_dh0)
, .oData_BM_Delta0(wdata_dh0)
, .iRST(iRST)
, .iCLK(iCLK)
);

HiddenLayer #
( .NP(NH0)
, .NC(NH1)
, .NN(NO)
, .WF(WF)
, .BURST(BURST)
, .INIT_FILE(INIT_FILE_H1)
) hl1
( .iMode(iMode)
, .iLR(iLR)
, .iValid_AM_State0(wvld_y_h00)
, .oReady_AM_State0(wrdy_y_h00)
, .iData_AM_State0(wdata_y_h00)
, .iValid_AS_State1(wvld_y_h01)
, .oReady_AS_State1(wrdy_y_h01)
, .iData_AS_State1(wdata_y_h01)
, .oValid_BM_State0(wvld_y_h10)
, .iReady_BM_State0(wrdy_y_h10)
, .oData_BM_State0(wdata_y_h10)
, .oValid_BM_State1(wvld_y_h11)
, .iReady_BM_State1(wrdy_y_h11)
, .oData_BM_State1(wdata_y_h11)
, .iValid_AM_Weight(wvld_wo)
, .oReady_AM_Weight(wrdy_wo)
, .iData_AM_Weight(wdata_wo)
, .oValid_BM_Weight(wvld_wh1)
, .iReady_BM_Weight(wrdy_wh1)
, .oData_BM_Weight(wdata_wh1)
, .iValid_AM_Delta0(wvld_do)
, .oReady_AM_Delta0(wrdy_do)
, .iData_AM_Delta0(wdata_do)
, .oValid_BM_Delta0(wvld_dh1)
, .iReady_BM_Delta0(wrdy_dh1)
, .oData_BM_Delta0(wdata_dh1)
, .iRST(iRST)
, .iCLK(iCLK)
);

OutputLayer #
( .NP(NH1)
, .NC(NO)
, .WF(WF)
, .BURST(BURST)
, .INIT_FILE(INIT_FILE_O)
) ol
( .iMode(iMode)
, .iLR(iLR)
, .iValid_AM_State0(wvld_y_h10)
, .oReady_AM_State0(wrdy_y_h10)
, .iData_AM_State0(wdata_y_h10)
, .iValid_AS_State1(wvld_y_h11)
, .oReady_AS_State1(wrdy_y_h11)
, .iData_AS_State1(wdata_y_h11)
, .oValid_BM_Output(oValid_BM_Output)
, .iReady_BM_Output(iReady_BM_Output)
, .oData_BM_Output(oData_BM_Output)
, .oValid_BM_Weight(wvld_wo)
, .iReady_BM_Weight(wrdy_wo)
, .oData_BM_Weight(wdata_wo)
, .oValid_BM_Delta0(wvld_do)
, .iReady_BM_Delta0(wrdy_do)
, .oData_BM_Delta0(wdata_do)
, .iValid_AS_Teacher(iValid_AS_Teacher)
, .oReady_AS_Teacher(oReady_AS_Teacher)
, .iData_AS_Teacher(iData_AS_Teacher)
, .iRST(iRST)
, .iCLK(iCLK)
);

endmodule
