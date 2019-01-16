module Neuron #
( parameter HIDDEN = "yes"
, parameter NP     = 4
, parameter NC     = 4
, parameter WD     = 4
)
( input                                            iValid_AS
, output                                           oReady_AS
, input                  [NC*($clo2(NP)+1+WD)-1:0] iData_AS
, output                                           oValid_BS
, input                                            iReady_BS
, output [NC*((HIDDEN=="yes")?$clog2(NP)+1+WD:WD)] oData_BS
, input                                            iRST
, input                                            iCLK
);

endmodule
