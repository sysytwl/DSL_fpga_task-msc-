module ALU(
  //standard signals
  input            CLK,
  input            RESET,

  //I/O
  input      [7:0] IN_A,
  input      [7:0] IN_B,
  input      [3:0] ALU_Op_Code,
  output reg [7:0] Out
);

 
always @(posedge CLK or posedge RESET) begin
  if(RESET)
    Out <= 8'hZZ;
  else begin
    case (ALU_Op_Code)
      4'h0: Out <= IN_A + IN_B;//Add A + B
      4'h1: Out <= IN_A - IN_B;//Subtract A - B
      4'h2: Out <= IN_A * IN_B;//Multiply A * B
      4'h3: Out <= IN_A << 1;//Shift Left A << 1
      4'h4: Out <= IN_A >> 1;//Shift Right A >> 1
      4'h5: Out <= IN_A + 1'b1;//Increment A+1
      4'h6: Out <= IN_A & IN_B;//bitwise and
      4'h7: Out <= IN_A - 1'b1;//Decrement A-1
      4'h8: Out <= IN_A | IN_B;//bitwise or 
      4'h9: Out <= (IN_A == IN_B) ? 8'h01 : 8'h00;//A == B 
      4'hA: Out <= (IN_A > IN_B) ? 8'h01 : 8'h00;//A > B
      4'hB: Out <= (IN_A < IN_B) ? 8'h01 : 8'h00;//A < B 
      default: Out <= 8'hZZ;//NOP  
    endcase
  end
end

endmodule