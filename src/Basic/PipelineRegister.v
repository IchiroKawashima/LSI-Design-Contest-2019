module PipelineRegister #
( parameter WD = 4
)
( input             iValid_AS
, output            oReady_AS
, input    [WD-1:0] iData_AS
, output            oValid_BS
, input             iReady_BS
, output   [WD-1:0] oData_BS
, input             iRST
, input             iCLK
);

reg  [WD-1:0] r_stl;
reg  r_vld;
wire w_rdy;

assign oData_BS = r_stl;
assign oValid_BS = r_vld;
assign oReady_AS = w_rdy;
assign w_rdy = (r_vld) ? iReady_BS : 1;

always @(posedge iCLK) begin
    if (iRST) begin
        r_stl <= 0;
        r_vld <= 0;
    end
    else begin
        r_stl <= (iValid_AS && w_rdy) ? iData_AS : r_stl;
        r_vld <= (r_vld) ? !((!iValid_AS) && w_rdy) : iValid_AS;
    end
end

endmodule