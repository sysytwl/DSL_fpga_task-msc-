`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 13.03.2025 13:44:21
// Design Name: 
// Module Name: ram_test
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

module ram_test;

    // Parameters
    parameter RAMBaseAddr = 0;
    parameter RAMHighAddr = 128;
    parameter RAMAddrWidth = 8;

    // Inputs
    reg CLK;
    reg [7:0] BUS_ADDR;
    reg BUS_WE;

    // Inouts
    wire [7:0] BUS_DATA;

    // Internal signals
    reg [7:0] data_in;
    wire [7:0] data_out;

    // Instantiate the RAM module
    RAM #(
        .RAMBaseAddr(RAMBaseAddr),
        .RAMHighAddr(RAMHighAddr),
        .RAMAddrWidth(RAMAddrWidth)
    ) uut (
        .CLK(CLK),
        .BUS_DATA(BUS_DATA),
        .BUS_ADDR(BUS_ADDR),
        .BUS_WE(BUS_WE)
    );

    // Tristate buffer for BUS_DATA
    assign BUS_DATA = (BUS_WE) ? data_in : 8'hZZ;
    assign data_out = BUS_DATA;

    // Clock generation
    initial begin
        CLK = 0;
        forever #5 CLK = ~CLK;
    end

    // Test sequence
    initial begin
        // Initialize Inputs
        BUS_ADDR = 0;
        BUS_WE = 0;
        data_in = 0;

        // Write data to RAM
        @(posedge CLK);
        BUS_ADDR = 8'h01;
        data_in = 8'hAA;
        BUS_WE = 1;

        // Read data from RAM
        @(posedge CLK) BUS_ADDR = 8'h00;
        BUS_WE = 0;

        #1;
        @(posedge CLK) BUS_ADDR = 8'hFF;

        // Check if the data read is correct
        if (data_out !== 8'hAA) begin
            $display("Test failed: Expected 8'hAA, got %h", data_out);
        end

        // Finish simulation
        $finish;
    end

endmodule
