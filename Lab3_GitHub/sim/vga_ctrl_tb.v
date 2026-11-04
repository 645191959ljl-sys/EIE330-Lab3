`timescale 1ns / 1ns
module vga_ctrl_tb;
reg vga_clk = 0;
reg sys_rst_n = 1;
reg [15:0] pix_data = 16'hf81f;
wire [9:0] pix_x,pix_y;
wire hsync,vsync;
wire [15:0] rgb;
integer i,h,v,active_count,request_count;
reg valid_expected,req_expected;
vga_ctrl dut (.vga_clk(vga_clk),.sys_rst_n(sys_rst_n),.pix_data(pix_data),
    .pix_x(pix_x),.pix_y(pix_y),.hsync(hsync),.vsync(vsync),.rgb(rgb));
always #20 vga_clk=~vga_clk;
initial begin
    $dumpfile("results/waves/vga_ctrl.vcd"); $dumpvars(0,vga_ctrl_tb);
    #1 sys_rst_n=0; #46 sys_rst_n=1;
    h=0; v=0; active_count=0; request_count=0;
    for (i=0;i<840000;i=i+1) begin
        @(posedge vga_clk);
        if (h==799) begin h=0; if(v==524) v=0; else v=v+1; end
        else h=h+1;
        #1;
        if (i==20) $dumpoff;
        if ((h==138 && v==35) || (h==795 && v==524)) $dumpon;
        if ((h==790 && v==35) || (h==110 && v==2)) $dumpoff;
        if (dut.cnt_h!==h || dut.cnt_v!==v) $fatal(1,"counter mismatch h=%0d v=%0d",h,v);
        if (hsync !== (h<96) || vsync !== (v<2)) $fatal(1,"sync mismatch");
        valid_expected=(h>=144 && h<784 && v>=35 && v<515);
        req_expected=(h>=143 && h<783 && v>=35 && v<515);
        if (dut.rgb_valid!==valid_expected || dut.pix_data_req!==req_expected)
            $fatal(1,"valid/request mismatch");
        if (valid_expected) begin
            active_count=active_count+1;
            if(rgb!==16'hf81f) $fatal(1,"valid pixel masked incorrectly");
        end
        else if (rgb!==16'h0000) $fatal(1,"blanking failed");
        if (req_expected) begin
            request_count=request_count+1;
            if (pix_x!==h-143 || pix_y!==v-35) $fatal(1,"coordinate mismatch");
        end
        else if (pix_x!==10'h3ff || pix_y!==10'h3ff) $fatal(1,"invalid coordinate mismatch");
    end
    if(active_count!=614400 || request_count!=614400) $fatal(1,"frame pixel count mismatch");
    #7 sys_rst_n=0; #1;
    if(dut.cnt_h!==0 || dut.cnt_v!==0 || rgb!==0) $fatal(1,"controller async reset failed");
    $display("PASS vga_ctrl: 840000 cycles, two frame wraps, 614400 valid and requested pixels");
    $display("Expected: H=32 us, H pulse=3.84 us, V=16.8 ms, V pulse=64 us");
    $finish;
end
endmodule
