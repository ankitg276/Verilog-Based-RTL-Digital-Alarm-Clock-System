`timescale 1ns/1ps
module alarm_reg (
    input  wire [3:0] new_alarm_ms_hr,
    input  wire [3:0] new_alarm_ls_hr,
    input  wire [3:0] new_alarm_ms_min,
    input  wire [3:0] new_alarm_ls_min,
    input  wire       load_new_alarm,
    input  wire       clock,
    input  wire       reset,
    output reg  [3:0] alarm_time_ms_hr,
    output reg  [3:0] alarm_time_ls_hr,
    output reg  [3:0] alarm_time_ms_min,
    output reg  [3:0] alarm_time_ls_min
);

    always @(posedge clock or posedge reset) begin
        if (reset) begin
            alarm_time_ms_hr  <= 4'd0;
            alarm_time_ls_hr  <= 4'd0;
            alarm_time_ms_min <= 4'd0;
            alarm_time_ls_min <= 4'd0;
        end else if (load_new_alarm) begin
            alarm_time_ms_hr  <= new_alarm_ms_hr;
            alarm_time_ls_hr  <= new_alarm_ls_hr;
            alarm_time_ms_min <= new_alarm_ms_min;
            alarm_time_ls_min <= new_alarm_ls_min;
        end
    end
endmodule
