module counter_init #(GRID_DIM=16*16, ADDRESS_WIDTH=$clog2(GRID_DIM)) (input Clk, Reset, Enable,
					  output [ADDRESS_WIDTH-1:0] Data_out);
					  
logic [ADDRESS_WIDTH-1:0] count;
assign Data_out = count;

always_ff @ (posedge Clk or negedge Reset)
begin
if (~Reset)
	count <= 0;
else if (Enable)
	count <= count + 1'b1;
end

endmodule
