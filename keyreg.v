`timescale 1ns/1ps
module keyreg (
    input  wire       reset,
    input  wire       clock,
    input  wire       shift,
    input  wire [3:0] key,
    output reg  [3:0] key_buffer_ls_min,
    output reg  [3:0] key_buffer_ms_min,
    output reg  [3:0] key_buffer_ls_hr,
    output reg  [3:0] key_buffer_ms_hr
);

    always @(posedge clock or posedge reset) begin
        if (reset) begin
            key_buffer_ms_hr  <= 4'd0;
            key_buffer_ls_hr  <= 4'd0;
            key_buffer_ms_min <= 4'd0;
            key_buffer_ls_min <= 4'd0;
        end else if (shift) begin
            key_buffer_ms_hr  <= key_buffer_ls_hr;
            key_buffer_ls_hr  <= key_buffer_ms_min;
            key_buffer_ms_min <= key_buffer_ls_min;
            key_buffer_ls_min <= key;
        end
    end
endmodule
