`timescale 1ns/1ps
module alarm_clock_top (
    input  wire       clock,
    input  wire [3:0] key,
    input  wire       reset,
    input  wire       time_button,
    input  wire       alarm_button,
    input  wire       fastwatch,
    output wire [7:0] ms_hour,
    output wire [7:0] ls_hour,
    output wire [7:0] ms_minute,
    output wire [7:0] ls_minute,
    output wire       alarm_sound
);

    wire one_second;
    wire reset_count;
    wire load_new_a, show_a, show_new_time, load_new_c, shift;

    wire [3:0] current_time_ms_hr, current_time_ls_hr, current_time_ms_min, current_time_ls_min;
    wire [3:0] alarm_time_ms_hr, alarm_time_ls_hr, alarm_time_ms_min, alarm_time_ls_min;
    wire [3:0] key_ms_hr, key_ls_hr, key_ms_min, key_ls_min;

    timing_generator TG (
        .clock(clock),
        .reset(reset),
        .fastwatch(fastwatch),
        .reset_count(reset_count),
        .one_second(one_second)
    );

    counter CNT (
        .clk(clock),
        .reset(reset),
        .one_minute(one_second),
        .load_new_c(load_new_c),
        .new_current_time_ms_hr(key_ms_hr),
        .new_current_time_ms_min(key_ms_min),
        .new_current_time_ls_hr(key_ls_hr),
        .new_current_time_ls_min(key_ls_min),
        .current_time_ms_hr(current_time_ms_hr),
        .current_time_ms_min(current_time_ms_min),
        .current_time_ls_hr(current_time_ls_hr),
        .current_time_ls_min(current_time_ls_min)
    );

    alarm_reg ALARM (
        .new_alarm_ms_hr(key_ms_hr),
        .new_alarm_ls_hr(key_ls_hr),
        .new_alarm_ms_min(key_ms_min),
        .new_alarm_ls_min(key_ls_min),
        .load_new_alarm(load_new_a),
        .clock(clock),
        .reset(reset),
        .alarm_time_ms_hr(alarm_time_ms_hr),
        .alarm_time_ls_hr(alarm_time_ls_hr),
        .alarm_time_ms_min(alarm_time_ms_min),
        .alarm_time_ls_min(alarm_time_ls_min)
    );

    keyreg KEYREG (
        .reset(reset),
        .clock(clock),
        .shift(shift),
        .key(key),
        .key_buffer_ls_min(key_ls_min),
        .key_buffer_ms_min(key_ms_min),
        .key_buffer_ls_hr(key_ls_hr),
        .key_buffer_ms_hr(key_ms_hr)
    );

    fsm FSM (
        .clock(clock),
        .reset(reset),
        .one_second(one_second),
        .time_button(time_button),
        .alarm_button(alarm_button),
        .key(key),
        .reset_count(reset_count),
        .load_new_a(load_new_a),
        .show_a(show_a),
        .show_new_time(show_new_time),
        .load_new_c(load_new_c),
        .shift(shift)
    );

    lcd_driver_4 LCD (
        .alarm_time_ms_hr(alarm_time_ms_hr),
        .alarm_time_ls_hr(alarm_time_ls_hr),
        .alarm_time_ms_min(alarm_time_ms_min),
        .alarm_time_ls_min(alarm_time_ls_min),
        .current_time_ms_hr(current_time_ms_hr),
        .current_time_ls_hr(current_time_ls_hr),
        .current_time_ms_min(current_time_ms_min),
        .current_time_ls_min(current_time_ls_min),
        .key_ms_hr(key_ms_hr),
        .key_ls_hr(key_ls_hr),
        .key_ms_min(key_ms_min),
        .key_ls_min(key_ls_min),
        .show_a(show_a),
        .show_current_time(show_new_time),
        .display_ms_hr(ms_hour),
        .display_ls_hr(ls_hour),
        .display_ms_min(ms_minute),
        .display_ls_min(ls_minute),
        .sound_a(alarm_sound)
    );

endmodule
