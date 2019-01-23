`include "Test.vh"

module RegisterTest;

ClockDomain c();

reg        iValid_AM;
wire       oReady_AM;
reg  [3:0] iData_AM;
wire       oValid_BM;
reg        iReady_BM;
wire [3:0] oData_BM;

Register #
( .WIDTH(4)
, .BURST("no")
) register
( .iValid_AM(iValid_AM)
, .oReady_AM(oReady_AM)
, .iData_AM(iData_AM)
, .oValid_BM(oValid_BM)
, .iReady_BM(iReady_BM)
, .oData_BM(oData_BM)
, .iRST(c.RST)
, .iCLK(c.CLK)
);

`DUMP_ALL("rg.vcd")
`SET_LIMIT(c, 100)

initial begin
    @(c.eCLK) begin
        iValid_AM = 1'b0;
        iData_AM  = 4'h0;
        iReady_BM = 1'b0;
    end

    //Case0
    @(c.eCLK) begin
        iValid_AM = 1'b1;
        iData_AM  = 4'ha;
        iReady_BM = 1'b0;
    end

    @(c.eCLK) begin
        iValid_AM = 1'b0;
        iData_AM  = 4'h0;
        iReady_BM = 1'b1;
    end

    `WAIT_UNTIL(c, oReady_AM === 1'b1)

    //Case1
    @(c.eCLK) begin
        iValid_AM = 1'b1;
        iData_AM  = 4'h7;
        iReady_BM = 1'b0;
    end

    @(c.eCLK) begin
        iValid_AM = 1'b0;
        iData_AM  = 4'h0;
        iReady_BM = 1'b0;
    end

    `WAIT_FOR(c, 3)

    @(c.eCLK) begin
        iValid_AM = 1'b0;
        iData_AM  = 4'h0;
        iReady_BM = 1'b1;
    end

    `WAIT_UNTIL(c, oReady_AM === 1'b1)

    //Case2
    @(c.eCLK) begin
        iValid_AM = 1'b1;
        iData_AM  = 4'ha;
        iReady_BM = 1'b0;
    end

    @(c.eCLK) begin
        iValid_AM = 1'b1;
        iData_AM  = 4'hb;
        iReady_BM = 1'b0;
    end

    @(c.eCLK) begin
        iValid_AM = 1'b0;
        iData_AM  = 4'h0;
        iReady_BM = 1'b0;
    end

    `WAIT_FOR(c, 1)

    @(c.eCLK) begin
        iValid_AM = 1'b1;
        iData_AM  = 4'hc;
        iReady_BM = 1'b1;
    end

    @(c.eCLK) begin
        iValid_AM = 1'b1;
        iData_AM  = 4'hd;
        iReady_BM = 1'b1;
    end

    @(c.eCLK) begin
        iValid_AM = 1'b1;
        iData_AM  = 4'he;
        iReady_BM = 1'b1;
    end

    @(c.eCLK) begin
        iValid_AM = 1'b0;
        iData_AM  = 4'h0;
        iReady_BM = 1'b1;
    end

    `WAIT_FOR(c, 3)

    @(c.eCLK)
        $finish;
end

endmodule
