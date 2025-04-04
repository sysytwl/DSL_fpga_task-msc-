module clk_divider #(
  parameter divider = 5'd1
)(
  input CLK,
  input RESET,

  output reg divided_clk
);

reg [31:0] Counter;
always@(posedge CLK) begin
  if(RESET) begin
    Counter <= 0;
    divided_clk <= 1'b0;
  end
  else begin
    Counter <= Counter + 1'b1;
    divided_clk <= Counter[divider];
  end
end

endmodule