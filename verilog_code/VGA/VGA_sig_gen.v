module VGA_Sig_Gen #(
  parameter color_background = 8'h00
)(  
  input             CLK,// PCLK 25.175MHz
  input             RESET, // Reset

  //Colour Configuration Interface
  input [7:0]      CONFIG_COLOURS,

  // Frame Buffer (Dual Port memory) Interface
  output            DPR_CLK,
  output reg [9:0] VGA_ADDR_H,
  output reg [9:0] VGA_ADDR_V,
  input            VGA_DATA,

  //VGA Port Interface
  output            VGA_HS,
  output            VGA_VS,
  output reg [7:0]  VGA_COLOUR //3,2,3 RGB
);

localparam HTpw   = 96;// Horizontal Pulse Width Time
localparam HTDisp  = 640;// Horizontal Display Time
localparam Hbp   = 48;// Horizontal Back Porch Time
localparam Hfp  = 16;// Horizontal Front Porch Time
localparam HTs   = HTpw + HTDisp + Hbp + Hfp;// Total Horizontal Sync Pulse  Time

localparam VTpw   = 2;// Vertical Pulse Width Time
localparam VTDisp   = 480;// Vertical Display Time
localparam Vbp   = 29;// Vertical Back Porch Time
localparam Vfp    = 10;// Vertical Front Porch Time
localparam VTs   = Vfp + VTDisp + VTpw + Vbp;// Total Vertical Sync Pulse Time

reg [9:0] HCount;  // Horizontal Counter
reg [9:0] VCount;  // Vertical Counter

//Pixel Clock Counter
always @(posedge CLK) begin
  if(RESET) begin
    HCount <= 0;
    VCount <= 0;
  end
  else if(HCount >= HTs) begin
    HCount <= 0;
    VCount <= VCount + 1;
  end
  else if(VCount >= VTs) begin
    VCount <= 0;
    HCount <= 0;
  end
  else begin
    HCount <= HCount + 1;
  end
end

// VREF && HREF Check
assign VGA_HS = ~((HCount >= Hfp+HTDisp) && (HCount < Hfp+HTDisp+HTpw));
assign VGA_VS = ~((VCount >= Vfp+VTDisp) && (VCount < Vfp+VTDisp+VTpw));

//Addr Pointer of pixel data
always @(posedge CLK) begin
  if(RESET)begin
    VGA_ADDR_H <= 0;
    VGA_ADDR_V <= 0;
  end
  else if(VCount <= VTDisp && HCount <= HTDisp) begin
    VGA_ADDR_H <= HCount;
    VGA_ADDR_V <= VCount;
    VGA_COLOUR <= (VGA_DATA ? CONFIG_COLOURS : color_background); //DATA 1 pixel clock cycle delay NOTE: No blur, displacement occur, No need to solve
  end
  else begin
    VGA_COLOUR <= 8'b0;
  end
end

assign DPR_CLK = CLK;

endmodule 