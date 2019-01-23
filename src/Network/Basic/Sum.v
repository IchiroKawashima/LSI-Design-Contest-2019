module Sum #
( parameter WIDTH = 8
, parameter SIZE  = 5
, parameter BURST = "yes"
)
( input                [SIZE-1:0] iValid_AS
, output               [SIZE-1:0] oReady_AS
, input          [SIZE*WIDTH-1:0] iData_AS
, output                          oValid_BM
, input                           iReady_BM
, output [$clog2(SIZE)+WIDTH-1:0] oData_BM
, input                           iRST
, input                           iCLK
);

generate
    if (SIZE == 1) begin
        assign oValid_BM = iValid_AS;
        assign oReady_AS = iReady_BM;
        assign oData_BM  = iData_AS;

    end else begin
        localparam SIZE_L0 = SIZE - (SIZE >> 1);
        localparam SIZE_L1 = SIZE - SIZE_L0;

        wire                                                   wvld0;
        wire                                                   wvld1;
        wire                                                   wrdy0;
        wire                                                   wrdy1;
        wire                       [$clog2(SIZE_L0)+WIDTH-1:0] wdata0;
        wire                       [$clog2(SIZE_L1)+WIDTH-1:0] wdata1;
        wire [$clog2(SIZE_L1)+WIDTH+$clog2(SIZE_L0)+WIDTH-1:0] wdata01;
        wire                                                   wvld;
        wire                                                   wrdy;
        wire                          [$clog2(SIZE)+WIDTH-1:0] wdata;

        Sum #
        ( .WIDTH(WIDTH)
        , .SIZE(SIZE_L0)
        , .BURST(BURST)
        )
        sum0
        ( .iValid_AS(iValid_AS[SIZE_L0-1:0])
        , .oReady_AS(oReady_AS[SIZE_L0-1:0])
        , .iData_AS(iData_AS[SIZE_L0*WIDTH-1:0])
        , .oValid_BM(wvld0)
        , .iReady_BM(wrdy0)
        , .oData_BM(wdata0)
        , .iRST(iRST)
        , .iCLK(iCLK)
        );

        Sum #
        ( .WIDTH(WIDTH)
        , .SIZE(SIZE_L1)
        , .BURST(BURST)
        )
        sum1
        ( .iValid_AS(iValid_AS[SIZE-1:SIZE_L0])
        , .oReady_AS(oReady_AS[SIZE-1:SIZE_L0])
        , .iData_AS(iData_AS[SIZE*WIDTH-1:SIZE_L0*WIDTH])
        , .oValid_BM(wvld1)
        , .iReady_BM(wrdy1)
        , .oData_BM(wdata1)
        , .iRST(iRST)
        , .iCLK(iCLK)
        );

        Combiner #
        ( .WIDTH0($clog2(SIZE_L0)+WIDTH)
        , .WIDTH1($clog2(SIZE_L1)+WIDTH)
        ) combiner
        ( .iValid_AS0(wvld0)
        , .oReady_AS0(wrdy0)
        , .iData_AS0(wdata0)
        , .iValid_AS1(wvld1)
        , .oReady_AS1(wrdy1)
        , .iData_AS1(wdata1)
        , .oValid_BM(wvld)
        , .iReady_BM(wrdy)
        , .oData_BM(wdata01)
        );

        assign wdata
            = $signed(wdata01[$clog2(SIZE_L0)+WIDTH+:$clog2(SIZE_L1)+WIDTH])
            + $signed(wdata01[0+:$clog2(SIZE_L0)+WIDTH]);

        Register #
        ( .WIDTH($clog2(SIZE)+WIDTH)
        , .BURST(BURST)
        ) register
        ( .iValid_AM(wvld)
        , .oReady_AM(wrdy)
        , .iData_AM(wdata)
        , .oValid_BM(oValid_BM)
        , .iReady_BM(iReady_BM)
        , .oData_BM(oData_BM)
        , .iRST(iRST)
        , .iCLK(iCLK)
        );
    end
endgenerate

endmodule
