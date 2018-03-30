`timescale 1ns / 1ps
`define		minuto 16'b1110101001100000
//////////////////////////////////////////////////////////////////////////////////
// Company: 		unitn
// Engineer: 		Sagar M., Sara Q., Giancarlo C. 
// 
// Create Date:    17:01:32 01/31/2018 
// Design Name: 
// Module Name:    Module_HR_Detection 
// Project Name: 		ECG	
// Target Devices: 
// Tool versions: 
// Description:  the module operates a division to return a value of HR [bits/minute]
//						to print on a display. the division is: 
//						60seconds[in bits] / counter time [in bits]
//						it uses an algorithm fount on wikipedia to perform division
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module Module_HR_Detection (qzt_clk,
					clk_in,
					counter,

					HR);

input		qzt_clk;
input		clk_in; 
input		[15:0] counter;  

output	[15:0] HR;  

reg	[15:0]	HR;
reg	[15:0]	Q;
reg	[15:0]   minute;
reg   count_flag;
reg	old_clk_in;

always @ (posedge qzt_clk) begin
if(clk_in & !old_clk_in) begin 
	count_flag=1;
	Q=0;
	minute = `minuto;
end
if (count_flag) begin
	if(minute<counter) begin
	count_flag=0 ;
	HR=Q;
	end else begin
	minute = minute + ~counter +1;
	Q=Q+1;
	end
end

old_clk_in <=clk_in;
end

endmodule
