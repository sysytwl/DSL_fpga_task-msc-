`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////
// Company:			UoE
// Engineer:		
// 
// Create Date:		10:26:39 10/03/2012 
// Design Name:		PS/2 Demo
// Module Name:		seg7decoder
// Project Name:	PS/2 Demo
// Target Devices:	Digilent Basys2 100K
// Tool versions:	Xilinx ISE WebPack 14.2
// Description:		A decoder for the Basys2's 4-digit 7-segment display
//
// Dependencies:	none
//
// Revision: 
//		Revision 1		-	Implementation complete
// 		Revision 0.01	-	File Created
// Additional Comments: 
//	Interface:
//		SEG_SELECT_IN:	Select line for which of the digits to
//					operate
//		BIN_IN:		Input data in BNN format.
//		DOT_IN:		Input bit for the decimal point segment.
//		SEG_SELECT_OUT:	4-bit positional code; selects one of the 4
//					anodes of the display
//		HEX_OUT:	Display control signals. Determines the symbol
//					to be outputted.
////////////////////////////////////////////////////////////////////////////////
module seg7decoder #(
	parameter baseaddr = 8'hD0,
	parameter highaddr = 8'hD1
)(
	input clk,
	input reset,

	//bus
	input BUS_CLK,
	inout [7:0] BUS_DATA,
	input [7:0] BUS_ADDR,
	input BUS_WE,

	//to seg7
	output	reg	[3:0]	SEG_SELECT_OUT,
	output	reg	[7:0]	HEX_OUT
);



// reg [7:0] addr, data;
// always @(posedge BUS_CLK or posedge RESET) begin
//     if (RESET) begin
//         high_addr <= highaddr;
//         low_addr <= baseaddr;
//         data <= 8'b0;
//     end else if (BUS_WE && BUS_ADDR == baseaddr) begin
//             low_addr <= BUS_DATA;
//     end
// 	else if(BUS_WE && BUS_ADDR == highaddr) begin
//             data <= BUS_DATA;
//     end
// end
//assign BUS_DATA = (!BUS_WE && (BUS_ADDR >= baseaddr && BUS_ADDR <= highaddr)) ? data : 8'bZZ;



reg [1:0] SEG_SELECT_IN;
reg [3:0] BIN_IN [0:3];
reg DOT_IN;
always @(posedge BUS_CLK or posedge reset) begin
    if (reset) begin
        BIN_IN[0] <= 0;
		BIN_IN[1] <= 0;
		BIN_IN[2] <= 0;
		BIN_IN[3] <= 0;
		DOT_IN <= 0;
    end 
	else if (BUS_WE && BUS_ADDR == baseaddr) begin
        BIN_IN[3] <= BUS_DATA[7:4];
		BIN_IN[2] <= BUS_DATA[3:0];
    end
	else if(BUS_WE && BUS_ADDR == highaddr) begin
        BIN_IN[1] <= BUS_DATA[7:4];
		BIN_IN[0] <= BUS_DATA[3:0];
    end
end
always @(posedge clk or posedge reset) begin
  if(reset)begin
    SEG_SELECT_IN <= 0;
  end
  else begin
    SEG_SELECT_IN <= SEG_SELECT_IN + 1;
  end
end



always@(posedge clk) begin
	case(BIN_IN[SEG_SELECT_IN])
		4'b0000:	HEX_OUT[6:0] <= 7'b1000000; // 0
		4'b0001:	HEX_OUT[6:0] <= 7'b1111001; // 1
		4'b0010:	HEX_OUT[6:0] <= 7'b0100100; // 2
		4'b0011:	HEX_OUT[6:0] <= 7'b0110000; // 3
		
		4'b0100:	HEX_OUT[6:0] <= 7'b0011001; // 4
		4'b0101:	HEX_OUT[6:0] <= 7'b0010010; // 5
		4'b0110:	HEX_OUT[6:0] <= 7'b0000010; // 6
		4'b0111:	HEX_OUT[6:0] <= 7'b1111000; // 7
		
		4'b1000:	HEX_OUT[6:0] <= 7'b0000000; // 8
		4'b1001:	HEX_OUT[6:0] <= 7'b0011000; // 9
		4'b1010:	HEX_OUT[6:0] <= 7'b0001000; // A
		4'b1011:	HEX_OUT[6:0] <= 7'b0000011; // B
		
		4'b1100:	HEX_OUT[6:0] <= 7'b1000110; // C
		4'b1101:	HEX_OUT[6:0] <= 7'b0100001; // D
		4'b1110:	HEX_OUT[6:0] <= 7'b0000110; // E
		4'b1111:	HEX_OUT[6:0] <= 7'b0001110; // F
		
		default:	HEX_OUT[6:0] <= 7'b1111111; // off
	endcase
end

always@(DOT_IN) begin
	HEX_OUT[7] <= ~DOT_IN;
end

always@(posedge clk) begin
	case(SEG_SELECT_IN)
		2'b00:		SEG_SELECT_OUT <= 4'b1110; // rightmost
		2'b01:		SEG_SELECT_OUT <= 4'b1101;
		2'b10:		SEG_SELECT_OUT <= 4'b1011;
		2'b11:		SEG_SELECT_OUT <= 4'b0111; // leftmost
		default:	SEG_SELECT_OUT <= 4'b1111; // all off
	endcase
end

endmodule
