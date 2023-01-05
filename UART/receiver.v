module receiver(input wire rx,
		output reg ready,
		input wire ready_clr,
		input wire clk,
		input wire EnClk,
		output reg [7:0] rdout);

initial begin
	ready = 0;
  rdout = 8'b0;
end

localparam RX_START	= 2'b00;
localparam RX_DATA		= 2'b01;
localparam RX_STOP		= 2'b10;

reg [1:0] state = RX_START;
reg [3:0] sample = 0;
reg [3:0] bitpos = 0;
reg [7:0] scratch = 8'b0;

always @(posedge clk) begin
	if (ready_clr)
		ready <= 0;

	if (EnClk) begin
		case (state)
		RX_START: begin
			if (!rx || sample != 0)
				sample <= sample + 4'b1;

			if (sample == 15) begin
				state <= RX_DATA;
				bitpos <= 0;
				sample <= 0;
				scratch <= 0;
			end
		end
		RX_DATA: begin
			sample <= sample + 4'b1;
			if (sample == 4'h8) begin
				scratch[bitpos[2:0]] <= rx;
				bitpos <= bitpos + 4'b1;
			end
			if (bitpos == 8 && sample == 15)
				state <= RX_STOP;
		end
		RX_STOP: begin
			if (sample == 15 || (sample >= 8 && !rx)) begin
				state <= RX_START;
				rdout <= scratch;
				ready <= 1'b1;
				sample <= 0;
			end else begin
				sample <= sample + 4'b1;
			end
		end
		default: begin
			state <= RX_START;
		end
		endcase
	end
end
endmodule
