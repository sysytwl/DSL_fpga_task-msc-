module MouseTransmitter(  
  input       RESET,  
  input       CLK,  
  input       CLK_MOUSE_IN,//Mouse IO - CLK
  output reg  CLK_MOUSE_OUT_EN,  // Allows for the control of the Clock line, ‾‾‾\_100us_/‾‾‾, Low for transmission
  
  input       DATA_MOUSE_IN,
  output reg  DATA_MOUSE_OUT,
  output reg  DATA_MOUSE_OUT_EN,

  //Control
  input       SEND_BYTE, //need to high during the send process
  input [7:0] BYTE_TO_SEND, //need not to change during the send process
  output reg  BYTE_SENT
);



// State definitions
localparam IDLE = 3'b000;
localparam START_BIT = 3'b010;
localparam DATA = 3'b011;
localparam PARITY = 3'b100;
localparam STOP_BIT = 3'b101;
localparam ACK = 3'b110;
localparam SENT = 3'b111;



reg [2:0] STATE;
reg [7:0] byte_pointer;
reg [15:0] time_counter;
always @(posedge CLK) begin
    if(RESET || !SEND_BYTE) begin
        time_counter <= 0;
        CLK_MOUSE_OUT_EN <= 1'b1;
    end
    else if (time_counter >= 10000) begin //200us
        CLK_MOUSE_OUT_EN <= 1'b1;
    end
    else begin
        time_counter <= time_counter + 1;
        CLK_MOUSE_OUT_EN <= 1'b0;
    end
end

always @(posedge RESET or posedge CLK_MOUSE_IN) begin//negedge SEND_BYTE
    if(RESET || !SEND_BYTE) begin //Reset, irs
        DATA_MOUSE_OUT_EN <= 1'b0;
        BYTE_SENT <= 1'b0;
        STATE <= IDLE;
        byte_pointer <= 0;
        DATA_MOUSE_OUT <= 1'b0;
    end
    else begin
        case (STATE)
            IDLE: begin //start bit
                STATE <= DATA;
            end
            // START_BIT: begin
            //     DATA_MOUSE_OUT_EN <= 1'b1;
            //     DATA_MOUSE_OUT <= 0;
            //     STATE <= DATA;
            // end
            DATA: begin
                DATA_MOUSE_OUT_EN <= 1'b1;
                DATA_MOUSE_OUT <= BYTE_TO_SEND[byte_pointer];
                byte_pointer <= byte_pointer + 1;

                if (byte_pointer == 7) begin
                    STATE <= PARITY;
                end
            end
            PARITY: begin
                DATA_MOUSE_OUT <= ~(^BYTE_TO_SEND);
                STATE <= STOP_BIT;
            end
            STOP_BIT: begin
                DATA_MOUSE_OUT <= 1'b1;
                STATE <= ACK;
            end
            ACK: begin // no need to check, it will return the wrong code to rx not ACK(FA)
                BYTE_SENT <= 1'b1;
                DATA_MOUSE_OUT_EN <= 1'b0;
                //STATE <= SENT;
            end
            // SENT: begin
            // end
            default: begin
                STATE <= IDLE;
            end
        endcase
    end
end


endmodule 