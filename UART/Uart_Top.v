
module UART_TOP #(
    parameter CLOCK_RATE = 100000000, //freq of MCU=100MHZ
    parameter BAUD_RATE = 9600,
    parameter DBits=8
)(
    input  PCLK,                                                        
    // rx interface
    input  rx,
    output wire rx_done,
    output wire [7:0] rx_dout,   
    //tx interface
                 
);
wire rx_tick;
wire tx_tick;
Baud_generator_timer #(
    .CLOCK_RATE(CLOCK_RATE),
    .BAUD_RATE(BAUD_RATE)
)generatorObj (
    .clk(PCLK),
    .rx_tick(rx_tick),
    .tx_tick(tx_tick)
);
Uart_rx rxObj(
        .clk(rx_tick),
        .rx_start(rx),
        .rx_done(rx_done),
        .rx_dout(rx_dout)
);










endmodule