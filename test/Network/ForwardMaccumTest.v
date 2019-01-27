`include "Test.vh"

module ForwardMaccumTest #
( parameter NP    = 3
, parameter NC    = 2
, parameter WF    = 8
, parameter BURST = "yes"
);

genvar gi, gj;
integer i, j;

ClockDomain c();

reg                           iValid_AM_WeightBias;
wire                          oReady_AM_WeightBias;
reg      [NP*NC*WF+NC*WF-1:0] iData_AM_WeightBias;
reg                           iValid_AM_State0;
wire                          oReady_AM_State0;
reg               [NP*WF-1:0] iData_AM_State0;
wire                          oValid_BM_Accum0;
reg                           iReady_BM_Accum0;
wire [NC*($clog2(NP)+WF)-1:0] oData_BM_Accum0;
wire                          oValid_BM_Accum1;
reg                           iReady_BM_Accum1;
wire [NC*($clog2(NP)+WF)-1:0] oData_BM_Accum1;

wire              [WF-1:0] wweit[0:NP*NC-1];
wire              [WF-1:0] wstat[0:NP-1];
wire              [WF-1:0] wbias[0:NC-1];
wire [$clog2(NP)-1+WF-1:0] wws[0:NC-1];
wire              [WF-1:0] wb[0:NC-1];
wire   [$clog2(NP)+WF-1:0] wwsb[0:NC-1];
wire   [$clog2(NP)+WF-1:0] wacm [0:NC-1];

ForwardMaccum #
( .NP(NP)
, .NC(NC)
, .WF(WF)
, .BURST(BURST)
) fm
( .iValid_AM_WeightBias(iValid_AM_WeightBias)
, .oReady_AM_WeightBias(oReady_AM_WeightBias)
, .iData_AM_WeightBias(iData_AM_WeightBias)
, .iValid_AM_State0(iValid_AM_State0)
, .oReady_AM_State0(oReady_AM_State0)
, .iData_AM_State0(iData_AM_State0)
, .oValid_BM_Accum0(oValid_BM_Accum0)
, .iReady_BM_Accum0(iReady_BM_Accum0)
, .oData_BM_Accum0(oData_BM_Accum0)
, .oValid_BM_Accum1(oValid_BM_Accum1)
, .iReady_BM_Accum1(iReady_BM_Accum1)
, .oData_BM_Accum1(oData_BM_Accum1)
, .iRST(c.RST)
, .iCLK(c.CLK)
);

generate
    for (gi = 0; gi < NP; gi = gi + 1)
        for (gj = 0; gj < NC; gj = gj + 1)
            assign wweit[gi*NC+gj]
                = fm.iData_AM_WeightBias[(gi*NC+gj)*WF+NC*WF+:WF];

    for (gi = 0; gi < NC; gi = gi + 1)
        assign wbias[gi] = fm.iData_AM_WeightBias[gi*WF+:WF];

    for (gi = 0; gi < NP; gi = gi + 1)
        assign wstat[gi] = fm.iData_AM_State0[gi*WF+:WF];

    for (gi = 0; gi < NC; gi = gi + 1) begin
        assign wws[gi]  = fm.genblk1[gi].wdata_wsbn_a[0+:$clog2(NP)-1+WF];
        assign wb[gi]   = fm.genblk1[gi].wdata_wsbn_a[$clog2(NP)-1+WF+:WF];
        assign wwsb[gi] = fm.genblk1[gi].wdata_wsbn_b;
    end

    for (gi = 0; gi < NC; gi = gi + 1)
        assign wacm[gi] = fm.oData_BM_Accum0[gi*($clog2(NP)+WF)+:$clog2(NP)+WF];
endgenerate

`DUMP_ALL("fm.vcd")
`SET_LIMIT(c, 100)

initial begin
    @(c.eCLK) begin
        iValid_AM_WeightBias = 1'b0;
        iData_AM_WeightBias  =
            { 8'd0, 8'd0, 8'd0
            , 8'd0, 8'd0, 8'd0
            , 8'd0, 8'd0
            };
    end

    //Case0
    `WAIT_UNTIL(c, oReady_AM_WeightBias === 1'b1)

    @(c.eCLK) begin
        iValid_AM_WeightBias = 1'b1;
        iData_AM_WeightBias  =
            { 8'd32, 8'd22, 8'd12
            , 8'd31, 8'd21, 8'd11
            , 8'd22, 8'd11
            };
    end

    @(c.eCLK) begin
        iValid_AM_WeightBias = 1'b0;
        iData_AM_WeightBias  =
            { 8'd0, 8'd0, 8'd0
            , 8'd0, 8'd0, 8'd0
            , 8'd0, 8'd0
            };
    end

    //Case1
    `WAIT_UNTIL(c, oReady_AM_WeightBias === 1'b1)

    @(c.eCLK) begin
        iValid_AM_WeightBias = 1'b1;
        iData_AM_WeightBias  =
            { 8'd5, 8'd4, 8'd3
            , 8'd2, 8'd1, 8'd0
            , 8'd7, 8'd6
            };
    end

    @(c.eCLK) begin
        iValid_AM_WeightBias = 1'b0;
        iData_AM_WeightBias  =
            { 8'd0, 8'd0, 8'd0
            , 8'd0, 8'd0, 8'd0
            , 8'd0, 8'd0
            };
    end

    //Case2
    `WAIT_UNTIL(c, oReady_AM_WeightBias === 1'b1)

    @(c.eCLK) begin
        iValid_AM_WeightBias = 1'b1;
        iData_AM_WeightBias  =
            {  8'd43, -8'd15,  8'd92
            , -8'd12,  8'd76, -8'd19
            , -8'd7 ,  8'd25
            };
    end

    @(c.eCLK) begin
        iValid_AM_WeightBias = 1'b0;
        iData_AM_WeightBias  =
            { 8'd0, 8'd0, 8'd0
            , 8'd0, 8'd0, 8'd0
            , 8'd0, 8'd0
            };
    end
end

initial begin
    @(c.eCLK) begin
        iValid_AM_State0 = 1'b0;
        iData_AM_State0  = {8'd0, 8'd0, 8'd0};
    end

    //Case0
    `WAIT_UNTIL(c, oReady_AM_State0 === 1'b1)

    @(c.eCLK) begin
        iValid_AM_State0 = 1'b1;
        iData_AM_State0  = {8'd103, 8'd102, 8'd101};
    end

    @(c.eCLK) begin
        iValid_AM_State0 = 1'b0;
        iData_AM_State0  = {8'd0, 8'd0, 8'd0};
    end

    //Case1
    `WAIT_UNTIL(c, oReady_AM_State0 === 1'b1)

    @(c.eCLK) begin
        iValid_AM_State0 = 1'b1;
        iData_AM_State0  = {8'd1, 8'd1, 8'd1};
    end

    @(c.eCLK) begin
        iValid_AM_State0 = 1'b0;
        iData_AM_State0  = {8'd0, 8'd0, 8'd0};
    end

    //Case2
    `WAIT_UNTIL(c, oReady_AM_State0 === 1'b1)

    @(c.eCLK) begin
        iValid_AM_State0 = 1'b1;
        iData_AM_State0  = {-8'd11, 8'd12, 8'd45};
    end

    @(c.eCLK) begin
        iValid_AM_State0 = 1'b0;
        iData_AM_State0  = {8'd0, 8'd0, 8'd0};
    end
end

initial begin
    @(c.eCLK) iReady_BM_Accum0 = 1'b0;

    for (i = 0; i < 3; i = i + 1) begin
        `WAIT_UNTIL(c, oValid_BM_Accum0 === 1'b1)

        @(c.eCLK) iReady_BM_Accum0 = 1'b1;
        @(c.eCLK) iReady_BM_Accum0 = 1'b0;
    end

        @(c.eCLK) $finish;
end

initial begin
    @(c.eCLK) iReady_BM_Accum1 = 1'b0;

    for (j = 0; j < 3; j = j + 1) begin
        `WAIT_UNTIL(c, oValid_BM_Accum1 === 1'b1)

        @(c.eCLK) iReady_BM_Accum1 = 1'b1;
        @(c.eCLK) iReady_BM_Accum1 = 1'b0;
    end

        @(c.eCLK) $finish;
end

endmodule
