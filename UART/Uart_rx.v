//1 start_bit + 8 data_bits + 1 stop_bit
module Uart_rx(clk,rx_done,rx_dout);
input           clk; 
output reg     rx_done;
output reg  [7:0]      rx_dout;
reg  [3:0]      OS_count;//oversampling counter max:15
reg  [3:0]      data_count; //d0:d8-->8 data bits
reg             rx_start;  

reg  [2:0]      state;
reg  [2:0]      nextstate;
parameter       NBits      =4'b1000;

//FSM
parameter      IDLE        = 2'b00;
parameter      START       = 2'b01;
parameter      RX_DATA     = 2'b10;
parameter      STOP        = 2'b11;
// nextstate transform
always@(*) begin
  data_count=4'd0;
    case(state)
    IDLE: begin
        if(rx_start==4'd1) begin
            OS_count=0;
            nextstate = START;
        end
        else begin
            nextstate = IDLE;
        end
    end
    START: begin
        if(OS_count==4'd7) //OS_count==7
        begin
            OS_count=0;
            nextstate = RX_DATA;
        end
        else begin
            OS_count=OS_count+1;
            nextstate = START;
        end
    end
    RX_DATA: begin
        if(OS_count == 4'd15) begin
          OS_count=0;
          rx_dout= rx_start|(rx_dout>>1);
          if(data_count==(NBits-1)) begin    
                nextstate = STOP;
            end
          else begin
            data_count=data_count+1;
            nextstate = RX_DATA;
          end
        end 
        else begin
            OS_count=OS_count+1;
            nextstate = RX_DATA;    
        end
    end
    
    STOP: begin
        if(OS_count==4'd7) begin
            rx_done=1;
            nextstate = IDLE;
        end
        else begin
          OS_count=OS_count+1;
          nextstate = STOP; 
        end
    end
    endcase
end
endmodule
