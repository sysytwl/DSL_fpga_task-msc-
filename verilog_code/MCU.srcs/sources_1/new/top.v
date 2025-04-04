module top(
    input clk_100M,
    input reset,

    //IO - Mouse side
    inout            CLK_MOUSE,
    inout            DATA_MOUSE,

    //leds
    output LEFT,
    output RIGHT,

    //seg7
    output     [7:0] HEX_OUT,
    output     [3:0] SEG_SELECT_OUT,

    //keys
    input btnU,
    input btnL,
    input btnR,
    input btnD,

    //serial
    // input RsRx,
    // output RsTx,

    //vga
    output     [7:0] VGA_DATA,
    output           VGA_HS,
    output           VGA_VS,

    //ir
    output IR_LED
);



//bus
wire [7:0] BUS_DATA;
wire [7:0] BUS_ADDR;
wire BUS_WE;

//irs
wire [7:0] BUS_INTERRUPTS_RAISE;
assign BUS_INTERRUPTS_RAISE[2] = btnL;
assign BUS_INTERRUPTS_RAISE[3] = btnR;
assign BUS_INTERRUPTS_RAISE[4] = btnD;
assign BUS_INTERRUPTS_RAISE[5] = btnD;



//main clk_divider
wire clk;
clk_divider #(
    .divider 	('d1))
main_clkdiv(
    .CLK         	(clk_100M),
    .RESET       	(reset),
    .divided_clk 	(clk)
);



//ps2 mouse
MouseTransceiver u_MouseTransceiver(
    .CLK(clk_100M),
    .RESET(reset),

    //IO - Mouse side, DEBUG
    .CLK_MOUSE(CLK_MOUSE),
    .DATA_MOUSE(DATA_MOUSE),

    .LEFT(LEFT),
    .RIGHT(RIGHT),

    //bus
    .BUS_CLK(clk),
    .BUS_DATA(BUS_DATA),
    .BUS_ADDR(BUS_ADDR),
    .BUS_WE(BUS_WE),
    .READY_INTERRUPT(BUS_INTERRUPTS_RAISE[0])
);



//rom
wire [7:0] ROM_DATA;
wire [7:0] ROM_ADDRESS;
ROM u_ROM(
    .CLK(clk),

    //BUS signals
    .DATA(ROM_DATA),
    .ADDR(ROM_ADDRESS)
);  



//ram
RAM u_RAM(  
    //standard signals  
    .CLK(clk),

    //BUS signals  
    .BUS_DATA(BUS_DATA),
    .BUS_ADDR(BUS_ADDR),
    .BUS_WE(BUS_WE)
);  



//timer
Timer u_Timer(
    .CLK                 	(clk),
    .RESET               	(reset),
    .BUS_DATA            	(BUS_DATA),
    .BUS_ADDR            	(BUS_ADDR),
    .BUS_WE              	(BUS_WE),
    .BUS_INTERRUPT_RAISE 	(BUS_INTERRUPTS_RAISE[1])
);



//seg7
wire clk_seg;
clk_divider #(
    .divider 	('d18)) //2^number = 262,144
seg7_clk_divider(
    .CLK         	(clk_100M),
    .RESET       	(reset),
    .divided_clk 	(clk_seg)
);
seg7decoder u_seg7decoder(
    .clk(clk_seg),
    .reset(reset),

    //bus
    .BUS_CLK(clk),
    .BUS_DATA(BUS_DATA),
    .BUS_ADDR(BUS_ADDR),
    .BUS_WE(BUS_WE),

    //to seg7
    .SEG_SELECT_OUT(SEG_SELECT_OUT),
    .HEX_OUT(HEX_OUT)
);



//vga
VGA_TOP u_VGA_TOP(
    .CLK      	(clk_100M),
    .RESET    	(reset),

    //bus
    .BUS_CLK  	(clk),
    .BUS_WE   	(BUS_WE),
    .BUS_ADDR 	(BUS_ADDR),
    .BUS_DATA 	(BUS_DATA),

    .VGA_DATA 	(VGA_DATA),
    .VGA_HS   	(VGA_HS),
    .VGA_VS   	(VGA_VS)
);



//ir
IRTransmitter ir (
    .CLK(clk_100M),
    .RESET(reset),
    .BUS_ADDR(BUS_ADDR),
    .BUS_DATA(BUS_DATA),
    .BUS_WE(BUS_WE),
    .IR_LED(IR_LED),
    .BUS_CLK(clk)
);



//cpu
Processor u_Processor(
    .CLK                  	(clk),
    .RESET                	(reset),
    .BUS_DATA             	(BUS_DATA),
    .BUS_ADDR             	(BUS_ADDR),
    .BUS_WE               	(BUS_WE),
    .ROM_ADDRESS          	(ROM_ADDRESS),
    .ROM_DATA             	(ROM_DATA),
    .BUS_INTERRUPTS_RAISE 	(BUS_INTERRUPTS_RAISE)
);



endmodule
