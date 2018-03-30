`define		t1millesimo 28'b0000000000000110000110101000

module ECG	(	CLK_50M,
				ADC_OUT,

				DAC_CS,
				DAC_CLR,
				SPI_SCK,
				AMP_CS,
				SPI_MOSI,
				AD_CONV, 
				LED,LCD_DB,
				LCD_E, LCD_RS, LCD_RW);

input		CLK_50M;
input		ADC_OUT;

output		DAC_CS;
output		DAC_CLR;
output		SPI_SCK;
output		SPI_MOSI;
output		AMP_CS;
output		AD_CONV;
output	[7:0]	LED;
output	[7:0]	LCD_DB;
output		LCD_E;
output		LCD_RS;
output		LCD_RW;

wire		w_SPI_MOSI_preAmp;
wire		w_SPI_MOSI_DAC;
wire		w_dacNumber;
wire 		overthr;
wire 		monover;
wire 		beat_period;
wire 		clk_un_k;
wire 		c_counter_1;
wire		[13:0]	wb_Va;
wire		[13:0]	wb_Vb;
wire		[19:0]	wb_V_HPF;
wire		[19:0]	wb_Va_filtered;
wire		[15:0]   period_count;
wire		[15:0]   b_period;
wire		[15:0]   HR_show;
wire		[15:0]   HR_to_conv;

buf(SPI_MOSI, ((AMP_CS & w_SPI_MOSI_DAC)|(!AMP_CS & w_SPI_MOSI_preAmp)));

buf(LCD_RW, 0);
buf(LCD_DB[3:0], 4'b1111);




Module_Counter_8_bit	SPI_SCK_generator	(	.clk_in(CLK_50M),
							.limit(30'd10),

							.carry(SPI_SCK));

Module_HighPassFilter	HPF		(	.qzt_clk(CLK_50M),
						.clk_in(~w_dacNumber),
						.k(4'b1011),
						.Vin({wb_Va,6'b000000}),
						.Vout(wb_V_HPF));
						
Module_LowPassFilter	LPF		(	.qzt_clk(CLK_50M),
						.clk_in(~w_dacNumber),
						.k(4'b1000),
						.Vin(wb_V_HPF),
						
						.Vout(wb_Va_filtered));
				
Comparing overt   (	.qzt_clk(CLK_50M),
					.Vin({!wb_Va_filtered[19],wb_Va_filtered[18:0]}),
					.Thr({!wb_Vb[13], wb_Vb[12:0], 6'b000000}),
					
					.overthr(overthr));

Module_Monostable  monov (	.clk_in(CLK_50M),
					.monostable_input(overthr),
					.N(28'b0000010011000100101101000000),//=5*10^6 ---> 100ms

					.monostable_output(monover));
					
			
Module_ToggleFlipFlop beat_toggle	(	.clk_in(CLK_50M),
					.ff_input(monover),

					.ff_output(beat_period));
									
					
Module_FrequencyDivider Clock_1kHz	(	.clk_in(CLK_50M),
					.period(`t1millesimo),

					.clk_out(clk_un_k));


					
Module_SynchroCounter_8_bit_SR counter_1 	(	.qzt_clk(CLK_50M),
						.clk_in(clk_un_k & beat_period),
						.set(0),
						.reset(!monover & !beat_period),
						.presetValue(0),
						
						.out(period_count[7:0]),
						.carry(c_counter_1));

Module_SynchroCounter_8_bit_SR counter_2 	(	.qzt_clk(CLK_50M),
						.clk_in(c_counter_1),
						.set(0),
						.reset(!monover & !beat_period),
						.presetValue(0),
						
						.out(period_count[15:8]));
						
						

assign LED = period_count[9:2];

Module_Buffer_16bit_sync display_buff	(	.qtz_clk(CLK_50M),
					.clk_in(!beat_period),
					.buff_input(period_count),
					
					.buff_output(b_period));
					
Module_HR_Detection frequency (.qzt_clk(CLK_50M),
					.clk_in(!beat_period),
					.counter(b_period),

					.HR(HR_to_conv));
					
bin2bcd_8_bit decimal_conv(						.bin(HR_to_conv),
						.bcd(HR_show));


LCD_Driver_pm10to4	lcd_driver	(	.qzt_clk(CLK_50M),
						.fourDigitInput(HR_show),
						.signFlag(0),
					   .dashFlag(0),

						.lcd_flags({LCD_RS, LCD_E}),
						.lcd_data(LCD_DB[7:4]));



ADC_Driver		ADC_Driver		(	.qzt_clk(CLK_50M),
							.SPI_SCK(SPI_SCK),
							.enable(1),
							.ADC_OUT(ADC_OUT),
							.gainLabel(0),
							.waitTime(5'b10000),

							.AD_CONV(AD_CONV),
							.Va_Vb({wb_Va, wb_Vb}),
							.AMP_CS(AMP_CS),
							.SPI_MOSI(w_SPI_MOSI_preAmp));

DAC_Driver		DAC_Driver		(	.CLK_50M(CLK_50M),
							.SPI_SCK(SPI_SCK),
							.Va({!wb_Va_filtered[19], wb_Va_filtered[18:8]}),
							.Vb({!wb_Vb[13], wb_Vb[12:2]}),
							.startEnable(AD_CONV),

							.SPI_MOSI(w_SPI_MOSI_DAC),
							.DAC_CS(DAC_CS),
							.DAC_CLR(DAC_CLR),
							.dacNumber(w_dacNumber));
							
							

endmodule
