`timescale 1ns / 1ns
module vga_pic (
    input wire vga_clk,
    input wire sys_rst_n,
    input wire [9:0] pix_x,
    input wire [9:0] pix_y,
    output reg [15:0] pix_data
);
parameter [15:0] BLACK = 16'h0000;
parameter [15:0] WHITE = 16'hffff;
parameter [7:0] M_ROW_0 = 8'b1100_0011;
parameter [7:0] M_ROW_1 = 8'b1110_0111;
parameter [7:0] M_ROW_2 = 8'b1111_1111;
parameter [7:0] M_ROW_3 = 8'b1101_1011;
parameter [7:0] M_ROW_4 = 8'b1100_0011;
parameter [7:0] M_ROW_5 = 8'b1100_0011;
parameter [7:0] M_ROW_6 = 8'b1100_0011;
parameter [7:0] M_ROW_7 = 8'b1100_0011;
parameter [7:0] U_ROW_0 = 8'b1100_0011;
parameter [7:0] U_ROW_1 = 8'b1100_0011;
parameter [7:0] U_ROW_2 = 8'b1100_0011;
parameter [7:0] U_ROW_3 = 8'b1100_0011;
parameter [7:0] U_ROW_4 = 8'b1100_0011;
parameter [7:0] U_ROW_5 = 8'b1100_0011;
parameter [7:0] U_ROW_6 = 8'b1100_0011;
parameter [7:0] U_ROW_7 = 8'b0111_1110;
parameter [7:0] S_ROW_0 = 8'b0111_1110;
parameter [7:0] S_ROW_1 = 8'b1100_0000;
parameter [7:0] S_ROW_2 = 8'b1100_0000;
parameter [7:0] S_ROW_3 = 8'b0111_1100;
parameter [7:0] S_ROW_4 = 8'b0000_0110;
parameter [7:0] S_ROW_5 = 8'b0000_0110;
parameter [7:0] S_ROW_6 = 8'b1100_0110;
parameter [7:0] S_ROW_7 = 8'b0111_1100;
parameter [7:0] T_ROW_0 = 8'b1111_1111;
parameter [7:0] T_ROW_1 = 8'b0001_1000;
parameter [7:0] T_ROW_2 = 8'b0001_1000;
parameter [7:0] T_ROW_3 = 8'b0001_1000;
parameter [7:0] T_ROW_4 = 8'b0001_1000;
parameter [7:0] T_ROW_5 = 8'b0001_1000;
parameter [7:0] T_ROW_6 = 8'b0001_1000;
parameter [7:0] T_ROW_7 = 8'b0001_1000;

wire [9:0] local_y = pix_y-10'd208;
wire [2:0] char_y = local_y[5:3];
wire [9:0] m_local_x = pix_x-10'd144;
wire [2:0] m_char_x = m_local_x[5:3];
wire [9:0] u_local_x = pix_x-10'd240;
wire [2:0] u_char_x = u_local_x[5:3];
wire [9:0] s_local_x = pix_x-10'd336;
wire [2:0] s_char_x = s_local_x[5:3];
wire [9:0] t_local_x = pix_x-10'd432;
wire [2:0] t_char_x = t_local_x[5:3];

// Each 8x8 bitmap cell becomes an 8x8 block of screen pixels.
always @(posedge vga_clk or negedge sys_rst_n) begin
    if (!sys_rst_n)
        pix_data <= BLACK;
    else if (pix_x >= 10'd144 && pix_x < 10'd208
          && pix_y >= 10'd208 && pix_y < 10'd272) begin
        case (char_y)
            3'd0: pix_data <= M_ROW_0[3'd7-m_char_x] ? WHITE : BLACK;
            3'd1: pix_data <= M_ROW_1[3'd7-m_char_x] ? WHITE : BLACK;
            3'd2: pix_data <= M_ROW_2[3'd7-m_char_x] ? WHITE : BLACK;
            3'd3: pix_data <= M_ROW_3[3'd7-m_char_x] ? WHITE : BLACK;
            3'd4: pix_data <= M_ROW_4[3'd7-m_char_x] ? WHITE : BLACK;
            3'd5: pix_data <= M_ROW_5[3'd7-m_char_x] ? WHITE : BLACK;
            3'd6: pix_data <= M_ROW_6[3'd7-m_char_x] ? WHITE : BLACK;
            3'd7: pix_data <= M_ROW_7[3'd7-m_char_x] ? WHITE : BLACK;
            default: pix_data <= BLACK;
        endcase
    end
    else if (pix_x >= 10'd240 && pix_x < 10'd304
          && pix_y >= 10'd208 && pix_y < 10'd272) begin
        case (char_y)
            3'd0: pix_data <= U_ROW_0[3'd7-u_char_x] ? WHITE : BLACK;
            3'd1: pix_data <= U_ROW_1[3'd7-u_char_x] ? WHITE : BLACK;
            3'd2: pix_data <= U_ROW_2[3'd7-u_char_x] ? WHITE : BLACK;
            3'd3: pix_data <= U_ROW_3[3'd7-u_char_x] ? WHITE : BLACK;
            3'd4: pix_data <= U_ROW_4[3'd7-u_char_x] ? WHITE : BLACK;
            3'd5: pix_data <= U_ROW_5[3'd7-u_char_x] ? WHITE : BLACK;
            3'd6: pix_data <= U_ROW_6[3'd7-u_char_x] ? WHITE : BLACK;
            3'd7: pix_data <= U_ROW_7[3'd7-u_char_x] ? WHITE : BLACK;
            default: pix_data <= BLACK;
        endcase
    end
    else if (pix_x >= 10'd336 && pix_x < 10'd400
          && pix_y >= 10'd208 && pix_y < 10'd272) begin
        case (char_y)
            3'd0: pix_data <= S_ROW_0[3'd7-s_char_x] ? WHITE : BLACK;
            3'd1: pix_data <= S_ROW_1[3'd7-s_char_x] ? WHITE : BLACK;
            3'd2: pix_data <= S_ROW_2[3'd7-s_char_x] ? WHITE : BLACK;
            3'd3: pix_data <= S_ROW_3[3'd7-s_char_x] ? WHITE : BLACK;
            3'd4: pix_data <= S_ROW_4[3'd7-s_char_x] ? WHITE : BLACK;
            3'd5: pix_data <= S_ROW_5[3'd7-s_char_x] ? WHITE : BLACK;
            3'd6: pix_data <= S_ROW_6[3'd7-s_char_x] ? WHITE : BLACK;
            3'd7: pix_data <= S_ROW_7[3'd7-s_char_x] ? WHITE : BLACK;
            default: pix_data <= BLACK;
        endcase
    end
    else if (pix_x >= 10'd432 && pix_x < 10'd496
          && pix_y >= 10'd208 && pix_y < 10'd272) begin
        case (char_y)
            3'd0: pix_data <= T_ROW_0[3'd7-t_char_x] ? WHITE : BLACK;
            3'd1: pix_data <= T_ROW_1[3'd7-t_char_x] ? WHITE : BLACK;
            3'd2: pix_data <= T_ROW_2[3'd7-t_char_x] ? WHITE : BLACK;
            3'd3: pix_data <= T_ROW_3[3'd7-t_char_x] ? WHITE : BLACK;
            3'd4: pix_data <= T_ROW_4[3'd7-t_char_x] ? WHITE : BLACK;
            3'd5: pix_data <= T_ROW_5[3'd7-t_char_x] ? WHITE : BLACK;
            3'd6: pix_data <= T_ROW_6[3'd7-t_char_x] ? WHITE : BLACK;
            3'd7: pix_data <= T_ROW_7[3'd7-t_char_x] ? WHITE : BLACK;
            default: pix_data <= BLACK;
        endcase
    end
    else
        pix_data <= BLACK;
end
endmodule
