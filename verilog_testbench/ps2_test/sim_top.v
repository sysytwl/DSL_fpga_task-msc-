`timescale 1ns / 0.1ns
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/01/28 08:47:16
// Design Name: 
// Module Name: sim_top
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module sim_top(
);



// Time period for 100 MHz clock
reg clk;
localparam CLK_PERIOD = 10; // 10 ns = 1 / 100 MHz
initial begin
  clk = 0;
  forever #(CLK_PERIOD / 2) clk = ~clk;
end

//reset
reg reset;
initial begin
  reset = 1;
  #100 reset = 0;  // De-assert reset after 100 ns
end

//ps2_clk, ps2_data
wire data_mouse;
pullup(data_mouse);
reg data_out;
reg data_en;

localparam MOUSE_CLK_PERIOD = 50000;
wire ps2_clk;
pullup(ps2_clk);
reg MOUSE_clk;
reg ps2_clk_en;
initial begin
  MOUSE_clk = 1;
  ps2_clk_en = 0;
  data_en = 0;

  //FF
  #100165;
  ps2_clk_en = 1;
  repeat (22) begin
    #(MOUSE_CLK_PERIOD / 2) MOUSE_clk = ~MOUSE_clk;
  end
  //send ACK
  // data_out = 0;
  // data_en = 1;
  // repeat (2) begin
  //   #(MOUSE_CLK_PERIOD / 2) MOUSE_clk = ~MOUSE_clk;
  // end
  
  //FA-ack
  data_out = 0;
  data_en = 1;
  repeat (2) begin
    #(MOUSE_CLK_PERIOD / 2) MOUSE_clk = ~MOUSE_clk;
  end
  data_out = 0;
  data_en = 1;
  repeat (2) begin
    #(MOUSE_CLK_PERIOD / 2) MOUSE_clk = ~MOUSE_clk;
  end
  data_out = 1;
  data_en = 1;
  repeat (2) begin
    #(MOUSE_CLK_PERIOD / 2) MOUSE_clk = ~MOUSE_clk;
  end
  data_out = 0;
  data_en = 1;
  repeat (2) begin
    #(MOUSE_CLK_PERIOD / 2) MOUSE_clk = ~MOUSE_clk;
  end
  data_out = 1;
  data_en = 1;
  repeat (2) begin
    #(MOUSE_CLK_PERIOD / 2) MOUSE_clk = ~MOUSE_clk;
  end
  data_out = 1;
  data_en = 1;
  repeat (2*6) begin
    #(MOUSE_CLK_PERIOD / 2) MOUSE_clk = ~MOUSE_clk;
  end

  //AA
  data_out = 0;
  data_en = 1;
  repeat (2) begin
    #(MOUSE_CLK_PERIOD / 2) MOUSE_clk = ~MOUSE_clk;
  end
  data_out = 0;
  data_en = 1;
  repeat (2) begin
    #(MOUSE_CLK_PERIOD / 2) MOUSE_clk = ~MOUSE_clk;
  end
  data_out = 1;
  data_en = 1;
  repeat (2) begin
    #(MOUSE_CLK_PERIOD / 2) MOUSE_clk = ~MOUSE_clk;
  end
  data_out = 0;
  data_en = 1;
  repeat (2) begin
    #(MOUSE_CLK_PERIOD / 2) MOUSE_clk = ~MOUSE_clk;
  end
  data_out = 1;
  data_en = 1;
  repeat (2) begin
    #(MOUSE_CLK_PERIOD / 2) MOUSE_clk = ~MOUSE_clk;
  end
  data_out = 0;
  data_en = 1;
  repeat (2) begin
    #(MOUSE_CLK_PERIOD / 2) MOUSE_clk = ~MOUSE_clk;
  end
  data_out = 1;
  data_en = 1;
  repeat (2) begin
    #(MOUSE_CLK_PERIOD / 2) MOUSE_clk = ~MOUSE_clk;
  end
  data_out = 0;
  data_en = 1;
  repeat (2) begin
    #(MOUSE_CLK_PERIOD / 2) MOUSE_clk = ~MOUSE_clk;
  end
  data_out = 1;
  data_en = 1;
  repeat (2) begin
    #(MOUSE_CLK_PERIOD / 2) MOUSE_clk = ~MOUSE_clk;
  end
  data_out = 1;
  data_en = 1;
  repeat (2*2) begin
    #(MOUSE_CLK_PERIOD / 2) MOUSE_clk = ~MOUSE_clk;
  end

  //00
  data_out = 0;
  data_en = 1;
  repeat (2*9) begin
    #(MOUSE_CLK_PERIOD / 2) MOUSE_clk = ~MOUSE_clk;
  end
  data_out = 1;
  data_en = 1;
  repeat (2*2) begin
    #(MOUSE_CLK_PERIOD / 2) MOUSE_clk = ~MOUSE_clk;
  end

  ps2_clk_en = 0;
  data_en = 0;
  //F4
  #75_240;
  ps2_clk_en = 1;
  repeat (22) begin
    #(MOUSE_CLK_PERIOD / 2) MOUSE_clk = ~MOUSE_clk;
  end
  //send ACK
  // data_out = 0;
  // data_en = 1;
  // repeat (2) begin
  //   #(MOUSE_CLK_PERIOD / 2) MOUSE_clk = ~MOUSE_clk;
  // end

  //FA-ack
  data_out = 0;
  data_en = 1;
  repeat (2) begin
    #(MOUSE_CLK_PERIOD / 2) MOUSE_clk = ~MOUSE_clk;
  end
  data_out = 0;
  data_en = 1;
  repeat (2) begin
    #(MOUSE_CLK_PERIOD / 2) MOUSE_clk = ~MOUSE_clk;
  end
  data_out = 1;
  data_en = 1;
  repeat (2) begin
    #(MOUSE_CLK_PERIOD / 2) MOUSE_clk = ~MOUSE_clk;
  end
  data_out = 0;
  data_en = 1;
  repeat (2) begin
    #(MOUSE_CLK_PERIOD / 2) MOUSE_clk = ~MOUSE_clk;
  end
  data_out = 1;
  data_en = 1;
  repeat (2) begin
    #(MOUSE_CLK_PERIOD / 2) MOUSE_clk = ~MOUSE_clk;
  end
  data_out = 1;
  data_en = 1;
  repeat (2*6) begin
    #(MOUSE_CLK_PERIOD / 2) MOUSE_clk = ~MOUSE_clk;
  end

  //status
  data_out = 0;
  data_en = 1;
  repeat (2) begin
    #(MOUSE_CLK_PERIOD / 2) MOUSE_clk = ~MOUSE_clk;
  end
  data_out = 1;
  data_en = 1;
  repeat (2*10) begin
    #(MOUSE_CLK_PERIOD / 2) MOUSE_clk = ~MOUSE_clk;
  end

  //x-
  data_out = 0;
  data_en = 1;
  repeat (2) begin
    #(MOUSE_CLK_PERIOD / 2) MOUSE_clk = ~MOUSE_clk;
  end
  data_out = 1;
  data_en = 1;
  repeat (2*10) begin
    #(MOUSE_CLK_PERIOD / 2) MOUSE_clk = ~MOUSE_clk;
  end

  //y-
  data_out = 0;
  data_en = 1;
  repeat (2) begin
    #(MOUSE_CLK_PERIOD / 2) MOUSE_clk = ~MOUSE_clk;
  end
  data_out = 1;
  data_en = 1;
  repeat (2*10) begin
    #(MOUSE_CLK_PERIOD / 2) MOUSE_clk = ~MOUSE_clk;
  end

  //repeat
  //status
  data_out = 0;
  data_en = 1;
  repeat (2) begin
    #(MOUSE_CLK_PERIOD / 2) MOUSE_clk = ~MOUSE_clk;
  end
  data_out = 1;
  data_en = 1;
  repeat (2*10) begin
    #(MOUSE_CLK_PERIOD / 2) MOUSE_clk = ~MOUSE_clk;
  end

  //x-
  data_out = 0;
  data_en = 1;
  repeat (2) begin
    #(MOUSE_CLK_PERIOD / 2) MOUSE_clk = ~MOUSE_clk;
  end
  data_out = 1;
  data_en = 1;
  repeat (2*10) begin
    #(MOUSE_CLK_PERIOD / 2) MOUSE_clk = ~MOUSE_clk;
  end

  //y-
  data_out = 0;
  data_en = 1;
  repeat (2) begin
    #(MOUSE_CLK_PERIOD / 2) MOUSE_clk = ~MOUSE_clk;
  end
  data_out = 1;
  data_en = 1;
  repeat (2*10) begin
    #(MOUSE_CLK_PERIOD / 2) MOUSE_clk = ~MOUSE_clk;
  end


  //ps2_clk_en = 0; // Disable the clock after 11 cycles
  $finish;
end
assign data_mouse = data_en ? data_out : 1'bz;
assign ps2_clk = ps2_clk_en ? MOUSE_clk : 1'bz;


MouseTransceiver PS2_Mouse_test(  
  //Standard Inputs
  .RESET(reset),
  .CLK(clk),

  //IO - Mouse side
  .CLK_MOUSE(ps2_clk),
  .DATA_MOUSE(data_mouse),

  // Mouse data information
  .BUS_CLK(clk),
  .BUS_DATA(8'hA0),
  .BUS_ADDR(8'hA1),
  .BUS_WE(),
  .READY_INTERRUPT()
);

endmodule
