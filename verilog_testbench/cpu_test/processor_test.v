`timescale 1ns / 1ps

module processor_test;

// Inputs
reg CLK;
reg RESET;

//irs
reg [7:0] BUS_INTERRUPTS_RAISE;

//ram
wire [7:0] BUS_ADDR;
reg [7:0] BUS_DATA;
wire [7:0] BUS_DATA_IO;
wire BUS_WE;
reg ram_en;
assign BUS_DATA_IO = (~BUS_WE && ram_en) ? BUS_DATA : 8'hZZ;
always @(posedge CLK) begin
    if(RESET)begin
        ram_en <= 0;
    end
    else if(BUS_ADDR <= 8'h80) begin
        ram_en <= 1;
    end
    else begin
        ram_en <= 0;
    end
end
reg [7:0] BUS_DATA_ARRAY [0:255];
initial begin
    BUS_DATA_ARRAY[0] = 10;
    BUS_DATA_ARRAY[1] = 20;
    BUS_DATA_ARRAY[2] = 30;
    BUS_DATA_ARRAY[50] = 200;
    BUS_DATA_ARRAY[70] = 100;
end
always @(posedge (CLK && (BUS_ADDR <= 8'h80))) begin
    if(RESET)
        BUS_DATA <= 8'h00;
    else if(BUS_WE) 
        BUS_DATA_ARRAY[BUS_ADDR] <= BUS_DATA_IO;
    else
        BUS_DATA <= BUS_DATA_ARRAY[BUS_ADDR];
end

//rom
wire [7:0] ROM_ADDRESS;
reg [7:0] ROM_DATA;
reg [7:0] ROM_DATA_ARRAY [0:255];
initial begin
    ROM_DATA_ARRAY[0] = 8'b0000_0001; ROM_DATA_ARRAY[1] = 8'b0000_0010;//mova 30
    ROM_DATA_ARRAY[2] = 8'b0000_0000; ROM_DATA_ARRAY[3] = 8'b0000_0001;//movb 20
    ROM_DATA_ARRAY[4] = 8'b0000_0010; ROM_DATA_ARRAY[5] = 8'b0000_0011;//sba
    ROM_DATA_ARRAY[6] = 8'b0000_0011; ROM_DATA_ARRAY[7] = 8'b0000_0100;//sbb
    ROM_DATA_ARRAY[8] = 8'b0000_0100;//opa a+b = 50
    ROM_DATA_ARRAY[9] = 8'b0001_0101;//opb a-b = 30
    ROM_DATA_ARRAY[10] = 8'b0000_1110; ROM_DATA_ARRAY[11] = 8'b0000_0000;//op a+b -> addr
    ROM_DATA_ARRAY[12] = 8'b1011_0110; ROM_DATA_ARRAY[13] = 8'b0001_0001;//cjal
    ROM_DATA_ARRAY[14] = 8'b0000_0111; ROM_DATA_ARRAY[15] = 8'b0000_1000;//jal
    ROM_DATA_ARRAY[16] = 8'b0000_1000;//nop
    ROM_DATA_ARRAY[17] = 8'b0000_1001; ROM_DATA_ARRAY[18] = 8'd19;//call
    ROM_DATA_ARRAY[19] = 8'b0000_1011;//lba
    ROM_DATA_ARRAY[20] = 8'b0000_1100;//lbb
    ROM_DATA_ARRAY[21] = 8'b1010_0110; ROM_DATA_ARRAY[22] = 8'd24;//cjal
    ROM_DATA_ARRAY[23] = 8'b0000_1010;//ret
    ROM_DATA_ARRAY[24] = 8'b0000_1101;//halt
    ROM_DATA_ARRAY[192] = 8'b0000_0000; ROM_DATA_ARRAY[193] = 8'd50;//mova FF
    ROM_DATA_ARRAY[194] = 8'b0000_0010; ROM_DATA_ARRAY[195] = 8'h82;//sba FF
    ROM_DATA_ARRAY[196] = 8'b0000_0000; ROM_DATA_ARRAY[197] = 8'd70;//sba FF
    ROM_DATA_ARRAY[198] = 8'b0000_0010; ROM_DATA_ARRAY[199] = 8'h82;//sba FF
    ROM_DATA_ARRAY[200] = 8'b0000_1010;//ret
end
always @(posedge CLK) begin
    ROM_DATA <= ROM_DATA_ARRAY[ROM_ADDRESS];
end

// Instantiate the Unit Under Test (UUT)
Processor uut (
    .CLK(CLK), 
    .RESET(RESET), 
    .BUS_DATA(BUS_DATA_IO), 
    .BUS_ADDR(BUS_ADDR), 
    .BUS_WE(BUS_WE), 
    .ROM_ADDRESS(ROM_ADDRESS), 
    .ROM_DATA(ROM_DATA), 
    .BUS_INTERRUPTS_RAISE(BUS_INTERRUPTS_RAISE)
);



initial begin
    // Initialize Inputs
    CLK = 0;
    RESET = 1;
    BUS_INTERRUPTS_RAISE = 0;

    //reset
    #17 RESET = 0;

    //test all cmd
    //@(ROM_ADDRESS >= 8'd20);
    #375;

    //Check interrupt handling
    @(posedge CLK) BUS_INTERRUPTS_RAISE = 8'hFF;
    #300;
    
    // Finish simulation
    $finish;
end

always #5 CLK = ~CLK;

endmodule