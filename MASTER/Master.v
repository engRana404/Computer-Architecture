module master (
get_w_paddr,get_r_paddr, 
get_w_data_in,PRDATA, 
PSTRB,        
PRESETn,
PCLK,
PREADY,
transfer,
READ_WRITE, 
PENABLE,
PADDR,
PWRITE, 
PWDATA,
send_r_out,
PSLVERR,
PSEL);
  input [32:0] get_w_paddr,get_r_paddr; //extra address bit to select slave
	input [31:0] get_w_data_in,PRDATA; 
  input [3:0]PSTRB;        
	input PRESETn,PCLK,PREADY;
  input transfer,READ_WRITE; //dummy signals, READ_WRITE -> read=1, write=0
	output reg PENABLE;
	output reg [32:0]PADDR;
	output reg PWRITE; // write =1 read=0
	output reg [32:0] PWDATA, send_r_out;
	output PSLVERR;
  output [1:0] PSEL; 




  //------------------------------------------
  //Needed variables
  //------------------------------------------
  reg [1:0] state, next_state;

  reg Error, //PSLVERR i
      setup_error,
      invalid_read_paddr,
      invalid_write_paddr,
      invalid_write_data ;
  
  localparam IDLE = 2'b00, SETUP = 2'b10, ENABLE = 2'b11 ;

  //------------------------------------------
  //Finite state machine
  //------------------------------------------
  always @(posedge PCLK)
  begin
	if(!PRESETn)
		state <= IDLE;
	else
		state <= next_state; 
  end

  always @(state,transfer,PREADY)

  begin
	if(!PRESETn)
	  next_state = IDLE;
	else
          begin
             PWRITE = ~READ_WRITE;
          end
        case (state)
                  
		    IDLE: begin 
		        PENABLE =0;

		        if(!transfer)
	        	    next_state = IDLE ;
	            else
			        next_state = SETUP;
	        end

	       	SETUP:   begin
			    PENABLE =0;

			    if(READ_WRITE)  // read = 1 write = 0
	                PADDR = get_r_paddr; //send reading address
			    else begin
			        PADDR = get_w_paddr; //send writing address

                    //select bits to write
                    if(PSTRB[0])
				        PWDATA[7:0] = get_w_data_in[7:0];
                    if(PSTRB[1])
				        PWDATA[15:8] = get_w_data_in[15:8];
                    if(PSTRB[2])
				        PWDATA[23:16] = get_w_data_in[23:16];
                    if(PSTRB[3])
				        PWDATA[31:24] = get_w_data_in[31:24];
                end
			    
			    if(transfer && !PSLVERR)
			        next_state = ENABLE;
		        else
           	        next_state = IDLE;
		    end

	       	ENABLE: begin 
                if(PSEL[0] || PSEL[1])
		            PENABLE =1;
			    if(transfer & !PSLVERR) begin
				   if(PREADY) begin
				        if(!READ_WRITE) // read=1 write=0
					        next_state = SETUP; //wrote
					    else begin
					        next_state = SETUP; 
				          	send_r_out = PRDATA; //get read data
					   end
			        end
				        else next_state = ENABLE;
		        end
		            else next_state = IDLE;
			end
        endcase
    end

    //------------------------------------------		   
	//select slave	 
    //------------------------------------------   
    assign {PSEL[0],PSEL[1]} = ((state != IDLE) ? (PADDR[32] ? {1'b0,1'b1} : {1'b1,1'b0}) : 2'd0);
    


    //------------------------------------------
    //PSLVERR (check errors)
    //------------------------------------------
    always @(*) begin
        if(!PRESETn) begin 
	        setup_error =0;
	        invalid_read_paddr = 0;
	        invalid_write_paddr = 0;
	        invalid_write_paddr =0 ;
	    end
        else begin	
	        if(state == IDLE && next_state == ENABLE)
                setup_error = 1;
	        else setup_error = 0;

            if((get_w_data_in===32'dx) && (!READ_WRITE) && (state==SETUP || state==ENABLE))
		        invalid_write_data =1;
	        else invalid_write_data = 0;

	        if((get_r_paddr===33'dx) && READ_WRITE && (state==SETUP || state==ENABLE))
		        invalid_read_paddr = 1;
	        else  invalid_read_paddr = 0;

            if((get_w_paddr===33'dx) && (!READ_WRITE) && (state==SETUP || state==ENABLE))
		        invalid_write_paddr =1;
            else invalid_write_paddr =0;
          
            if(state == SETUP) begin
                if(PWRITE) begin
                    if(PADDR==get_w_paddr && PWDATA==get_w_data_in)
                        setup_error=1'b0;
                    else
                       setup_error=1'b1;
                   end
                else begin
                    if (PADDR==get_r_paddr)
                        setup_error=1'b0;
                    else
                        setup_error=1'b1;
                end    
            end 
            else setup_error=1'b0;
        end 
        Error = setup_error ||  invalid_read_paddr || invalid_write_data || invalid_write_paddr  ;
    end

    assign PSLVERR =  Error ; //assign error checks to PSLVERR

endmodule
    
