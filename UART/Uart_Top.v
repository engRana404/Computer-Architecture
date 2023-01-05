module Uart_Top
#( 
 parameter DBITS = 8 ,
           SB_TICK = 16 , //ticksforstopbits ,
           
           CLOCK_RATE = 100000000, //freq of MCU=100MHZ
           BAUD_RATE = 9600
)
(
input wire  PCLK , PRESETn ,
// rx interface
input  rx,
output wire rx_done,
output wire [DBITS-1:0] rx_dout, 

input wire PWRITE,//wr_uart
input wire [DBITS-1:0] PWDATA ,//w_data
output wire  tx ,
output wire tx_busy,
output wire   [DBITS-1:0] r_data
);
wire rx_tick;
wire tx_tick;



//Receiver
Uart_rx rxObj(
        .clk(rx_tick),
        .rx_start(rx),
        .rx_done(rx_done),
        .rx_dout(rx_dout)
);
Baud_generator_timer #(
    .CLOCK_RATE(CLOCK_RATE),
    .BAUD_RATE(BAUD_RATE)
)generatorObj (
    .clk(PCLK),
    .rx_tick(rx_tick),
    .tx_tick(tx_tick)
);
 
//transmitter 

transmitter uart_tx(.din(PWDATA),
		    .wr_en(PWRITE),
		    .clk_50m(PCLK),
		    .clken(tx_tick),
		    .tx(tx),
		    .tx_busy(tx_busy));



endmodule
