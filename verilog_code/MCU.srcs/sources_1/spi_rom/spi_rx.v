module spi_rx(
  input reset,

  input miso,
  input sck,

  input read_en,
  output reg [7:0] data_read,
  output reg read_done
);

reg [3:0] bit_pointer;

always @(posedge sck or posedge reset) begin
    if (reset || !read_en) begin
        data_read <= 0;
        read_done <= 0;
        bit_pointer <= 7;
    end
    else if (bit_pointer != 0) begin
        data_read[bit_pointer] <= miso;
        bit_pointer <= bit_pointer - 1;
    end
    else if (bit_pointer == 0 && !read_done) begin
        data_read[bit_pointer] <= miso;
        read_done <= 1;
    end
end

endmodule