module program_counter #(
    parameter irs_addr = 8'd16
)(
    input CLK,
    input RESET,

    input [2:0] cmd,
    input [7:0] count_in, //jump

    output reg [7:0] counter,
    output irs_running
);

localparam pp1 = 1;
localparam jump = 2;
localparam set2save = 3; //+2
localparam irs = 4;
localparam function_call = 5;

reg [7:0] counter_save;
always @(negedge CLK or posedge RESET) begin
    if(RESET)begin
        counter <= 0;
        counter_save <= 0;
    end
    else begin
        case(cmd)
            pp1: begin
                counter <= counter + 1;
            end

            jump: begin
                counter <= count_in;
            end

            function_call: begin
                counter <= count_in;
                counter_save <= counter + 1;
            end

            set2save: begin
                counter <= counter_save;
            end

            irs: begin
                counter <= irs_addr;
                counter_save <= counter;
            end

            default: begin
                //doing nothing
            end
        endcase
    end
end

assign irs_running = counter >= irs_addr;

endmodule