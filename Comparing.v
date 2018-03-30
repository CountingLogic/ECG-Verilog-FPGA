module Comparing	(	qzt_clk,
					Vin,
					Thr,
					overthr);

input		qzt_clk;
input	[19:0]	Vin;
input	[19:0]	Thr; //threashold

output	overthr;

reg	overthr;


always @(posedge qzt_clk) begin
		overthr= (Vin>Thr)? 1 : 0;
end

endmodule