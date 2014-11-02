//colorizer.v

module colorizer(

input	video_on,
input clk,
input [1:0]	world_pixel,
input [1:0]	icon,
output reg [3:0] vga_red,
output reg [3:0] vga_green,
output reg [3:0] vga_blue
);

reg [3:0] counter;


always @ (posedge clk) begin
     if (video_on) begin   
         if (icon != 2'b00) begin// bot here
            vga_red <= 4'b1111;
            vga_green <= 4'b0000;
            vga_blue <= 4'b0000;
         end else begin
            
            if (world_pixel == 2'b00) begin
                vga_red <= 4'b0000;
                vga_green <= 4'b0000;
                vga_blue <= 4'b0000;
            end
            if (world_pixel == 2'b01) begin
                    vga_red <= 4'b1111;
                    vga_green <= 4'b1111;
                    vga_blue <= 4'b1111;
                end
                if (world_pixel == 2'b10) begin
                        vga_red <= 4'b1111;
                        vga_green <= 4'b0000;
                        vga_blue <= 4'b1111;
                 end
                 
             end//bot not here
     end//video_on
        
//pass the color to the VGA port

end


endmodule