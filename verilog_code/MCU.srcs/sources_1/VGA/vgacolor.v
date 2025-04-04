module ColorPannel(
    input clk,
    input [3:0] color,
    output reg [7:0] vgacolor
);

always @(posedge clk) begin
    case (color)
        4'b0000: vgacolor <= 8'b00000000; // Black
        4'b0001: vgacolor <= 8'b00000011; // Blue
        4'b0010: vgacolor <= 8'b00001100; // Green
        4'b0011: vgacolor <= 8'b00001111; // Cyan
        4'b0100: vgacolor <= 8'b11000000; // Red
        4'b0101: vgacolor <= 8'b11000011; // Magenta
        4'b0110: vgacolor <= 8'b11110000; // Brown
        4'b0111: vgacolor <= 8'b11111111; // White
        4'b1000: vgacolor <= 8'b01111111; // Light Gray
        4'b1001: vgacolor <= 8'b00000010; // Dark Blue
        4'b1010: vgacolor <= 8'b00001000; // Dark Green
        4'b1011: vgacolor <= 8'b00001010; // Dark Cyan
        4'b1100: vgacolor <= 8'b10000000; // Dark Red
        4'b1101: vgacolor <= 8'b10000010; // Dark Magenta
        4'b1110: vgacolor <= 8'b10010000; // Dark Yellow
        4'b1111: vgacolor <= 8'b10010010; // Dark Gray
        default: vgacolor <= 8'b00000000; // Default to Black
    endcase
end

endmodule