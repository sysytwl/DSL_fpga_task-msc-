/* timer reg addrbase F0
 * MSB    -------------------------------------------------------- LSB
 * addr 0 | EN | autoR | RESV | RESV | RESV | RESV | RESV | RESV | R/W
 * addr 1 |          divison  2^clk divider                      | R/W
 * addr 2 |          timer interrupt interval register           | R/W
 * addr 3 |                   timer counter                      | RO
 *        --------------------------------------------------------
*/

module Timer #(
  parameter [7:0] TimerBaseAddr = 8'hF0,  // Timer Base Address in the Memory Map
  parameter InitialIterruptRate = 7,
  parameter InitialIterruptEnable = 1'b1,  // By default the Interrupt is Enabled
  parameter InterruptAutoReset = 1,
  parameter Initialclk_divider_value = 7 //128
)(
  //standard signals
  input       CLK,
  input       RESET,

  //BUS signals
  inout [7:0] BUS_DATA,
  input [7:0] BUS_ADDR,
  input       BUS_WE,
  output      BUS_INTERRUPT_RAISE
);



//Interrupt Enable Configuration - If this is not set to 1, no interrupts will be created.
reg InterruptEnable;
reg Interrupt_auto_Reset; //auto reset the counter when reached the target
reg InterruptEnable_en;
always@(posedge CLK)begin
  if(RESET) begin
    InterruptEnable <= InitialIterruptEnable;
    Interrupt_auto_Reset <= InterruptAutoReset;
    InterruptEnable_en <= 0;
  end
  else if((BUS_ADDR == TimerBaseAddr) && BUS_WE)
    InterruptEnable <= BUS_DATA[7];
  else if ((BUS_ADDR == TimerBaseAddr) && BUS_WE)
    Interrupt_auto_Reset <= BUS_DATA[6];
  else if (BUS_ADDR == TimerBaseAddr)
    InterruptEnable_en <= 1;
  else
    InterruptEnable_en <= 0;
end

//read reg
assign BUS_DATA = InterruptEnable_en ? {InterruptEnable, Interrupt_auto_Reset , 6'b00_0000} : 8'hZZ;



//CLK divider & clk divider configerable
clk_divider #(
  .divider 	(9) //512
)fixed_clk_divider(
  .CLK         	(CLK),//50Mhz
  .RESET       	(RESET),
  .divided_clk 	(clk_100k)//97.65625 khz
);

reg [7:0] clk_divider_value;
always@(posedge CLK) begin
  if(RESET)
    clk_divider_value <= Initialclk_divider_value;
  else if((BUS_ADDR == TimerBaseAddr + 1) && BUS_WE)
    clk_divider_value <= BUS_DATA;
end
assign BUS_DATA = (BUS_ADDR == TimerBaseAddr + 1) ? clk_divider_value : 8'hZZ;

clk_divider_cfb timer_clk_divider(//2^32
  .CLK(clk_100k),
  .RESET(RESET),
  .divider(clk_divider_value[4:0]),
  .divided_clk(clk_1k)
);



//Interrupt Rate Configuration
reg [7:0] InterruptRate;
always@(posedge CLK) begin
  if(RESET)
    InterruptRate <= InitialIterruptRate;
  else if((BUS_ADDR == TimerBaseAddr + 2) && BUS_WE)
    InterruptRate[7:0] <= BUS_DATA;
end
assign BUS_DATA = (BUS_ADDR == TimerBaseAddr + 2) ? InterruptRate : 8'hZZ;



//timer counter, irs, stop when reached the target to save power than the old method
reg [7:0] Timer_counter;
reg Interrupt;
always@(posedge clk_1k) begin
  if(RESET || ~InterruptEnable) begin
    Timer_counter <= 0;
    Interrupt <= 1'b0;
  end
  else if (Timer_counter == InterruptRate) begin
    Interrupt <= 1'b1;
    if (Interrupt_auto_Reset)
      Timer_counter <= 0;
  end
  else begin
    Interrupt <= 1'b0;
    Timer_counter <= Timer_counter + 1'b1;
  end
end
assign BUS_DATA = (BUS_ADDR == TimerBaseAddr + 3) ? Timer_counter[7:0] : 8'hZZ;
assign BUS_INTERRUPT_RAISE = Interrupt; //move IRS reg into the mcu, better module structure

endmodule