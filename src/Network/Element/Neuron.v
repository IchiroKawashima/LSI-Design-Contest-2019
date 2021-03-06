`include "Parameter.vh"

module Neuron #
( parameter HIDDEN = "yes"
, parameter NP     = 4
, parameter NC     = 4
, parameter WV     = 4
, parameter BURST  = "yes"
)
( input                             iMode
, input                             iValid_AM_Accum0
, output                            oReady_AM_Accum0
, input  [NC*($clog2(NP)+1+WV)-1:0] iData_AM_Accum0
, output                            oValid_BM_State0
, input                             iReady_BM_State0
, output                [NC*WN-1:0] oData_BM_State0
, output                            oValid_BM_State1
, input                             iReady_BM_State1
, output                [NC*WN-1:0] oData_BM_State1
, input                             iRST
, input                             iCLK
);

localparam WN = (HIDDEN == "yes") ? WV : $clog2(NP) + 1 + WV;
`DECLARE_MODE_PARAMETERS

// pipeline register

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
localparam MAX_YC = 2 ** (WV - 1) - 1;

genvar gi;
generate
    if (HIDDEN == "yes") begin
        wire                    [NC*WN-1:0] w_lgc;
        wire signed [($clog2(NP)+1+WV)-1:0] w_vc[0:NC-1];
        wire signed [($clog2(NP)+1+WV)-1:0] w_yc_pos[0:NC-1];
        wire signed                [WV-1:0] w_yc_clp[0:NC-1];
        
        for (gi = 0; gi < NC; gi = gi + 1) begin : in
            assign w_vc[gi] = iData_AM_Accum0[gi*($clog2(NP)+1+WV) +: ($clog2(NP)+1+WV)];
        end
    
        // ReLU
        for (gi = 0; gi < NC; gi = gi + 1) begin : relu
            assign w_yc_pos[gi] = w_vc[gi][($clog2(NP)+1+WV)-1] ? 0: w_vc[gi];
            assign w_yc_clp[gi] = (w_yc_pos[gi] <= MAX_YC[WV:0]) ? w_yc_pos[gi][WV-1:0] : MAX_YC[WV:0];
        end
    
        // out
        for (gi = 0; gi < NC; gi = gi + 1) begin : out
            assign w_lgc[gi*WN +: WV] = w_yc_clp[gi];
        end

    
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
    end else begin
        Register #
        ( .WIDTH(NC*WN)
        , .BURST(BURST)
        ) register1
        ( .iValid_AM(iValid_AM_Accum0)
        , .oReady_AM(oReady_AM_Accum0)
        , .iData_AM(iData_AM_Accum0)
        , .oValid_BM(oValid_BM_State0)
        , .iReady_BM(iReady_BM_State0)
        , .oData_BM(oData_BM_State0)
        , .iRST(iRST)
        , .iCLK(iCLK)
        );

        assign oValid_BM_State1 = 1'b0;
        assign oData_BM_State1  = {NC*WN{1'b0}};
    end
endgenerate

endmodule
