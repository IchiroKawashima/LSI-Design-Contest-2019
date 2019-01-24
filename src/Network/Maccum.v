module Maccum #
( parameter NP    = 4
, parameter NC    = 4
, parameter WF    = 4
, parameter BURST = "yes"
)
( input                           iValid_AM_WeightBias
, output                          oReady_AM_WeightBias
, input      [NC*NP*WF+NC*WF-1:0] iData_AM_WeightBias
, input                           iValid_AM_State0
, output                          oReady_AM_State0
, input               [NP*WF-1:0] iData_AM_State0
, output                          oValid_BM_Accum0
, input                           iReady_BM_Accum0
, output [NC*($clog2(NP)+WF)-1:0] oData_BM_Accum0
, output                          oValid_BM_Accum1
, input                           iReady_BM_Accum1
, output [NC*($clog2(NP)+WF)-1:0] oData_BM_Accum1
, input                           iRST
, input                           iCLK
);

genvar gi, gj;

wire                          wvld_b;
wire                          wrdy_b;
wire              [NC*WF-1:0] wdata_b;
wire                          wvld_w;
wire                          wrdy_w;
wire           [NC*NP*WF-1:0] wdata_w;
wire                 [NC-1:0] wvld_bn;
wire                 [NC-1:0] wrdy_bn;
wire              [NC*WF-1:0] wdata_bn;
wire              [NC*NP-1:0] wvld_wn;
wire              [NC*NP-1:0] wrdy_wn;
wire           [NC*NP*WF-1:0] wdata_wn;
wire              [NC*NP-1:0] wvld_sn;
wire              [NC*NP-1:0] wrdy_sn;
wire           [NC*NP*WF-1:0] wdata_sn;
wire                 [NC-1:0] wvld_accn;
wire                 [NC-1:0] wrdy_accn;
wire [NC*($clog2(NP)+WF)-1:0] wdata_accn;
wire                          wvld_acc;
wire                          wrdy_acc;
wire [NC*($clog2(NP)+WF)-1:0] wdata_acc;

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

BroadcasterN #
( .SIZE(NC*NP)
, .WIDTH(WF)
, .BURST(BURST)
) broadcasterNW
( .iValid_AM(wvld_w)
, .oReady_AM(wrdy_w)
, .iData_AM(wdata_w)
, .oValid_BM(wvld_wn)
, .iReady_BM(wrdy_wn)
, .oData_BM(wdata_wn)
, .iRST(iRST)
, .iCLK(iCLK)
);

BroadcasterN #
( .SIZE(NC*NP)
, .WIDTH(WF)
, .BURST(BURST)
) broadcasterNS
( .iValid_AM(iValid_AM_State0)
, .oReady_AM(oReady_AM_State0)
, .iData_AM({NC{iData_AM_State0}})
, .oValid_BM(wvld_sn)
, .iReady_BM(wrdy_sn)
, .oData_BM(wdata_sn)
, .iRST(iRST)
, .iCLK(iCLK)
);

generate
    for (gi = 0; gi < NC; gi = gi + 1) begin
        wire                          wvld_wsn;
        wire                          wryd_wsn;
        wire [$clog2(NP)-1+WF+WF-1:0] wdata_wsn;
        wire                          wvld_wsbn;
        wire                          wrdy_wsbn;
        wire [WF+$clog2(NP)-1+WF-1:0] wdata_wsbn_a;
        wire      [$clog2(NP)+WF-1:0] wdata_wsbn_b;

        MulSum #
        ( .WIDTH0(WF)
        , .WIDTH1(WF)
        , .SIZE(NP)
        , .BURST(BURST)
        ) mulSum
        ( .iValid_AS0(wvld_wn[gi*NP+:NP])
        , .oReady_AS0(wrdy_wn[gi*NP+:NP])
        , .iData_AS0(wdata_wn[gi*NP*WF+:NP*WF])
        , .iValid_AS1(wvld_sn[gi*NP+:NP])
        , .oReady_AS1(wrdy_sn[gi*NP+:NP])
        , .iData_AS1(wdata_sn[gi*NP*WF+:NP*WF])
        , .oValid_BM(wvld_wsn)
        , .iReady_BM(wryd_wsn)
        , .oData_BM(wdata_wsn)
        , .iRST(iRST)
        , .iCLK(iCLK)
        );

        Combiner #
        ( .WIDTH0($clog2(NP)-1+WF)
        , .WIDTH1(WF)
        ) combiner
        ( .iValid_AS0(wvld_wsn)
        , .oReady_AS0(wryd_wsn)
        , .iData_AS0(wdata_wsn[WF+:$clog2(NP)-1+WF])
        , .iValid_AS1(wvld_bn[gi])
        , .oReady_AS1(wrdy_bn[gi])
        , .iData_AS1(wdata_bn[gi*WF+:WF])
        , .oValid_BM(wvld_wsbn)
        , .iReady_BM(wrdy_wsbn)
        , .oData_BM(wdata_wsbn_a)
        );

        assign wdata_wsbn_b
            = $signed(wdata_wsbn_a[$clog2(NP)-1+WF+:WF])
            + $signed(wdata_wsbn_a[0+:$clog2(NP)-1+WF]);

        Register #
        ( .WIDTH($clog2(NP)+WF)
        , .BURST(BURST)
        ) register
        ( .iValid_AM(wvld_wsbn)
        , .oReady_AM(wrdy_wsbn)
        , .iData_AM(wdata_wsbn_b)
        , .oValid_BM(wvld_accn[gi])
        , .iReady_BM(wrdy_accn[gi])
        , .oData_BM(wdata_accn[gi*($clog2(NP)+WF)+:$clog2(NP)+WF])
        , .iRST(iRST)
        , .iCLK(iCLK)
        );
    end
endgenerate

CombinerN #
( .SIZE(NC)
, .WIDTH($clog2(NP)+WF)
) combinerNA
( .iValid_AS(wvld_accn)
, .oReady_AS(wrdy_accn)
, .iData_AS(wdata_accn)
, .oValid_BM(wvld_acc)
, .iReady_BM(wrdy_acc)
, .oData_BM(wdata_acc)
);

Broadcaster #
( .WIDTH0(NC*($clog2(NP)+WF))
, .WIDTH1(NC*($clog2(NP)+WF))
, .BURST(BURST)
) broadcaster1
( .iValid_AM(wvld_acc)
, .oReady_AM(wrdy_acc)
, .iData_AM({wdata_acc, wdata_acc})
, .oValid_BM0(oValid_BM_Accum0)
, .iReady_BM0(iReady_BM_Accum0)
, .oData_BM0(oData_BM_Accum0)
, .oValid_BM1(oValid_BM_Accum1)
, .iReady_BM1(iReady_BM_Accum1)
, .oData_BM1(oData_BM_Accum1)
, .iRST(iRST)
, .iCLK(iCLK)
);

endmodule
