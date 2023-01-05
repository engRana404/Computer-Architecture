
/*Oversampling by making reciever faster than transmitter by 16 times*/
module Uart_Baud
#(parameter CLOCK_RATE = 100000000, //f=100MHZ frequency of microcontroller
    parameter BAUD_RATE = 9600)(
    input wire clk, 
    output reg rx_tick, //receiver clock 
    output reg tx_tick //transmitter clock
);
parameter FINAL_VALUE_RX = CLOCK_RATE / (BAUD_RATE * 16); //oversample  
parameter FINAL_VALUE_TX = CLOCK_RATE / (BAUD_RATE);
parameter RX_COUNT_WIDTH = $clog2(FINAL_VALUE_RX);//calculate the minimum width required to address a memory of given size
parameter TX_COUNT_WIDTH = $clog2(FINAL_VALUE_TX);

reg [RX_COUNT_WIDTH - 1:0] rxCount = 0;
reg [RX_COUNT_WIDTH - 1:0] txCount = 0;

initial begin
    rx_tick = 1'b0;
    tx_tick = 1'b0;
end

always @(posedge clk) begin
    // rx_clk
    if (rxCount == FINAL_VALUE_RX[RX_COUNT_WIDTH-1:0]) begin
        rxCount <= 0;
        rx_tick <= ~rx_tick;
    end else begin
        rxCount <= rxCount + 1'b1;
    end
    // tx_clk
    if (txCount == FINAL_VALUE_TX[RX_COUNT_WIDTH-1:0]) begin
        txCount <= 0;
        tx_tick <= ~tx_tick;
    end else begin
        txCount <= txCount + 1'b1;
    end
end

endmodule
