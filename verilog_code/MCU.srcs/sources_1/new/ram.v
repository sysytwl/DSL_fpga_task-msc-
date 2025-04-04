module RAM #(
  parameter RAMBaseAddr   = 8'd0,
  parameter RAMHighAddr   = 8'd127
)(  
  //standard signals  
  input       CLK,

  //BUS signals  
  inout [7:0] BUS_DATA,
  input [7:0] BUS_ADDR,
  input        BUS_WE
);  

//Tristate
reg ram_read_en;
always @(posedge CLK) begin
  if(!BUS_WE && (BUS_ADDR <= RAMHighAddr))
    ram_read_en <= 1;
  else
    ram_read_en <= 0;
end

wire [7:0] Out;
assign BUS_DATA = ram_read_en ? Out : 8'hZZ;

MCU_RAM u_MCU_RAM(
  .clka  	(CLK), 
  .wea   	(BUS_WE && !BUS_ADDR[7]), //only response within the ram range
  .addra 	(BUS_ADDR[6:0]),
  .dina  	(BUS_DATA),
  .douta 	(Out)
);

endmodule  