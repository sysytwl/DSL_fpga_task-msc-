module Processor(
  //Standard Signals
  input CLK,
  input RESET,

  //BUS Signals
  inout [7:0] BUS_DATA,
  output [7:0] BUS_ADDR,//set to FF when not in use
  output BUS_WE,

  // ROM signals
  output [7:0] ROM_ADDRESS,
  input [7:0] ROM_DATA,

  // INTERRUPT signals
  input [7:0] BUS_INTERRUPTS_RAISE
);



//reg A and B
wire [2:0] reg_control_a, reg_control_b;
wire [7:0] DATA2ALU_A, DATA2ALU_B;
regs regsA(
  .CLK(CLK),
  .RESET(RESET),
  .cmd(reg_control_a),

  .write2busaddr_en(write2busaddr_en_a),
  .write2bus_en(write2bus_en_a),
  .data_reg(DATA2ALU_A),

  .data_in(BUS_DATA)
);
regs regsB(
  .CLK(CLK),
  .RESET(RESET),
  .cmd(reg_control_b),

  .write2busaddr_en(write2busaddr_en_b),
  .write2bus_en(write2bus_en_b),
  .data_reg(DATA2ALU_B),

  .data_in(BUS_DATA)
);
//(* dont_touch = "true" *) 
assign BUS_DATA = write2bus_en_a ? DATA2ALU_A : (write2bus_en_b ? DATA2ALU_B : 8'hZZ);
wire IBD2DBA;
assign BUS_ADDR = (IBD2DBA) ? ROM_DATA : (write2busaddr_en_a ? DATA2ALU_A : (write2busaddr_en_b ? DATA2ALU_B : 8'hFF));


//Interrupt
localparam irs_baseaddr = 8'h80;
reg [7:0] rising_edge_mask;
reg [7:0] falling_edge_mask;
wire [7:0] interrupt_flag;
reg [7:0] interrupt_flag_set_0;
reg rising_edge_mask_en, falling_edge_mask_en, interrupt_flag_en;
always @(posedge CLK) begin
  if(RESET)begin
    rising_edge_mask <= 0;
    falling_edge_mask <= 0;
    interrupt_flag_set_0 <= 0;

    rising_edge_mask_en <= 0;
    falling_edge_mask_en <= 0;
    interrupt_flag_en <= 0;
  end
  else if (BUS_ADDR == irs_baseaddr && BUS_WE) begin
    rising_edge_mask <= BUS_DATA;
  end
  else if (BUS_ADDR == irs_baseaddr+1 && BUS_WE) begin
    falling_edge_mask <= BUS_DATA;
  end
  else if (BUS_ADDR == irs_baseaddr+2 && BUS_WE) begin
    interrupt_flag_set_0 <= BUS_DATA;
  end
  else if (BUS_ADDR == irs_baseaddr) begin
    rising_edge_mask_en <= 1;
    falling_edge_mask_en <= 0;
    interrupt_flag_en <= 0;
  end
  else if (BUS_ADDR == irs_baseaddr+1) begin
    rising_edge_mask_en <= 0;
    falling_edge_mask_en <= 1;
    interrupt_flag_en <= 0;
  end
  else if (BUS_ADDR == irs_baseaddr+2) begin
    rising_edge_mask_en <= 0;
    falling_edge_mask_en <= 0;
    interrupt_flag_en <= 1;
  end
  else begin
    rising_edge_mask_en <= 0;
    falling_edge_mask_en <= 0;
    interrupt_flag_en <= 0;
  end
end
assign BUS_DATA = rising_edge_mask_en ? rising_edge_mask : 8'hZZ;
assign BUS_DATA = falling_edge_mask_en ? falling_edge_mask : 8'hZZ;
assign BUS_DATA = interrupt_flag_en ? interrupt_flag : 8'hZZ;
generate
  genvar i;
  for (i = 0; i < 8; i = i + 1) begin : interrupt_gen
    interrupts u_interrupts(
      .clk                  	(CLK),
      .reset                	(RESET),
      .interrupts_signal    	(BUS_INTERRUPTS_RAISE[i]),
      .rising_edge_mask     	(rising_edge_mask[i]),
      .falling_edge_mask    	(falling_edge_mask[i]),
      .interrupt_flag       	(interrupt_flag[i]),
      .interrupt_flag_set_0 	(interrupt_flag_set_0[i])
    );
  end
endgenerate



//program counter
wire [2:0] counter_cmd;
program_counter u_program_counter(
  .CLK(CLK),
  .RESET(RESET),
  .cmd(counter_cmd),
  .counter(ROM_ADDRESS),
  .count_in(ROM_DATA),
  .irs_running(irs_running)//the irs is running, in irs addr
);



//ALU
wire [3:0] opcode;
ALU ALU0(
  .CLK(CLK),
  .RESET(RESET),

  //I/O
  .IN_A(DATA2ALU_A),
  .IN_B(DATA2ALU_B),
  .ALU_Op_Code(opcode),
  .Out(BUS_DATA)
);



// output declaration of module decoder
decoder u_decoder(
  .clk(CLK),
  .reset(RESET),

  .instruction(ROM_DATA),
  .condition_result(BUS_DATA[0]),
  .opcode(opcode),
  .counter_cmd(counter_cmd),

  .reg_control_a(reg_control_a),
  .reg_control_b(reg_control_b),

  .irs_signal(|interrupt_flag),
  .irs_running(irs_running),
  .instruction_bus_data_2_data_bus_addr(IBD2DBA),

  .data_write_en(BUS_WE)
);


endmodule 