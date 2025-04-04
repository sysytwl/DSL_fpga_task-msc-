`timescale 1ns / 0.1ns
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Yingtong
// 
// Create Date: 11.03.2025 23:26:39
// Design Name: 
// Module Name: reg_sim_top
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module reg_sim_top();

reg CLK;
initial begin // Generate a 100 MHz clock
    CLK = 0;
    forever #5 CLK = ~CLK; // 100 MHz clock period is 10 ns (5 ns high, 5 ns low)
end

// Initialize reset
reg RESET;
initial begin
    RESET = 1;
    #20 RESET = 0; // Release reset after 20 ns
end

//all cmd test
reg [2:0] cmd;
wire [7:0] DATA2BUS;
assign DATA2BUS = cmd == 1 ? 8'h1a : 8'hZZ;
initial begin
    @(negedge RESET); //start from the falling edge of the reset
    @(posedge CLK) cmd <= 0;//doing nothing
    @(posedge CLK) cmd <= 3'b001;//write to reg
    @(posedge CLK) cmd <= 3'b010;//write to bus
    @(posedge CLK) cmd <= 3'b011;//write to alu
    @(posedge CLK) cmd <= 3'b100;//write to bus addr
    @(posedge CLK) cmd <= 3'b101;//doing nothing
    @(posedge CLK) cmd <= 3'b110;//doing nothing
    @(posedge CLK) cmd <= 3'b111;//doing nothing
    #10;
    $finish;
end

regs u_regs(
    .CLK          	(CLK           ),
    .RESET        	(RESET         ),
    .cmd          	(cmd           ),
    .DATA2BUS     	(DATA2BUS      ),
    .DATA2BUSADDR 	(),
    .DATA2ALU     	()
);


endmodule
