`include "Parameter.vh"
`include "Test.vh"

module NetworkTest #
( parameter SIZE         = 3
, parameter INPUT_FILE   = "input.mem"
, parameter TEACHER_FILE = ""
, parameter OUTPUT_FILE  = ""
, parameter MODE         = TRAIN
, parameter LR           = {1'b0, 1'b1, {6{1'b0}}}
, parameter NI           = 3
, parameter NH0          = 2
, parameter NH1          = 3
, parameter NO           = 2
, parameter WV           = 8
, parameter SEED_H0      = 0032352685
, parameter SEED_H1      = 1628063272
, parameter SEED_O       = 3496660372
, parameter BURST        = "yes"
);

ClockDomain c();

`DECLARE_MODE_PARAMETERS

genvar gi, gj;

reg  iStart;
wire oEnd;

wire                             wstti;
wire                             wvldi;
wire                             wrdyi;
wire                [NI*WV-1:0] wdatai;
wire                             wsttt;
wire                             wvldt;
wire                             wrdyt;
wire [NO*($clog2(NH1)+1+WV)-1:0] wdatat;
wire                             wendo;
wire                             wvldo;
wire                             wrdyo;
wire [NO*($clog2(NH1)+1+WV)-1:0] wdatao;

assign wstti = iStart;
assign wsttt = iStart;
assign oEnd  = wendo;

//Sources
StreamSource #
( .SIZE(SIZE)
, .WIDTH(NI*WV)
, .INPUT_FILE(INPUT_FILE)
, .BURST(BURST)
) soi
( .iStart(wstti)
, .oValid_BM(wvldi)
, .iReady_BM(wrdyi)
, .oData_BM(wdatai)
, .iRST(c.RST)
, .iCLK(c.CLK)
);

StreamSource #
( .SIZE(SIZE)
, .WIDTH(NO*($clog2(NH1)+1+WV))
, .INPUT_FILE(INPUT_FILE)
, .BURST(BURST)
) sot
( .iStart(wsttt)
, .oValid_BM(wvldt)
, .iReady_BM(wrdyt)
, .oData_BM(wdatat)
, .iRST(c.RST)
, .iCLK(c.CLK)
);

//Network
Network #
( .NI(NI)
, .NH0(NH0)
, .NH1(NH1)
, .NO(NO)
, .WV(WV)
, .BURST(BURST)
, .SEED_H0(SEED_H0)
, .SEED_H1(SEED_H1)
, .SEED_O(SEED_O)
) ne
( .iMode(MODE)
, .iLR(LR)
, .iValid_AM_Input(wvldi)
, .oReady_AM_Input(wrdyi)
, .iData_AM_Input(wdatai)
, .oValid_BM_Output(wvldo)
, .iReady_BM_Output(wrdyo)
, .oData_BM_Output(wdatao)
, .iValid_AS_Teacher(wvldt)
, .oReady_AS_Teacher(wrdyt)
, .iData_AS_Teacher(wdatat)
, .iRST(c.RST)
, .iCLK(c.CLK)
);

//Sink
StreamSink #
( .SIZE(SIZE)
, .WIDTH(NO*($clog2(NH1)+1+WV))
, .OUTPUT_FILE(OUTPUT_FILE)
, .BURST(BURST)
) sio
( .oEnd(wendo)
, .iValid_AM(wvldo)
, .oReady_AM(wrdyo)
, .iData_AM(wdatao)
, .iRST(c.RST)
, .iCLK(c.CLK)
);

//DebugNets
wire                [WV-1:0] wstat_h0[0:NI-1];
wire                [WV-1:0] wweit_h0[0:NI*NH0-1];
wire                [WV-1:0] wbias_h0[0:NH0-1];
wire [($clog2(NI)+1+WV)-1:0] waccm_h0[0:NH0-1];
wire                [WV-1:0] wdelta_h0[0:NH0-1];

wire                 [WV-1:0] wstat_h1[0:NH0-1];
wire                 [WV-1:0] wweit_h1[0:NH0*NH1-1];
wire                 [WV-1:0] wbias_h1[0:NH1-1];
wire [($clog2(NH0)+1+WV)-1:0] waccm_h1[0:NH1-1];
wire                 [WV-1:0] wdelta_h1[0:NH1-1];

wire                 [WV-1:0] wstat_o[0:NH1-1];
wire                 [WV-1:0] wweit_o[0:NH1*NO-1];
wire                 [WV-1:0] wbias_o[0:NO-1];
wire [($clog2(NH1)+1+WV)-1:0] waccm_o[0:NO-1];
wire                 [WV-1:0] wdelta_o[0:NO-1];

wire [$clog2(NH1)+1+WV-1:0] woutput[0:NO-1];
wire [$clog2(NH1)+1+WV-1:0] wteacher[0:NO-1];

generate
    for (gi = 0; gi < NI; gi = gi + 1)
        assign wstat_h0[gi] = ne.hl0.fm.iData_AM_State0[gi*WV+:WV];

    for (gi = 0; gi < NI; gi = gi + 1)
        for (gj = 0; gj < NH0; gj = gj + 1)
            assign wweit_h0[gi*NH0+gj]
                = ne.hl0.fm.iData_AM_WeightBias[(gi*NH0+gj)*WV+NH0*WV+:WV];

    for (gi = 0; gi < NH0; gi = gi + 1)
        assign wbias_h0[gi] = ne.hl0.fm.iData_AM_WeightBias[gi*WV+:WV];

    for (gi = 0; gi < NH0; gi = gi + 1)
        assign waccm_h0[gi] = ne.hl0.fm.oData_BM_Accum0[gi*WV+:WV];

    for (gi = 0; gi < NH0; gi = gi + 1)
        assign wdelta_h0[gi] = ne.hl0.de.oData_BM_Delta0[gi*WV+:WV];

    for (gi = 0; gi < NH0; gi = gi + 1)
        for (gj = 0; gj < NH1; gj = gj + 1)
            assign wweit_h1[gi*NH1+gj]
                = ne.hl1.fm.iData_AM_WeightBias[(gi*NH1+gj)*WV+NH1*WV+:WV];

    for (gi = 0; gi < NH1; gi = gi + 1)
        assign wbias_h1[gi] = ne.hl1.fm.iData_AM_WeightBias[gi*WV+:WV];

    for (gi = 0; gi < NH1; gi = gi + 1)
        assign waccm_h1[gi] = ne.hl1.fm.oData_BM_Accum0[gi*WV+:WV];

    for (gi = 0; gi < NH0; gi = gi + 1)
        assign wstat_h1[gi] = ne.hl1.fm.iData_AM_State0[gi*WV+:WV];

    for (gi = 0; gi < NH1; gi = gi + 1)
        assign wdelta_h1[gi] = ne.hl1.de.oData_BM_Delta0[gi*WV+:WV];

    for (gi = 0; gi < NH1; gi = gi + 1)
        for (gj = 0; gj < NO; gj = gj + 1)
            assign wweit_o[gi*NO+gj]
                = ne.ol.fm.iData_AM_WeightBias[(gi*NO+gj)*WV+NO*WV+:WV];

    for (gi = 0; gi < NO; gi = gi + 1)
        assign wbias_o[gi] = ne.ol.fm.iData_AM_WeightBias[gi*WV+:WV];

    for (gi = 0; gi < NO; gi = gi + 1)
        assign waccm_o[gi] = ne.ol.fm.oData_BM_Accum0[gi*WV+:WV];

    for (gi = 0; gi < NH1; gi = gi + 1)
        assign wstat_o[gi] = ne.ol.fm.iData_AM_State0[gi*WV+:WV];

    for (gi = 0; gi < NO; gi = gi + 1)
        assign wdelta_o[gi] = ne.ol.de.oData_BM_Delta0[gi*WV+:WV];

    for (gi = 0; gi < NO; gi = gi + 1) begin
        assign woutput[gi]
            = ne.ol.oData_BM_Output[gi*($clog2(NH1)+1+WV)+:$clog2(NH1)+1+WV];
        assign wteacher[gi]
            = ne.ol.iData_AS_Teacher[gi*($clog2(NH1)+1+WV)+:$clog2(NH1)+1+WV];
    end
endgenerate

`DUMP_ALL("ne.vcd")
`SET_LIMIT(c, 120)

initial begin
    @(c.eCLK) iStart = 1'b0;
    @(c.eCLK) iStart = 1'b1;
end

initial begin
    `WAIT_UNTIL(c, oEnd === 1'b1)

    @(c.eCLK) $finish;
end

endmodule
