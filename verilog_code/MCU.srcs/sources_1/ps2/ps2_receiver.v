module MouseReceiver(
  input            RESET,  
  input            CLK,  
  input            CLK_MOUSE_IN,//Mouse IO - CLK
  input            DATA_MOUSE_IN,//Mouse IO - DATA  
  input            READ_ENABLE,//Control
  output reg [7:0] BYTE_READ,//MSB first
  output reg [1:0] BYTE_ERROR_CODE,  
  output reg       BYTE_READY
);  



// State definitions
localparam IDLE = 2'b00, DATA_BITS = 2'b01, STOP_BIT = 2'b11, PARITY_BIT = 2'b10;



//sync ps2_clk with 100Mhz main clk
// reg ps2_clk_prev;
// always @(posedge CLK or posedge RESET) begin
//     if (RESET)  begin
//         ps2_clk_prev <= 1'b1;
//     end
//     else begin
//         ps2_clk_prev <= CLK_MOUSE_IN;
//     end    
// end



// State variable
reg [1:0] state;
reg [3:0] bit_pointer;
always @(posedge(RESET) or negedge(CLK_MOUSE_IN)) begin// posedge CLK
    if (RESET || (!READ_ENABLE)) begin // Init, not read
        state <= IDLE;
        bit_pointer <= 0;
        BYTE_READY <= 0;
        BYTE_READ <= 0;
        BYTE_ERROR_CODE <= 0;
    end
    else begin// if (ps2_clk_prev && !CLK_MOUSE_IN) 
        case (state)
        
        IDLE: begin
            bit_pointer <= 0;//reset for continuous mode
            BYTE_READY <= 0;
            BYTE_READ <= 0;
            BYTE_ERROR_CODE <= 0;
            if (DATA_MOUSE_IN == 0) begin //start bit
                state <= DATA_BITS;
            end
        end

        DATA_BITS: begin
            BYTE_READ[bit_pointer] <= DATA_MOUSE_IN;
            bit_pointer <= bit_pointer + 1;
            if (bit_pointer == 7) begin
                state <= PARITY_BIT;
            end
        end

        PARITY_BIT: begin
            if (^BYTE_READ[7:0] != ~DATA_MOUSE_IN) begin // Odd parity check
                BYTE_ERROR_CODE[0] <= 1'b1;
            end
            state <= STOP_BIT;
        end

        STOP_BIT: begin
            BYTE_READY <= 1;
            state <= IDLE;//for continuous read, process speed must faster than ps2_clk, DO NOT reset read_enable
            if (DATA_MOUSE_IN != 1) begin
                BYTE_ERROR_CODE[1] <= 1'b1; //no end bit
            end
        end

        default: begin
            state <= IDLE;
        end

        endcase
    end
end

endmodule 