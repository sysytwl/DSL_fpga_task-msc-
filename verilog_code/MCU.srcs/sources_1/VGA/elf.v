//-----------------------------------------------------------------------------
// Module: ELF
// Description: This module generates enable signals and calculates line and 
//              pixel values for an ELF sprite based on its position and size 
//              within a VGA display.
//
// Parameters:
//   - ELFwide: Width of the ELF sprite (constant, 8 pixels).
//   - ELFheight: Height of the ELF sprite (constant, 16 pixels).
//
// Ports:
//   - clk (input): Clock signal.
//   - RESET (input): Reset signal, active high. Resets internal registers.
//   - addrH (input): Horizontal address of the VGA display (10-bit).
//   - addrV (input): Vertical address of the VGA display (10-bit).
//   - ELFx (input): Horizontal position of the ELF sprite (10-bit).
//   - ELFy (input): Vertical position of the ELF sprite (10-bit).
//   - line (output, reg): Line index within the ELF sprite (4-bit).
//   - pixel (output, reg): Pixel index within the ELF sprite (3-bit).
//   - ELFen (output, reg): Enable signal for the ELF sprite (1-bit).
//
// Functionality:
//   - When RESET is active, all outputs are reset to their default values.
//   - When the current VGA address (addrH, addrV) falls within the bounds of 
//     the ELF sprite (defined by ELFx, ELFy, ELFwide, and ELFheight), the 
//     module calculates the line and pixel indices relative to the sprite's 
//     position and asserts the ELFen signal.
//   - If the VGA address is outside the sprite's bounds, the module deasserts 
//     ELFen and outputs the current VGA address' lower bits as line and pixel.
//
// Notes:
//   - The line index is calculated as the difference between the vertical 
//     address (addrV) and the sprite's vertical position (ELFy), limited to 
//     4 bits.
//   - The pixel index is calculated as the difference between the horizontal 
//     address (addrH) and the sprite's horizontal position (ELFx), limited to 
//     3 bits.
//-----------------------------------------------------------------------------
module ELF(
  input clk,
  input RESET,

  //back ground
  input [9:0] addrH,
  input [9:0] addrV,

  //input
  input [9:0] ELFx,
  input [9:0] ELFy,

  output reg [3:0] line,
  output reg [2:0] pixel,
  output reg ELFen
);

localparam ELFwide = 8;
localparam ELFheight = 16;

always @(posedge clk) begin
  if (RESET) begin
    ELFen <= 0;
    line <= 0;
    pixel <= 0;
  end
  else if ((addrH >= ELFx && addrH < ELFx + ELFwide) && (addrV >= ELFy && addrV < ELFy + ELFheight)) begin
    ELFen <= 1;
    line <= addrV[3:0] - ELFy[3:0];
    pixel <= addrH[2:0] - ELFx[2:0];
  end
  else begin
    line <= addrV[3:0];
    pixel <= addrH[2:0];
    ELFen <= 0;
  end
end

endmodule