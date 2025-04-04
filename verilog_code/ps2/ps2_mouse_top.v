module MouseTransceiver #(
  parameter baseaddr = 8'hA0,
  parameter highaddr = 8'hA2
)(  
  //Standard Inputs
  input            RESET,
  input            CLK,

  //IO - Mouse side, DEBUG
  inout            CLK_MOUSE,
  inout            DATA_MOUSE,

  output LEFT,
  output RIGHT,

  //Config data bus
  input BUS_CLK,
  input BUS_WE,
  input [7:0] BUS_ADDR,
  inout [7:0] BUS_DATA,
  output READY_INTERRUPT
);

wire [7:0] MouseStatus;
wire [8:0] MouseX_raw; // signed 2's Complement
wire [8:0] MouseY_raw;
reg status_en, x_en, y_en;
always @(posedge BUS_CLK) begin
  if (RESET) begin
    status_en <= 0;
    x_en <= 0;
    y_en <= 0;
  end else begin
    if (BUS_ADDR == baseaddr) begin
      status_en <= 1;
      x_en <= 0;
      y_en <= 0;
    end else if (BUS_ADDR == (baseaddr + 1)) begin
      status_en <= 0;
      x_en <= 1;
      y_en <= 0;
    end else if (BUS_ADDR == (baseaddr + 2)) begin
      status_en <= 0;
      x_en <= 0;
      y_en <= 1;
    end
    else begin
      status_en <= 0;
      x_en <= 0;
      y_en <= 0;
    end
  end
end
assign BUS_DATA = (status_en) ? MouseStatus : ((x_en) ? MouseX_raw[7:0] : ((y_en) ? (8'd240 - MouseY_raw[7:0]) :8'bZZ));
assign LEFT = MouseStatus[0];
assign RIGHT = MouseStatus[1];





wire SEND_BYTE;
wire [7:0] BYTE_TO_SEND;
wire BYTE_SENT;
wire READ_ENABLE;
wire [7:0] BYTE_READ;
//wire BYTE_ERROR_CODE;
wire BYTE_READY;
MouseMasterSM ps2_mouse_controller( 
  .CLK(CLK),
  .RESET(RESET),

  //Transmitter Control 
  .SEND_BYTE(SEND_BYTE),
  .BYTE_TO_SEND(BYTE_TO_SEND),
  .BYTE_SENT(BYTE_SENT),

  //Receiver Control 
  .READ_ENABLE(READ_ENABLE),
  .BYTE_READ(BYTE_READ),
  .BYTE_ERROR_CODE(),
  .BYTE_READY(BYTE_READY),

  //Data Registers 
  .MOUSE_DX(MouseX_raw),
  .MOUSE_DY(MouseY_raw),
  .MOUSE_STATUS(MouseStatus),
  .SEND_INTERRUPT(READY_INTERRUPT)
);



/**************** PS2 CLK inout -> input & output ****************/
wire CLK_MOUSE_LOW;
assign CLK_MOUSE = CLK_MOUSE_LOW ? 1'bz : 0; // Assign 0 or high-impedance (Z)



/**************** PS2 DATA inout -> input & output ****************/
wire DATA_MOUSE_OUT_EN;
wire DATA_MOUSE_OUT;
assign DATA_MOUSE = (DATA_MOUSE_OUT_EN || !CLK_MOUSE_LOW) ? DATA_MOUSE_OUT : 1'bz; // include tx start bit



/**************** PS2 RX ****************/
MouseReceiver ps2_rx(
  .RESET(RESET),
  .CLK(CLK),
  .CLK_MOUSE_IN(CLK_MOUSE),//Mouse IO - CLK
  .DATA_MOUSE_IN(DATA_MOUSE),//Mouse IO - DATA
  .READ_ENABLE(READ_ENABLE),//Control
  .BYTE_READ(BYTE_READ),//MSB first
  .BYTE_ERROR_CODE(),
  .BYTE_READY(BYTE_READY)
);



/**************** PS2 TX ****************/
MouseTransmitter ps2_tx(  
  .RESET(RESET),
  .CLK(CLK),

  .CLK_MOUSE_IN(CLK_MOUSE),//Mouse IO - CLK
  .CLK_MOUSE_OUT_EN(CLK_MOUSE_LOW),
  
  .DATA_MOUSE_IN(DATA_MOUSE),
  .DATA_MOUSE_OUT(DATA_MOUSE_OUT),
  .DATA_MOUSE_OUT_EN(DATA_MOUSE_OUT_EN),

  //Control
  .SEND_BYTE(SEND_BYTE), //need to high during the send process
  .BYTE_TO_SEND(BYTE_TO_SEND),
  .BYTE_SENT(BYTE_SENT)
);

endmodule