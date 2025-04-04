`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02.04.2025 19:53:03
// Design Name: 
// Module Name: TenHz_tb
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

module tb_TenHz_cnt;

    // Testbench signals
    reg CLK;
    reg RESET;
    wire SEND_PACKET;

    // Instantiate the TenHz_cnt module
    TenHz_counter uut (
        .CLK(CLK),
        .RESET(RESET),
        .SEND_PACKET(SEND_PACKET)
    );

    // Clock generation (100 MHz)
    always begin
        #5 CLK = ~CLK;  // 10 ns period for a 100 MHz clock
    end

    // Stimulus block
    initial begin
        // Initialize signals
        CLK = 0;
        RESET = 0;

        // Apply reset
        RESET = 1;       // Assert reset
        #20;             // Wait for 20 ns
        RESET = 0;       // Deassert reset

        // Run the simulation for some time to observe SEND_PACKET
        #200000000;      // Run for ~1 second (10 Hz -> 100 million cycles)
        $finish;         // End simulation
    end

    // Monitor the SEND_PACKET signal for debugging
    initial begin
        $monitor("Time: %t, SEND_PACKET: %b", $time, SEND_PACKET);
    end


endmodule
