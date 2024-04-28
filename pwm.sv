`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/18/2024 09:15:48 PM
// Design Name: 
// Module Name: pwm
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


module pwm
(
input logic clk,                    //Clock
input logic reset,                  //Reset
input logic [7:0] audioData,        //Receive waveform data
output logic pwmOut                 //Output single bit of duty cycle
);

logic [7:0] counter, counterNext;
logic [15:0] clk_counter;           //Internal logic for controlling
logic pwmNext;                      //the flow of the PWM
logic new_clk;

//Hard-coding audioData
//always_comb begin
//    if (new_clk == 1)begin
//        audioData = 8'hff;
//    end else begin
//        audioData = 8'h00;
//    end
//end

//Clock Divider
always_ff @(posedge clk) begin
    if ((clk_counter >= 64000) && (~reset))begin
        new_clk <= ~new_clk;
        clk_counter <= 0;
    end else if(~reset)begin
        new_clk <= new_clk;
        clk_counter <= clk_counter + 1;
    end else begin
        new_clk <= 0;
        clk_counter <= 0;
    end
end

//Duty Cycle
always_comb begin
    counterNext = counter + 1;

    if (counter <= audioData)begin  //Set the duty cycle
        pwmNext = 1;                //High while couter less than sample spike
    end else begin                  
        pwmNext = 0;                //Low when counter surpasses sample spike
    end    
end

always_ff @(posedge clk) begin
    if (reset) begin                //Resetting cuts audio playback
       counter <= 0;                //Set counter back to zero
       pwmOut <= 0;                 //Set pwm data back to zero
    end else begin
       counter <= counterNext;      //Counter follows from previous block^^
       pwmOut <= pwmNext;           //Pwm data follows from previous block^^
    end
    if (counter >= 255) begin       //Maximum counter value for 8-bit sound
        counter <= 0;               //Reset counter in this case
    end
end




















//New counter needed in order to expand scope
//always_comb begin
//    temp_counter_next = temp_counter + 1;

//    if (temp_counter > audioData)begin  //Set the duty cycle
//        pwmNext = 0;                //High while couter less than sample spike
//    end else begin                  
//        pwmNext = 1;                //Low when counter surpasses sample spike
//    end    
//end

//always_ff @(posedge clk) begin
//    if (reset) begin               //Reset active low
//       temp_counter <= 0;                //Set counter back to zero
//       pwmOut <= 0;                 //Set pwm data back to zero
//    end else begin
//       temp_counter <= temp_counter_next;      //Counter follows from previous block^^
//       pwmOut <= pwmNext;           //Pwm data follows from previous block^^
//    end
//    if (temp_counter == 8'b11111111) begin       //Maximum counter value for 8-bit sound
//        temp_counter <= 0;               //Reset counter in this case
//    end
//end

//always_ff @(posedge clk)begin
//    data_counter = data_counter + 1;
//end

//font_rom font_rom(
//    .addr(temp_counter),
//    .data(audioData)
//);




endmodule
