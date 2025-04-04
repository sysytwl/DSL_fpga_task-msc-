`timescale 1ns / 1ps

module test_top;

    // Inputs
    reg clk_100M;
    reg reset;
    reg btnU;
    reg btnL;
    reg btnR;
    reg btnD;
    reg RsRx;

    // Bidirectional
    wire CLK_MOUSE;
    wire DATA_MOUSE;

    // Outputs
    wire [7:0] HEX_OUT;
    wire [3:0] SEG_SELECT_OUT;
    wire RsTx;
    wire [7:0] VGA_DATA;
    wire VGA_HS;
    wire VGA_VS;

    // Instantiate the Unit Under Test (UUT)
    top uut (
        .clk_100M(clk_100M),
        .reset(reset),
        .CLK_MOUSE(CLK_MOUSE),
        .DATA_MOUSE(DATA_MOUSE),
        .HEX_OUT(HEX_OUT),
        .SEG_SELECT_OUT(SEG_SELECT_OUT),
        .btnU(btnU),
        .btnL(btnL),
        .btnR(btnR),
        .btnD(btnD),
        .RsRx(RsRx),
        .RsTx(RsTx),
        .VGA_DATA(VGA_DATA),
        .VGA_HS(VGA_HS),
        .VGA_VS(VGA_VS)
    );

    // Clock generation
    initial begin
        clk_100M = 0;
        forever #5 clk_100M = ~clk_100M; // 100 MHz clock
    end

    // Test stimulus
    initial begin
        // Initialize Inputs
        reset = 1;
        btnU = 0;
        btnL = 0;
        btnR = 0;
        btnD = 0;
        RsRx = 0;

        // Wait for global reset
        #100;
        reset = 0;

        // Test button inputs
        #50 btnL = 1; // Simulate left button press
        #50 btnL = 0;

        #50 btnU = 1; // Simulate up button press
        #50 btnU = 0;

        // Add more test cases as needed
        #1000;

        // Finish simulation
        $stop;
    end

endmodule