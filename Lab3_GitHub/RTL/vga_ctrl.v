`timescale 1ns / 1ns
module vga_ctrl (
    input wire vga_clk,
    input wire sys_rst_n,
    input wire [15:0] pix_data,
    output wire [9:0] pix_x,
    output wire [9:0] pix_y,
    output wire hsync,
    output wire vsync,
    output wire [15:0] rgb
);
parameter [9:0] H_SYNC = 10'd96;
parameter [9:0] H_BACK = 10'd40;
parameter [9:0] H_LEFT = 10'd8;
parameter [9:0] H_VALID = 10'd640;
parameter [9:0] H_RIGHT = 10'd8;
parameter [9:0] H_FRONT = 10'd8;
parameter [9:0] H_TOTAL = H_SYNC+H_BACK+H_LEFT+H_VALID+H_RIGHT+H_FRONT;
parameter [9:0] V_SYNC = 10'd2;
parameter [9:0] V_BACK = 10'd25;
parameter [9:0] V_TOP = 10'd8;
parameter [9:0] V_VALID = 10'd480;
parameter [9:0] V_BOTTOM = 10'd8;
parameter [9:0] V_FRONT = 10'd2;
parameter [9:0] V_TOTAL = V_SYNC+V_BACK+V_TOP+V_VALID+V_BOTTOM+V_FRONT;
reg [9:0] cnt_h;
reg [9:0] cnt_v;
wire rgb_valid;
wire pix_data_req;

always @(posedge vga_clk or negedge sys_rst_n) begin
    if (!sys_rst_n)
        cnt_h <= 10'd0;
    else if (cnt_h == H_TOTAL-10'd1)
        cnt_h <= 10'd0;
    else
        cnt_h <= cnt_h+10'd1;
end
always @(posedge vga_clk or negedge sys_rst_n) begin
    if (!sys_rst_n)
        cnt_v <= 10'd0;
    else if (cnt_h == H_TOTAL-10'd1) begin
        if (cnt_v == V_TOTAL-10'd1)
            cnt_v <= 10'd0;
        else
            cnt_v <= cnt_v+10'd1;
    end
    else
        cnt_v <= cnt_v;
end

// Follow the lecture's active-high sync convention for the virtual board.
assign hsync = (cnt_h < H_SYNC) ? 1'b1 : 1'b0;
assign vsync = (cnt_v < V_SYNC) ? 1'b1 : 1'b0;
assign rgb_valid = (cnt_h >= H_SYNC+H_BACK+H_LEFT)
                && (cnt_h < H_SYNC+H_BACK+H_LEFT+H_VALID)
                && (cnt_v >= V_SYNC+V_BACK+V_TOP)
                && (cnt_v < V_SYNC+V_BACK+V_TOP+V_VALID);
// vga_pic registers its output: request each coordinate one clock early.
assign pix_data_req = (cnt_h >= H_SYNC+H_BACK+H_LEFT-10'd1)
                   && (cnt_h < H_SYNC+H_BACK+H_LEFT+H_VALID-10'd1)
                   && (cnt_v >= V_SYNC+V_BACK+V_TOP)
                   && (cnt_v < V_SYNC+V_BACK+V_TOP+V_VALID);
assign pix_x = pix_data_req ? cnt_h-(H_SYNC+H_BACK+H_LEFT-10'd1) : 10'h3ff;
assign pix_y = pix_data_req ? cnt_v-(V_SYNC+V_BACK+V_TOP) : 10'h3ff;
assign rgb = rgb_valid ? pix_data : 16'h0000;
endmodule
