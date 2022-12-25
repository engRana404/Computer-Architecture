//1 start_bit + 8 data_bits + 1 stop_bit
module Uart_rx(clk,rx_to_fifo);
input           clk; 
output reg     rx_to_fifo;
reg  [3:0]      OS_count;//oversampling counter max:15
reg  [3:0]      data_count; //d0:d8-->8 data bits
reg             rx_start;  
reg  [7:0]      shift_reg;
reg  [2:0]      state;
reg  [2:0]      nextstate;
parameter       NBits      =4'b1000;

//FSM
parameter      IDLE        = 3'b000;
parameter      START       = 3'b001;
parameter      RX_DATA     = 3'b011;
parameter      STOP        = 3'b110;
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
          shift_reg=shift_reg|(rx_start<<1);
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
            rx_to_fifo=1;
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