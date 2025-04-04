module spi_tx(
  input reset,

  output reg mosi,
  input sck,

  input write_en,
  input [7:0] data_to_write,
  output reg write_done
);

reg [3:0] bit_pointer;
always @(negedge sck) begin
  if(reset || !write_en)begin
    write_done <= 0;
    bit_pointer <= 7;
    mosi <= 0;
  end
  else if (bit_pointer != 0)begin
    mosi <= data_to_write[bit_pointer];
    bit_pointer <= bit_pointer - 1;
  end
  else if (bit_pointer == 0 && !write_done)begin
    mosi <= data_to_write[bit_pointer];
    write_done <= 1;
  end
end

endmodule