module	LCD_Driver_pm10to4	(	qzt_clk,
					fourDigitInput,
					signFlag,
					dashFlag,

					lcd_flags,
					lcd_data);

input		qzt_clk;
input	[15:0]	fourDigitInput;
input		signFlag;
input		dashFlag;

output	[1:0]	lcd_flags;
output	[3:0]	lcd_data;

endmodule
