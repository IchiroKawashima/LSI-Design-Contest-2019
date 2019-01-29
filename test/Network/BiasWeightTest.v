`include "Test.vh"

module BiasWeightTest #
( parameter NP     = 3
, parameter NC     = 2
, parameter WV     = 8
, parameter BURST  = "yes"
);

reg                       iMode;
reg              [WV-1:0] iLR;
reg                       iValid_AS_State1;
wire                      oReady_AS_State1;
reg           [NP*WV-1:0] iData_AS_State1;
reg                       iValid_AS_Delta1;
wire                      oReady_AS_Delta1;
reg           [NC*WV-1:0] iData_AS_Delta1;
wire                      oValid_BM_WeightBias;
reg                       iReady_BM_WeightBias;
wire [NC*NP*WV+NC*WV-1:0] oData_BM_WeightBias;
wire                      oValid_BM_Weight;
reg                       iReady_BM_Weight;
wire       [NP*NC*WV-1:0] oData_BM_Weight;
reg                       iRST;
reg                       iCLK;

wire [WV-1:0] w_state [0:NP-1];
wire [WV-1:0] w_delta [0:NC-1];

wire [WV-1:0] w_bias_bm0 [0:NC-1];
wire [WV-1:0] w_weight0_bm0 [0:NP-1];
wire [WV-1:0] w_weight1_bm0 [0:NP-1];
wire [WV-1:0] w_weight0_bm1 [0:NC-1];
wire [WV-1:0] w_weight1_bm1 [0:NC-1];
wire [WV-1:0] w_weight2_bm1 [0:NC-1];

genvar gi;

generate
for (gi = 0; gi < NP; gi = gi + 1) begin : gen_w_state
    assign w_state[gi] = iData_AS_State1[gi*WV +: WV];
end

for (gi = 0; gi < NC; gi = gi + 1) begin : gen_w_delta
    assign w_delta[gi] = iData_AS_Delta1[gi*WV +: WV];
end

for (gi = 0; gi < NC; gi = gi + 1) begin : gen_weight_bias0
    assign w_bias_bm0[gi] = oData_BM_WeightBias[gi*WV +: WV];
end

for (gi = 0; gi < NP; gi = gi + 1) begin : gen_weight_bias1
    assign w_weight0_bm0[gi] = oData_BM_WeightBias[gi*WV + NC*WV +: WV];
    assign w_weight1_bm0[gi] = oData_BM_WeightBias[gi*WV + NP*WV + NC*WV +: WV];
end

for (gi = 0; gi < NC; gi = gi + 1) begin : gen_weight
    assign w_weight0_bm1[gi] = oData_BM_Weight[gi*WV +: WV];
    assign w_weight1_bm1[gi] = oData_BM_Weight[gi*WV + NC*WV +: WV];
    assign w_weight2_bm1[gi] = oData_BM_Weight[gi*WV + NC*WV + NC*WV +: WV];
end
endgenerate

BiasWeight #
( .NP                   (NP)
, .NC                   (NC)
, .WV                   (WV)
, .BURST                (BURST)
) biasweight0
( .iMode                (iMode)
, .iLR                  (iLR)    
, .iValid_AS_State1     (iValid_AS_State1)
, .oReady_AS_State1     (oReady_AS_State1)
, .iData_AS_State1      (iData_AS_State1)
, .iValid_AS_Delta1     (iValid_AS_Delta1)
, .oReady_AS_Delta1     (oReady_AS_Delta1)
, .iData_AS_Delta1      (iData_AS_Delta1)
, .oValid_BM_WeightBias (oValid_BM_WeightBias)
, .iReady_BM_WeightBias (iReady_BM_WeightBias)
, .oData_BM_WeightBias  (oData_BM_WeightBias)
, .oValid_BM_Weight     (oValid_BM_Weight)
, .iReady_BM_Weight     (iReady_BM_Weight)
, .oData_BM_Weight      (oData_BM_Weight)
, .iRST                 (iRST)
, .iCLK                 (iCLK)
);

parameter PERIOD = 2;
always #(PERIOD/2) iCLK = ~iCLK;

integer i, j;

/*
initial begin
#0
    iMode = 1'b0;
    iLR   = 8'b00001111;
    iCLK  = 1'b0;

    iValid_AS_State1        = 1'b0;
    iData_AS_State1         = {8'd0, 8'd0, 8'd0};
    iValid_AS_Delta1        = 1'b0;
    iData_AS_Delta1         = {8'd0, 8'd0};
    iReady_BM_WeightBias    = 1'b0;
    iReady_BM_Weight        = 1'b0;

#(PERIOD)
    iRST = 1;

#(PERIOD)
    iRST = 0;

#(PERIOD)
    for (i = 0; i < NC; i = i + 1) begin
        biasweight0.r_bias[i*WV +: WV] = i[WV-1:0];
    end
    
    for (i = 0; i < NP; i = i + 1) begin
        for (j = 0; j < NC; j = j + 1) begin
            biasweight0.r_weight[i*NC*WV + j*WV +: WV] = (i * NC + j);
        end
    end

#(PERIOD)
    iReady_BM_WeightBias    = 1'b1;

#(PERIOD)
    iReady_BM_WeightBias    = 1'b0;

#(PERIOD)
    iReady_BM_WeightBias    = 1'b1;

#(PERIOD * 2)
    iReady_BM_WeightBias    = 1'b0;

#(PERIOD)
    $finish;
*/

initial begin
#0
    iMode = 1'b1;
    iLR   = 8'b00001111;
    iCLK  = 1'b0;

    iValid_AS_State1        = 1'b0;
    iData_AS_State1         = {8'd0, 8'd0, 8'd0};
    iValid_AS_Delta1        = 1'b0;
    iData_AS_Delta1         = {8'd0, 8'd0};
    iReady_BM_WeightBias    = 1'b0;
    iReady_BM_Weight        = 1'b0;

#(PERIOD)
    iRST = 1;

#(PERIOD)
    iRST = 0;

#(PERIOD)
    for (i = 0; i < NC; i = i + 1) begin
        biasweight0.r_bias[i*WV +: WV] = i[WV-1:0];
    end
    
    for (i = 0; i < NP; i = i + 1) begin
        for (j = 0; j < NC; j = j + 1) begin
            biasweight0.r_weight[i*NC*WV + j*WV +: WV] = (i * NC + j);
        end
    end

#(PERIOD * 5)
    iValid_AS_State1        = 1'b1;
    iData_AS_State1         = {8'd30, 8'd20, 8'd10};
    iReady_BM_WeightBias    = 1'b1;

#(PERIOD * 10)
    iValid_AS_Delta1        = 1'b1;
    iData_AS_Delta1         = {8'd20, 8'd10};
    
#(PERIOD)
    iValid_AS_State1        = 1'b0;
    iData_AS_State1         = {8'd0, 8'd0, 8'd0};    
    iValid_AS_Delta1        = 1'b0;
    iData_AS_Delta1         = {8'd0, 8'd0, 8'd0};
    
#(PERIOD)
    iReady_BM_Weight        = 1'b1;
    
#(PERIOD)
    iReady_BM_WeightBias    = 1'b0;
    iReady_BM_Weight        = 1'b0;
    
#(PERIOD * 10)
    $finish;

end
endmodule
