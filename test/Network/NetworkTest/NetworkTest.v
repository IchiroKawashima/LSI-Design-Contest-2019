`include "Parameter.vh"
`include "Test.vh"

module NetworkTest #
( parameter SIZE         = 10
, parameter WIDTH0       = 8
, parameter WIDTH1       = 8
, parameter WIDTH2       = 8
, parameter INPUT_FILE   = ""
, parameter TEACHER_FILE = ""
, parameter OUTPUT_FILE  = ""
, parameter MODE         = TEST
, parameter NI            = 2
, parameter NH0           = 10
, parameter NH1           = 10
, parameter NO            = 1
, parameter WF            = 8
, parameter BURST         = "yes"
);

ClockDomain c();

`DECLARE_MODE_PARAMETERS

wire              wvldi;
wire              wrdyi;
wire [WIDTH0-1:0] wdatai;
wire              wvldt;
wire              wrdyt;
wire [WIDTH1-1:0] wdatat;
wire              wvldo;
wire              wrdyo;
wire [WIDTH2-1:0] wdatao;

StreamSource #
( .SIZE(SIZE)
, .WIDTH(WIDTH0)
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
, .WIDTH(WIDTH1)
, .INPUT_FILE(INPUT_FILE)
, .BURST(BURST)
) sot
( .oValid_BM(wvldt)
, .iReady_BM(wrdyt)
, .oData_BM(wdatat)
, .iRST(c.RST)
, .iCLK(c.CLK)
);

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
, .iData_AS_Teacher(wdatat)
, .iRST(c.RST)
, .iCLK(c.CLK)
);

StreamSink #
( .SIZE(SIZE)
, .WIDTH(WIDTH2)
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
`SET_LIMIT(c, SIZE)

endmodule
