`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/29/2014 10:16:47 PM
// Design Name: 
// Module Name: icon
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module Icon(
    input clk,
    input [9:0] LocY,
    input [9:0] LocX,
    input [9:0] pixel_row,
    input [9:0] pixel_column,
    output reg [1:0] icon,
    input [2:0] BotInfo,
    output reg [7:0] debug_led
    );


//Declarations

reg [9:0] row_start;
reg [9:0] row_end;
reg [9:0] col_start;
reg [9:0] col_end;
reg [9:0] rom_address_0;
reg [9:0] rom_address_1;
reg [3:0] rom_row_address;
reg [3:0] rom_col_address;
reg [7:0] debugledreg;
wire [1:0] icon_holder;
wire [1:0] icon_zero = 0;
wire [1:0] anaothericon;

//assign icon = icon_holder;
//assign debug_led = debugledreg;
//assign debug_led [1:0] = icon;

    always @(posedge clk) begin// set the icon to use
        //if reset, blah blah blah
        //else do the work...
        
        row_start <= LocY - 3'b111;
        row_end <= LocY + 4'b1111;
        col_start <= LocY - 3'b111;
        col_end <= LocY + 4'b1111;
        
        ////Variables
        //is the pixel in the range of the icon
        if (((pixel_row >= row_start) && (pixel_row <= row_end))
                &&
        ((pixel_column >= col_start) && (pixel_column <= col_end))) begin
                    //icon <= 2'b11;
//                    case (BotInfo [2:1])
//                        2'b00: begin
//                        //row first east/se
//                        rom_row_address <= row_end - pixel_row;
//                        rom_col_address  <= pixel_column - col_start;
//                       // debug_led <= rom_row_address;
//                        end
                        
//                        2'b01: begin
//                        //column first south /SW
//                            rom_row_address <= row_end - pixel_row;
//                            rom_col_address  <= col_end - pixel_column;
//                           // debug_led <= rom_row_address;
                                           
//                        end
                        
//                        2'b10: begin
//                        //west/ nw
//                        rom_row_address <= pixel_column - col_start;
//                        rom_col_address  <= row_end - pixel_row;
//                       //debug_led <= rom_row_address;
//                        end
                        
                    //    2'b11: begin
                        //north/NE
                           rom_row_address <= pixel_row - row_start;
                           rom_col_address  <= pixel_column - col_start;
                           rom_address_0 <= {BotInfo[0], rom_col_address, rom_row_address, 1'b0};
                           rom_address_1 <= {BotInfo[0], rom_col_address, rom_row_address, 1'b1};
                           icon <= icon_holder;
                           //debug_led [1:0] <= {rom_address_1, rom_address_0};
                          
//                        end
//                      endcase  
            //is there a need for default?  default: 
        end //end if in side icon range
        else begin
           icon <= icon_zero; //no bot to display
        end
        
        debug_led [3:2] <= icon;
    end//end always @posedge clk
    


//always begin
//    if  ((LocY == pixel_column) && (LocX== pixel_row)) begin
//        icon <= 2'b11;
        
//    end
//        else icon <= 2'b00;
    
//end
//rom_address_0 
//rom_address_1
//assign internal_row_address = {row_address_0, 1'b0};  //All address locations are 
//                                                    //2 bits somultiply * 2
//assign address = {icon_number, col_address_0, internal_row_address};
//assign address_plus1 = address + 1;   
//    .row_address_0(),//in
//.col_address_1(),//in  
icon_rom ICON_ROM(
    .clk(clk),//in
    .address_0(rom_address_0),//in
    .address_1(rom_address_1),//in    
    .icon_data(icon_holder)//out
    //.debug_led(debug_led)
    //i.enable(rom_enable)//in
    );
    
endmodule


//bitmap of bot icon stored in rom is listed in comments below


//270 degree bot 0 degrees is east ->
//00000000000000000000000000000000
//00000000000000101000000000000000
//00000000000010111110000000000000
//00000000001011111111100000000000
//00000000101111010111111000000000
//00000010111111010111111110000000
//00001010101010111110101010100000
//00000000000010111110000000000000
//00000000000010111110000000000000
//00000000000010111110000000000000
//00000000000010111110000000000000
//00000000000010111110000000000000
//00000000000010111110000000000000
//00000000000010111110000000000000
//00000000000010101010000000000000
//00000000000000000000000000000000

//315 degree bot
//00000000000000000000000000000000
//00000000000000000000000000000000
//00000000000000101010101010100000
//00000000000000001011111111100000
//00000000000000000010010111100000
//00000000000000001011010111100000
//00000000000000101111111011100000
//00000000000010111111100010100000
//00000000001011111110000000100000
//00000000101111111000000000000000
//00000010111111100000000000000000
//00001011111110000000000000000000
//00101111111000000000000000000000
//00001011100000000000000000000000
//00000010000000000000000000000000
//00000000000000000000000000000000

//     270 degree bot               || 315 degree bot
//    0000000000000000000000000000000000000000000000000000000000000000
//    0000000000000010100000000000000000000000000000000000000000000000
//    0000000000001011111000000000000000000000000000101010101010100000
//    0000000000101111111110000000000000000000000000001011111111100000
//    0000000010111101011111100000000000000000000000000010010111100000
//    0000001011111101011111111000000000000000000000001011010111100000
//    0000101010101011111010101010000000000000000000101111111011100000
//    0000000000001011111000000000000000000000000010111111100010100000
//    0000000000001011111000000000000000000000001011111110000000100000
//    0000000000001011111000000000000000000000101111111000000000000000
//    0000000000001011111000000000000000000010111111100000000000000000
//    0000000000001011111000000000000000001011111110000000000000000000
//    0000000000001011111000000000000000101111111000000000000000000000
//    0000000000001011111000000000000000001011100000000000000000000000
//    0000000000001010101000000000000000000010000000000000000000000000
//    0000000000000000000000000000000000000000000000000000000000000000

    
//    bot_icons [0]  = 64'b00000000000000000000000000000000_00000000000000000000000000000000;
//    bot_icons [1]  = 64'b00000000000000101000000000000000_00000000000000000000000000000000;
//    bot_icons [2]  = 64'b00000000000010111110000000000000_00000000000000101010101010100000;
//    bot_icons [3]  = 64'b00000000001011111111100000000000_00000000000000001011111111100000;
//    bot_icons [4]  = 64'b00000000101111010111111000000000_00000000000000000010010111100000;
//    bot_icons [5]  = 64'b00000010111111010111111110000000_00000000000000001011010111100000;
//    bot_icons [6]  = 64'b00001010101010111110101010100000_00000000000000101111111011100000;
//    bot_icons [7]  = 64'b00000000000010111110000000000000_00000000000010111111100010100000;
//    bot_icons [8]  = 64'b00000000000010111110000000000000_00000000001011111110000000100000;
//    bot_icons [9]  = 64'b00000000000010111110000000000000_00000000101111111000000000000000;
//    bot_icons [10] = 64'b00000000000010111110000000000000_00000010111111100000000000000000;
//    bot_icons [11] = 64'b00000000000010111110000000000000_00001011111110000000000000000000;
//    bot_icons [12] = 64'b00000000000010111110000000000000_00101111111000000000000000000000;
//    bot_icons [13] = 64'b00000000000010111110000000000000_00001011100000000000000000000000;
//    bot_icons [14] = 64'b00000000000010101010000000000000_00000010000000000000000000000000;
//    bot_icons [15] = 64'b00000000000000000000000000000000_00000000000000000000000000000000;
