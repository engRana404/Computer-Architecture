module uart_TX
#( 

parameter DBIT = 8 ,
SB_TICK = 16 , //ticksforstopbits ,

DVSR = 163 , // baud ratedivisor

DVSR_BIT = 8 , 
FIFO_W = 2 

)
(
input wire  clk , reset ,
input wire rd_uart , wr_uart , rx ,
input wire [7:0] w_data ,
output wire  tx_full  , tx ,
output wire   [7:0] r_data
);


wire tick  , tx_done_tick ;
wire tx_empty , tx_fifo_not_empty ;
wire [7:0] tx_fifo_out ;


mod_m_counter #(.M ( DVSR ) , .N ( DVSR_BIT )) baud_gen_unit
(.clk ( clk ) , .reset ( reset ) , .q () , .max_tick ( tick ));


fifo #(.B ( DBIT ) , .W ( FIFO_W )) fifo_tx_unit
(.clk ( clk ) , .reset ( reset ) , .rd ( tx_done_tick ) , .wr ( wr_uart ) , .w_data ( w_data ) , .empty ( tx_empty ) ,
.full ( tx_full ) , .r_data ( tx_fifo_out ));


uart_tx #(.DBIT ( DBIT ) , .SB_TICK ( SB_TICK )) uart_tx_unit
(.clk ( clk ) , .reset ( reset ) , .tx_start ( tx_fifo_not_empty ) ,
.s_tick ( tick ) , .din ( tx_fifo_out ) ,
.tx_done_tick ( tx_done_tick ) , .tx ( tx ));

assign tx_fifo_not_empty = ~ tx_empty ;

endmodule
