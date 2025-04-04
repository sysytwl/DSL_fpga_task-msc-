module regs(
    input CLK,
    input RESET,

    input [2:0] cmd,

    output reg write2busaddr_en,
    output reg write2bus_en,
    //output reg write2alu_en,
    output reg [7:0] data_reg,
    input [7:0] data_in
);

localparam [2:0] write2reg = 1;
localparam [2:0] write2bus = 2;
localparam [2:0] write2alu = 3;
localparam [2:0] write2busaddr = 4;



always @(posedge CLK or posedge RESET) begin
    if(RESET) begin
        data_reg <= 0;
        write2bus_en <= 0;
        //write2alu_en <= 0;
        write2busaddr_en <= 0;
    end
    else begin
        case (cmd)
            write2reg: begin 
                data_reg <= data_in;
                write2bus_en <= 0;
                //write2alu_en <= 0;
                write2busaddr_en <= 0;
            end
            write2bus: begin 
                write2bus_en <= 1;
                //write2alu_en <= 0;
                write2busaddr_en <= 0;
            end
            write2alu: begin 
                //write2alu_en <= 1;
                write2bus_en <= 0;
                write2busaddr_en <= 0;
            end
            write2busaddr: begin
                //write2alu_en <= 0;
                write2bus_en <= 0;
                write2busaddr_en <= 1;
            end
            default: begin
                write2bus_en <= 0;
                //write2alu_en <= 0;
                write2busaddr_en <= 0;
            end
        endcase
    end
end

endmodule