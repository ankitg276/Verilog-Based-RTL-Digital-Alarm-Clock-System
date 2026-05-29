Alarm Clock Verilog Project

Compile:
iverilog -o simv tb_alarm_clock.v alarm_clock_top.v timing_generator.v counter.v alarm_reg.v keyreg.v lcd_driver.v lcd_driver_4.v fsm.v

Run:
vvp simv

Waveform:
gtkwave alarm_clock.vcd
