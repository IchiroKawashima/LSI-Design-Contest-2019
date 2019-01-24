`include "Parameter.vh"

module BiasWeight #
( parameter NP     = 4
, parameter NC     = 4
, parameter WF     = 4
, parameter BURST  = "yes"
)
( input                       iMode
, input              [WF-1:0] iLR
, input                       iValid_AS_State1
, output                      oReady_AS_State1
, input           [NP*WF-1:0] iData_AS_State1
, input                       iValid_AS_Delta1
, output                      oReady_AS_Delta1
, input           [NC*WF-1:0] iData_AS_Delta1
, output                      oValid_BM_WeightBias
, input                       iReady_BM_WeightBias
, output [NC*NP*WF+NC*WF-1:0] oData_BM_WeightBias
, output                      oValid_BM_Weight
, input                       iReady_BM_Weight
, output       [NP*NC*WF-1:0] oData_BM_Weight
, input                       iRST
, input                       iCLK
);

genvar gi, gj;

// combiner 0
wire                   w_vld_bm_comb0;
wire                   w_rdy_bm_comb0;
wire [NC*WF+NP*WF-1:0] w_dat_bm_comb0; // 0:LSB side, 1:MSB side

Combiner #
( .WIDTH0       (NP*WF)
, .WIDTH1       (NC*WF)
) combiner0
( .iValid_AS0   (iValid_AS_State1)
, .oReady_AS0   (oReady_AS_State1)
, .iData_AS0    (iData_AS_State1)
, .iValid_AS1   (iValid_AS_Delta1)
, .oReady_AS1   (oReady_AS_Delta1)
, .iData_AS1    (iData_AS_Delta1)
, .oValid_BM    (w_vld_bm_comb0)
, .iReady_BM    (w_rdy_bm_comb0)
, .oData_BM     (w_dat_bm_comb0)
);

// pipeline 0
wire signed   [WF-1:0] w_dc0  [0:NC-1];
wire signed   [WF-1:0] w_adc0 [0:NC-1];

wire                   w_vld_as_pipe0;
wire                   w_rdy_as_pipe0;
wire [NC*WD+NP*WF-1:0] w_dat_as_pipe0;

assign w_dat_as_pipe0[NP*WF-1:0] = w_dat_bm_comb0[NP*WF-1:0];

generate
for (gi = 0; gi < NC; gi = gi + 1) begin : w_adc0
    assign w_dc0[gi] = w_dat_bm_comb0[NP*WF + gi*WF +: WF];
    assign w_adc0[gi] = (iLR * w_dc0[gi])[WF+WF-1:WF]; // note
    assign w_dat_as_pipe0[NP*WF + gi*WF +: WF] = w_adc0[gi];
end
endgenerate

wire                   w_vld_bs_pipe0;
wire                   w_rdy_bs_pipe0;
wire [NC*WF+NP*WF-1:0] w_dat_bs_pipe0;  // adc, yc

assign w_vld_as_pipe0 = w_vld_bm_comb0 && (iMode == TRAIN);
assign w_rdy_bm_comb0 = (iMode == TRAIN) ? w_rdy_as_pipe0 : w_rdy_am_broad2;

PipelineRegister #
( .WD           (NC*WF+NP*WF)
) pipeline_register0
( .iValid_AS    (w_vld_as_pipe0)
, .oReady_AS    (w_rdy_as_pipe0)
, .iData_AS     (w_dat_as_pipe0)
, .oValid_BS    (w_vld_bs_pipe0)
, .iReady_BS    (w_rdy_bs_pipe0)
, .oData_BS     (w_dat_bs_pipe0)
, .iRST         (iRST)
, .iCLK         (iCLK)
);

// pipeline 1
wire signed    [WF-1:0] w_adc1  [0:NC-1];
wire signed    [WF-1:0] w_yc1   [0:NC-1];
wire signed [NC*WF-1:0] w_adyc1 [0:NP-1];

wire                      w_vld_as_pipe1;
wire                      w_rdy_as_pipe1;
wire [NP*NC*WF+NC*WF-1:0] w_dat_as_pipe1;   // adyc1, adc1

assign w_vld_as_pipe1 = w_vld_bs_pipe0;
assign w_rdy_as_pipe1 = w_rdy_bs_pipe0;

generate
for (gi = 0; gi < NP; gi = gi + 1) begin : w_yc1
    assign w_yc1[gi] = w_dat_bs_pipe0[gi*WF +: WF];
end

for (gi = 0; gi < NC; gi = gi + 1) begin : w_adc1
    assign w_adc1[gi] = w_dat_bs_pipe0[NP*WF + gi*WD +: WD];
end

for (gi = 0; gi < NP; gi = gi + 1) begin : w_adyc1_i
    for (gj = 0; gj < NC; gj = gi + 1) begin : w_adyc1_j
        assign w_adyc1[gi][gj*WF +: WF] = (w_yc1[gi] * w_adc1[gj])[WF+WF-1:WF];
    end
end

for (gi = 0; gi < NP; gi = gi + 1) begin : w_dat_as_pipe1
    assign w_dat_as_pipe1[gi*(NC*WF) +: NC*WF] = w_adyc1[gi];
end
endgenerate

wire                      w_vld_bs_pipe1;
wire                      w_rdy_bs_pipe1;
wire [NP*NC*WF+NC*WF-1:0] w_dat_bs_pipe1;   // adyc1, adc1

PipelineRegister #
( .WD           (NP*NC*WF+NC*WF)
) pipeline_register1
( .iValid_AS    (w_vld_as_pipe1)
, .oReady_AS    (w_rdy_as_pipe1)
, .iData_AS     (w_dat_as_pipe1)
, .oValid_BS    (w_vld_bs_pipe1)
, .iReady_BS    (w_rdy_bs_pipe1)
, .oData_BS     (w_dat_bs_pipe1)
, .iRST         (iRST)
, .iCLK         (iCLK)
);

// Broadcaster 2
wire signed       [WF-1:0] w_adc2  [0:NC-1];
wire signed    [NC*WF-1:0] w_adyc2 [0:NP-1];
wire signed    [NC*WF-1:0] w_bias;
wire signed [NP*NC*WF-1:0] w_weight;

reg  signed    [NC*WF-1:0] r_bias;
reg  signed [NP*NC*WF-1:0] r_weight;
reg                        r_vld_bias_weight;

wire        [NC*NP*WF-1:0] w_weight_t;

wire w_vld_am_broad2;
wire w_rdy_am_broad2;

generate
for (gi = 0; gi < NC; gi = gi + 1) begin : w_adc2
    assign w_adc2[gi] = w_dat_bs_pipe1[gi*WF +: WF];
end

for (gi = 0; gi < NP; gi = gi + 1) begin : w_adyc2
    assign w_adyc2[gi] = w_dat_bs_pipe1[NC*WF + gi*WF +: WF];
end

for (gi = 0; gi < NC; gi = gi + 1) begin : w_bias
    assign w_bias[gi*WF +: WF] = r_bias[gi*WF +: WF] - w_adc2[gi];
end

for (gi = 0; gi < NP; gi = gi + 1) begin : w_weight_i
    for (gj = 0; gj < NC; gj = gj + 1) begin : w_weight_j
        assign w_weight[gi*(gj*WF) +: WF] = r_weight[gi*(gj*WF) +: WF] - w_adyc2[gi][gj*WF +: WF];
    end
end

for (gi = 0; gi < NC; gi = gi + 1) begin : w_weight_t_i
    for (gj = 0; gj < NC; gj = gj + 1) begin : w_weight_t_j
        assign w_weight_t[(gi*NC+gj)*WF +: WF] = r_weight[(gj*NP+gi)*WF +: WF];
    end
end
endgenerate

//assign w_vld_am_broad2 = (iMode == TRAIN) ? w_vld_bs_pipe1 : w_vld_bm_comb0;
assign w_vld_am_broad2 = (iMode == TRAIN) ? r_vld_bias_weight : w_vld_bm_comb0;
assign w_rdy_bs_pipe1 = w_rdy_am_broad2 && iMode;

always @(posedge iCLK) begin
    if (iRST) begin
        r_bias                  <= 0;
        r_weight                <= 0;
        r_vld_bias_weight       <= 0;
    end
    else begin
        if (iMode == TRAIN) begin
            r_bias              <= w_bias;
            r_weight            <= w_weight;
            r_vld_bias_weight   <= w_vld_bs_pipe1;
        end
    end
end

module Broadcaster #
( .WIDTH0       (NC*NP*WF+NC*WF)
, .WIDTH1       (NP*NC*WF)
, .BURST        (BURST)
) broadcaster2
( .iValid_AM    (w_vld_am_broad2)
, .oReady_AM    (w_rdy_am_broad2)
, .iData_AM     ({r_weight, {w_weight_t, r_bias}})
, .oValid_BM0   (oValid_BM_WeightBias)
, .iReady_BM0   (iReady_BM_WeightBias)
, .oData_BM0    (oData_BM_WeightBias)
, .oValid_BM1   (oValid_BM_Weight)
, .iReady_BM1   (iReady_BM_Weight)
, .oData_BM1    (oData_BM_Weight)
, .iRST         (iRST)
, .iCLK         (iCLK)
);

endmodule
