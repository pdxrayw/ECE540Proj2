//	bot_if.v - Register interface to the Rojobot external world picoblaze 
//	
//	8-bit registers:
//			Loc_X		O	X (column) coordinate of Rojobot's current location
//			Loc_y		O 	Y (row) coordinate of Rojobot's current location
//			Sensors		O	Sensor values.  Rojobot contains a proximity sensor (left and right)
//						 	A proximity sensor is set to 1 if Rojobot detects an object in
//						  	front of it.  It also contains a black line sensor (left, center
//						  	and right).  Each black line sensor is set to 0 if there is
//							a black line under it and set to 1 if there is not black line
//							under it.
//			BotInfo		O 	Information on rojobot's current orientation and movement
//
//////////

module nexys4_bot_if(
	// interface to the picoblaze
	input 				Wr_Strobe,		// Write strobe - asserted to write I/O data
		 				Rd_Strobe,		// Read strobe - asserted to read I/O data
	input 		[7:0] 	AddrIn,			// I/O port address port_id
	input 		[7:0] 	DataIn,			// Data to be written to I/O register out_port
	output reg	[7:0] 	DataOut,		// I/O register data to picoblaze in_port

	// interface to the system	
	output reg 	[7:0]	MotCtl,			// (Port 0) Motor control input	into botsim
	input    	[7:0] 	LocX,			// (Port 1) X-coordinate of rojobot's location		
						LocY,			// (Port 2) Y-coordinate of rojobot's location
						BotInfo,		// (Port 3) Rojobot orientation and movement
						Sensors,		// (Port 4) Sensor readings
												
	// interface to the world map logic
//	output reg	[7:0]	MapX,			// (Port 8) Column address of world map location
//	output reg	[7:0]	MapY,			// (Port 9) Row address of world map location
//	input 		[1:0]	MapVal,			// (Port 10) Map value for location [row_addr, col_addr]	

	
	input				clk,			// system clock
						reset,			// system reset
	input   			upd_sysregs,	// flag from PicoBlaze to indicate that the system registers 
										// (LocX, LocY, Sensors, BotInfo)have been updated	
    input       [5:0]   db_btns,
    input       [15:0]  db_sw,
    output reg [15:0]   led, //out led
    output reg [4:0]    dig7, dig6, dig5, dig4, dig3, dig2, dig1, dig0, //7 seg display to sevenseg.v
    output reg [7:0]    dp,  //decimal point out to sevenseg.v   
    output reg          interrupt
		
);

// internal variables		
// used sot synchronize the register transfer so Application gets a consistant snapshot of the BOT status	
reg			load_sys_regs,			// Load system register flip-flop			
			load_dist_regs;			// Load distance register flip-flop

// holding registers for bot.  We want all registers to be updated
// at the same time (from system's point of view) to make sure
// the bot movement is consistent.
reg	[7:0] 	DataOut_int,					
            MotCtl_int,
            dp_int;
reg [15:0]   led_int;
reg [4:0]    dig7_int, dig6_int, dig5_int, dig4_int, dig3_int, dig2_int, dig1_int, dig0_int;
//reg          interrupt_int;
// read registers
always @(posedge clk) 
begin
    case(AddrIn[7:0])
    8'b0000_0000 : //pushbuttons inputs
    begin
    // format is: output(for this file) <= input (for this file)
    //dbbtns[5:0]
        DataOut <= {4'b00, db_btns};//dataout is to picoblaze
    end
    8'b0000_0001 : //slide switches
    begin
        DataOut <= db_sw[7:0];
    end
    8'b0000_1010 :// X coordinate of rojobot location
    begin
        DataOut <= LocX;
    end
    8'b0000_1011 : //(i))Y coordinate of rojobot location
    begin
        DataOut <= LocY;
    end
    8'b0000_1100 : //(i) Rojobot info register
    begin
        DataOut <= BotInfo;
    end
    8'b0000_1101 : //(i) Sensor register
    begin
        DataOut <= Sensors;
    end
    8'b0001_0000 : //(i) pushbutton inputs alternate port address
    begin
        DataOut <= {4'b00, db_btns};
    end
    8'b0001_0001 : //(i) slide switches 15:8 (high byte of switches
    begin
        DataOut <= db_sw[15:8];
    end
    8'b0001_1010 : //(i) X coordinate of rojobot location
    begin
        DataOut <= LocX;
    end
    8'b0001_1011 : //(i) Y coordinate of rojobot location
    begin
        DataOut <= LocY;
    end
    8'b0001_1100 : //(i) Rojobot info register
    begin
        DataOut <= BotInfo;
    end
    8'b0001_1101 : //(i) Sensor register
    begin
        DataOut <= Sensors;
    end
    default : 
    begin
        DataOut <= 8'bXXXXXXXX;
    end
    endcase
end //always read registers


// write registers
always @(posedge clk) begin
	if (reset) begin
	/*	LocX_int <= 0;		
		LocY_int <= 0;
		BotInfo_int <= 0;
		Sensors_int <= 0;
		LMDist_int <= 0;
		RMDist_int <= 0;*/
		
		load_sys_regs <= 0;
		load_dist_regs <= 0;
		//upd_sysregs <= 0;
	end
	else begin
    if(Wr_Strobe) begin
    case (AddrIn[7:0])
    8'b0000_0010 : //(o) LEDs
        begin
        // format is: output(for this file) <= input (for this file)
        led_int[7:0] <= DataIn; //Datain is from picoblaze
        end
    8'b0000_0011 : // (o) digit 3 port address
        begin
        dig3_int <= DataIn;
        end
    8'b0000_0100 : //(o) digit 2 port address
        begin
        dig2_int <= DataIn;
        end
    8'b0000_0101 : //(o) digit 1 port address
        begin
        dig1_int <= DataIn;
        end
    8'b0000_0110 : //(o) digit 0 port address
        begin
        dig0_int <= DataIn;
        end
    8'b0000_0111 : //(o) decimal points 3:0 port address
        begin
        dp[3:0] <= DataIn[3:0];
        end
    8'b0000_1001 : //(o) Rojobot motor control output from system
        begin
        MotCtl_int <= DataIn;
        end
    8'b0001_0010 : //(o) LEDs 15:8 (high byte of switches)
        begin
        led_int[15:8] <= DataIn;
        end
    8'b0001_0011 : //(o) digit 7 port address
        begin
        dig7_int <= DataIn;
        end
    8'b0001_0100 : //(o) digit 6 port address
        begin
        dig6_int <= DataIn;
        end
    8'b0001_0101 : //(o) digit 5 port address
        begin
        dig5_int <= DataIn;
        end
    8'b0001_0110 : //(o) digit 4 port address
        begin
        dig4_int <= DataIn;
        end 
    8'b0001_0111 : //(o) decimal points 7:4 port address
        begin
        dp_int[7:4] <= DataIn; 
        end         
    8'b0001_1001 : //(o) Rojobot motor control output from system
        begin
        MotCtl_int <= DataIn; 
        end
    // I/O registers for system interface	
	//8'b0000_1100 : 	load_sys_regs <= ~load_sys_regs;		// toggles load system registers ctrl signal
	//8'b0000_1101 : 	load_dist_regs <= ~load_dist_regs;		// toggles load distance register ctrl signal
	//4'b0000_1110 : 	upd_sysregs <= ~upd_sysregs;			// toggles update system registers flag
	8'b0000_1111 : 	;										// reserved
    default :
        begin
        ;
        end
    endcase
    end
	end
end // always - write registers

	
// synchronized system register interface
always @(posedge clk) begin
	/*if (reset) begin
		LocX <= 0;
		LocY <= 0;
		Sensors <= 0;
		BotInfo <= 0;
	end
	else*/ 
    if (upd_sysregs) begin  // copy holding registers to system interface registers
            MotCtl <= MotCtl_int;
            dp <= dp_int;
            led <= led_int;
            dig7 <= dig7_int;
            dig6 <= dig6_int;
            dig5 <= dig5_int;
            dig4 <= dig4_int;
            dig3 <= dig3_int;
            dig2 <= dig2_int;
            dig1 <= dig1_int;
            dig0 <= dig0_int;
            interrupt <= interrupt;//interrupt_int;
	end
	else begin // refresh registers
			MotCtl <= MotCtl;
            dp <= dp;
            led <= led;
            dig7 <= dig7;
            dig6 <= dig6;
            dig5 <= dig5;
            dig4 <= dig4;
            dig3 <= dig3;
            dig2 <= dig2;
            dig1 <= dig1;
            dig0 <= dig0;
            interrupt <= interrupt;
	end		
end // always - synchronized system register interface

endmodule
		
				

