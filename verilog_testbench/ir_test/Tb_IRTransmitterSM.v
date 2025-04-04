`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02.04.2025 20:27:43
// Design Name: 
// Module Name: Tb_IRTransmitterSM
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


module tb_IRTransmitterSM;

    // Testbench signals
    reg CLK;                  // System clock
    reg RESET;                // Reset signal
    reg [3:0] COMMAND;        // Command to be transmitted
    reg SEND_PACKET;          // Signal to start packet transmission
    wire IR_LED;              // IR LED output signal
    wire PHASE_FINISHED;      // Phase finished output
    wire [3:0] CURR_STATE;    // Current state
    wire [3:0] NEXT_STATE;    // Next state
    wire CAR_CLK;             // Carrier clock
    wire SEND_PACKET_REC;     // Processed send packet signal
    wire [3:0] CURR_COMMAND;  // Currently processed command
    wire [3:0] COMMAND_COUNT; // Command bit count
    wire NOT_CAR_CLK;         // Inverted carrier clock
    wire [24:0] CLK_COUNT;    // Clock counter value
    wire [24:0] CLK_COUNT_TARGET; // Target count value for clock counter
    wire CLK_COUNT_FINISHED;  // Indicates when clock count target is reached
    wire [15:0] CLK_COUNTER;  // Carrier clock counter

    // Instantiate the IRTransmitterSM module
    IRTransmitterSM irsm (
        .CLK(CLK),
        .COMMAND(COMMAND),
        .SEND_PACKET(SEND_PACKET),
        .RESET(RESET),
        .IR_LED(IR_LED),
        .PHASE_FINISHED(PHASE_FINISHED),
        .CURR_STATE(CURR_STATE),
        .NEXT_STATE(NEXT_STATE),
        .CAR_CLK(CAR_CLK),
        .SEND_PACKET_REC(SEND_PACKET_REC),
        .CURR_COMMAND(CURR_COMMAND),
        .COMMAND_COUNT(COMMAND_COUNT),
        .NOT_CAR_CLK(NOT_CAR_CLK),
        .CLK_COUNT(CLK_COUNT),
        .CLK_COUNT_TARGET(CLK_COUNT_TARGET),
        .CLK_COUNT_FINISHED(CLK_COUNT_FINISHED),
        .CLK_COUNTER(CLK_COUNTER)
    );

    // Generate a clock signal with a period of 10 ns (100 MHz)
    initial begin
        CLK = 0;
        forever #5 CLK = ~CLK;  // Toggle every 5 ns (10 ns period)
    end

    // Test sequence
    initial begin
        // Initialize signals
        RESET = 1;               // Start with reset active
        SEND_PACKET = 0;         // No packet sending initially
        COMMAND = 4'b0000;       // Initial command is 0
        
        // Display signals for monitoring
        $monitor("Time: %t, RESET: %b, SEND_PACKET: %b, COMMAND: %b, IR_LED: %b, PHASE_FINISHED: %b, CURR_STATE: %b, CAR_CLK: %b", 
                 $time, RESET, SEND_PACKET, COMMAND, IR_LED, PHASE_FINISHED, CURR_STATE, CAR_CLK);

        // Apply reset
        #10 RESET = 0;  // Deassert reset after 10 ns

        // Test case 1: Send a command with SEND_PACKET signal
        #20 COMMAND = 4'b1010;        // Change command to 1010
        SEND_PACKET = 1;              // Start sending the packet
        #40 SEND_PACKET = 0;          // Stop sending the packet after some time

        // Test case 2: Send another command after some delay
        #60 COMMAND = 4'b1100;        // Change command to 1100
        SEND_PACKET = 1;              // Start sending the packet
        #40 SEND_PACKET = 0;          // Stop sending the packet after some time
        
        // Test case 3: Reset the system and send a new command
        #80 RESET = 1;                // Assert reset again
        #10 RESET = 0;                // Deassert reset
        COMMAND = 4'b0011;            // Change command to 0011
        SEND_PACKET = 1;              // Start sending the packet
        #40 SEND_PACKET = 0;          // Stop sending the packet after some time

        // Finish simulation after a while
        #100 $finish;
    end

endmodule
