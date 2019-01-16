module Combiner #
( parameter WIDTH0 = 32
, parameter WIDTH1 = 32
, parameter BURST  = "yes"
)
( input                      iValid_AM0
, output                     oReady_AM0
, input         [WIDTH0-1:0] iData_AM0
, input                      iValid_AM1
, output                     oReady_AM1
, input         [WIDTH1-1:0] iData_AM1
, output                     oValid_BM
, input                      iReady_BM
, output [WIDTH1+WIDTH0-1:0] oData_BM
, input                      iRST
, input                      iCLK
);

wire              wvld;
wire              wvld0;
wire              wvld1;
wire              wrdy;
wire [WIDTH0-1:0] wdata0;
wire [WIDTH1-1:0] wdata1;

assign oValid_BM = wvld;
assign oData_BM  = {wdata0, wdata1};

//Register
Register #
( .WIDTH(WIDTH0) , .BURST(BURST)
) rg0
( .iValid_AM(iValid_AM0) , .oReady_AM(oReady_AM0) , .iData_AM(iData_AM0)
, .oValid_BM(wvld0)      , .iReady_BM(wrdy)       , .oData_BM(wdata0)
, .iRST(iRST)            , .iCLK(iCLK)
);

Register #
( .WIDTH(WIDTH1) , .BURST(BURST)
) rg1
( .iValid_AM(iValid_AM1) , .oReady_AM(oReady_AM1) , .iData_AM(iData_AM1)
, .oValid_BM(wvld1)      , .iReady_BM(wrdy)       , .oData_BM(wdata1)
, .iRST(iRST)            , .iCLK(iCLK)
);

//Valid
assign wvld = wvld0 && wvld1;

//Ready
assign wrdy = iReady_BM && wvld;

endmodule
