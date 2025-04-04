`timescale 1ns / 1ps

module test_VGA_TOP;

    // Inputs
    reg CLK;
    reg RESET;
    reg BUS_CLK;
    reg BUS_WE;
    reg [7:0] BUS_ADDR;
    reg [7:0] BUS_DATA_IN;

    // Outputs
    wire [7:0] VGA_DATA;
    wire VGA_HS;
    wire VGA_VS;

    // Bidirectional BUS_DATA
    wire [7:0] BUS_DATA;
    assign BUS_DATA = (BUS_WE) ? BUS_DATA_IN : 8'bz;

    // Instantiate the Unit Under Test (UUT)
    VGA_TOP uut (
        .CLK(CLK),
        .RESET(RESET),
        .BUS_CLK(BUS_CLK),
        .BUS_WE(BUS_WE),
        .BUS_ADDR(BUS_ADDR),
        .BUS_DATA(BUS_DATA),
        .VGA_DATA(VGA_DATA),
        .VGA_HS(VGA_HS),
        .VGA_VS(VGA_VS)
    );

    // Clock generation
    initial begin
        CLK = 0;
        forever #5 CLK = ~CLK; // 100MHz clock
    end

    initial begin
        BUS_CLK = 0;
        forever #10 BUS_CLK = ~BUS_CLK; // 50MHz clock
    end

    // Testbench logic
    initial begin
        // Initialize inputs
        RESET = 1;
        BUS_WE = 0;
        BUS_ADDR = 0;
        BUS_DATA_IN = 0;

        // Wait for global reset
        #100;
        RESET = 0;

        #10;

        // Test writing to video_addr high byte
        BUS_WE = 1;
        BUS_ADDR = 8'hB0; // baseaddr
        BUS_DATA_IN = 8'h09;
        #20;

        // Test writing to video_addr low byte
        BUS_ADDR = 8'hB1; // baseaddr + 1
        BUS_DATA_IN = 8'h61;
        #20;

        // Test writing data
        BUS_ADDR = 8'hB2; // baseaddr + 2
        BUS_DATA_IN = 8'hFA;
        #20;


        // Add more tests as needed for other functionality
        BUS_ADDR = 8'hff;
        BUS_DATA_IN = 8'h00;
        #20;
        
        // Finish simulation
        #40000;
        $stop;
    end

endmodule