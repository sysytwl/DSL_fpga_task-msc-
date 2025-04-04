`timescale 1ns / 0.1ns

module interrupt_test;

    // Inputs
    reg clk;
    reg reset;
    reg interrupts_signal;
    reg rising_edge_mask;
    reg falling_edge_mask;
    reg interrupt_flag_set_0;

    // Outputs
    wire interrupt_flag;

    // Instantiate the Unit Under Test (UUT)
    interrupts uut (
        .clk(clk), 
        .reset(reset), 
        .interrupts_signal(interrupts_signal), 
        .rising_edge_mask(rising_edge_mask), 
        .falling_edge_mask(falling_edge_mask), 
        .interrupt_flag(interrupt_flag), 
        .interrupt_flag_set_0(interrupt_flag_set_0)
    );

    initial begin
        // Initialize Inputs
        clk = 0;
        reset = 1;
        interrupts_signal = 0;
        rising_edge_mask = 0;
        falling_edge_mask = 0;
        interrupt_flag_set_0 = 0;

        // Wait for global reset to finish
        #25 reset = 0;

        // Test rising edge detection
        rising_edge_mask = 1;
        #5 interrupts_signal = 1;
        #5 interrupts_signal = 0;
        #15 interrupts_signal = 1;
        #15 interrupts_signal = 0;
        #1 if (~interrupt_flag) $display("error for rising edge dection");

        // Test interrupt flag reset
        interrupt_flag_set_0 = 1;
        #20 interrupt_flag_set_0 = 0;
        #1 if (interrupt_flag) $display("error for irs reset");

        // Test falling edge detection
        falling_edge_mask = 1;
        #5 interrupts_signal = 1;
        #5 interrupts_signal = 0;
        #15 interrupts_signal = 1;
        #15 interrupts_signal = 0;
        #1 if (~interrupt_flag) $display("error for falling edge dection");

        // Finish simulation
        #30;
        $finish;
    end

    always #5 clk = ~clk;

endmodule