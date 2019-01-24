`timescale 1ns / 1ps

module NeuronTest;

parameter HIDDEN = "yes";
parameter NP     = 4;
parameter NC     = 8;
parameter WD     = 4;

reg                                                 iValid_AS;
wire                                                oReady_AS;
reg                      [NC*($clog2(NP)+1+WD)-1:0] iData_AS;
wire                                                oValid_BS;
reg                                                 iReady_BS;
wire [NC*((HIDDEN=="yes")?WD:$clog2(NP)+1+WD)-1:0] oData_BS;
reg                                                 iRST;
reg                                                 iCLK;

Neuron #
( .HIDDEN   (HIDDEN)
, .NP       (NP)
, .NC       (NC)
, .WD       (WD)
) neuron
( .iValid_AS(iValid_AS)
, .oReady_AS(oReady_AS)
, .iData_AS (iData_AS)
, .oValid_BS(oValid_BS)
, .iReady_BS(iReady_BS)
, .oData_BS (oData_BS)
, .iRST     (iRST)
, .iCLK     (iCLK)
);

parameter PERIOD = 2;
always #(PERIOD/2) iCLK = ~iCLK;

integer i;

initial begin
#0
    iCLK        = 0;
    iRST        = 0;
    iValid_AS   = 0;
    iReady_BS   = 0;
#(PERIOD)
    iRST        = 1;
#(PERIOD)
    iRST        = 0;
#(PERIOD * 5)
    iValid_AS   = 1;
    iReady_BS   = 1;
    for (i = 0; i < NC; i = i + 1)
        iData_AS[i*($clog2(NP)+1+WD) +: ($clog2(NP)+1+WD)] = -7 + 3*i;
#(PERIOD * 10)
    iValid_AS   = 0;
#(PERIOD)
    iReady_BS   = 0;
#(PERIOD * 10)
    $finish;
end

endmodule