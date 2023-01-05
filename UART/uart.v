module uart(input wire [7:0] din, //input data to transmitter
	    input wire wr_en, //wirte into transmitter enable
	    input wire CLK, //clock
	    output wire tx, //transmitter serial output 
	    output wire tx_busy, //transmitter is IDLE  or busy
	    input wire rx, //reciever serial input 
	    output wire rdy,
	    input wire rdy_clr,
	    output wire [7:0] dout); // data out from reciever 

wire rxclk_en, txclk_en;  //reciever and transmitter baud clock
//baud generator
baud_rate_gen uart_baud(.CLK(CLK),
			.rxclk_en(rxclk_en),
			.txclk_en(txclk_en));

//transitter 
transmitter uart_tx(.din(din),
		    .wr_en(wr_en),
		    .CLK(CLK),
		    .clken(txclk_en),
		    .tx(tx),
		    .tx_busy(tx_busy));
		    
//reciever
receiver uart_rx(.rx(rx),
		 .ready(rdy),
		 .ready_clr(rdy_clr),
		 .clk(clk_50m),
		 .EnClk(rxclk_en),
		 .rdout(dout));
endmodule

