`timescale 1ns / 1ns
module vga_pic_tb;
reg vga_clk=0;
reg sys_rst_n=1;
reg [9:0] pix_x=10'h3ff,pix_y=10'h3ff;
wire [15:0] pix_data;
integer x,y,checks;
reg [15:0] previous_color;
vga_pic dut (.vga_clk(vga_clk),.sys_rst_n(sys_rst_n),.pix_x(pix_x),.pix_y(pix_y),.pix_data(pix_data));
always #20 vga_clk=~vga_clk;

function [15:0] expected_pixel;
    input integer x;
    input integer y;
    integer start_x;
    integer col;
    integer row;
    reg [63:0] glyph;
    begin
        glyph = 64'd0;
        start_x = 0;
        if (x >= 144 && x < 208) begin
            start_x = 144; glyph = 64'hc3e7ffdbc3c3c3c3;
        end
        else if (x >= 240 && x < 304) begin
            start_x = 240; glyph = 64'hc3c3c3c3c3c3c37e;
        end
        else if (x >= 336 && x < 400) begin
            start_x = 336; glyph = 64'h7ec0c07c0606c67c;
        end
        else if (x >= 432 && x < 496) begin
            start_x = 432; glyph = 64'hff18181818181818;
        end
        expected_pixel = 16'h0000;
        if (y >= 208 && y < 272 && glyph != 64'd0) begin
            col = (x-start_x)/8;
            row = (y-208)/8;
            if (glyph[63-row*8-col]) expected_pixel = 16'hffff;
        end
    end
endfunction

initial begin
    $dumpfile("results/waves/vga_pic.vcd"); $dumpvars(0,vga_pic_tb);
    #1 sys_rst_n=0; #46 sys_rst_n=1; checks=0;
    for(y=0;y<480;y=y+1) begin
        for(x=0;x<640;x=x+1) begin
            @(negedge vga_clk);
            previous_color=pix_data; pix_x=x; pix_y=y;
            #1;
            // Changing the inputs must not bypass the output register.
            if(pix_data!==previous_color) $fatal(1,"pixel changed before clock");
            @(posedge vga_clk); #1;
            if(pix_data!==expected_pixel(x,y)) $fatal(1,"pixel mismatch (%0d,%0d)",x,y);
            checks=checks+1;
            if (x==10 && y==0) $dumpoff;
            if (x==138 && y==212) $dumpon;
            if (x==505 && y==212) $dumpoff;
        end
    end
    @(negedge vga_clk); pix_x=1023;pix_y=1023;
    @(posedge vga_clk);#1;
    if(pix_data!==0) $fatal(1,"invalid coordinates not black");
    @(negedge vga_clk);pix_x=144;pix_y=212;
    @(posedge vga_clk);#1;
    if(pix_data!==16'hffff) $fatal(1,"reset precondition failed");
    #7 sys_rst_n=0;#1;
    if(pix_data!==0) $fatal(1,"pixel async reset failed");
    #47 sys_rst_n=1;
    @(posedge vga_clk);#1;
    if(pix_data!==16'hffff) $fatal(1,"pixel reset release failed");
    $display("PASS vga_pic: %0d visible coordinates, registered output, invalid input and reset",checks);
    $finish;
end
endmodule
