`timescale 1ps / 1ps

module ClockDomain #
( parameter CYCLE = 10000 // 0..    [ps]
, parameter DUTY  = 50    // 0..100 [%]
, parameter PHASE = 0     // 0..360 [°]
);

localparam N_CYCLE = CYCLE * (100 - DUTY) / 100;
localparam P_CYCLE = CYCLE * DUTY / 100;
localparam DELAY   = CYCLE * PHASE / 360;

localparam STB = 1;

reg        CLK;
event      eCLK;
reg        RST;
reg        EN;
reg [31:0] CNT;

//Clock
initial begin
    CLK = 1'b0;
    #(DELAY) forever begin
        #(N_CYCLE) CLK = 1'b1;
        #(P_CYCLE) CLK = 1'b0;
    end
end

//Reset
initial begin
    RST = 1'b0;
    @(posedge CLK) #(STB) RST = 1'b1;
    @(posedge CLK) #(STB) RST = 1'b0;
end

initial begin
    forever
        @(posedge CLK) #(STB) -> eCLK;
end

//Enable
initial begin
    EN = 1'b0;
    @(posedge CLK);
    @(posedge CLK) #(STB) EN = 1'b1;
end

//Count
initial begin
    CNT = {32{1'b0}};
    @(posedge CLK);
    forever
        @(posedge CLK) #(STB) CNT = CNT + 1'b1;
end

endmodule
