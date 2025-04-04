module MouseMasterSM( 
    input            CLK, 
    input            RESET,

    //Transmitter Control 
    output reg       SEND_BYTE, 
    output reg [7:0] BYTE_TO_SEND, 
    input            BYTE_SENT,

    //Receiver Control 
    output reg       READ_ENABLE, 
    input      [7:0] BYTE_READ, 
    input      [1:0] BYTE_ERROR_CODE,
    input            BYTE_READY,

    //Data Registers sign, 
    output reg [8:0] MOUSE_DX, 
    output reg [8:0] MOUSE_DY, 
    output reg [7:0] MOUSE_STATUS, 
    output reg       SEND_INTERRUPT 
);



/**************** clk divider ****************/
reg clk;
reg [7:0] clk_counter;
always @(posedge CLK)begin
  if(RESET)begin
    clk <= 0;
    clk_counter <= 0;
  end
  else if (clk_counter >= 50) begin //1MHz
    clk_counter <= 0;
    clk <= ~clk;
  end
  else begin
    clk_counter <= clk_counter + 1;
  end
end



//shift register
reg [3:0] shift_reg;
always @(posedge clk or posedge RESET) begin
    if (RESET) begin
        shift_reg <= 4'b0000;
    end else begin
        shift_reg <= shift_reg << 1 | BYTE_READY;
    end
end
assign edge_trigger = !shift_reg[3] && !shift_reg[2] && shift_reg[1] && shift_reg[0];//posedge, reduce conflics with clk



//states
localparam MOUSE_RESET = 4'b0000;
localparam WAIT_ACK = 4'b0001;
localparam WAIT_SELF_TEST = 4'b0010;
localparam WAIT_MOUSE_ID = 4'b0011;
localparam MOUSE_START = 4'b0100;
localparam WAIT_MOUSE_START_ACK = 4'b0101;
//gray code
localparam WAIT_MOUSE_STATUS = 4'b0110;
localparam WAIT_MOUSE_X_DIR = 4'b0111;
localparam WAIT_MOUSE_Y_DIR = 4'b1111;
localparam WAIT_MOUSE_W = 4'b1110;



//commands
localparam RESET_COM = 8'hFF;
localparam ACK = 8'hFA;
localparam SELF_TEST = 8'hAA;
localparam MOUSE_ID = 8'h00;
localparam START_TRANS = 8'hF4;



reg [3:0] STATE;
reg [8:0] MouseX_tmp, MouseY_tmp;
always @(posedge RESET or posedge clk) begin
    if(RESET) begin
        SEND_BYTE <= 1'b0;
        READ_ENABLE <= 1'b0;
        BYTE_TO_SEND <= 0;
        SEND_INTERRUPT <= 1'b0;

        MOUSE_DX <= 9'b0_0101_0000;//>>2; 
        MOUSE_DY <= 9'b0_0111_1000;//>>1

        MOUSE_STATUS <= 8'b0;
        STATE <= MOUSE_RESET;
        
        MouseX_tmp <= 0;
        MouseY_tmp <= 0;
    end
    else begin

        case (STATE)
            MOUSE_RESET: begin
                if(BYTE_SENT == 1) begin
                    SEND_BYTE <= 1'b0;
                    STATE <= WAIT_ACK;
                end
                else begin
                    SEND_BYTE <= 1'b1;
                    BYTE_TO_SEND <= RESET_COM;
                end
            end

            WAIT_ACK: begin
                if(BYTE_READY && BYTE_READ==ACK) begin
                    READ_ENABLE <= 1'b0;
                    STATE <= WAIT_SELF_TEST;
                end
                else begin
                    READ_ENABLE <= 1'b1;
                end
            end

            WAIT_SELF_TEST: begin
                if(BYTE_READY && BYTE_READ==SELF_TEST) begin
                    READ_ENABLE <= 1'b0;
                    STATE <= WAIT_MOUSE_ID;
                end
                else begin
                    READ_ENABLE <= 1'b1;
                end
            end

            WAIT_MOUSE_ID: begin
                if(BYTE_READY && BYTE_READ==MOUSE_ID) begin
                    READ_ENABLE <= 1'b0;
                    STATE <= MOUSE_START;
                end
                else begin
                    READ_ENABLE <= 1'b1;
                end
            end

            MOUSE_START: begin
                if(BYTE_SENT == 1) begin
                    SEND_BYTE <= 1'b0;
                    STATE <= WAIT_MOUSE_START_ACK;
                end
                else begin
                    SEND_BYTE <= 1'b1;
                    BYTE_TO_SEND <= START_TRANS; 
                end
            end

            WAIT_MOUSE_START_ACK: begin
                if(BYTE_READY && BYTE_READ==ACK) begin// Basys3 problem, no errors no my borad
                    READ_ENABLE <= 1'b0;
                    STATE <= WAIT_MOUSE_STATUS;
                end
                else begin
                    READ_ENABLE <= 1'b1;
                end
            end

            WAIT_MOUSE_STATUS: begin
                if(edge_trigger && BYTE_READ[3] && !BYTE_READ[2])begin
                    //READ_ENABLE <= 1'b0;
                    MOUSE_STATUS <= BYTE_READ;
                    STATE <= WAIT_MOUSE_X_DIR;
                    SEND_INTERRUPT <= 1'b0;
                end
                else begin
                    READ_ENABLE <= 1'b1;
                end
            end

            WAIT_MOUSE_X_DIR: begin
                MouseX_tmp <= MOUSE_DX + {MOUSE_STATUS[4], BYTE_READ};
                if(edge_trigger) begin
                    //READ_ENABLE <= 1'b0;
                    if (MouseX_tmp[8])
                        MOUSE_DX <= 0;
                    else if (MouseX_tmp > 'd160)
                        MOUSE_DX <= 'd160;
                    else
                        MOUSE_DX <= MouseX_tmp;

                    STATE <= WAIT_MOUSE_Y_DIR;
                end
                else begin
                    READ_ENABLE <= 1'b1;
                end
            end

            WAIT_MOUSE_Y_DIR: begin
                MouseY_tmp <= MOUSE_DY + {MOUSE_STATUS[5], BYTE_READ};
                if(edge_trigger) begin
                    //READ_ENABLE <= 1'b0;
                    if (MouseY_tmp[8])
                        MOUSE_DY <= 0;
                    else if (MouseY_tmp > 'd240)
                        MOUSE_DY <= 'd240;
                    else
                        MOUSE_DY <= MouseY_tmp;

                    STATE <= WAIT_MOUSE_STATUS;
                    SEND_INTERRUPT <= 1'b1;
                end
                else begin
                    READ_ENABLE <= 1'b1;
                end
            end

            default: begin
                STATE <= MOUSE_RESET;
            end
        endcase
    end
end

endmodule