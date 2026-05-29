`timescale 1ns/1ps
module timing_generator (
    input  wire       clock,
    input  wire       reset,
    input  wire       fastwatch,
    input  wire       reset_count,
    output reg        one_second
);
    reg [31:0] count;
    reg [31:0] limit;

    always @(*) begin
        if (fastwatch)
            limit = 32'd256;
        else
            limit = 32'd50000000;
    end

    always @(posedge clock or posedge reset) begin
        if (reset) begin
            count      <= 32'd0;
            one_second <= 1'b0;
        end else if (reset_count) begin
            count      <= 32'd0;
            one_second <= 1'b0;
        end else if (count == (limit - 1)) begin
            count      <= 32'd0;
            one_second <= 1'b1;
        end else begin
            count      <= count + 32'd1;
            one_second <= 1'b0;
        end
    end
endmodule
