module Xor32Initializer #
( parameter SIZE  = 8
, parameter SEED0 = 123456789
, parameter SEED1 = 362436069
, parameter SEED2 = 521288629
, parameter SEED3 = 088675123
)
( output [SIZE*32-1:0] oInit
);

genvar gi;

wire [(SIZE+4)*32-1:0] wxval;

assign oInit = wxval[4*32+:SIZE*32];

generate
    for (gi = 0; gi < SIZE + 4; gi = gi + 1)
        if (gi == 0)
            assign wxval[gi*32+:32] = SEED0;
        else if (gi == 1)
            assign wxval[gi*32+:32] = SEED1;
        else if (gi == 2)
            assign wxval[gi*32+:32] = SEED2;
        else if (gi == 3)
            assign wxval[gi*32+:32] = SEED3;
        else begin
            wire [31:0] wtemp;

            assign wtemp
                = wxval[(gi-4)*32+:32]
                ^ {wxval[(gi-4)*32+11+:21], {11{1'b0}}};

            assign wxval[gi*32+:32]
                = ( wxval[(gi-1)*32+:32]
                  ^ {{19{1'b0}}, wxval[(gi-1)*32+31-:13]})
                ^ ( wtemp
                  ^ {{8{1'b0}}, wtemp[31-:24]});
        end
endgenerate

endmodule
