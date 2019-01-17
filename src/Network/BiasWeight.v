module BiasWeight #
( parameter HIDDEN = "yes"
, parameter NP     = 4
, parameter NC     = 4
, parameter WC     = 4
, parameter WD     = 4
)
( input                                                               iMode
, input                                                               iValid_AS
, output                                                              oReady_AS
, input  [NP*WD+(HIDDEN=="yes")?NC*($clog2(NN)+WC+WD):NC*(WC+WD)-1:0] iData_AS
, output                                                              oValid_BS
, input                                                               iReady_BS
, output                                    [NP*NC*WD+NC*WD+NC*NP*WD] oData_BS
, input                                                               iRST
, input                                                               iCLK
);

endmodule
