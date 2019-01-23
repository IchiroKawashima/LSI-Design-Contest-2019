module CombinerN #
( parameter SIZE  = 8
, parameter WIDTH = 32
)
( input        [SIZE-1:0] iValid_AS
, output       [SIZE-1:0] oReady_AS
, input  [SIZE*WIDTH-1:0] iData_AS
, output                  oValid_BM
, input                   iReady_BM
, output [SIZE*WIDTH-1:0] oData_BM
);

wire                  wvld;
wire                  wrdy;
wire [SIZE*WIDTH-1:0] wdata;

assign oReady_AS = {SIZE{wrdy}};
assign oValid_BM = wvld;
assign oData_BM  = iData_AS;

//Valid
assign wvld = &iValid_AS;

//Ready
assign wrdy = iReady_BM && wvld;

endmodule
