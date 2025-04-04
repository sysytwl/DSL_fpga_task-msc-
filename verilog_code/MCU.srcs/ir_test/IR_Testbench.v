`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 27.03.2025 22:11:10
// Design Name: 
// Module Name: IR_Testbench
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
module IRTransmitter_TB;
    
    reg CLK;
    reg RESET;
    wire IR_LED;
    wire SEND_PACKET;
    reg [3:0] COMMAND;
    
    IRTransmitterSM IR_DUT(
        .CLK(CLK),
        .RESET(RESET),
        .IR_LED(IR_LED),
        .SEND_PACKET(SEND_PACKET),
        .COMMAND(COMMAND)
    );
    
    TenHz_counter TenHz_DUT(
        .CLK(CLK),
        .SEND_PACKET(SEND_PACKET),
        .RESET(RESET)
    );
    
    //Clock Generation
    initial begin 
        CLK = 0;
        forever begin
            #5
            CLK = ~CLK;
        end
    end
    
    initial begin
        RESET = 0;
        #10
        RESET = 1;
        #10
        RESET = 0;
    end
    
    initial begin
        
        // Initial Command
        COMMAND = 4'b0000; //  No operation
        #120000000;
        
        // Command 1: Move Right
        COMMAND = 4'b0100;  // Right direction command
        #120000000
        
        // Command 2: Move Left
        COMMAND = 4'b1000;  // Left direction command
        #120000000;
        
        // Command 3: Move Forward
        COMMAND = 4'b0010;  // Forward direction command
        #120000000;
        
        // Command 4: Move Backward
        COMMAND = 4'b0001;  // Backward direction command
        #120000000;
        
        // Command 5: Assert Forward
        COMMAND = 4'b1100;  // Combination for Assert Forward
        #120000000;
        
        // Command 6: Assert Backward
        COMMAND = 4'b1110;  // Combination for Assert Backward
        #120000000;
        
        // Command 7: Assert Right
        COMMAND = 4'b1111;  // Assert Right
        #120000000;
        
        // Command 8: Assert Left
        COMMAND = 4'b0011;  // Assert Left
        #120000000;
        
       #120000000; // Run the simulation for 400000 time units
        $finish;  // End simulation
       
    end
    
    
    // Signal Monitoring
    initial begin
        $monitor("Time=%0t, RESET=%b, COMMAND=%b, IR_LED=%b, SEND_PACKET=%b", $time, RESET, COMMAND, IR_LED, SEND_PACKET);
    end
    
endmodule
