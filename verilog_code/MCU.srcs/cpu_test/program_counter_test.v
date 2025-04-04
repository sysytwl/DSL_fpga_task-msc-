`timescale 1ns / 0.1ns
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12.03.2025 00:25:00
// Design Name: 
// Module Name: program_counter_test
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

module program_counter_test();

reg CLK;
initial begin // Generate a 100 MHz clock
    CLK = 0;
    forever #5 CLK = ~CLK; // 100 MHz clock period is 10 ns (5 ns high, 5 ns low)
end

reg RESET;
reg [2:0] cmd;
reg [7:0] count_in;
wire [7:0] counter;
wire irs_running;

program_counter uut (
    .CLK(CLK), 
    .RESET(RESET), 
    .cmd(cmd), 
    .count_in(count_in), 
    .counter(counter), 
    .irs_running(irs_running)
);

initial begin
    // Initialize Inputs
    RESET = 1;
    cmd = 0;
    count_in = 0;

    // Wait for global reset
    #20;
    RESET = 0;

    // Test pp1 command
    @(posedge CLK) cmd = 3'b001;//++1
    @(posedge CLK) cmd = 3'b000;//stop
    @(posedge CLK) cmd = 3'b001;//++1
    #1 if (counter != 2) $display("Test pp1 failed");

    // Test jump command
    @(posedge CLK) cmd = 3'b010;
    count_in = 8'd50;
    #1 if (counter != 50) $display("Test jump failed");

    // Test set2save command
    @(posedge CLK) cmd = 3'b011;
    #1 if (counter != 4) $display("Test set2save failed");

    // Test irs command
    @(posedge CLK) cmd = 3'b100;
    #1 if (counter != 192) $display("Test irs failed");

    // Test irs_running signal
    if (!irs_running) $display("Test irs_running failed");

    #9;

    $finish;
end

endmodule
