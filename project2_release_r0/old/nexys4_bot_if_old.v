/*
This module connects the first picoblaze with the bot.v, sevensegment.v, and debounce.v
*/

module nexys4_bot_if (
    input clk, reset,
    input [7:0] port_id,out_port, //out of picoblaze
    input write_strobe, read_strobe, //interrupt_ack,  //from picoblase
    input reg [4:0] db_btns, //from debounce
    input [15:0] db_sw, //from debounce
    input [7:0] locX, locY, botinfo, sensors, //from botsim 
    input upd_sysregs, //interrupt signal from bot sim
    output reg [15:0] led, //out led
    output reg [7:0] in_port, //into picoblaze
    output reg [7:0] motctl, //into botsim
    output reg [4:0] dig7, dig6, dig5, dig4, dig3, dig2, dig1, dig0, //7 seg display to sevenseg.v
    output reg [7:0] dp,  //decimal point out to sevenseg.v   
    output reg interrupt
);

/*
from proj2deom.psm file:
;  Port Addresses
CONSTANT	PA_PBTNS,		00		; (i) pushbuttons inputs
CONSTANT	PA_SLSWTCH,		01		; (i) slide switches
CONSTANT	PA_LEDS,		02		; (o) LEDs
CONSTANT	PA_DIG3,		03		; (o) digit 3 port address
CONSTANT	PA_DIG2,		04		; (o) digit 2 port address
CONSTANT	PA_DIG1,		05		; (o) digit 1 port address
CONSTANT	PA_DIG0,		06		; (o) digit 0 port address
CONSTANT	PA_DP,			07		; (o) decimal points 3:0 port address
CONSTANT	PA_RSVD,		08		; (o) *RESERVED* port address
; Rojobot interface registers
CONSTANT	PA_MOTCTL_IN,	09		; (o) Rojobot motor control output from system
CONSTANT	PA_LOCX,		0A		; (i) X coordinate of rojobot location
CONSTANT	PA_LOCY,		0B		; (i))Y coordinate of rojobot location
CONSTANT	PA_BOTINFO,		0C		; (i) Rojobot info register
CONSTANT	PA_SENSORS,		0D		; (i) Sensor register
CONSTANT	PA_LMDIST,		0E		; (i) Rojobot left motor distance register = NOT USED
CONSTANT	PA_RMDIST,		0F		; (i) Rojobot right motor distance register = NOT USED
; Extended I/O interface port addresses for the Nexys4.  Your Nexys4_Bot interface module
; should include these additional ports even though they are not used in this program
CONSTANT	PA_PBTNS_ALT,	10		; (i) pushbutton inputs alternate port address
CONSTANT	PA_SLSWTCH1508,	11		; (i) slide switches 15:8 (high byte of switches
CONSTANT	PA_LEDS1508,	12		; (o) LEDs 15:8 (high byte of switches)
CONSTANT	PA_DIG7,		13		; (o) digit 7 port address
CONSTANT	PA_DIG6,		14		; (o) digit 6 port address
CONSTANT	PA_DIG5,		15		; (o) digit 5 port address
CONSTANT	PA_DIG4,		16		; (o) digit 4 port address
CONSTANT	PA_DP0704,		17		; (o) decimal points 7:4 port address
CONSTANT	PA_RSVD_ALT,	18		; (o) *RESERVED* alternate port address

; Extended Rojobot interface registers.  These are alternate Port addresses
CONSTANT	PA_MOTCTL_IN_ALT,	19	; (o) Rojobot motor control output from system
CONSTANT	PA_LOCX_ALT,		1A	; (i) X coordinate of rojobot location
CONSTANT	PA_LOCY_ALT,		1B	; (i))Y coordinate of rojobot location
CONSTANT	PA_BOTINFO_ALT,		1C	; (i) Rojobot info register
CONSTANT	PA_SENSORS_ALT,		1D	; (i) Sensor register
CONSTANT	PA_LMDIST_ALT,		1E	; (i) Rojobot left motor distance register
CONSTANT	PA_RMDIST_ALT,		1F	; (i) Rojobot right motor distance register
*/

////////////////////////////////////////
//Inputs
///////////////////////////////////////
always @(posedge clk)
begin
case (port_id)
8'b0000_0000 : //pushbuttons inputs
begin
// format is: output(for this file) <= input (for this file)
    in_port <= {3'b000, db_btns};
end
8'b0000_0001 : //slide switches
begin
    in_port <= db_sw[7:0];
end
8'b0000_1010 :// X coordinate of rojobot location
begin
    in_port <= locX;
end
8'b0000_1011 : //(i))Y coordinate of rojobot location
begin
    in_port <= locY;
end
8'b0000_1100 : //(i) Rojobot info register
begin
    in_port <= botinfo;
end
8'b0000_1101 : //(i) Sensor register
begin
    in_port <= sensors;
end
8'b0001_000 : //(i) pushbutton inputs alternate port address
begin
    in_port <= 8'b0001_0000;//not sure if this is correct
end
8'b0001_0001 : //(i) slide switches 15:8 (high byte of switches
begin
    in_port <= db_sw[15:8];
end
8'b0001_1010 : //(i) X coordinate of rojobot location
begin
    in_port <= locX;
end
8'b0001_1011 : //(i) Y coordinate of rojobot location
begin
    in_port <= locY;
end
8'b0001_1001 : //(i) Rojobot info register
begin
    in_port <= botinfo;
end
8'b0001_1001 : //(i) Sensor register
begin
    in_port <= sensors;
end
default : 
begin
    in_port <= in_port;
end
endcase
end
////////////////////////////////////////
//Outputs
///////////////////////////////////////
always @(posedge clk)
begin
    if (write_strobe == 1'b1)
    begin
    case (port_id)
    8'b0000_0010 : //(o) LEDs
        begin
        // format is: output(for this file) <= input (for this file)
        led[7:0] <= out_port; 
        end
    8'b0000_0011 : // (o) digit 3 port address
        begin
        dig3 <=out_port;
        end
    8'b0000_0100 : //(o) digit 2 port address
        begin
        dig2 <= out_port;
        end
    8'b0000_0101 : //(o) digit 1 port address
        begin
        dig1 <= out_port;
        end
    8'b0000_0110 : //(o) digit 0 port address
        begin
        dig0 <= out_port;
        end
    8'b0000_0111 : //(o) decimal points 3:0 port address
        begin
        dp[3:0] <= out_port;
        end
    8'b0000_1001 : //(o) Rojobot motor control output from system
        begin
        motctl <= out_port;
        end
    8'b0001_0010 : //(o) LEDs 15:8 (high byte of switches)
        begin
        led[15:8] <= out_port;
        end
    8'b0001_0011 : //(o) digit 7 port address
        begin
        dig7 <= out_port;
        end
    8'b0001_0100 : //(o) digit 6 port address
        begin
        dig6 <= out_port;
        end
    8'b0001_0101 : //(o) digit 5 port address
        begin
        dig5 <= out_port;
        end
    8'b0001_0110 : //(o) digit 4 port address
        begin
        dig4 <= out_port;
        end 
    8'b0001_0111 : //(o) decimal points 7:4 port address
        begin
        dp[7:4] <= out_port; 
        end         
    8'b0001_1001 : //(o) Rojobot motor control output from system
        begin
        motctl <= out_port; 
        end
    default :
        begin
        ;
        end
    endcase
    end
end
//an interrupt ff to connect upd_sysregs(botsim) with interrupt (picoblaze)
//Using a sync reset d-ff
always @(posedge clk)
begin
if (~reset) 
    begin
    interrupt <= 1'b0;
    end
else
    begin
    interrupt <= upd_sysregs;
    end
end

endmodule
