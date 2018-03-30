module	ADC_Driver	(	qzt_clk,
				SPI_SCK,
				enable,
				ADC_OUT,
				gainLabel,
				waitTime,

				AD_CONV,
				Va_Vb,
				AMP_CS,
				SPI_MOSI);

input		qzt_clk;
input		SPI_SCK;
input		enable;
input		ADC_OUT;
input		gainLabel;
input	[4:0]	waitTime;

output		AD_CONV;
output	[27:0]	Va_Vb;
output		AMP_CS;
output		SPI_MOSI;

endmodule
