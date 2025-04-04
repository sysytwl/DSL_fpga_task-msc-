module SPI_ROM(
  input clk,
  input reset,

  // SPI
  output reg CS, //K19
  output SCK, //C11
  inout SDI, //DQ0 D18
  inout SDO, //DQ1 D19
  inout WP, //DQ2 G18
  inout HLD, //DQ3 F18

  // data out
  output reg [7:0]  data_out,
  output reg        data_ready,
  input             addr_en,
  input             write_en,//low for read
  input      [15:0] addr
);


reg [15:0] address_reg;
reg [2:0] state;

//4Mb flash, 51% for FPGA bitMap, 49% * 40_0000 for user, here use only 256/one page
localparam addr_offset = 24'h30_0000;
localparam FAST_READ = 8'b0000_1011;//104MHz
localparam QOR = 8'b0110_1011;//Quad Output Read 80MHz
localparam P4E = 8'b0010_0000;// 4 KB Parameter Sector Erase
localparam P8E = 8'b0100_0000;// 8 KB (two 4KB) Parameter Sector Erase
localparam SE = 8'b1101_1000;// 64KB Sector Erase
localparam PP = 8'b0000_0010;// Page Programming

assign SCK = clk;
reg [7:0] data_read;
reg read_done;
spi_rx u_spi_rx(
  .reset     	(reset),
  .miso      	(SDO),
  .sck       	(SCK),
  .read_en   	(rx_en),
  .data_read 	(data_read),
  .read_done 	(read_done)
);

wire write_done;
spi_tx u_spi_tx(
  .reset         	(reset),
  .mosi          	(SDI),
  .sck           	(SCK),
  .write_en      	(tx_en),
  .data_to_write 	(data_to_write),
  .write_done    	(write_done)
);



// State machine states
localparam IDLE = 3'b000,
           READ = 3'b001,
           WRITE = 3'b010,
           WAIT = 3'b011;

// State machine
always @(posedge clk or posedge reset) begin
  if (reset) begin
    state <= IDLE;
    data_out <= 8'b0;
    data_ready <= 1'b0;
    address_reg <= 16'b0;
  end else begin
    case (state)
      IDLE: begin
        if (addr_en && !write_en) begin
          address_reg <= addr;
          state <= READ;
        end
        else if (addr_en && write_en) begin
          address_reg <= addr;
          state <= WRITE;
        end
      end
      READ: begin // 1 - OO, stop when clk stop
        // Implement read operation from QSPI flash
        // Set data_out_reg and data_ready_reg accordingly
        state <= IDLE;
      end
      WRITE: begin
        // Implement write operation to QSPI flash
        state <= IDLE;
      end
    endcase
  end
end

endmodule
