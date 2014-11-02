/*
This module connects all the files for project 2 
*/

module nexys4fpga (
    input clk,          // 100MHz clock from on-board oscillator
    input btnL, btnR,   // pushbutton inputs - left (db_btns[4])and right (db_btns[2])
    input btnU, btnD,   // pushbutton inputs - up (db_btns[3]) and down (db_btns[1])
    input btnC,			// pushbutton inputs - center button -> db_btns[5]
	input btnCpuReset,	// red pushbutton input -> db_btns[0]
	input [15:0] sw,	// switch inputs
	
	output [15:0] led,    // LED outputs
    //output reg [4:0]    digi7,digi6,digi5,digi4,digi3,digi2,digi1,digi0,
	output [6:0] seg,	// Seven segment display cathode pins
	output  dp,          //decimal point
	output [7:0] an,	// Seven segment display anode pins	
	output [7:0] JA,		// JA Header

	output  Hsync, 
	output  Vsync, 

    output  [3:0] vgaRed,
    output  [3:0] vgaGreen,
    output  [3:0] vgaBlue
 
);
// parameter
	parameter SIMULATE = 0;

//incoming clock is at 100 Mhz
//formula is 100 Mhz / 10 HZ * 50% duty cycle
//So for 25 Hz: 100000000 / 25 * 0.5 = 2000000 
    wire c_CNT_25MHZ = 1'b1;//2
    wire [31:0] c_CNT_10HZ = 32'b0000_0000_0100_1100_0100_1011_0100_0000;//5_000_000
    
    

// internal variables
	wire 	[15:0]		db_sw;					// debounced switches
	wire 	[5:0]		db_btns;				// debounced buttons
	
	wire				sysclk;					// 100MHz clock from on-board oscillator	
	wire				sysreset;				// system reset signal - asserted high to force reset
	
	wire 	[4:0]	    dig6,
						dig5, dig4,
						dig3, dig2, 
						dig1, dig0;				// display digits
    wire    [4:0]       dig7;                   
	wire 	[7:0]		dpts;					// decimal points
	wire 	[15:0]		chase_segs;				// chase segments from Rojobot (debug)
	
	wire    [7:0]       segs_int;              // sevensegment module the segments and the decimal point
	wire	[7:0]		left_pos, right_pos;
	wire 	[63:0]		digits_out;				// ASCII digits (Only for Simulation)
    wire    [7:0]       motor;                  //wire for motor connection
    wire    [7:0]       loc_x,loc_y,sens,boti,LMDist,RMDist;  //wires for bot connections
    wire    [9:0]       vid_row, vid_col;//current location of map to write out
    wire    [1:0]       v_pix;// data at vid_row x vid_col
    wire    video_on;   //on when in the 512x512 viewable map area 640 - 128 for width 
    wire    [1:0] icon;

    wire                up_sys;
    	//output  Hsync, //horz sync for vga
    //output  Vsync, //horz sync for vga
    // v_sync, h_sync, video_on;
    
 // internal variables for picoblaze and program ROM signals
// signal names taken from kcpsm6_design_template.v
wire	[11:0]		address;
wire	[17:0]		instruction;
wire				bram_enable;
wire				rdl;

wire	[7:0]		port_id;
wire	[7:0]		out_port;
wire	[7:0]		in_port;
wire				write_strobe;
wire				read_strobe;
wire				interrupt_w;
wire				interrupt_ack_w;
wire				kcpsm6_sleep; 
wire				kcpsm6_reset;
	
wire 	[1:0]		wrld_loc_info;		// location value from world map
wire 	[7:0]		wrld_col_addr,		// column address to map logic
					wrld_row_addr;		// row address to map logic


    
//counter for clock
    reg  r_CNT_25MHZ = 1'b0;
    reg [31:0] r_CNT_10HZ = 32'b0000_0000_0000_0000_0000_0000_0000_0000;
//toggles for clock
	reg 	r_Toggle_25MHZ = 1'b0;
    reg 	r_Toggle_10HZ = 1'b0;
//start 25 MHz clock
	always @(posedge clk) //25 Hz clock
		begin
		if (r_CNT_25MHZ == c_CNT_25MHZ)	//if counter for 25Hz is equal to what the count should be
			begin
			r_Toggle_25MHZ <= !r_Toggle_25MHZ; //toggle the switch and
			r_CNT_25MHZ <= 1'b0;				//reset the counter
			end
		else
			begin
			r_CNT_25MHZ <= r_CNT_25MHZ + 1'b1; //if not, increment the counter
			end
		end
//start 10 Hz clock
    always @(posedge clk) //10 Hz clock
		begin
		if (r_CNT_10HZ == c_CNT_10HZ)	//if counter for 10Hz is equal to what the count should be
			begin
			r_Toggle_10HZ <= !r_Toggle_10HZ; //toggle the switch and
			r_CNT_10HZ <= 32'b0000_0000_0000_0000_0000_0000_0000_0000;				//reset the counter
			end
		else
			begin
			r_CNT_10HZ <= r_CNT_10HZ + 1'b1; //if not, increment the counter
			end
		end
// global assigns
	assign	sysclk = clk;
	assign 	sysreset = ~db_btns[0]; // btnCpuReset is asserted low (fixed to be asserted high)
	
    //assign dp = up_sys; //used for debug, when turned on all decimal points were solid, not blinking
	assign dp = segs_int[7];  //decimal point wire
	assign seg = segs_int[6:0]; //7 seg wire
	
	assign	JA = {sysclk, sysreset, 6'b000000};
    assign kcpsm6_reset = sysreset;			// Picoblaze is reset w/ global reset signal
    assign kcpsm6_sleep = 1'b0;				// kcpsm6 sleep mode is not used
    
    assign led [9:8] = icon;
    //assign led [10:8] = boti;
	
//instantiate the debounce module
	debounce
	#(
		.RESET_POLARITY_LOW(0), //change to 0 to match other resets
		.SIMULATE(SIMULATE)
	)  	DB
	(
		.clk(sysclk),	
		.pbtn_in({btnC,btnL,btnU,btnR,btnD,btnCpuReset}),
		.switch_in(sw),
		.pbtn_db(db_btns),
		.swtch_db(db_sw)
	);	
		
// instantiate the 7-segment, 8-digit display
	sevensegment
	#(
		.RESET_POLARITY_LOW(0), //change to 0 match other resets
		.SIMULATE(SIMULATE)
	) SSB
	(
		// inputs for control signals
		.d0(dig0),
		.d1(dig1),
 		.d2(dig2),
		.d3(dig3),
		.d4(dig4),
		.d5(dig5),
		.d6(dig6),
		.d7(dig7),
		.dp(dpts),
		
		// outputs to seven segment display
		.seg(segs_int),			
		.an(an),
		
		// clock and reset signals (100 MHz clock, active high reset)
		.clk(sysclk),
		.reset(sysreset),
		
		// ouput for simulation only
		.digits_out(digits_out)
	);
//instantiate picoblaze
  kcpsm6 #(
	.interrupt_vector	(12'h3FF),
	.scratch_pad_memory_size(64),
	.hwbuild		(8'h00))
  processor (
	.address 		(address),
	.instruction 	(instruction),
	.bram_enable 	(bram_enable),
	.port_id 		(port_id),
	.write_strobe 	(write_strobe),
	.k_write_strobe 	(),
	.out_port 		(out_port),
	.read_strobe 	(read_strobe),
	.in_port 		(in_port),
	.interrupt 		(interrupt_w),
	.interrupt_ack 	(interrupt_ack_w),
	.reset 		(kcpsm6_reset),
	.sleep		(kcpsm6_sleep),
	.clk 			(clk)); 
proj2demo PROJ2DEMO(
    .address(address), 
    .instruction(instruction), 
    .enable(bram_enable), 
    .rdl(rdl), 
    .clk(clk));    
//instantiate bot
bot BOT(
	// system interface registers
	.MotCtl_in(motor),		// Motor control input	
	.LocX_reg(loc_x),		// X-coordinate of rojobot's location		
	.LocY_reg(loc_y),		// Y-coordinate of rojobot's location
	.Sensors_reg(sens),	// Sensor readings
	.BotInfo_reg(boti),	// Information about rojobot's activity
	.LMDist_reg(LMDist),		// left motor distance register
	.RMDist_reg(RMDist),		// right motor distance register						
	// interface to the video logic
	.vid_row({2'b00, vid_row [9:2]}),//(vid_row),shift right 2 times diveds by 4 video logic row address
	.vid_col({2'b00, vid_col [9:2]}),		//(vid_col), video logic column address
    .vid_pixel_out(v_pix),	// pixel (location) value
	// interface to the system
	.clk(clk),			// system clock
	.reset(sysreset),			// system reset
	.upd_sysregs(up_sys)		// flag from PicoBlaze to indicate that the system registers 
											// (LocX, LocY, Sensors, BotInfo)have been updated
);
//instantiate bot_if 
nexys4_bot_if BOT_IF(
	// interface to the picoblaze
	.Wr_Strobe(write_strobe),		// Write strobe - asserted to write I/O data
	.Rd_Strobe(read_strobe),		// Read strobe - asserted to read I/O data
    .AddrIn(port_id),			// I/O port address port_id
	.DataIn(out_port),			// Data to be written to I/O register out_port
	.DataOut(in_port),		// I/O register data to picoblaze in_port
    .interrupt(interrupt_w),
	.interrupt_ack(interrupt_ack_w),
	// interface to the system	
	.MotCtl(motor),			// (Port 0) Motor control input	into botsim
	.LocX(loc_x),			// (Port 1) X-coordinate of rojobot's location		
	.LocY(loc_y),			// (Port 2) Y-coordinate of rojobot's location
	.BotInfo(boti),		// (Port 3) Rojobot orientation and movement
	.Sensors(sens),		// (Port 4) Sensor readings												
	// interface to the world map logic
//	output reg	[7:0]	MapX,			// (Port 8) Column address of world map location
//	output reg	[7:0]	MapY,			// (Port 9) Row address of world map location
//	input 		[1:0]	MapVal,			// (Port 10) Map value for location [row_addr, col_addr]	

	.clk(clk),			// system clock or r_Toggle_10HZ???
	.reset(sysreset),			// system reset
	.upd_sysregs(up_sys),	// flag from PicoBlaze to indicate that the system registers 
										// (LocX, LocY, Sensors, BotInfo)have been updated	
    .db_btns(db_btns[5:0]),
    .db_sw(db_sw),
    .led(led[7:0]), //out led
    .dig7(dig7), 
    .dig6(dig6), 
    .dig5(dig5), 
    .dig4(dig4), 
    .dig3(dig3), 
    .dig2(dig2), 
    .dig1(dig1), 
    .dig0(dig0), //7 seg display to sevenseg.v
    .dp(dpts)  //decimal point out to sevenseg.v   		
);





dtg DTG (
		.clock(r_Toggle_25MHZ),
		.rst(sysreset),
        .horiz_sync(Hsync),
        .vert_sync(Vsync),
        .video_on(video_on),        
        .pixel_row(vid_row),
        .pixel_column(vid_col)	
	);
	    

    //assign vid_pixel_out = v_pix;
    
colorizer COLOR(
     .video_on(video_on),
     .clk(clk),
     .world_pixel(v_pix),
     .icon(icon),
     .vga_red(vgaRed),//[3:0] 
     .vga_green(vgaGreen),//[3:0] 
     .vga_blue(vgaBlue) //[3:0] 
);

Icon ICON(
        .clk(clk),
        .LocY({loc_y, 2'b00}),
        .LocX({loc_x, 2'b00}),
//        .vid_row({2'b00, vid_row [9:2]}),//shift right 2 times diveds by 4 video logic row address
//            .vid_col({2'b00, vid_col [9:2]}),        // video logic column address
        .pixel_row(vid_row),//({2'b00, vid_row [9:2]}),
        .pixel_column(vid_col),//({2'b00, vid_col [9:2]}),
        .icon(icon),
        .BotInfo(boti[2:0]),
        .debug_led(led[15:8])

);
endmodule