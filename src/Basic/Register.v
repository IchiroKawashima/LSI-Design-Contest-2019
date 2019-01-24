module Register #
( parameter WIDTH = 64
, parameter BURST = "no"
)
( input              iValid_AM
, output             oReady_AM
, input  [WIDTH-1:0] iData_AM
, output             oValid_BM
, input              iReady_BM
, output [WIDTH-1:0] oData_BM
, input              iRST
, input              iCLK
);

wire             wput;
wire             wget;
reg              rrdy;
reg              rvld;
reg  [WIDTH-1:0] rdata;

assign oReady_AM = rrdy;
assign oValid_BM = rvld;
assign oData_BM  = rdata;

//Put
assign wput = iValid_AM && rrdy;

//Get
assign wget = iReady_BM && rvld;

generate
    if (BURST == "yes") begin
        //Ready
        always @(posedge iCLK)
            if (iRST)
                rrdy <= 1'b1;
            else
                rrdy <= (rrdy)
                    ? !(wput && !wget && rvld)
                    : wget && !wput || !rvld;

        //Valid
        always @(posedge iCLK)
            if (iRST)
                rvld <= 1'b0;
            else
                rvld <= (rvld)
                    ? !(wget && !wput && rrdy)
                    : wput && !wget || !rrdy;

        //Data
        wire [WIDTH-1:0] wdata0;
        reg  [WIDTH-1:0] rdata0;

        assign wdata0 = (wput && rvld) ? iData_AM : rdata0;

        always @(posedge iCLK)
            rdata0 <= wdata0;

        always @(posedge iCLK)
            if (wput && !rvld)
                rdata <= iData_AM;
            else if (wget)
                rdata <= wdata0;
    end else begin
        //Ready
        always @(posedge iCLK)
            if (iRST)
                rrdy <= 1'b1;
            else
                rrdy <= (rrdy) ? !wput : wget;

        //Valid
        always @(posedge iCLK)
            if (iRST)
                rvld <= 1'b0;
            else
                rvld <= (rvld) ? !wget : wput;

        //Data
        always @(posedge iCLK)
            if (wput)
                rdata <= iData_AM;
    end
endgenerate

endmodule
