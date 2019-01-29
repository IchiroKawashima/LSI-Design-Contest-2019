`timescale 1ns / 1ps

module NeuronTest;

parameter HIDDEN = "yes";
parameter NP     = 4;
parameter NC     = 8;
parameter WV     = 4;

localparam WN = (HIDDEN == "yes") ? WV : $clog2(NP) + WV;

reg                          iMode;
reg                          iValid_AM_Accum0;
wire                         oReady_AM_Accum0;
reg  [NC*($clog2(NP)+WV)-1:0] iData_AM_Accum0;
wire                         oValid_BM_State0;
reg                          iReady_BM_State0;
wire             [NC*WN-1:0] oData_BM_State0;
wire                         oValid_BM_State1;
reg                          iReady_BM_State1;
wire             [NC*WN-1:0] oData_BM_State1;
reg                          iRST;
reg                          iCLK;

Neuron #
( .HIDDEN   (HIDDEN)
, .NP       (NP)
, .NC       (NC)
, .WV       (WV)
) neuron
( .iMode           (iMode)
, .iValid_AM_Accum0(iValid_AM_Accum0)
, .oReady_AM_Accum0(oReady_AM_Accum0)
, .iData_AM_Accum0 (iData_AM_Accum0)
, .oValid_BM_State0(oValid_BM_State0)
, .iReady_BM_State0(iReady_BM_State0)
, .oData_BM_State0 (oData_BM_State0)
, .oValid_BM_State1(oValid_BM_State1)
, .iReady_BM_State1(iReady_BM_State1)
, .oData_BM_State1 (oData_BM_State1)
, .iRST            (iRST)
, .iCLK            (iCLK)
);

parameter PERIOD = 2;
always #(PERIOD/2) iCLK = ~iCLK;

integer i;

initial begin
#0
    iMode       = 0;
    iCLK        = 0;
    iRST        = 0;
    iValid_AM_Accum0   = 0;
    iReady_BM_State0   = 0;
    iReady_BM_State1   = 0;
#(PERIOD)
    iRST        = 1;
#(PERIOD)
    iRST        = 0;
#(PERIOD * 5)
    iValid_AM_Accum0   = 1;
    iReady_BM_State0   = 1;
    iReady_BM_State1   = 1;
    for (i = 0; i < NC; i = i + 1)
        iData_AM_Accum0[i*($clog2(NP)+WV) +: ($clog2(NP)+WV)] = -7 + 3*i;
#(PERIOD * 10)
    iValid_AM_Accum0   = 0;
#(PERIOD)
    iReady_BM_State0   = 0;
    iReady_BM_State1   = 0;
#(PERIOD * 10)
    $finish;
end

endmodule
