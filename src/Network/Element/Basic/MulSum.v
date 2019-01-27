module MulSum #
( parameter WIDTH0 = 7
, parameter WIDTH1 = 3
, parameter SIZE   = 5
, parameter BURST  = "yes"
)
( input                          [SIZE-1:0] iValid_AS0
, output                         [SIZE-1:0] oReady_AS0
, input                   [SIZE*WIDTH0-1:0] iData_AS0
, input                          [SIZE-1:0] iValid_AS1
, output                         [SIZE-1:0] oReady_AS1
, input                   [SIZE*WIDTH1-1:0] iData_AS1
, output                                    oValid_BM
, input                                     iReady_BM
, output [$clog2(SIZE)-1+WIDTH1+WIDTH0-1:0] oData_BM
, input                                     iRST
, input                                     iCLK
);

genvar gi;

wire                   [SIZE-1:0] wvld_a;
wire                   [SIZE-1:0] wrdy_a;
wire            [SIZE*WIDTH0-1:0] wdata_a0;
wire            [SIZE*WIDTH1-1:0] wdata_a1;
wire [SIZE*(WIDTH1+WIDTH0-1)-1:0] wdata_a;
wire                   [SIZE-1:0] wvld_b;
wire                   [SIZE-1:0] wrdy_b;
wire [SIZE*(WIDTH1+WIDTH0-1)-1:0] wdata_b;

generate
    for (gi = 0; gi < SIZE; gi = gi + 1) begin
        Combiner #
        ( .WIDTH0(WIDTH0)
        , .WIDTH1(WIDTH1)
        ) combiner
        ( .iValid_AS0(iValid_AS0[gi])
        , .oReady_AS0(oReady_AS0[gi])
        , .iData_AS0(iData_AS0[gi*WIDTH0+:WIDTH0])
        , .iValid_AS1(iValid_AS1[gi])
        , .oReady_AS1(oReady_AS1[gi])
        , .iData_AS1(iData_AS1[gi*WIDTH1+:WIDTH1])
        , .oValid_BM(wvld_a[gi])
        , .iReady_BM(wrdy_a[gi])
        , .oData_BM({wdata_a1[gi*WIDTH1+:WIDTH1], wdata_a0[gi*WIDTH0+:WIDTH0]})
        );

        assign wdata_a[gi*(WIDTH1+WIDTH0-1)+:WIDTH1+WIDTH0-1]
            = $signed(wdata_a1[gi*WIDTH1+:WIDTH1])
            * $signed(wdata_a0[gi*WIDTH0+:WIDTH0]);

        Register #
        ( .WIDTH(WIDTH1+WIDTH0-1)
        , .BURST(BURST)
        ) register
        ( .iValid_AM(wvld_a[gi])
        , .oReady_AM(wrdy_a[gi])
        , .iData_AM(wdata_a[gi*(WIDTH1+WIDTH0-1)+:WIDTH1+WIDTH0-1])
        , .oValid_BM(wvld_b[gi])
        , .iReady_BM(wrdy_b[gi])
        , .oData_BM(wdata_b[gi*(WIDTH1+WIDTH0-1)+:WIDTH1+WIDTH0-1])
        , .iRST(iRST)
        , .iCLK(iCLK)
        );
    end
endgenerate

Sum #
( .WIDTH(WIDTH1+WIDTH0-1)
, .SIZE(SIZE)
, .BURST(BURST)
) sum
( .iValid_AS(wvld_b)
, .oReady_AS(wrdy_b)
, .iData_AS(wdata_b)
, .oValid_BM(oValid_BM)
, .iReady_BM(iReady_BM)
, .oData_BM(oData_BM)
, .iRST(iRST)
, .iCLK(iCLK)
);

endmodule
