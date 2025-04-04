`timescale 1ns / 1ps

module decoder_test;

    // Inputs
    reg clk;
    reg reset;
    reg [7:0] instruction;
    reg condition_result;
    reg irs_signal;
    reg irs_running;

    // Outputs
    wire [3:0] opcode;
    wire [2:0] counter_cmd;
    wire [2:0] reg_control_a;
    wire [2:0] reg_control_b;
    wire instruction_bus_data_2_data_bus_addr;
    wire data_write_en;

    // Instantiate the Unit Under Test (UUT)
    decoder uut (
        .clk(clk), 
        .reset(reset), 
        .instruction(instruction), 
        .condition_result(condition_result), 
        .opcode(opcode), 
        .counter_cmd(counter_cmd), 
        .reg_control_a(reg_control_a), 
        .reg_control_b(reg_control_b), 
        .irs_signal(irs_signal), 
        .irs_running(irs_running), 
        .instruction_bus_data_2_data_bus_addr(instruction_bus_data_2_data_bus_addr), 
        .data_write_en(data_write_en)
    );

    initial begin
        // Initialize Inputs
        clk = 0;
        reset = 1;
        instruction = 0;
        condition_result = 0;
        irs_signal = 0;
        irs_running = 0;

        // Wait for global reset
        #25 reset = 0;

        // Test MOVa instruction
        @(posedge clk) instruction = 8'b00000000; // MOVa addr
        #20 if (opcode !== 4'hF || counter_cmd !== 1 || reg_control_a !== 0 || reg_control_b !== 0 || data_write_en !== 0 || instruction_bus_data_2_data_bus_addr !== 0) begin
            $display("Test MOVa failed");
        end

        // Test MOVb instruction
        @(posedge clk) instruction = 8'b00000001; // MOVb addr
        #20;
        if (opcode !== 4'hF || counter_cmd !== 1 || reg_control_a !== 0 || reg_control_b !== 0 || data_write_en !== 0 || instruction_bus_data_2_data_bus_addr !== 0) begin
            $display("Test MOVb failed");
        end

        // Test sbA instruction
        instruction = 8'b00000010; // sbA addr
        #20;
        if (opcode !== 4'hF || counter_cmd !== 1 || reg_control_a !== 2 || reg_control_b !== 0 || data_write_en !== 0 || instruction_bus_data_2_data_bus_addr !== 0) begin
            $display("Test sbA failed");
        end

        // Test sbB instruction
        instruction = 8'b00000011; // sbB addr
        #20;
        if (opcode !== 4'hF || counter_cmd !== 1 || reg_control_a !== 0 || reg_control_b !== 2 || data_write_en !== 0 || instruction_bus_data_2_data_bus_addr !== 0) begin
            $display("Test sbB failed");
        end

        // Test OpA instruction
        instruction = 8'b00000100; // OpA
        #20;
        if (opcode !== 4'hF || counter_cmd !== 0 || reg_control_a !== 3 || reg_control_b !== 3 || data_write_en !== 0 || instruction_bus_data_2_data_bus_addr !== 0) begin
            $display("Test OpA failed");
        end

        // Test OpB instruction
        instruction = 8'b00000101; // OpB
        #20;
        if (opcode !== 4'hF || counter_cmd !== 0 || reg_control_a !== 3 || reg_control_b !== 3 || data_write_en !== 0 || instruction_bus_data_2_data_bus_addr !== 0) begin
            $display("Test OpB failed");
        end

        // Test OpMem instruction
        instruction = 8'b11111111; // OpMem
        #20;
        if (opcode !== 4'hF || counter_cmd !== 0 || reg_control_a !== 3 || reg_control_b !== 3 || data_write_en !== 0 || instruction_bus_data_2_data_bus_addr !== 0) begin
            $display("Test OpMem failed");
        end

        // Test CJAL instruction
        instruction = 8'b00000110; // CJAL
        condition_result = 1;
        #20;
        if (opcode !== 4'hF || counter_cmd !== 2 || reg_control_a !== 3 || reg_control_b !== 3 || data_write_en !== 0 || instruction_bus_data_2_data_bus_addr !== 0) begin
            $display("Test CJAL failed");
        end

        // Test JAL instruction
        instruction = 8'b00000111; // JAL
        #20;
        if (opcode !== 4'hF || counter_cmd !== 1 || reg_control_a !== 0 || reg_control_b !== 0 || data_write_en !== 0 || instruction_bus_data_2_data_bus_addr !== 0) begin
            $display("Test JAL failed");
        end

        // Test Call instruction
        instruction = 8'b00001001; // Call
        #20;
        if (opcode !== 4'hF || counter_cmd !== 2 || reg_control_a !== 0 || reg_control_b !== 0 || data_write_en !== 0 || instruction_bus_data_2_data_bus_addr !== 0) begin
            $display("Test Call failed");
        end

        // Test Ret instruction
        instruction = 8'b00001010; // Ret
        #20;
        if (opcode !== 4'hF || counter_cmd !== 3 || reg_control_a !== 0 || reg_control_b !== 0 || data_write_en !== 0 || instruction_bus_data_2_data_bus_addr !== 0) begin
            $display("Test Ret failed");
        end

        // Test lbA instruction
        instruction = 8'b00001011; // lbA
        #20;
        if (opcode !== 4'hF || counter_cmd !== 0 || reg_control_a !== 4 || reg_control_b !== 0 || data_write_en !== 0 || instruction_bus_data_2_data_bus_addr !== 0) begin
            $display("Test lbA failed");
        end

        // Test lbB instruction
        instruction = 8'b00001100; // lbB
        #20;
        if (opcode !== 4'hF || counter_cmd !== 0 || reg_control_a !== 0 || reg_control_b !== 4 || data_write_en !== 0 || instruction_bus_data_2_data_bus_addr !== 0) begin
            $display("Test lbB failed");
        end

        $stop;
    end

    always #5 clk = ~clk;

endmodule