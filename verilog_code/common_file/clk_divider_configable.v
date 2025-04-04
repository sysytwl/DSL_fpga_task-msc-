module clk_divider_cfb(
  input CLK,
  input RESET,
  
  input [4:0] divider,
  output reg divided_clk
);

reg [31:0] Counter;
always@(posedge CLK) begin
  if(RESET) begin
    Counter <= 0;
    divided_clk <= 0;
  end
  else begin
    Counter <= Counter + 1'b1;
    divided_clk <= Counter[divider];
  end
end

endmodule