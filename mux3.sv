module mux3 #(DATA_WIDTH=32)(input logic signed [DATA_WIDTH-1:0] Din0,
									  input logic signed [DATA_WIDTH-1:0] Din1,
									  input logic signed [DATA_WIDTH-1:0] Din2,
									  input [1:0] select,
									  output logic signed [DATA_WIDTH-1:0] Dout);
				 
logic signed [DATA_WIDTH-1:0] Dout_wire;
assign Dout = Dout_wire;
always @ (Din0 or Din1 or Din2 or select)
begin
	case(select)
	2'b00		   :Dout_wire = Din0; 
	2'b01			:Dout_wire = Din1;
	default  	:Dout_wire = Din2; 
	endcase
end
endmodule 