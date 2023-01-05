
module Tri_Buff(enable,data_out,i_port,o_port,data_in);
    input [31:0] enable;
    input [31:0] i_port;
    output reg [31:0] o_port;
    input [31:0] data_out;
    output reg [31:0] data_in;
    integer i;

    always @(*) begin
        for(i=0; i<32; i=i+1)begin
            o_port[i] = enable[i]? data_out[i]: 1'bz;
        end
        
        data_in = i_port;
    end  
endmodule