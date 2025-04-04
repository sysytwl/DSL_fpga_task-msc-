
module ROM #(
  parameter ROMBaseAddr = 0,
  parameter ROMHighAddr = 256
)(
  input CLK,

  //BUS signals
  output [7:0] DATA,
  input [7:0] ADDR
);  

MCU_ROM u_MCU_ROM(
  .clka(CLK),
  .addra(ADDR),
  .douta(DATA)
);

endmodule 