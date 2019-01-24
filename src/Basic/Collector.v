module Collector #
( parameter WIDTH0   = 32
, parameter WIDTH1   = 32
, parameter PRIORITY = 0
)
( input                      iValid_AS0
, output                     oReady_AS0
, input         [WIDTH0-1:0] iData_AS0
, input                      iValid_AS1
, output                     oReady_AS1
, input         [WIDTH1-1:0] iData_AS1
, output                     oValid_BM
, input                      iReady_BM
, output                     oSelect_BM
, output [WIDTH1+WIDTH0-1:0] oData_BM
);

wire              wvld;
wire              wrdy;
reg               wsel;
wire              wpri;

assign {oReady_AS1, oReady_AS0} = (wsel) ? {wrdy, 1'b0} : {1'b0, wrdy};
assign oValid_BM                = wvld;
assign oSelect_BM               = wsel;
assign oData_BM                 = {iData_AS1, iData_AS0};

//Valid
assign wvld = (wsel) ? iValid_AS1 : iValid_AS0;

//Ready
assign wrdy = iReady_BM && wvld;

//Select
always @(*)
    case ({iValid_AS1, iValid_AS0})
        2'b01  : wsel = 1'b0;
        2'b10  : wsel = 1'b1;
        2'b11  : wsel = wpri;
        default: wsel = 1'bx;
    endcase

//Priority
generate
    if (PRIORITY == 0)
        assign wpri = 1'b0;
    else
        assign wpri = 1'b1;
endgenerate

endmodule
