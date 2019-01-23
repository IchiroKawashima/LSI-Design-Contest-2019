module BroadcasterN #
( parameter SIZE  = 8
, parameter WIDTH = 32
, parameter BURST = "yes"
)
( input                   iValid_AM
, output                  oReady_AM
, input  [SIZE*WIDTH-1:0] iData_AM
, output       [SIZE-1:0] oValid_BM
, input        [SIZE-1:0] iReady_BM
, output [SIZE*WIDTH-1:0] oData_BM
, input                   iRST
, input                   iCLK
);

genvar gi;

wire                  wvld;
wire                  wrdy;
wire       [SIZE-1:0] wrdy_n;
wire [SIZE*WIDTH-1:0] wdata;

assign oReady_AM = wrdy;
assign wdata     = iData_AM;

//Valid
assign wvld = iValid_AM && wrdy;

//Ready
assign wrdy = &wrdy_n;

generate
    for (gi = 0; gi < SIZE; gi = gi + 1)
        //Register
        Register #
        ( .WIDTH(WIDTH)
        , .BURST(BURST)
        ) rg
        ( .iValid_AM(wvld)
        , .oReady_AM(wrdy_n[gi])
        , .iData_AM(wdata[gi*WIDTH+:WIDTH])
        , .oValid_BM(oValid_BM[gi])
        , .iReady_BM(iReady_BM[gi])
        , .oData_BM(oData_BM[gi*WIDTH+:WIDTH])
        , .iRST(iRST)
        , .iCLK(iCLK)
        );
endgenerate

endmodule
