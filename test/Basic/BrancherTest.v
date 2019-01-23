`include "Test.vh"

module BrancherTest #
(parameter BURST = "yes"
);

ClockDomain c();

reg         iValid_AM;
wire        oReady_AM;
reg         iSelect_AM;
reg   [7:0] iData_AM;
wire        oValid_BM0;
reg         iReady_BM0;
wire  [3:0] oData_BM0;
wire        oValid_BM1;
reg         iReady_BM1;
wire  [3:0] oData_BM1;

Brancher #
( .WIDTH0(4)
, .WIDTH1(4)
, .BURST(BURST)
) brancher
( .iValid_AM(iValid_AM)
, .oReady_AM(oReady_AM)
, .iSelect_AM(iSelect_AM)
, .iData_AM(iData_AM)
, .oValid_BM0(oValid_BM0)
, .iReady_BM0(iReady_BM0)
, .oData_BM0(oData_BM0)
, .oValid_BM1(oValid_BM1)
, .iReady_BM1(iReady_BM1)
, .oData_BM1(oData_BM1)
, .iRST(c.RST)
, .iCLK(c.CLK)
);

`DUMP_ALL("bn.vcd")
`SET_LIMIT(c, 100)

initial begin
    @(c.eCLK) begin
        iValid_AM  = 1'b0;
        iSelect_AM = 1'b0;
        iData_AM   = {4'h0, 4'h0};
        iReady_BM0 = 1'b0;
        iReady_BM1 = 1'b0;
    end

    //Case0
    @(c.eCLK) begin
        iValid_AM  = 1'b1;
        iSelect_AM = 1'b0;
        iData_AM   = {4'h0, 4'ha};
        iReady_BM0 = 1'b0;
        iReady_BM1 = 1'b0;
    end

    @(c.eCLK) begin
        iValid_AM  = 1'b1;
        iSelect_AM = 1'b0;
        iData_AM   = {4'h0, 4'hb};
        iReady_BM0 = 1'b1;
        iReady_BM1 = 1'b0;
    end

    @(c.eCLK) begin
        iValid_AM  = 1'b0;
        iSelect_AM = 1'b0;
        iData_AM   = {4'h0, 4'h0};
        iReady_BM0 = 1'b0;
        iReady_BM1 = 1'b0;
    end

    `WAIT_UNTIL(c, oReady_AM === 1'b1)

    //Case1
    @(c.eCLK) begin
        iValid_AM  = 1'b1;
        iSelect_AM = 1'b1;
        iData_AM   = {4'h7, 4'h0};
        iReady_BM0 = 1'b0;
        iReady_BM1 = 1'b0;
    end

    @(c.eCLK) begin
        iValid_AM  = 1'b1;
        iSelect_AM = 1'b1;
        iData_AM   = {4'h0, 4'h8};
        iData_AM   = 4'h8;
        iReady_BM0 = 1'b1;
        iReady_BM1 = 1'b0;
    end

    @(c.eCLK) begin
        iValid_AM  = 1'b0;
        iSelect_AM = 1'b0;
        iData_AM   = {4'h0, 4'h0};
        iReady_BM0 = 1'b0;
        iReady_BM1 = 1'b1;
    end

    `WAIT_UNTIL(c, oReady_AM === 1'b1)

    //Case2
    @(c.eCLK) begin
        iValid_AM  = 1'b1;
        iSelect_AM = 1'b0;
        iData_AM   = {4'h5, 4'h0};
        iReady_BM0 = 1'b0;
        iReady_BM1 = 1'b0;
    end

    @(c.eCLK) begin
        iValid_AM  = 1'b0;
        iSelect_AM = 1'b0;
        iData_AM   = {4'h0, 4'h0};
        iReady_BM0 = 1'b0;
        iReady_BM1 = 1'b0;
    end

    `WAIT_FOR(c, 3)

    @(c.eCLK) begin
        iValid_AM  = 1'b0;
        iSelect_AM = 1'b0;
        iData_AM   = {4'h0, 4'h0};
        iReady_BM0 = 1'b1;
        iReady_BM1 = 1'b0;
    end

    `WAIT_FOR(c, 1)

    @(c.eCLK)
        $finish;
end

endmodule
