`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 27.03.2025 21:58:05
// Design Name: 
// Module Name: IR_Transmitter
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

module IRTransmitter #(
  parameter  [7:0] IRBaseAddress = 8'h90, // Base address for IR communication on the bus
  parameter  [3:0] RESET_COMMAND=4'h0    //Reset
)(
    input CLK,             // System clock input
    input RESET,           // Active-high reset signal

    input [7:0] BUS_ADDR,  // Bus address input
    input [7:0] BUS_DATA,  // Bus data input
    input BUS_WE,          // Write enable signal for the bus
    input BUS_CLK,

    output IR_LED          // Output signal to drive the IR LED
);

// Signal that triggers the transmission of an IR packet
wire SEND_PACKET;

// 4-bit command register to store control commands
reg [3:0] command;


// Instantiate the IR transmitter state machine
IRTransmitterSM IR(
    .CLK(CLK),          // Connect system clock
    .RESET(RESET),      // Connect reset signal
    .IR_LED(IR_LED),    // Output IR LED control signal
    .COMMAND(command),  // Input command for transmission
    .SEND_PACKET(SEND_PACKET) // Signal to initiate transmission
);

// Instantiate the 10 Hz counter module to control the transmission timing
TenHz_cnt Ten_Hz (
    .CLK(CLK),          // Connect system clock
    .SEND_PACKET(SEND_PACKET), // Generate periodic send pulses
    .RESET(RESET)       // Connect reset signal
);

// Sequential logic to store the command from the bus interface
always@(posedge BUS_CLK) begin
    if (RESET)  
        command <= RESET_COMMAND;  // Reset the command to zero on reset
    else if (BUS_WE & (BUS_ADDR == IRBaseAddress))  
        command <= BUS_DATA[3:0];  // Update command when a write is detected at IRBaseAddress
end
    
endmodule 

