`include "Parameter.vh"

module ForwardMaccum #
( parameter NP    = 7
, parameter NC    = 11
, parameter WF    = 5
, parameter BURST = "yes"
)
( input                             iMode
, input                             iValid_AM_WeightBias
, output                            oReady_AM_WeightBias
, input        [NC*NP*WF+NC*WF-1:0] iData_AM_WeightBias
, input                             iValid_AM_State0
, output                            oReady_AM_State0
, input                 [NP*WF-1:0] iData_AM_State0
, output                            oValid_BM_Accum0
, input                             iReady_BM_Accum0
, output   [NC*($clog2(NP)+1+WF)-1:0] oData_BM_Accum0
, output                            oValid_BM_Accum1
, input                             iReady_BM_Accum1
, output [NC*($clog2(NP)+1+WF)-1:0] oData_BM_Accum1
, input                             iRST
, input                             iCLK
);

`DECLARE_MODE_PARAMETERS

genvar gi;

wire                            wvld_b;
wire                            wrdy_b;
wire                [NC*WF-1:0] wdata_b;
wire                   [NC-1:0] wvld_bn;
wire                   [NC-1:0] wrdy_bn;
wire                [NC*WF-1:0] wdata_bn;
wire                            wvld_w;
wire                            wrdy_w;
wire             [NC*NP*WF-1:0] wdata_w;
wire                   [NC-1:0] wvld_ws;
wire                   [NC-1:0] wrdy_ws;
  wire [NC*($clog2(NP)+WF)-1:0] wdata_ws;
wire                   [NC-1:0] wvld_accn;
wire                   [NC-1:0] wrdy_accn;
wire [NC*($clog2(NP)+1+WF)-1:0] wdata_accn;
wire                            wvld_acc;
wire                            wrdy_acc;
wire [NC*($clog2(NP)+1+WF)-1:0] wdata_acc;
wire                            wvld_bc1;
wire                            wrdy_bc1;

Broadcaster #
( .WIDTH0(NC*WF)
, .WIDTH1(NC*NP*WF)
, .BURST(BURST)
) broadcaster0
( .iValid_AM(iValid_AM_WeightBias)
, .oReady_AM(oReady_AM_WeightBias)
, .iData_AM(iData_AM_WeightBias)
, .oValid_BM0(wvld_b)
, .iReady_BM0(wrdy_b)
, .oData_BM0(wdata_b)
, .oValid_BM1(wvld_w)
, .iReady_BM1(wrdy_w)
, .oData_BM1(wdata_w)
, .iRST(iRST)
, .iCLK(iCLK)
);

BroadcasterN #
( .SIZE(NC)
, .WIDTH(WF)
, .BURST(BURST)
) broadcasterNB
( .iValid_AM(wvld_b)
, .oReady_AM(wrdy_b)
, .iData_AM(wdata_b)
, .oValid_BM(wvld_bn)
, .iReady_BM(wrdy_bn)
, .oData_BM(wdata_bn)
, .iRST(iRST)
, .iCLK(iCLK)
);

Maccum #
( .SIZE_A(NP)
, .SIZE_B(NC)
, .WIDTH(WF)
, .BURST(BURST)
) maccum
( .iValid_AM_W(wvld_w)
, .oReady_AM_W(wrdy_w)
, .iData_AM_W(wdata_w)
, .iValid_AM_S(iValid_AM_State0)
, .oReady_AM_S(oReady_AM_State0)
, .iData_AM_S(iData_AM_State0)
, .oValid_BM_WS(wvld_ws)
, .iReady_BM_WS(wrdy_ws)
, .oData_BM_WS(wdata_ws)
, .iRST(iRST)
, .iCLK(iCLK)
);

generate
    for (gi = 0; gi < NC; gi = gi + 1) begin
        wire                        wvld_wsbn;
        wire                        wrdy_wsbn;
        wire [WF+$clog2(NP)+WF-1:0] wdata_wsbn_a;
        wire  [$clog2(NP)+1+WF-1:0] wdata_wsbn_b;

        Combiner #
        ( .WIDTH0($clog2(NP)+WF)
        , .WIDTH1(WF)
        ) combiner
        ( .iValid_AS0(wvld_ws[gi])
        , .oReady_AS0(wrdy_ws[gi])
        , .iData_AS0(wdata_ws[gi*($clog2(NP)+WF)+:$clog2(NP)+WF])
        , .iValid_AS1(wvld_bn[gi])
        , .oReady_AS1(wrdy_bn[gi])
        , .iData_AS1(wdata_bn[gi*WF+:WF])
        , .oValid_BM(wvld_wsbn)
        , .iReady_BM(wrdy_wsbn)
        , .oData_BM(wdata_wsbn_a)
        );

        assign wdata_wsbn_b
            = $signed(wdata_wsbn_a[$clog2(NP)+WF+:WF])
            + $signed(wdata_wsbn_a[0+:$clog2(NP)+WF]);

        Register #
        ( .WIDTH($clog2(NP)+1+WF)
        , .BURST(BURST)
        ) register
        ( .iValid_AM(wvld_wsbn)
        , .oReady_AM(wrdy_wsbn)
        , .iData_AM(wdata_wsbn_b)
        , .oValid_BM(wvld_accn[gi])
        , .iReady_BM(wrdy_accn[gi])
        , .oData_BM(wdata_accn[gi*($clog2(NP)+1+WF)+:$clog2(NP)+1+WF])
        , .iRST(iRST)
        , .iCLK(iCLK)
        );
    end
endgenerate

CombinerN #
( .SIZE(NC)
, .WIDTH($clog2(NP)+1+WF)
) combinerNA
( .iValid_AS(wvld_accn)
, .oReady_AS(wrdy_accn)
, .iData_AS(wdata_accn)
, .oValid_BM(wvld_acc)
, .iReady_BM(wrdy_acc)
, .oData_BM(wdata_acc)
);

assign {wrdy_bc1, oValid_BM_Accum1} =
    (iMode == TRAIN) ? {iReady_BM_Accum1, wvld_bc1} :
    (iMode == TEST ) ? {wvld_bc1        , 1'b0    } : 2'bxx;

Broadcaster #
( .WIDTH0(NC*($clog2(NP)+1+WF))
, .WIDTH1(NC*($clog2(NP)+1+WF))
, .BURST(BURST)
) broadcaster1
( .iValid_AM(wvld_acc)
, .oReady_AM(wrdy_acc)
, .iData_AM({wdata_acc, wdata_acc})
, .oValid_BM0(oValid_BM_Accum0)
, .iReady_BM0(iReady_BM_Accum0)
, .oData_BM0(oData_BM_Accum0)
, .oValid_BM1(wvld_bc1)
, .iReady_BM1(wrdy_bc1)
, .oData_BM1(oData_BM_Accum1)
, .iRST(iRST)
, .iCLK(iCLK)
);

endmodule
