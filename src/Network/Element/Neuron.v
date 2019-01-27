`include "Parameter.vh"

module Neuron #
( parameter HIDDEN = "yes"
, parameter NP     = 4
, parameter NC     = 4
, parameter WF     = 4
, parameter BURST  = "yes"
)
( input                             iMode
, input                             iValid_AM_Accum0
, output                            oReady_AM_Accum0
, input  [NC*($clog2(NP)+1+WF)-1:0] iData_AM_Accum0
, output                            oValid_BM_State0
, input                             iReady_BM_State0
, output                [NC*WN-1:0] oData_BM_State0
, output                            oValid_BM_State1
, input                             iReady_BM_State1
, output                [NC*WN-1:0] oData_BM_State1
, input                             iRST
, input                             iCLK
);

localparam WN = (HIDDEN == "yes") ? WF : $clog2(NP) + 1 + WF;
`DECLARE_MODE_PARAMETERS

// pipeline register
wire [NC*WN-1:0] w_lgc;
//reg  [NC*WN-1:0] r_stl;
//reg  r_vld;
//wire w_rdy;

//assign oData_BS = r_stl;
//assign oValid_BS = r_vld;
//assign oReady_AM_Accum0 = w_rdy;
//assign w_rdy = (r_vld) ? iReady_BS : 1;

/*
always @(posedge iCLK) begin
    if (iRST) begin
        r_stl <= 0;
        r_vld <= 0;
    end
    else begin
        r_stl <= (iValid_AM_Accum0 && w_rdy) ? w_lgc : r_stl;
        r_vld <= (r_vld) ? !((!iValid_AM_Accum0) && w_rdy) : iValid_AM_Accum0;
    end
end
*/

// logic
localparam MAX_YC = 2 ** (WF - 1) - 1;
wire signed [($clog2(NP)+1+WF)-1:0] w_vc[0:NC-1];
wire signed [($clog2(NP)+1+WF)-1:0] w_yc_pos[0:NC-1];
wire signed              [WF-1:0] w_yc_clp[0:NC-1];

genvar gi;
generate
    for (gi = 0; gi < NC; gi = gi + 1) begin : in
        assign w_vc[gi] = iData_AM_Accum0[gi*($clog2(NP)+1+WF) +: ($clog2(NP)+1+WF)];
    end

    // ReLU
    for (gi = 0; gi < NC; gi = gi + 1) begin : relu
        if (HIDDEN == "yes") begin
            assign w_yc_pos[gi] = w_vc[gi][($clog2(NP)+1+WF)-1] ? 0: w_vc[gi];
            assign w_yc_clp[gi] = (w_yc_pos[gi] <= MAX_YC[WF:0]) ? w_yc_pos[gi][WF-1:0] : MAX_YC[WF:0];
        end
        else
            assign w_yc_clp[gi] = w_vc[gi][WF-1:0];
    end

    // out
    for (gi = 0; gi < NC; gi = gi + 1) begin : out
        assign w_lgc[gi*WN +: (HIDDEN=="yes")?WF:$clog2(NP)+1+WF] = w_yc_clp[gi];
    end
endgenerate

wire w_vld_bm1;
wire w_rdy_bm1;
assign {w_rdy_bm1, oValid_BM_State1} = (iMode == TRAIN)
    ? {iReady_BM_State1, w_vld_bm1}
    : {w_vld_bm1, 1'b0};

Broadcaster #
( .WIDTH0(NC*WN)
, .WIDTH1(NC*WN)
, .BURST(BURST)
) broadcaster1
( .iValid_AM(iValid_AM_Accum0)
, .oReady_AM(oReady_AM_Accum0)
, .iData_AM({w_lgc, w_lgc})
, .oValid_BM0(oValid_BM_State0)
, .iReady_BM0(iReady_BM_State0)
, .oData_BM0(oData_BM_State0)
, .oValid_BM1(w_vld_bm1)
, .iReady_BM1(w_rdy_bm1)
, .oData_BM1(oData_BM_State1)
, .iRST(iRST)
, .iCLK(iCLK)
);

endmodule
