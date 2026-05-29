`timescale 1ns/1ps
module tb_alarm_clock;

    reg clk;
    reg reset;
    reg fast_watch;
    reg alarm_button;
    reg time_button;
    reg [3:0] key;

    wire [7:0] display_ms_hr;
    wire [7:0] display_ls_hr;
    wire [7:0] display_ms_min;
    wire [7:0] display_ls_min;
    wire sound_alarm;

    parameter cycle = 2;

    alarm_clock_top DUV (
        .clock(clk),
        .key(key),
        .reset(reset),
        .time_button(time_button),
        .alarm_button(alarm_button),
        .fastwatch(fast_watch),
        .ms_hour(display_ms_hr),
        .ls_hour(display_ls_hr),
        .ms_minute(display_ms_min),
        .ls_minute(display_ls_min),
        .alarm_sound(sound_alarm)
    );

    initial begin
        clk = 1'b0;
        forever #(cycle/2) clk = ~clk;
    end

    initial begin
        $dumpfile("alarm_clock.vcd");
        $dumpvars(0, tb_alarm_clock);

        reset = 1'b1;
        fast_watch = 1'b0;
        alarm_button = 1'b0;
        time_button = 1'b0;
        key = 4'd10;

        #10;
        reset = 1'b0;
        fast_watch = 1'b1;

        // set current time = 11:23
        key = 4'd1; repeat (3) @(negedge clk);
        key = 4'd10; @(negedge clk);
        key = 4'd1; repeat (3) @(negedge clk);
        key = 4'd10; @(negedge clk);
        key = 4'd2; repeat (3) @(negedge clk);
        key = 4'd10; @(negedge clk);
        key = 4'd3; repeat (3) @(negedge clk);
        key = 4'd10; @(negedge clk);
        time_button = 1'b1; @(negedge clk); time_button = 1'b0;

        // set alarm time = 11:30
        key = 4'd1; repeat (3) @(negedge clk);
        key = 4'd10; @(negedge clk);
        key = 4'd1; repeat (3) @(negedge clk);
        key = 4'd10; @(negedge clk);
        key = 4'd3; repeat (3) @(negedge clk);
        key = 4'd10; @(negedge clk);
        key = 4'd0; repeat (3) @(negedge clk);
        key = 4'd10; @(negedge clk);
        alarm_button = 1'b1; @(negedge clk); alarm_button = 1'b0;

        // wait for alarm match
        #(7*256*2);
        repeat (4*2564) @(negedge clk);
        $finish;
    end

    initial begin
        $monitor("%0t ns  MS_HR=%h LS_HR=%h MS_MIN=%h LS_MIN=%h  ALARM=%b",
                 $time,
                 display_ms_hr[3:0],
                 display_ls_hr[3:0],
                 display_ms_min[3:0],
                 display_ls_min[3:0],
                 sound_alarm);
    end
endmodule
