`timescale 1ns / 1ns
module vga_must_tb;
reg sys_clk=0;
reg sys_rst_n=1;
wire hsync,vsync;
wire [15:0] rgb;
integer i,h,v,pixels,frame_file,line_file;
integer white_count;
time last_pixel,last_line,last_frame;
reg old_hsync,old_vsync;
reg [15:0] expected_color;
vga_must dut (.sys_clk(sys_clk),.sys_rst_n(sys_rst_n),.hsync(hsync),.vsync(vsync),.rgb(rgb));
always #10 sys_clk=~sys_clk;

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

task check_frame;
    input integer save_image;
    integer k;
    begin
        h=0;v=0;pixels=0;white_count=0;
        for(k=0;k<420000;k=k+1) begin
            @(posedge dut.vga_clk); #1;
            if(h==799) begin h=0;if(v==524)v=0;else v=v+1;end
            else h=h+1;
            if(dut.vga_ctrl_inst.cnt_h!==h || dut.vga_ctrl_inst.cnt_v!==v)
                $fatal(1,"top counters mismatch");
            if(hsync!==(h<96) || vsync!==(v<2)) $fatal(1,"top sync mismatch");
            expected_color=0;
            if(h>=144 && h<784 && v>=35 && v<515) begin
                pixels=pixels+1;
                expected_color=expected_pixel(h-144,v-35);
                if(rgb==16'hffff) white_count=white_count+1;
                if(save_image) begin
                    if(rgb==16'hffff) $fwrite(frame_file,"255 255 255\n");
                    else $fwrite(frame_file,"0 0 0\n");
                end
            end
            if(rgb!==expected_color) $fatal(1,"top RGB mismatch display=(%0d,%0d), got=%h want=%h",h-144,v-35,rgb,expected_color);
            if(k>0 && $time-last_pixel!=40) $fatal(1,"pixel clock period mismatch");
            last_pixel=$time;
            if(hsync && !old_hsync) begin
                if(last_line!=0 && $time-last_line!=32000) $fatal(1,"line period mismatch");
                last_line=$time;
            end
            if(vsync && !old_vsync) begin
                if(last_frame!=0 && $time-last_frame!=16800000) $fatal(1,"frame period mismatch");
                last_frame=$time;
            end
            if(!hsync && old_hsync && last_line!=0 && $time-last_line!=3840)
                $fatal(1,"horizontal sync pulse width mismatch");
            if(!vsync && old_vsync && last_frame!=0 && $time-last_frame!=64000)
                $fatal(1,"vertical sync pulse width mismatch");
            old_hsync=hsync;old_vsync=vsync;
            if(save_image && v==247 && h>=138 && h<=790)
                $fwrite(line_file,"%0t,%0d,%0d,%0d,%0d,%0d,%0d,%0d\n",$time,h,v,dut.pix_x,dut.pix_y,dut.vga_ctrl_inst.pix_data_req,dut.vga_ctrl_inst.rgb_valid,rgb);
            if(k==20) $dumpoff;
            if((h==138 && (v==35 || v==247)) || (h==795 && v==524)) $dumpon;
            if((h==790 && (v==35 || v==247)) || (h==8 && v==0)) $dumpoff;
        end
        if(pixels!=307200) $fatal(1,"top active count mismatch");
        $display("PASS frame: %0d visible pixels checked, white pixels=%0d",pixels,white_count);
    end
endtask
initial begin
    $dumpfile("results/waves/vga_must.vcd"); $dumpvars(0,vga_must_tb);
    frame_file=$fopen("results/figures/simulated_frame.ppm","w");
    line_file=$fopen("results/line_samples.csv","w");
    if(!frame_file || !line_file) $fatal(1,"cannot create results");
    $fwrite(frame_file,"P3\n640 480\n255\n");
    $fwrite(line_file,"time_ns,cnt_h,cnt_v,request_x,request_y,request,valid,rgb_decimal\n");
    #1 sys_rst_n=0; #1;if(rgb!==0) $fatal(1,"initial reset not black");
    #45 sys_rst_n=1;
    last_pixel=0;last_line=0;last_frame=0;old_hsync=1;old_vsync=1;
    check_frame(1); check_frame(0);
    $fclose(frame_file);$fclose(line_file);
    // Assert reset while a white M pixel is being displayed, away from a clock edge.
    wait(dut.vga_ctrl_inst.cnt_h==288 && dut.vga_ctrl_inst.cnt_v==247);
    #2;if(rgb!==16'hffff) $fatal(1,"mid-character reset precondition failed");
    $dumpon;
    #5 sys_rst_n=0; #1;
    if(rgb!==0 || dut.vga_clk!==0 || dut.vga_ctrl_inst.cnt_h!==0 || dut.vga_ctrl_inst.cnt_v!==0)
        $fatal(1,"mid-frame asynchronous reset failed");
    #71 sys_rst_n=1;
    last_pixel=0;last_line=0;last_frame=0;old_hsync=1;old_vsync=1;
    check_frame(0);
    $display("PASS vga_must: two continuous frames and one complete frame after mid-character reset");
    $display("MEASURED: pixel period=40 ns; H period=32000 ns; V period=16800000 ns");
    $display("MEASURED: H high pulse=3840 ns; V high pulse=64000 ns");
    $finish;
end
initial begin #100000000; $fatal(1,"top test timeout"); end
endmodule
