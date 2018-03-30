`define		uni	25'b1111111111111111111111111
module Module_HighPassFilter	(	qzt_clk,
					clk_in,
					k,
					Vin,

					Vout);

input		qzt_clk;
input		clk_in;
input	[3:0]	k;
input	[19:0]	Vin;

output	[19:0]	Vout;

reg	[19:0]	Vout;
reg	[19:0]	tmp;
reg	[19:0]	old;
reg		clk_in_old;

always @(posedge qzt_clk) begin
	if (clk_in & !clk_in_old) begin
		tmp<=Vin + ~ (Vin[19]? ({`uni,Vin}>>(k+1)): Vin>>(k+1)) + 1;
		Vout<= old + Vin + ~ (Vin[19]? ({`uni,Vin}>>(k+1)): Vin>>(k+1)) + 1 + ~tmp+1;  
		old<= Vout + ~ (Vout[19]? ({`uni,Vout}>>(k)): Vout>>(k)) + 1;                   
	end
	clk_in_old <= clk_in;
end  
endmodule
