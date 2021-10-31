module counter_init #(GRID_SIZE=16*16, COUNT_SIZE=$clog2(GRID_SIZE)) (input Clk, Reset, Enable,
					  output [COUNT_SIZE-1:0] Data_out);
					  
logic [COUNT_SIZE-1:0] count;
assign Data_out = count;

always_ff @ (posedge Clk or negedge Reset)
begin
if (~Reset)
	count <= 0;
else if (Enable)
	count <= count + 1'b1;
end

endmodule
