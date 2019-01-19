module Neuron #
( parameter HIDDEN = "yes"
, parameter NP     = 4
, parameter NC     = 4
, parameter WD     = 4
)
( input                                                 iValid_AS
, output                                                oReady_AS
, input                      [NC*($clog2(NP)+1+WD)-1:0] iData_AS
, output                                                oValid_BS
, input                                                 iReady_BS
, output [NC*((HIDDEN=="yes")?WD:$clog2(NP)+1+WD)-1:0] oData_BS
, input                                                 iRST
, input                                                 iCLK
);


// pipeline register
wire [NC*((HIDDEN=="yes")?WD:$clog2(NP)+1+WD)-1:0] w_lgc;
reg  [NC*((HIDDEN=="yes")?WD:$clog2(NP)+1+WD)-1:0] r_stl;
reg  r_vld;
wire w_rdy;

assign oData_BS = r_stl;
assign oValid_BS = r_vld;
assign oReady_AS = w_rdy;
assign w_rdy = (r_vld) ? iReady_BS : 1;

always @(posedge iCLK) begin
    if (iRST) begin
        r_stl <= 0;
        r_vld <= 0;
    end
    else begin
        r_stl <= (iValid_AS && w_rdy) ? w_lgc : r_stl;
        r_vld <= (r_vld) ? !((!iValid_AS) && w_rdy) : iValid_AS; 
    end
end


// logic
localparam MAX_YC = 2 ** (WD - 1) - 1;
wire signed [($clog2(NP)+1+WD)-1:0] w_vc[0:NC-1];
wire signed [($clog2(NP)+1+WD)-1:0] w_yc_pos[0:NC-1];
wire signed                [WD-1:0] w_yc_clp[0:NC-1];

genvar gi;
generate
    for (gi = 0; gi < NC; gi = gi + 1) begin : in
        assign w_vc[gi] = iData_AS[gi*($clog2(NP)+1+WD) +: ($clog2(NP)+1+WD)];
    end

    // ReLU
    for (gi = 0; gi < NC; gi = gi + 1) begin : relu
        if (HIDDEN == "yes") begin
            assign w_yc_pos[gi] = w_vc[gi][($clog2(NP)+1+WD)-1] ? 0: w_vc[gi];
            assign w_yc_clp[gi] = (w_yc_pos[gi] <= MAX_YC[WD:0]) ? w_yc_pos[gi][WD-1:0] : MAX_YC[WD:0];
        end
        else
            assign w_yc_clp[gi] = w_vc[gi][WD-1:0];
    end

    // out
    for (gi = 0; gi < NC; gi = gi + 1) begin : out
        assign w_lgc[gi*((HIDDEN=="yes")?WD:$clog2(NP)+1+WD) +: (HIDDEN=="yes")?WD:$clog2(NP)+1+WD] = w_yc_clp[gi];
    end
endgenerate

endmodule
