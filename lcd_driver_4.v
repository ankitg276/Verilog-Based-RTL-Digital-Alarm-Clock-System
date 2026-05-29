`timescale 1ns/1ps
module lcd_driver_4 (
    input  wire [3:0] alarm_time_ms_hr,
    input  wire [3:0] alarm_time_ls_hr,
    input  wire [3:0] alarm_time_ms_min,
    input  wire [3:0] alarm_time_ls_min,
    input  wire [3:0] current_time_ms_hr,
    input  wire [3:0] current_time_ls_hr,
    input  wire [3:0] current_time_ms_min,
    input  wire [3:0] current_time_ls_min,
    input  wire [3:0] key_ms_hr,
    input  wire [3:0] key_ls_hr,
    input  wire [3:0] key_ms_min,
    input  wire [3:0] key_ls_min,
    input  wire       show_a,
    input  wire       show_current_time,
    output wire [7:0] display_ms_hr,
    output wire [7:0] display_ls_hr,
    output wire [7:0] display_ms_min,
    output wire [7:0] display_ls_min,
    output wire       sound_a
);

    wire sound_alarm1, sound_alarm2, sound_alarm3, sound_alarm4;

    lcd_driver MS_HR (
        .alarm_time(alarm_time_ms_hr),
        .current_time(current_time_ms_hr),
        .show_alarm(show_a),
        .show_new_time(show_current_time),
        .key(key_ms_hr),
        .display_time(display_ms_hr),
        .sound_alarm(sound_alarm1)
    );

    lcd_driver LS_HR (
        .alarm_time(alarm_time_ls_hr),
        .current_time(current_time_ls_hr),
        .show_alarm(show_a),
        .show_new_time(show_current_time),
        .key(key_ls_hr),
        .display_time(display_ls_hr),
        .sound_alarm(sound_alarm2)
    );

    lcd_driver MS_MIN (
        .alarm_time(alarm_time_ms_min),
        .current_time(current_time_ms_min),
        .show_alarm(show_a),
        .show_new_time(show_current_time),
        .key(key_ms_min),
        .display_time(display_ms_min),
        .sound_alarm(sound_alarm3)
    );

    lcd_driver LS_MIN (
        .alarm_time(alarm_time_ls_min),
        .current_time(current_time_ls_min),
        .show_alarm(show_a),
        .show_new_time(show_current_time),
        .key(key_ls_min),
        .display_time(display_ls_min),
        .sound_alarm(sound_alarm4)
    );

    assign sound_a = sound_alarm1 & sound_alarm2 & sound_alarm3 & sound_alarm4;

endmodule
