module tb_mux2();

	timeunit 1ns;
	timeprecision 1ns;
	
	parameter DATA_WIDTH = 32;
	
	logic signed [DATA_WIDTH-1:0] Din0;
   logic signed [DATA_WIDTH-1:0] Din1;
   logic select;
   logic signed [DATA_WIDTH-1:0] Dout;
	
	mux2 #(.DATA_WIDTH(DATA_WIDTH)) mux0 (.*);
	
	initial begin
		Din0 = 32'h0123_45;//67_00000000;
		Din1 = 32'h89AB_CD;//EF_00000000;
		select = 1'b0;
		#10 select = 1'b1;
		#10 Din0 = 32'hABCD_DC;//BA_00000000;
		#10 select = 1'b0;
		#10 select = 1'b1;
		#10 $finish;
	end
	
endmodule
