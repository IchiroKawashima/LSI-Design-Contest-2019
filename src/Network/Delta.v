module Delta #
( parameter HIDDEN = "yes"
, parameter NC     = 4
, parameter NN     = 4
, parameter WC     = 4
, parameter WD     = 4
)
( input                                                         iValid_AS
, output                                                        oReady_AS
, input    [((HIDDEN=="yes")?NC*(WC+WD)+NN*NC*WD+NN*(WC+WD):
                                    NC*(WC+WD)+NC*(WC+WD))-1:0] iData_AS
, output                                                        oValid_BS
, input                                                         iReady_BS
, output [(HIDDEN=="yes")?NC*($clog2(NN)+WC+WD):NC*(WC+WD)-1:0] oData_BS
, input                                                         iRST
, input                                                         iCLK
);

endmodule
