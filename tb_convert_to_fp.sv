module tb_convert_to_fp();

	timeunit 1ns;
	timeprecision 1ns;
	
	parameter INPUT_WIDTH=8;
	parameter OUTPUT_WIDTH=32;
	parameter FBITS=24;
	
	logic [INPUT_WIDTH-1:0] Data_In;
	logic [OUTPUT_WIDTH-1:0] Data_Out;
	
	convert_to_fp #(.INPUT_WIDTH(INPUT_WIDTH), .OUTPUT_WIDTH(OUTPUT_WIDTH), .FBITS(FBITS)) fpconverter (.*);
	
	initial begin
		#5 Data_In = 8'b0000_1010; // no wall	
		
		#10 $finish;
	end
	
endmodule
