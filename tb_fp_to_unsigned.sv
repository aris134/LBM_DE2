module tb_fp_to_unsigned();

	timeunit 1ns;
	timeprecision 1ns;
	
	parameter INPUT_WIDTH=32;
	parameter OUTPUT_WIDTH=8;
	
	logic [INPUT_WIDTH-1:0] Data_In;
	logic [OUTPUT_WIDTH-1:0] Data_Out;
	
	fp_to_unsigned #(.INPUT_WIDTH(INPUT_WIDTH), .OUTPUT_WIDTH(OUTPUT_WIDTH)) fp_unsigned_converter (.*);

	initial begin
		#5 Data_In = 32'h00_000000;
		
		#5 Data_In = 32'h01_000000;
		
		#5 Data_In = 32'hFF_000000;
		
		#10 $finish;
	end
	
endmodule

