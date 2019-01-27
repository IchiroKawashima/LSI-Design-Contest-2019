module StreamSink #
( parameter SIZE        = 256
, parameter WIDTH       = 8
, parameter OUTPUT_FILE = ""
, parameter BURST       = "yes"
)
( input              iValid_AM
, output             oReady_AM
, input  [WIDTH-1:0] iData_AM
, input              iRST
, input              iCLK
);

integer i;

wire                   wrdy;
wire                   wvld;
wire       [WIDTH-1:0] wdata;
reg [$clog2(SIZE)-1:0] raddr;
reg        [WIDTH-1:0] rmem[0:SIZE-1];

generate
    if (OUTPUT_FILE == "")
        initial begin
            wait (raddr == SIZE);
            for (i = 0; i < SIZE; i = i + 1)
                    $display("%b", rmem[i]);
        end
    else
        initial begin
            wait (raddr == SIZE);
            $writememb(OUTPUT_FILE, rmem, 0, SIZE - 1);
        end
endgenerate

Register #
( .WIDTH(WIDTH)
, .BURST(BURST)
) register
( .iValid_AM(iValid_AM)
, .oReady_AM(oReady_AM)
, .iData_AM(iData_AM)
, .oValid_BM(wvld)
, .iReady_BM(wrdy)
, .oData_BM(wdata)
, .iRST(iRST)
, .iCLK(iCLK)
);

always @(posedge iCLK)
    if (iRST)
        raddr <= {$clog2(SIZE){1'b0}};
    else if (wrdy)
        raddr <= raddr + 1'b1;

assign wrdy = wvld && raddr < SIZE;

always @(posedge iCLK)
    if (wrdy)
        rmem[raddr] <= wdata;

endmodule
