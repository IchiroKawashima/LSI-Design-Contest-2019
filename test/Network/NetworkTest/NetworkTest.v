`include "Parameter.vh"
`include "Test.vh"

module NetworkTest #
( parameter SIZE         = 3
, parameter INPUT_FILE   = ""
, parameter TEACHER_FILE = ""
, parameter OUTPUT_FILE  = ""
, parameter MODE         = TRAIN
, parameter NI            = 3
, parameter NH0           = 2
, parameter NH1           = 3
, parameter NO            = 2
, parameter WF            = 8
, parameter BURST         = "yes"
);

ClockDomain c();

`DECLARE_MODE_PARAMETERS

genvar gi, gj;

wire                             wvldi;
wire                             wrdyi;
wire                [NI*WF-1:0] wdatai;
wire                             wvldt;
wire                             wrdyt;
wire                 [NO*WF-1:0] wdatat;
wire [NO*($clog2(NH1)+1+WF)-1:0] wdatat_c;
wire                             wvldo;
wire                             wrdyo;
wire [NO*($clog2(NH1)+1+WF)-1:0] wdatao;


wire                [WF-1:0] wstat_h0[0:NI-1];
wire                [WF-1:0] wweit_h0[0:NI*NH0-1];
wire                [WF-1:0] wbias_h0[0:NH0-1];
wire [($clog2(NI)+1+WF)-1:0] waccm_h0[0:NH0-1];
wire                [WF-1:0] wdelta_h0[0:NH0-1];

wire                [WF-1:0] wstat_h1[0:NH0-1];
wire                [WF-1:0] wweit_h1[0:NH0*NH1-1];
wire                [WF-1:0] wbias_h1[0:NH1-1];
wire [($clog2(NH0)+1+WF)-1:0] waccm_h1[0:NH1-1];
wire                [WF-1:0] wdelta_h1[0:NH1-1];

wire                [WF-1:0] wstat_o[0:NH1-1];
wire                [WF-1:0] wweit_o[0:NH1*NO-1];
wire                [WF-1:0] wbias_o[0:NO-1];
wire [($clog2(NH1)+1+WF)-1:0] waccm_o[0:NO-1];
wire                [WF-1:0] wdelta_o[0:NO-1];

wire [$clog2(NH1)+1+WF-1:0] woutput[0:NO-1];
wire [$clog2(NH1)+1+WF-1:0] wteacher[0:NO-1];

generate
    for (gi = 0; gi < NI; gi = gi + 1)
        assign wstat_h0[gi] = ne.hl0.fm.iData_AM_State0[gi*WF+:WF];

    for (gi = 0; gi < NI; gi = gi + 1)
        for (gj = 0; gj < NH0; gj = gj + 1)
            assign wweit_h0[gi*NH0+gj]
                = ne.hl0.fm.iData_AM_WeightBias[(gi*NH0+gj)*WF+NH0*WF+:WF];

    for (gi = 0; gi < NH0; gi = gi + 1)
        assign wbias_h0[gi] = ne.hl0.fm.iData_AM_WeightBias[gi*WF+:WF];

    for (gi = 0; gi < NH0; gi = gi + 1)
        assign waccm_h0[gi] = ne.hl0.fm.oData_BM_Accum0[gi*WF+:WF];

    for (gi = 0; gi < NH0; gi = gi + 1)
        assign wdelta_h0[gi] = ne.hl0.de.oData_BM_Delta0[gi*WF+:WF];

    for (gi = 0; gi < NH0; gi = gi + 1)
        for (gj = 0; gj < NH1; gj = gj + 1)
            assign wweit_h1[gi*NH1+gj]
                = ne.hl1.fm.iData_AM_WeightBias[(gi*NH1+gj)*WF+NH1*WF+:WF];

    for (gi = 0; gi < NH1; gi = gi + 1)
        assign wbias_h1[gi] = ne.hl1.fm.iData_AM_WeightBias[gi*WF+:WF];

    for (gi = 0; gi < NH1; gi = gi + 1)
        assign waccm_h1[gi] = ne.hl1.fm.oData_BM_Accum0[gi*WF+:WF];

    for (gi = 0; gi < NH0; gi = gi + 1)
        assign wstat_h1[gi] = ne.hl1.fm.iData_AM_State0[gi*WF+:WF];

    for (gi = 0; gi < NH1; gi = gi + 1)
        assign wdelta_h1[gi] = ne.hl1.de.oData_BM_Delta0[gi*WF+:WF];

    for (gi = 0; gi < NH1; gi = gi + 1)
        for (gj = 0; gj < NO; gj = gj + 1)
            assign wweit_o[gi*NO+gj]
                = ne.ol.fm.iData_AM_WeightBias[(gi*NO+gj)*WF+NO*WF+:WF];

    for (gi = 0; gi < NO; gi = gi + 1)
        assign wbias_o[gi] = ne.ol.fm.iData_AM_WeightBias[gi*WF+:WF];

    for (gi = 0; gi < NO; gi = gi + 1)
        assign waccm_o[gi] = ne.ol.fm.oData_BM_Accum0[gi*WF+:WF];

    for (gi = 0; gi < NH1; gi = gi + 1)
        assign wstat_o[gi] = ne.ol.fm.iData_AM_State0[gi*WF+:WF];

    for (gi = 0; gi < NO; gi = gi + 1)
        assign wdelta_o[gi] = ne.ol.de.oData_BM_Delta0[gi*WF+:WF];


    for (gi = 0; gi < NO; gi = gi + 1) begin
        assign woutput[gi]
            = ne.ol.oData_BM_Output[gi*($clog2(NH1)+1+WF)+:$clog2(NH1)+1+WF];
        assign wteacher[gi]
            = ne.ol.iData_AS_Teacher[gi*($clog2(NH1)+1+WF)+:$clog2(NH1)+1+WF];
    end
endgenerate

StreamSource #
( .SIZE(SIZE)
, .WIDTH(NI*WF)
, .INPUT_FILE(INPUT_FILE)
, .BURST(BURST)
) soi
( .oValid_BM(wvldi)
, .iReady_BM(wrdyi)
, .oData_BM(wdatai)
, .iRST(c.RST)
, .iCLK(c.CLK)
);

StreamSource #
( .SIZE(SIZE)
, .WIDTH(NO*WF)
, .INPUT_FILE(INPUT_FILE)
, .BURST(BURST)
) sot
( .oValid_BM(wvldt)
, .iReady_BM(wrdyt)
, .oData_BM(wdatat)
, .iRST(c.RST)
, .iCLK(c.CLK)
);

generate
    for (gi = 0; gi < NO; gi = gi + 1)
        assign wdatat_c[gi*($clog2(NH1)+1+WF)+:$clog2(NH1)+1+WF]
            = {{$clog2(NH1)+1{1'b0}}, wdatat[gi*WF+:WF]};
endgenerate

Network #
( .NI(NI)
, .NH0(NH0)
, .NH1(NH1)
, .NO(NO)
, .WF(WF)
, .BURST(BURST)
) ne
( .iMode(MODE)
, .iValid_AM_Input(wvldi)
, .oReady_AM_Input(wrdyi)
, .iData_AM_Input(wdatai)
, .oValid_BM_Output(wvldo)
, .iReady_BM_Output(wrdyo)
, .oData_BM_Output(wdatao)
, .iValid_AS_Teacher(wvldt)
, .oReady_AS_Teacher(wrdyt)
, .iData_AS_Teacher(wdatat_c)
, .iRST(c.RST)
, .iCLK(c.CLK)
);

StreamSink #
( .SIZE(SIZE)
, .WIDTH(NO*($clog2(NH1)+1+WF))
, .OUTPUT_FILE(OUTPUT_FILE)
, .BURST(BURST)
) sio
( .iValid_AM(wvldo)
, .oReady_AM(wrdyo)
, .iData_AM(wdatao)
, .iRST(c.RST)
, .iCLK(c.CLK)
);

`DUMP_ALL("ne.vcd")
`SET_LIMIT(c, 120)

endmodule
