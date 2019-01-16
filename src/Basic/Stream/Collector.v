module Collector #
( parameter WIDTH0   = 32
, parameter WIDTH1   = 32
, parameter BURST    = "yes"
, parameter PRIORITY = 2
)
( input                      iValid_AM0
, output                     oReady_AM0
, input         [WIDTH0-1:0] iData_AM0
, input                      iValid_AM1
, output                     oReady_AM1
, input         [WIDTH1-1:0] iData_AM1
, output                     oValid_BM
, input                      iReady_BM
, output                     oSelect_BM
, output [WIDTH1+WIDTH0-1:0] oData_BM
, input                      iRST
, input                      iCLK
);

wire              wvld;
wire              wvld0;
wire              wvld1;
wire              wrdy;
wire              wrdy0;
wire              wrdy1;
reg               wsel;
wire              wpri;
wire [WIDTH0-1:0] wdata0;
wire [WIDTH1-1:0] wdata1;

assign oValid_BM  = wvld;
assign oSelect_BM = wsel;
assign oData_BM   = {wdata1, wdata0};

//Register
Register #
( .WIDTH(WIDTH0) , .BURST(BURST)
) rg0
( .iValid_AM(iValid_AM0) , .oReady_AM(oReady_AM0) , .iData_AM(iData_AM0)
, .oValid_BM(wvld0)      , .iReady_BM(wrdy0)      , .oData_BM(wdata0)
, .iRST(iRST)            , .iCLK(iCLK)
);

Register #
( .WIDTH(WIDTH1) , .BURST(BURST)
) rg1
( .iValid_AM(iValid_AM1) , .oReady_AM(oReady_AM1) , .iData_AM(iData_AM1)
, .oValid_BM(wvld1)      , .iReady_BM(wrdy1)      , .oData_BM(wdata1)
, .iRST(iRST)            , .iCLK(iCLK)
);

//Valid
assign wvld = (wsel) ? wvld1 : wvld0;

//Ready
assign wrdy           = iReady_BM && wvld;
assign {wrdy1, wrdy0} = (wsel) ? {wrdy, 1'b0} : {1'b0, wrdy};

//Select
always @(*)
    case ({wvld1, wvld0})
        2'b01  : wsel = 1'b0;
        2'b10  : wsel = 1'b1;
        2'b11  : wsel = wpri;
        default: wsel = 1'bx;
    endcase

//Priority
generate
    if (PRIORITY == 0)
        assign wpri = 1'b0;
    else if (PRIORITY == 1)
        assign wpri = 1'b1;
    else begin
        reg rsel;

        assign wpri = !rsel;

        always @(posedge iCLK)
            if (wvld)
                rsel <= wsel;
    end
endgenerate

endmodule
