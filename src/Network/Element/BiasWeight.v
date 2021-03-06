`include "Parameter.vh"

module BiasWeight #
( parameter NP    = 4
, parameter NC    = 4
, parameter WV    = 4
, parameter SEED  = 123456789
, parameter BURST = "yes"
)
( input                       iMode
, input              [WV-1:0] iLR
, input                       iValid_AS_State1
, output                      oReady_AS_State1
, input           [NP*WV-1:0] iData_AS_State1
, input                       iValid_AS_Delta1
, output                      oReady_AS_Delta1
, input           [NC*WV-1:0] iData_AS_Delta1
, output                      oValid_BM_WeightBias
, input                       iReady_BM_WeightBias
, output [NC*NP*WV+NC*WV-1:0] oData_BM_WeightBias
, output                      oValid_BM_Weight
, input                       iReady_BM_Weight
, output       [NP*NC*WV-1:0] oData_BM_Weight
, input                       iRST
, input                       iCLK
);

`DECLARE_MODE_PARAMETERS

genvar gi, gj;

// init file
wire      [NP*NC*WV-1:0] w_init_weight;
wire         [NC*WV-1:0] w_init_bias;
wire [(NC*NP+NC)*32-1:0] w_x32_init;

localparam MAX  = {2'b00, {WV-1{1'b1}}},
           MIN  = {2'b11, {WV-1{1'b0}}};

Xor32Initializer #
( .SIZE(NC*NP+NC)
, .SEED0(SEED)
) xor32Initializer
( .oInit(w_x32_init)
);

generate
    for (gi = 0; gi < NP; gi = gi + 1)
        for (gj = 0; gj < NC; gj = gj + 1)
            assign w_init_weight[(gi*NC+gj)*WV+:WV]
                = w_x32_init[(gi*NC+gj+NC)*32+:WV];

    for (gi = 0; gi < NC; gi = gi + 1)
            assign w_init_bias[gi*WV+:WV] = w_x32_init[gi*32+:WV];
endgenerate

// combiner 0
wire                   w_vld_bm_comb0;
wire                   w_rdy_bm_comb0;
wire [NC*WV+NP*WV-1:0] w_dat_bm_comb0; // 0:LSB side, 1:MSB side

Combiner #
( .WIDTH0       (NP*WV)
, .WIDTH1       (NC*WV)
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
wire signed     [WV-1:0] w_dc0  [0:NC-1];
wire signed [WV*2-1-1:0] w_adc0_tmp [0:NC-1];
wire signed     [WV-1:0] w_adc0 [0:NC-1];

wire                   w_vld_as_pipe0;
wire                   w_rdy_as_pipe0;
wire [NC*WV+NP*WV-1:0] w_dat_as_pipe0;

assign w_dat_as_pipe0[NP*WV-1:0] = w_dat_bm_comb0[NP*WV-1:0];

generate
for (gi = 0; gi < NC; gi = gi + 1) begin : gen_w_adc0
    assign w_dc0[gi] = w_dat_bm_comb0[NP*WV + gi*WV +: WV];
    assign w_adc0_tmp[gi] = $signed(iLR) * w_dc0[gi];
    assign w_adc0[gi] = w_adc0_tmp[gi][WV-1 +: WV];
    
    assign w_dat_as_pipe0[NP*WV + gi*WV +: WV] = w_adc0[gi];
end
endgenerate

wire                   w_vld_bs_pipe0;
wire                   w_rdy_bs_pipe0;
wire [NC*WV+NP*WV-1:0] w_dat_bs_pipe0;  // adc, yc

assign w_vld_as_pipe0 = w_vld_bm_comb0;
assign w_rdy_bm_comb0 = w_rdy_as_pipe0;

PipelineRegister #
( .WD           (NC*WV+NP*WV)
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
wire signed          [WV-1:0] w_adc1      [0:NC-1];
wire signed          [WV-1:0] w_yc1       [0:NP-1];
wire signed [NC*(2*WV-1)-1:0] w_adyc1_tmp [0:NP-1];
wire signed       [NC*WV-1:0] w_adyc1     [0:NP-1];

wire                      w_vld_as_pipe1;
wire                      w_rdy_as_pipe1;
wire [NP*NC*WV+NC*WV-1:0] w_dat_as_pipe1;   // adyc1, adc1

assign w_vld_as_pipe1 = w_vld_bs_pipe0;
assign w_rdy_bs_pipe0 = w_rdy_as_pipe1;

generate
for (gi = 0; gi < NP; gi = gi + 1) begin : gen_w_yc1
    assign w_yc1[gi] = w_dat_bs_pipe0[gi*WV +: WV];
end

for (gi = 0; gi < NC; gi = gi + 1) begin : gen_w_adc1
    assign w_adc1[gi] = w_dat_bs_pipe0[NP*WV + gi*WV +: WV];
end

for (gi = 0; gi < NP; gi = gi + 1) begin : gen_w_adyc1_i
    for (gj = 0; gj < NC; gj = gj + 1) begin : gen_w_adyc1_j
        assign w_adyc1_tmp[gi][gj*(2*WV-1) +: 2*WV-1] = w_yc1[gi] *w_adc1[gj];
        assign w_adyc1[gi][gj*WV +: WV] = w_adyc1_tmp[gi][gj*(2*WV-1) + WV-1 +: WV];
    end
end

for (gi = 0; gi < NC; gi = gi + 1) begin  : gen_w_dat_as_pipe1_0
    assign w_dat_as_pipe1[gi*WV +: WV] = w_adc1[gi]; 
end

for (gi = 0; gi < NP; gi = gi + 1) begin : gen_w_dat_as_pipe1_1
    assign w_dat_as_pipe1[gi*(NC*WV) + NC*WV +: NC*WV] = w_adyc1[gi];
end
endgenerate

wire                      w_vld_bs_pipe1;
wire                      w_rdy_bs_pipe1;
wire [NP*NC*WV+NC*WV-1:0] w_dat_bs_pipe1;   // adyc1, adc1

PipelineRegister #
( .WD           (NP*NC*WV+NC*WV)
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
wire signed            [WV-1:0] w_adc2  [0:NC-1];
wire signed         [NC*WV-1:0] w_adyc2 [0:NP-1];
wire signed     [NC*(WV+1)-1:0] w_bias;
wire signed         [NC*WV-1:0] w_bias_clp;

wire signed  [NP*NC*(WV+1)-1:0] w_weight;
wire signed      [NP*NC*WV-1:0] w_weight_clp;

reg  signed         [NC*WV-1:0] r_bias;
reg  signed      [NP*NC*WV-1:0] r_weight;
reg                             r_vld_bias_weight;

wire             [NC*NP*WV-1:0] w_weight_t;

wire                       w_vld_am_broad2;
wire                       w_rdy_am_broad2;
wire                       w_vld_bm0_broad2;
wire                       w_rdy_bm0_broad2;
wire  [NC*NP*WV+NC*WV-1:0] w_dat_bm0_broad2;
wire                       w_vld_bm1_broad2;
wire                       w_rdy_bm1_broad2;
wire        [NP*NC*WV-1:0] w_dat_bm1_broad2;
wire                       w_vld_am_reg3;
wire                       w_rdy_am_reg3;
wire        [NP*NC*WV-1:0] w_dat_am_reg3;

generate
for (gi = 0; gi < NC; gi = gi + 1) begin : gen_w_adc2
    assign w_adc2[gi] = w_dat_bs_pipe1[gi*WV +: WV];
end

for (gi = 0; gi < NP; gi = gi + 1) begin : gen_w_adyc2
    assign w_adyc2[gi] = w_dat_bs_pipe1[gi*(NC*WV) + NC*WV +: NC*WV];
end

for (gi = 0; gi < NC; gi = gi + 1) begin : gen_w_bias
    assign w_bias[gi*(WV+1) +: WV+1] = $signed(r_bias[gi*WV +: WV]) - $signed(w_adc2[gi]);
    assign w_bias_clp[gi*WV +: WV] = ($signed(w_bias[gi*(WV+1)+:WV+1]) > $signed(MAX)) ? MAX[0+:WV] :
                  ($signed(w_bias[gi*(WV+1)+:WV+1]) < $signed(MIN)) ? MIN[0+:WV] :
                  w_bias[gi*(WV+1)+:WV+1];
end

for (gi = 0; gi < NP; gi = gi + 1) begin : gen_w_weight_i
    for (gj = 0; gj < NC; gj = gj + 1) begin : gen_w_weight_j
        assign w_weight[gi*NC*WV + gj*WV +: WV] = $signed(r_weight[gi*NC*WV + gj*WV +: WV]) - $signed(w_adyc2[gi][gj*WV +: WV]);
        assign w_weight_clp[gi*NC*WV + gj*WV +: WV] = ($signed(w_weight[gi*NC*(WV+1) + gj*(WV+1) +: WV+1]) > $signed(MAX)) ? MAX[0+:WV] :
                  ($signed(w_weight[gi*NC*(WV+1) + gj*(WV+1) +: WV+1]) < $signed(MIN)) ? MIN[0+:WV] :
                  w_weight[gi*(WV+1)+:WV+1];
    end
end

for (gi = 0; gi < NP; gi = gi + 1) begin : gen_w_weight_t_i
    for (gj = 0; gj < NC; gj = gj + 1) begin : gen_w_weight_t_j
        //assign w_weight_t[(gi*NC+gj)*WV +: WV] = r_weight[(gj*NP+gi)*WV +: WV];
        assign w_weight_t[gj*NP*WV + gi*WV +: WV] = r_weight[gi*NC*WV + gj*WV +: WV];
    end
end
endgenerate

assign w_vld_am_broad2 = r_vld_bias_weight;
assign w_rdy_bs_pipe1 = w_rdy_am_broad2;


//localparam  IDLE = 2'b00,
//            FOR  = 2'b01,
//            BACK = 2'b10;
localparam  RUN   = 2'b00,
            INIT0 = 2'b01,
            INIT1 = 2'b10;

reg [1:0] r_stt;

always @(posedge iCLK) begin
    if (iRST) begin
        r_bias                  <= w_init_bias;
        r_weight                <= w_init_weight;
        r_vld_bias_weight       <= 0;
        r_stt                   <= INIT0;
    end
    else begin
        if (iMode == TRAIN) begin
            if (w_vld_bs_pipe1) begin
                r_bias          <= w_bias_clp;
                r_weight        <= w_weight;
            end
            r_vld_bias_weight   <= w_vld_bs_pipe1;
        
            if (r_stt == INIT0) begin
                if (iReady_BM_WeightBias)
                    r_stt       <= INIT1;
            end
            else if (r_stt == INIT1) begin
                if (iReady_BM_Weight)
                    r_stt       <= RUN;
            end
            else begin
                r_stt           <= RUN;
            end
        end
    end
end

//assign w_rdy_bm0_broad2     = (iMode == TRAIN) ? iReady_BM_WeightBias : 1'b0;
//assign oValid_BM_WeightBias = (iMode == TRAIN) ? w_vld_bm0_broad2 : iReady_BM_WeightBias;
//assign oData_BM_WeightBias  = (iMode == TRAIN) ? w_dat_bm0_broad2 : {w_weight_t, r_bias};
assign w_rdy_bm0_broad2     = (iMode == TEST  || r_stt == INIT0) ? 1'b0                 : iReady_BM_WeightBias;
assign oValid_BM_WeightBias = (iMode == TEST  || r_stt == INIT0) ? iReady_BM_WeightBias : w_vld_bm0_broad2;
assign oData_BM_WeightBias  = (iMode == TEST  || r_stt == INIT0) ? {r_weight, r_bias} : w_dat_bm0_broad2;
assign w_rdy_bm1_broad2     = (r_stt == INIT0 || r_stt == INIT1) ? 1'b0                 : w_rdy_am_reg3;
assign w_vld_am_reg3        = (r_stt == INIT0 || r_stt == INIT1) ? w_rdy_am_reg3        : w_vld_bm1_broad2;
assign w_dat_am_reg3        = (r_stt == INIT0 || r_stt == INIT1) ? r_weight             : w_dat_bm1_broad2;

Broadcaster #
( .WIDTH0       (NC*NP*WV+NC*WV)
, .WIDTH1       (NP*NC*WV)
, .BURST        (BURST)
) broadcaster2
( .iValid_AM    (w_vld_am_broad2)
, .oReady_AM    (w_rdy_am_broad2)
, .iData_AM     ({r_weight, {r_weight, r_bias}})
, .oValid_BM0   (w_vld_bm0_broad2)
, .iReady_BM0   (w_rdy_bm0_broad2)
, .oData_BM0    (w_dat_bm0_broad2)
, .oValid_BM1   (w_vld_bm1_broad2)
, .iReady_BM1   (w_rdy_bm1_broad2)
, .oData_BM1    (w_dat_bm1_broad2)
, .iRST         (iRST)
, .iCLK         (iCLK)
);

Register #
( .WIDTH(NP*NC*WV) 
, .BURST(BURST)
) register3
( .iValid_AM(w_vld_am_reg3)       
, .oReady_AM(w_rdy_am_reg3)      
, .iData_AM (w_dat_am_reg3)
, .oValid_BM(oValid_BM_Weight) 
, .iReady_BM(iReady_BM_Weight) 
, .oData_BM(oData_BM_Weight)
, .iRST(iRST)            
, .iCLK(iCLK)
);

endmodule
