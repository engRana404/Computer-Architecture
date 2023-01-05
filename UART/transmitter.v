module transmitter(input wire [7:0] din, 
		   input wire wr_en,
		   input wire CLK ,
		   input wire clken,
		   output reg tx,
		   output wire tx_busy);
	
// din : input data from bus to transmitter 
//wr_enable enable data to be written 
// clken from baud generator
// tx serial output 
// tx_busy TX is transmitting or IDLE 

initial begin
	 tx = 1'b1;   
end

parameter STATE_IDLE	= 2'b00;  //default *TX is waiting for order
parameter STATE_START	= 2'b01; // laod data
parameter STATE_DATA	= 2'b10;  // start transmitting
parameter STATE_STOP	= 2'b11;  //tx is done

reg [7:0] data = 8'h00;
reg [2:0] bitpos = 3'h0;  //data bits count register 
reg [1:0] state = STATE_IDLE;  //register for current state

always @(posedge CLK) begin
	case (state)
	STATE_IDLE: begin
		if (wr_en) begin //tx moves to start state
			state <= STATE_START;
			data <= din; //loads data
			bitpos <= 3'h0; 
		end
	end
	STATE_START: begin //start state
		if (clken) begin
			tx <= 1'b0;  //sends start bit active low
			state <= STATE_DATA; //moves to next state
		end
	end
	STATE_DATA: begin  //data state
		if (clken) begin
			if (bitpos == 3'h7)  //stop when 8 bits of data are sent
				state <= STATE_STOP; //moves to next state as tx is done 
			else
				bitpos <= bitpos + 3'h1; // increment data bits counter by 1
			tx <= data[bitpos]; //shift and transmits data
		end
	end
	STATE_STOP: begin // state stop 
		if (clken) begin
			tx <= 1'b1;  //sends stop bit 
			state <= STATE_IDLE; //returns to IDLE
		end
	end
	default: begin
		tx <= 1'b1;  // default value for serial output
		state <= STATE_IDLE;  //default state is IDLE
	end
	endcase
end

assign tx_busy = (state != STATE_IDLE);  // if TX is in IDLE *not transmitting tx isn't busy else it's busy

endmodule

