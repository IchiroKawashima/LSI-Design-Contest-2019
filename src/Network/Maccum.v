module Maccum #
( parameter NP = 4
, parameter NC = 4
, parameter WD = 4
)
( input                             iValid_AS
, output                            oReady_AS
, input  [NP*WD+NP*NC*WD+NC*WD-1:0] iData_AS
, output                            oValid_BS
, input                             iReady_BS
, output  [NC*($clo2(NP)+1+WD)-1:0] oData_BS
, input                             iRST
, input                             iCLK
);

endmodule
