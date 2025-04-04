module VGA_TOP #(
    parameter baseaddr = 8'hB0,
    parameter highaddr = 8'hB2
)(
    input CLK, //100MHz
    input RESET, // Reset

    //Config data bus
    input BUS_CLK,
    input BUS_WE,
    input [7:0] BUS_ADDR,
    inout [7:0] BUS_DATA,

    output [7:0] VGA_DATA,
    output VGA_HS,
    output VGA_VS
);

reg [11:0] video_addr;
reg [7:0] data;
reg bus_data_valid;
always @(posedge BUS_CLK or posedge RESET) begin
    if (RESET) begin
        video_addr <= 0;
        data <= 0;
        bus_data_valid <= 0;
    end 
    else if (BUS_WE && BUS_ADDR == baseaddr) begin
        video_addr[11:8] <= BUS_DATA[3:0];
        bus_data_valid <= 0;
    end 
    else if (BUS_WE && BUS_ADDR == baseaddr+1) begin
        video_addr[7:0] <= BUS_DATA;
        bus_data_valid <= 0;
    end
    else if (BUS_WE && BUS_ADDR == baseaddr+2) begin
        data <= BUS_DATA;
        bus_data_valid <= 1;
    end
    else
        bus_data_valid <= 0;
end
//assign BUS_DATA = (!BUS_WE && (BUS_ADDR >= baseaddr && BUS_ADDR <= highaddr)) ? data : 8'bZZ;


/********** VGA Pixel CLK **********/
wire pclk, locked;
PCLK PLL_GEN(//PLL for 25.175MHz vga pclk
  .clk_out1(pclk),
  .locked(locked),
  .reset(RESET),
  .clk_in1(CLK)
);



/********** TEXT RAM **********/
wire [7:0] frame_buffer_data;
wire [9:0] addr_H;
wire [9:0] addr_V;
wire [11:0] frame_buffer_addr;
assign frame_buffer_addr = (addr_V / 16 * 80) + (addr_H / 8);
VRAM VRAM_BUFFER(
    .clka(BUS_CLK),
    .ena(~RESET), //enable opposite of reset
    .wea(bus_data_valid), //Port A Write Enable
    .addra(video_addr[11:0]), //Port A Address
    .dina(data),

    .clkb(pclk),
    .enb(locked),
    .addrb(frame_buffer_addr), //text tile addr 0-2400
    .doutb(frame_buffer_data)
);



/********** sprite **********/
reg [9:0] sprite_x;
reg [8:0] sprite_y;
reg [7:0] sprite_text;
reg [3:0] sprite_color, text_color;
wire [19:0] fifo_dout;
fifo_generator_0 sprite_fifo(
    .wr_clk(BUS_CLK),
    .din({video_addr, data}),
    .wr_en(bus_data_valid),
    .full(),

    .rd_clk(pclk),
    .rd_en(~empty),
    .dout(fifo_dout),
    .empty(empty)
);
always @(posedge pclk or posedge RESET) begin
    if (RESET) begin
        sprite_x <= 10'd320;
        sprite_y <= 9'd240;
        sprite_text <= 8'h7F;
        sprite_color <= 4'b0111; //default to white
        text_color <= 4'b0111; //default to white
    end
    else begin
        case (fifo_dout[19:8])
            'd2401: sprite_x[9:2] <= fifo_dout[7:0];
            'd2402: sprite_x[1:0] <= fifo_dout[1:0];
            'd2403: sprite_y[8:1] <= fifo_dout[7:0];
            'd2404: sprite_y[0] <= fifo_dout[0];
            'd2405: sprite_text <= fifo_dout[7:0];
            'd2406: sprite_color <= fifo_dout[3:0];
            'd2407: text_color <= fifo_dout[3:0];
            default: ; // Do nothing
        endcase
    end
end

wire [3:0] line;
wire [2:0] pixel;
ELF sprite_modeule(
    .clk(pclk),
    .RESET(RESET),

    .addrH(addr_H),
    .addrV(addr_V),

    .ELFx(sprite_x),
    .ELFy({1'b0, sprite_y}),

    .line(line),
    .pixel(pixel),
    .ELFen(sprite_en)
);
wire [7:0] final_data;
assign final_data = sprite_en ? sprite_text : frame_buffer_data;
wire [3:0] final_color;
assign final_color = sprite_en ? sprite_color : text_color;



/******** Tile to VGA pixel ********/
ascii_ROM font_tiles(
    .clka(pclk),

    .addra({final_data[6:0], line, pixel}), //Port A Address
    .douta(pixdata)
);



/********** VGA VREF & HREF Generator **********/
wire [7:0] color;
ColorPannel vga_sprite_color(
    .clk(pclk),
    .color(final_color),
    .vgacolor(color)
);

VGA_Sig_Gen VGA_TIMING_GEN(  
  .CLK(pclk),// PCLK 25.175MHz
  .RESET(RESET || ~locked), // Reset

  //Colour Configuration Interface
  .CONFIG_COLOURS(color),

  // Frame Buffer (Dual Port memory) Interface
  .DPR_CLK(),
  .VGA_ADDR_H(addr_H),
  .VGA_ADDR_V(addr_V),
  .VGA_DATA(pixdata),

  //VGA Port Interface
  .VGA_HS(VGA_HS),
  .VGA_VS(VGA_VS),
  .VGA_COLOUR(VGA_DATA) //3,2,3 RGB
);

//assign VGA_DATA = pixdata ? 8'hFF : 8'h00; //DATA 1 pixel clock cycle delay NOTE: No blur, displacement occur, No need to solve

endmodule
