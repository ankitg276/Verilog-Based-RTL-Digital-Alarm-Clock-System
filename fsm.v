`timescale 1ns/1ps
module fsm (
    input  wire       clock,
    input  wire       reset,
    input  wire       one_second,
    input  wire       time_button,
    input  wire       alarm_button,
    input  wire [3:0] key,
    output reg        reset_count,
    output reg        load_new_a,
    output reg        show_a,
    output reg        show_new_time,
    output reg        load_new_c,
    output reg        shift
);

    reg [2:0] pre_state, next_state;
    wire time_out;
    reg [3:0] count1, count2;

    parameter SHOW_TIME        = 3'b000;
    parameter KEY_ENTRY        = 3'b001;
    parameter KEY_STORED       = 3'b010;
    parameter SHOW_ALARM       = 3'b011;
    parameter SET_ALARM_TIME   = 3'b100;
    parameter SET_CURRENT_TIME = 3'b101;
    parameter KEY_WAITED       = 3'b110;
    parameter NOKEY            = 4'd10;

    always @(posedge clock or posedge reset) begin
        if (reset)
            count1 <= 4'd0;
        else if (pre_state != KEY_ENTRY)
            count1 <= 4'd0;
        else if (one_second) begin
            if (count1 == 4'd9)
                count1 <= 4'd0;
            else
                count1 <= count1 + 4'd1;
        end
    end

    always @(posedge clock or posedge reset) begin
        if (reset)
            count2 <= 4'd0;
        else if (pre_state != KEY_WAITED)
            count2 <= 4'd0;
        else if (one_second) begin
            if (count2 == 4'd9)
                count2 <= 4'd0;
            else
                count2 <= count2 + 4'd1;
        end
    end

    assign time_out = ((pre_state == KEY_ENTRY)  && (count1 == 4'd9)) ||
                      ((pre_state == KEY_WAITED) && (count2 == 4'd9));

    always @(posedge clock or posedge reset) begin
        if (reset)
            pre_state <= SHOW_TIME;
        else
            pre_state <= next_state;
    end

    always @(*) begin
        case (pre_state)
            SHOW_TIME: begin
                if (alarm_button)
                    next_state = SHOW_ALARM;
                else if (key != NOKEY)
                    next_state = KEY_STORED;
                else
                    next_state = SHOW_TIME;
            end

            KEY_STORED: begin
                next_state = KEY_WAITED;
            end

            KEY_WAITED: begin
                if (key == NOKEY)
                    next_state = KEY_ENTRY;
                else if (time_out)
                    next_state = SHOW_TIME;
                else
                    next_state = KEY_WAITED;
            end

            KEY_ENTRY: begin
                if (alarm_button)
                    next_state = SET_ALARM_TIME;
                else if (time_button)
                    next_state = SET_CURRENT_TIME;
                else if (time_out)
                    next_state = SHOW_TIME;
                else if (key != NOKEY)
                    next_state = KEY_STORED;
                else
                    next_state = KEY_ENTRY;
            end

            SHOW_ALARM: begin
                if (alarm_button)
                    next_state = SHOW_ALARM;
                else
                    next_state = SHOW_TIME;
            end

            SET_ALARM_TIME:   next_state = SHOW_TIME;
            SET_CURRENT_TIME: next_state = SHOW_TIME;
            default:          next_state = SHOW_TIME;
        endcase
    end

    always @(*) begin
        reset_count   = 1'b0;
        load_new_a    = 1'b0;
        show_a        = 1'b0;
        show_new_time = 1'b0;
        load_new_c    = 1'b0;
        shift         = 1'b0;

        case (pre_state)
            KEY_ENTRY: begin
                show_new_time = 1'b1;
            end

            KEY_STORED: begin
                show_new_time = 1'b1;
                shift         = 1'b1;
            end

            KEY_WAITED: begin
                show_new_time = 1'b1;
            end

            SHOW_ALARM: begin
                show_a = 1'b1;
            end

            SET_ALARM_TIME: begin
                load_new_a = 1'b1;
            end

            SET_CURRENT_TIME: begin
                load_new_c  = 1'b1;
                reset_count = 1'b1;
            end
        endcase
    end
endmodule
