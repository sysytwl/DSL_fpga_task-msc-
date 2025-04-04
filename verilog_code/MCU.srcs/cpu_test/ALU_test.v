`timescale 1ns / 1ps

module alu_test;

    // Inputs
    reg CLK;
    reg RESET;
    reg [7:0] IN_A;
    reg [7:0] IN_B;
    reg [3:0] ALU_Op_Code;

    // Outputs
    wire [7:0] Out;

    // Instantiate the ALU
    ALU uut (
        .CLK(CLK), 
        .RESET(RESET), 
        .IN_A(IN_A), 
        .IN_B(IN_B), 
        .ALU_Op_Code(ALU_Op_Code), 
        .Out(Out)
    );

    // Clock generation
    always #5 CLK = ~CLK;

    initial begin
        // Initialize Inputs
        CLK = 0;
        RESET = 1;
        IN_A = 0;
        IN_B = 0;
        ALU_Op_Code = 0;

        // Wait for global reset
        #30 RESET = 0;

        // Test Add
        @(posedge CLK);
        IN_A = 8'h05;
        IN_B = 8'h03;
        ALU_Op_Code = 4'h0;
        #1 if(Out != 8'h08) $display("Add Error: %h", Out);

        // Test Subtract
        @(posedge CLK);
        IN_A = 8'h05;
        IN_B = 8'h03;
        ALU_Op_Code = 4'h1;
        #1 if(Out != 8'h02) $display("Subtract Error: %h", Out);

        // Test Multiply
        @(posedge CLK);
        IN_A = 8'h02;
        IN_B = 8'h03;
        ALU_Op_Code = 4'h2;
        #1 if(Out != 8'h06) $display("Multiply Error: %h", Out);

        // Test Shift Left
        @(posedge CLK);
        IN_A = 8'h01;
        ALU_Op_Code = 4'h3;
        #1 if(Out != 8'h02) $display("Shift Left Error: %h", Out);

        // Test Shift Right
        @(posedge CLK);
        IN_A = 8'h02;
        ALU_Op_Code = 4'h4;
        #1 if(Out != 8'h01) $display("Shift Right Error: %h", Out);

        // Test Increment A
        @(posedge CLK);
        IN_A = 8'h05;
        ALU_Op_Code = 4'h5;
        #1 if(Out != 8'h06) $display("Increment A Error: %h", Out);

        // Test Increment B
        @(posedge CLK);
        IN_B = 8'h05;
        ALU_Op_Code = 4'h6;
        #1 if(Out != 8'h06) $display("Increment B Error: %h", Out);

        // Test Decrement A
        @(posedge CLK);
        IN_A = 8'h05;
        ALU_Op_Code = 4'h7;
        #1 if(Out != 8'h04) $display("Decrement A Error: %h", Out);

        // Test Decrement B
        @(posedge CLK);
        IN_B = 8'h05;
        ALU_Op_Code = 4'h8;
        #1 if(Out != 8'h04) $display("Decrement B Error: %h", Out);

        // Test A == B
        @(posedge CLK);
        IN_A = 8'h05;
        IN_B = 8'h05;
        ALU_Op_Code = 4'h9;
        #1 if(Out != 8'h01) $display("A == B Error: %h", Out);

        // Test A > B
        @(posedge CLK);
        IN_A = 8'h06;
        IN_B = 8'h05;
        ALU_Op_Code = 4'hA;
        #1 if(Out != 8'h01) $display("A > B Error: %h", Out);

        // Test A < B
        @(posedge CLK);
        IN_A = 8'h04;
        IN_B = 8'h05;
        ALU_Op_Code = 4'hB;
        #1 if(Out != 8'h01) $display("A < B Error: %h", Out);

        // Test NOP
        @(posedge CLK);
        ALU_Op_Code = 4'hF;
        #1 if(Out != 8'h00) $display("NOP Error: %h", Out);

        #19;

        $stop;
    end

endmodule