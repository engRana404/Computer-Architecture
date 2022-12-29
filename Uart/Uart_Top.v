module Uart_Top
#( 
 parameter DBITS = 8 ,
           SB_TICK = 16 , //ticksforstopbits ,
           FIFO_W = 2 ,
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
output wire  tx_full  , tx ,
output wire   [DBITS-1:0] r_data
);
wire rx_tick;
wire tx_tick;
wire tx_done_tick ;
wire tx_empty , tx_fifo_not_empty ;
wire [DBITS-1:0] tx_fifo_out ;
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

//Transmitter
fifo #(.B ( DBITS ) , .W ( FIFO_W )) fifo_tx_unit
(.clk ( PCLK ) , .reset ( PRESETn ) , .rd ( tx_done_tick ) , .wr ( PWRITE ) , .w_data ( PWDATA ) , .empty ( tx_empty ) ,
.full ( tx_full ) , .r_data ( tx_fifo_out ));


uart_tx #(.DBIT ( DBITS ) , .SB_TICK ( SB_TICK )) uart_tx_unit
(.clk ( PCLK ) , .reset ( PRESETn ) , .tx_start ( tx_fifo_not_empty ) ,
.s_tick ( tx_tick ) , .din ( tx_fifo_out ) ,
.tx_done_tick ( tx_done_tick ) , .tx ( tx ));

assign tx_fifo_not_empty = ~ tx_empty ;

endmodule
