module Broadcaster #
( parameter WIDTH0 = 32
, parameter WIDTH1 = 32
, parameter BURST  = "yes"
)
( input                      iValid_AM
, output                     oReady_AM
, input  [WIDTH1+WIDTH0-1:0] iData_AM
, output                     oValid_BM0
, input                      iReady_BM0
, output        [WIDTH0-1:0] oData_BM0
, output                     oValid_BM1
, input                      iReady_BM1
, output        [WIDTH1-1:0] oData_BM1
, input                      iRST
, input                      iCLK
);

wire              wvld;
wire              wrdy;
wire              wrdy0;
wire              wrdy1;
wire [WIDTH0-1:0] wdata0;
wire [WIDTH1-1:0] wdata1;

assign oReady_AM        = wrdy;
assign {wdata1, wdata0} = iData_AM;

//Valid
assign wvld = iValid_AM && wrdy;

//Ready
assign wrdy = wrdy0 && wrdy1;

//Register
Register #
( .WIDTH(WIDTH0) , .BURST(BURST)
) rg0
( .iValid_AM(wvld)       , .oReady_AM(wrdy0)      , .iData_AM(wdata0)
, .oValid_BM(oValid_BM0) , .iReady_BM(iReady_BM0) , .oData_BM(oData_BM0)
, .iRST(iRST)            , .iCLK(iCLK)
);

Register #
( .WIDTH(WIDTH1) , .BURST(BURST)
) rg1
( .iValid_AM(wvld)       , .oReady_AM(wrdy1)      , .iData_AM(wdata1)
, .oValid_BM(oValid_BM1) , .iReady_BM(iReady_BM1) , .oData_BM(oData_BM1)
, .iRST(iRST)            , .iCLK(iCLK)
);

endmodule
