module BiasWeight #
( parameter HIDDEN = "yes"
, parameter NP     = 4
, parameter NC     = 4
, parameter WI     = 4
, parameter WF     = 4
)
( input                                                               iMode
, input                                                      [WD-1:0] iLR
, input                                                               iValid_AS
, output                                                              oReady_AS
, input  [NP*WD+(HIDDEN=="yes")?NC*($clog2(NN)+WC+WD):NC*(WC+WD)-1:0] iData_AS
, output                                                              oValid_BS
, input                                                               iReady_BS
, output                                    [NP*NC*WD+NC*WD+NC*NP*WD] oData_BS
, input                                                               iRST
, input                                                               iCLK
);

genvar gi;

// pipeline 0
wire signed             [(HIDDEN=="yes")?($clog2(NN)+WC+WD):(WC+WD)-1:0] w_dc  [0:NC-1];
wire signed             [(HIDDEN=="yes")?($clog2(NN)+WC+WD):(WC+WD)-1:0] w_adc [0:NC-1];    // bit width ?
wire        [NP*WD+(HIDDEN=="yes")?NC*($clog2(NN)+WC+WD):NC*(WC+WD)-1:0] w_dat_as0;

assign w_dat_as0[NP*WD-1:0] = iData_AS[NP*WD-1:0];

generate
for (gi = 0; gi < NC; gi = gi + 1) begin : w_adc
    assign w_dc[gi] = iData_AS[NP*WD + gi*((HIDDEN=="yes")?($clog2(NN)+WC+WD):(WC+WD)) +: (HIDDEN=="yes")?($clog2(NN)+WC+WD):(WC+WD)];
    assign w_adc[gi] = iLR * w_dc[gi];
    assign w_dat_as0[NP*WD + gi*((HIDDEN=="yes")?($clog2(NN)+WC+WD):(WC+WD)) +: (HIDDEN=="yes")?($clog2(NN)+WC+WD):(WC+WD)] = w_adc[gi];
end
endgenerate

wire w_vld_as0;
wire w_rdy_as0;

assign 

PipelineRegister #
( .WD           (NP*WD+(HIDDEN=="yes")?NC*($clog2(NN)+WC+WD):NC*(WC+WD))
) pipeline_register0
( .iValid_AS    (w_vld_as0)
, .oReady_AS    (w_rdy_as0)
, .iData_AS     (w_dat_as0)
, .oValid_BS    (w_vld_bs0)
, .iReady_BS    (w_rdy_bs0)
, .oData_BS     ()
, .iRST         (iRST)
, .iCLK         (iCLK)
);

// pipeline 1
PipelineRegister #
( .WD           ()
) pipeline_register1
( .iValid_AS    ()
, .oReady_AS    ()
, .iData_AS     ()
, .oValid_BS    ()
, .iReady_BS    ()
, .oData_BS     ()
, .iRST         (iRST)
, .iCLK         (iCLK)
);

// pipeline 2
PipelineRegister #
( .WD           ()
) pipeline_register2
( .iValid_AS    ()
, .oReady_AS    ()
, .iData_AS     ()
, .oValid_BS    ()
, .iReady_BS    ()
, .oData_BS     ()
, .iRST         (iRST)
, .iCLK         (iCLK)
);

endmodule
