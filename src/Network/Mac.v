module Mac #
( parameter SIZE_A = 32
, parameter SIZE_B = 32
, parameter WIDTH  = 4
, parameter BURST  = "yes"
)
( input                                        iValid_AM_W
, output                                       oReady_AM_W
, input              [SIZE_B*SIZE_A*WIDTH-1:0] iData_AM_W
, input                                        iValid_AM_S
, output                                       oReady_AM_S
, input                     [SIZE_A*WIDTH-1:0] iData_AM_S
, output                          [SIZE_B-1:0] oValid_BM_WS
, input                           [SIZE_B-1:0] iReady_BM_WS
, output [SIZE_B*($clog2(SIZE_A)-1+WIDTH)-1:0] oData_BM_WS
, input                                        iRST
, input                                        iCLK
);

genvar gi, gj;

wire                   [SIZE_B*SIZE_A-1:0] wvld_wn;
wire                   [SIZE_B*SIZE_A-1:0] wrdy_wn;
wire             [SIZE_B*SIZE_A*WIDTH-1:0] wdata_wn;
wire                   [SIZE_B*SIZE_A-1:0] wvld_sn;
wire                   [SIZE_B*SIZE_A-1:0] wrdy_sn;
wire             [SIZE_B*SIZE_A*WIDTH-1:0] wdata_sn;
wire                          [SIZE_B-1:0] wvld_wsn;
wire                          [SIZE_B-1:0] wrdy_wsn;
wire [SIZE_B*($clog2(SIZE_A)-1+WIDTH)-1:0] wdata_wsn;

BroadcasterN #
( .SIZE(SIZE_B*SIZE_A)
, .WIDTH(WIDTH)
, .BURST(BURST)
) broadcasterNW
( .iValid_AM(iValid_AM_W)
, .oReady_AM(oReady_AM_W)
, .iData_AM(iData_AM_W)
, .oValid_BM(wvld_wn)
, .iReady_BM(wrdy_wn)
, .oData_BM(wdata_wn)
, .iRST(iRST)
, .iCLK(iCLK)
);

BroadcasterN #
( .SIZE(SIZE_B*SIZE_A)
, .WIDTH(WIDTH)
, .BURST(BURST)
) broadcasterNS
( .iValid_AM(iValid_AM_S)
, .oReady_AM(oReady_AM_S)
, .iData_AM({SIZE_B{iData_AM_S}})
, .oValid_BM(wvld_sn)
, .iReady_BM(wrdy_sn)
, .oData_BM(wdata_sn)
, .iRST(iRST)
, .iCLK(iCLK)
);

generate
    for (gi = 0; gi < SIZE_B; gi = gi + 1) begin
        wire [$clog2(SIZE_A)-1+WIDTH+WIDTH-1:0] wdata_ws;

        MulSum #
        ( .WIDTH0(WIDTH)
        , .WIDTH1(WIDTH)
        , .SIZE(SIZE_A)
        , .BURST(BURST)
        ) mulSum
        ( .iValid_AS0(wvld_wn[gi*SIZE_A+:SIZE_A])
        , .oReady_AS0(wrdy_wn[gi*SIZE_A+:SIZE_A])
        , .iData_AS0(wdata_wn[gi*SIZE_A*WIDTH+:SIZE_A*WIDTH])
        , .iValid_AS1(wvld_sn[gi*SIZE_A+:SIZE_A])
        , .oReady_AS1(wrdy_sn[gi*SIZE_A+:SIZE_A])
        , .iData_AS1(wdata_sn[gi*SIZE_A*WIDTH+:SIZE_A*WIDTH])
        , .oValid_BM(oValid_BM_WS[gi])
        , .iReady_BM(iReady_BM_WS[gi])
        , .oData_BM(wdata_ws)
        , .iRST(iRST)
        , .iCLK(iCLK)
        );

        assign oData_BM_WS[gi*($clog2(SIZE_A)-1+WIDTH)+:$clog2(SIZE_A)-1+WIDTH]
            = wdata_ws[WIDTH+:$clog2(SIZE_A)-1+WIDTH];
    end
endgenerate

endmodule
