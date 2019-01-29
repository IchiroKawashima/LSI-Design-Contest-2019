module StreamSource #
( parameter SIZE       = 256
, parameter WIDTH      = 8
, parameter INPUT_FILE = ""
, parameter BURST      = "yes"
)
( input              iStart
, output             oValid_BM
, input              iReady_BM
, output [WIDTH-1:0] oData_BM
, input              iRST
, input              iCLK
);

genvar gi;

wire                   wrdy;
wire                   wvld;
wire       [WIDTH-1:0] wdata;
reg [$clog2(SIZE)-1:0] raddr;
reg        [WIDTH-1:0] rmem[0:SIZE-1];
reg                    ren;

generate
    if (INPUT_FILE == "")
        for (gi = 0; gi < SIZE; gi = gi + 1)
            initial
                rmem[gi] = $random;
    else
        initial
            $readmemb(INPUT_FILE, rmem, 0, SIZE - 1);
endgenerate

//Enable
always @(posedge iCLK)
    if (iRST)
        ren <= 1'b0;
    else if (iStart)
        ren <= 1'b1;

//Address
always @(posedge iCLK)
    if (iRST)
        raddr <= {$clog2(SIZE){1'b0}};
    else if (ren && wvld)
        raddr <= raddr + 1'b1;

assign wvld  = wrdy && raddr < SIZE;
assign wdata = rmem[raddr];

//Register
Register #
( .WIDTH(WIDTH)
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

endmodule
