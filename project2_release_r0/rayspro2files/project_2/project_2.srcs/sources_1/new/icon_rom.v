`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/01/2014 04:10:02 PM
// Design Name: 
// Module Name: icon_rom
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


module icon_rom(
    input clk,
    //input [9:0] address,
    input [9:0] address_0,     
    input [9:0] address_1,    
    output reg [1:0] icon_data
    //input enable
   // output reg [7:0] debug_led
    );
    
    
    
    reg [511:0] complete_icon;
    wire [4:0] internal_row_address;
    wire [9:0] address; 
    wire [9:0] address_plus1;
    
//    assign internal_row_address = {row_address_0, 1'b0};  //All address locations are 
//                                                        //2 bits somultiply * 2
//    assign address = {icon_number, col_address_0, internal_row_address};
//    assign address_plus1 = address + 1;    
    initial begin//set all data
    
    complete_icon [31:0]    = 32'b0000000000000000000000000000000000000000000000000000000000000000;
    complete_icon [63:32]   = 32'b0000000000000010100000000000000000000000000000000000000000000000;
    complete_icon [95:64]   = 32'b0000000000001011111000000000000000000000000000101010101010100000;
    complete_icon [127:96]  = 32'b0000000000101111111110000000000000000000000000001011111111100000;
    complete_icon [159:128] = 32'b0000000010111101011111100000000000000000000000000010010111100000;
    complete_icon [191:160] = 32'b0000001011111101011111111000000000000000000000001011010111100000;
    complete_icon [223:192] = 32'b0000101010101011111010101010000000000000000000101111111011100000;
    complete_icon [255:224] = 32'b0000000000001011111000000000000000000000000010111111100010100000;
    complete_icon [287:256] = 32'b0000000000001011111000000000000000000000001011111110000000100000;
    complete_icon [319:288] = 32'b0000000000001011111000000000000000000000101111111000000000000000;
    complete_icon [351:320] = 32'b0000000000001011111000000000000000000010111111100000000000000000;
    complete_icon [383:352] = 32'b0000000000001011111000000000000000001011111110000000000000000000;
    complete_icon [415:384] = 32'b0000000000001011111000000000000000101111111000000000000000000000;
    complete_icon [447:416] = 32'b0000000000001011111000000000000000001011100000000000000000000000;
    complete_icon [479:448] = 32'b0000000000001010101000000000000000000010000000000000000000000000;
    complete_icon [511:480] = 32'b0000000000000000000000000000000000000000000000000000000000000000;
    
    end
    
    
    always @ (posedge clk) begin
        //if reset
        
        //else not reset
        //if enabled
        icon_data[0]  <= complete_icon [address_0];
        icon_data[1] <= complete_icon [address_1];
        //debug_led [0] <= complete_icon [address];
    end
endmodule
