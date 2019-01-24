module Combiner #
( parameter WIDTH0 = 32
, parameter WIDTH1 = 32
)
( input                      iValid_AS0
, output                     oReady_AS0
, input         [WIDTH0-1:0] iData_AS0
, input                      iValid_AS1
, output                     oReady_AS1
, input         [WIDTH1-1:0] iData_AS1
, output                     oValid_BM
, input                      iReady_BM
, output [WIDTH1+WIDTH0-1:0] oData_BM
);

wire wvld;
wire wrdy;

assign {oReady_AS1, oReady_AS0} = {wrdy, wrdy};
assign oValid_BM                = wvld;
assign oData_BM                 = {iData_AS1, iData_AS0};

//Valid
assign wvld = iValid_AS0 && iValid_AS1;

//Ready
assign wrdy = iReady_BM && wvld;

endmodule
