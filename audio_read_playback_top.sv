`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/21/2024 11:08:31 PM
// Design Name: 
// Module Name: audio_read_playback_top
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module audio_read_playback_top(
    input logic clk,
    input logic reset,
    
    output logic spkl,
    output logic spkr
    );
    
logic [24:0] prev_sd_addr;
logic taken_sample;                                 //Used to signify that the sd fsm can move to next addr
logic [11:0] pulse_counter, pulse_counter_next;     //used to emulate ideal sampling frequency
logic [15:0] sound_byte;                            //Represents two consecutive samples
logic [7:0] audio_left, audio_right;                //Destination of each half of sound_byte
logic song_data_left, song_data_right;              //To be wired to audio jack inputs
logic begin_read = 1'b0;

assign spkl = song_data_left;
assign spkr = song_data_right;

always_ff @(posedge clk) begin
    if (reset) begin
        begin_read = 1'b1;
    end else begin
        begin_read = 1'b0;
    end
end

always_comb begin
    pulse_counter_next = pulse_counter + 1;
    if (pulse_counter == 2267) begin
        audio_left = sound_byte[15:8];  //Take next sample from SD card -- send to left channel
        audio_right = sound_byte[7:0];  //Take next sample from SD card -- send to right channel
        pulse_counter_next = 0;         //Reset sample frequency counter
        taken_sample = 1'b1;            //Acknowledge that we have completed one sample
    end else begin                      //so the sd driver knows to move to next mem address
        taken_sample = 1'b0;
    end
end

always_ff @(posedge clk)begin           //Sequential loop for incrementing sample frequency counter
    if (reset) begin                    //
        pulse_counter <= 0;             //
    end else begin                      //
        pulse_counter <= pulse_counter_next;
    end
end    
    
clk_wiz_0 clk_wiz(
    .clk_out1(clk_50MHz),
    .clk_out2(clk_100MHz),
    .reset(reset),
    .clk_in1(clk)
);

sdcard_init SD_card(
    .clk50(clk_50MHz),
    .reset(begin_read),
    .ram_address(prev_sd_addr),
    .ram_op_begun(taken_sample),
    .ram_data(sound_byte)
);
    
pwm pwm_left(
    .*,
    .audioData(audio_left), 
    .pwmOut(song_data_left)
);

pwm pwm_right(
    .*, 
    .audioData(audio_right),
    .pwmOut(song_data_right)
);
    
    
    
    
    
    
endmodule
