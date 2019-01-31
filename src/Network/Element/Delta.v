module Delta #
( parameter HIDDEN = "yes"
, parameter NP     = 5
, parameter NC     = 6
, parameter NN     = 7
, parameter WV     = 4
, parameter BURST  = "yes"
)
( input                             iValid_AS_Accum1
, output                            oReady_AS_Accum1
, input  [NC*($clog2(NP)+1+WV)-1:0] iData_AS_Accum1
, input                             iValid_AS_Accum2
, output                            oReady_AS_Accum2
, input                 [NC*WA-1:0] iData_AS_Accum2
, output                            oValid_BM_Delta0
, input                             iReady_BM_Delta0
, output                [NC*WV-1:0] oData_BM_Delta0
, output                            oValid_BM_Delta1
, input                             iReady_BM_Delta1
, output                [NC*WV-1:0] oData_BM_Delta1
, input                             iRST
, input                             iCLK
);

genvar gi;

localparam WA = (HIDDEN == "yes") ? ($clog2(NN) + WV) : ($clog2(NP) + 1 + WV);

localparam ONE  = {{$clog2(NP){1'b0}}, 1'b0, {WV-1{1'b1}}},
           ZERO = {{$clog2(NP){1'b0}}, 1'b0, {WV-1{1'b0}}},
           MAX  = {{WA-WV{1'b0}}, 1'b0, {WV-1{1'b1}}},
           MIN  = {{WA-WV{1'b1}}, 1'b1, {WV-1{1'b0}}};

wire                            wvld_a12;
wire                            wrdy_a12;
wire [NC*($clog2(NP)+1+WV)-1:0] wdata_a1;
wire                [NC*WA-1:0] wdata_a2;
wire                [NC*WA-1:0] wdata_a12;
wire            [NC*(WA+1)-1:0] wdata_a12_of;
wire                [NC*WV-1:0] wdata_sat;

Combiner #
( .WIDTH0(NC*($clog2(NP)+1+WV))
, .WIDTH1(NC*WA)
) combiner
( .iValid_AS0(iValid_AS_Accum1)
, .oReady_AS0(oReady_AS_Accum1)
, .iData_AS0(iData_AS_Accum1)
, .iValid_AS1(iValid_AS_Accum2)
, .oReady_AS1(oReady_AS_Accum2)
, .iData_AS1(iData_AS_Accum2)
, .oValid_BM(wvld_a12)
, .iReady_BM(wrdy_a12)
, .oData_BM({wdata_a2, wdata_a1})
);

generate
    for (gi = 0; gi < NC; gi = gi + 1) begin
        if (HIDDEN == "yes")
            assign wdata_a12[gi*WA+:WA]
                =  ( $signed(wdata_a1[gi*($clog2(NP)+1+WV)+:$clog2(NP)+1+WV])
                   > $signed(ONE)
                  || $signed(wdata_a1[gi*($clog2(NP)+1+WV)+:$clog2(NP)+1+WV])
                   < $signed(ZERO)
                   ) ? {WA{1'b0}} : wdata_a2[gi*WA+:WA];
        else begin
            assign wdata_a12_of[gi*(WA+1) +: WA+1]
                = $signed(wdata_a1[gi*($clog2(NP)+1+WV)+:$clog2(NP)+1+WV])
                - $signed(wdata_a2[gi*WA+:WA]);
                
            assign wdata_a12[gi*WA+:WA]
                = ($signed(wdata_a12_of[gi*(WA+1) +: (WA+1)]) > $signed({1'b0, MAX})) ? MAX[0+:WA] :
                  ($signed(wdata_a12_of[gi*(WA+1) +: (WA+1)]) < $signed({1'b1, MIN})) ? MIN[0+:WA] :
                  wdata_a12_of[gi*(WA+1) +:WA];
        end
        
        assign wdata_sat[gi*WV+:WV]
            = ($signed(wdata_a12[gi*WA+:WA]) > $signed(MAX)) ? MAX[0+:WV] :
              ($signed(wdata_a12[gi*WA+:WA]) < $signed(MIN)) ? MIN[0+:WV] :
              wdata_a12[gi*WA+:WV];
    end
endgenerate

Broadcaster #
( .WIDTH0(NC*WV)
, .WIDTH1(NC*WV)
, .BURST(BURST)
) broadcaster
( .iValid_AM(wvld_a12)
, .oReady_AM(wrdy_a12)
, .iData_AM({wdata_sat, wdata_sat})
, .oValid_BM0(oValid_BM_Delta0)
, .iReady_BM0(iReady_BM_Delta0)
, .oData_BM0(oData_BM_Delta0)
, .oValid_BM1(oValid_BM_Delta1)
, .iReady_BM1(iReady_BM_Delta1)
, .oData_BM1(oData_BM_Delta1)
, .iRST(iRST)
, .iCLK(iCLK)
);

endmodule
