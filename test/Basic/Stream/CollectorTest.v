`include "Test.vh"

module CollectorTest #
( parameter BURST    = "no"
, parameter PRIORITY = 2
);

ClockDomain c();

reg        iValid_AM0;
wire       oReady_AM0;
reg  [3:0] iData_AM0;
reg        iValid_AM1;
wire       oReady_AM1;
reg  [3:0] iData_AM1;
wire       oValid_BM;
reg        iReady_BM;
wire       oSelect_BM;
wire [7:0] oData_BM;

Collector #
( .WIDTH0(4)
, .WIDTH1(4)
, .BURST(BURST)
, .PRIORITY(PRIORITY)
) collector
( .iValid_AM0(iValid_AM0)
, .oReady_AM0(oReady_AM0)
, .iData_AM0(iData_AM0)
, .iValid_AM1(iValid_AM1)
, .oReady_AM1(oReady_AM1)
, .iData_AM1(iData_AM1)
, .oValid_BM(oValid_BM)
, .iReady_BM(iReady_BM)
, .oSelect_BM(oSelect_BM)
, .oData_BM(oData_BM)
, .iRST(c.RST)
, .iCLK(c.CLK)
);

`DUMP_ALL("cl.vcd")
`SET_LIMIT(c, 30)

initial begin
    @(c.eCLK) begin
        iValid_AM0 = 1'b0;
        iValid_AM1 = 1'b0;
        iData_AM0  = 4'h0;
        iData_AM1  = 4'h0;
        iReady_BM  = 1'b0;
    end

    //Case0
    @(c.eCLK) begin
        iValid_AM0 = 1'b1;
        iValid_AM1 = 1'b0;
        iData_AM0  = 4'ha;
        iData_AM1  = 4'h0;
        iReady_BM  = 1'b1;
    end

    @(c.eCLK) begin
        iValid_AM0 = 1'b0;
        iValid_AM1 = 1'b0;
        iData_AM0  = 4'h0;
        iData_AM1  = 4'h0;
        iReady_BM  = 1'b1;
    end

    `WAIT_UNTIL(c, oReady_AM0 === 1'b1 && oReady_AM1 === 1'b1)

    //Case1
    @(c.eCLK) begin
        iValid_AM0 = 1'b0;
        iValid_AM1 = 1'b1;
        iData_AM0  = 4'h0;
        iData_AM1  = 4'hb;
        iReady_BM  = 1'b1;
    end

    @(c.eCLK) begin
        iValid_AM0 = 1'b0;
        iValid_AM1 = 1'b0;
        iData_AM0  = 4'h0;
        iData_AM1  = 4'h0;
        iReady_BM  = 1'b1;
    end

    `WAIT_UNTIL(c, oReady_AM0 === 1'b1 && oReady_AM1 === 1'b1)

    //Case2
    @(c.eCLK) begin
        iValid_AM0 = 1'b1;
        iValid_AM1 = 1'b1;
        iData_AM0  = 4'h7;
        iData_AM1  = 4'h8;
        iReady_BM  = 1'b0;
    end

    @(c.eCLK) begin
        iValid_AM0 = 1'b0;
        iValid_AM1 = 1'b0;
        iData_AM0  = 4'h0;
        iData_AM1  = 4'h0;
        iReady_BM  = 1'b1;
    end

    @(c.eCLK) begin
        iValid_AM0 = 1'b0;
        iValid_AM1 = 1'b0;
        iData_AM0  = 4'h0;
        iData_AM1  = 4'h0;
        iReady_BM  = 1'b0;
    end

    `WAIT_FOR(c, 2)

    @(c.eCLK) begin
        iValid_AM0 = 1'b0;
        iValid_AM1 = 1'b0;
        iData_AM0  = 4'h0;
        iData_AM1  = 4'h0;
        iReady_BM  = 1'b1;
    end

    `WAIT_UNTIL(c, oReady_AM0 === 1'b1 && oReady_AM1 === 1'b1)

    //Case3
    @(c.eCLK) begin
        iValid_AM0 = 1'b1;
        iValid_AM1 = 1'b0;
        iData_AM0  = 4'h4;
        iData_AM1  = 4'h0;
        iReady_BM  = 1'b0;
    end

    `WAIT_FOR(c, 2)

    @(c.eCLK) begin
        iValid_AM0 = 1'b0;
        iValid_AM1 = 1'b1;
        iData_AM0  = 4'h0;
        iData_AM1  = 4'h5;
        iReady_BM  = 1'b0;
    end

    @(c.eCLK) begin
        iValid_AM0 = 1'b0;
        iValid_AM1 = 1'b0;
        iData_AM0  = 4'h0;
        iData_AM1  = 4'h0;
        iReady_BM  = 1'b1;
    end

    `WAIT_UNTIL(c, oReady_AM0 === 1'b1 && oReady_AM1 === 1'b1)

    //Case4
    @(c.eCLK) begin
        iValid_AM0 = 1'b1;
        iValid_AM1 = 1'b0;
        iData_AM0  = 4'h1;
        iData_AM1  = 4'h0;
        iReady_BM  = 1'b1;
    end

    @(c.eCLK) begin
        iValid_AM0 = 1'b0;
        iValid_AM1 = 1'b1;
        iData_AM0  = 4'h0;
        iData_AM1  = 4'h2;
        iReady_BM  = 1'b1;
    end

    @(c.eCLK) begin
        iValid_AM0 = 1'b1;
        iValid_AM1 = 1'b0;
        iData_AM0  = 4'h3;
        iData_AM1  = 4'h0;
        iReady_BM  = 1'b1;
    end

    @(c.eCLK) begin
        iValid_AM0 = 1'b1;
        iValid_AM1 = 1'b0;
        iData_AM0  = 4'h4;
        iData_AM1  = 4'h0;
        iReady_BM  = 1'b1;
    end

    `WAIT_FOR(c, 1)

    @(c.eCLK)
        $finish;
end

endmodule
