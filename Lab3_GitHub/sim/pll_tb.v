`timescale 1ns / 1ns
module pll_tb;
reg sys_clk = 1'b0;
reg sys_rst_n = 1'b1;
wire vga_clk;
integer i;
reg expected_clk;
pll dut (.sys_clk(sys_clk), .sys_rst_n(sys_rst_n), .vga_clk(vga_clk));
always #10 sys_clk = ~sys_clk;
initial begin
    $dumpfile("results/waves/pll.vcd"); $dumpvars(0,pll_tb);
    #1 sys_rst_n=0; #1;
    if (vga_clk !== 0) $fatal(1,"divider not cleared during reset");
    #35 sys_rst_n = 1;
    expected_clk = 0;
    for (i=0;i<20;i=i+1) begin
        @(posedge sys_clk); expected_clk = ~expected_clk; #1;
        if (vga_clk !== expected_clk) $fatal(1,"divide-by-two mismatch");
    end
    #6 sys_rst_n = 0; #1;
    if (vga_clk !== 0) $fatal(1,"asynchronous reset failed");
    #45 sys_rst_n = 1;
    expected_clk = 0;
    for (i=0;i<10;i=i+1) begin
        @(posedge sys_clk); expected_clk = ~expected_clk; #1;
        if (vga_clk !== expected_clk) $fatal(1,"restart mismatch");
    end
    $display("PASS pll: divide-by-two, reset and restart; expected period 40 ns");
    $finish;
end
endmodule
