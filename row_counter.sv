module row_counter #(GRID_DIM=16*16, INIT_COUNT_WIDTH=$clog2(GRID_DIM), COUNT_WIDTH=$clog2(GRID_DIM/16)) (input Clk, Reset, Enable,
					  input logic [INIT_COUNT_WIDTH-1:0] count_init,
					  output logic [COUNT_WIDTH-1:0] Data_out);
					  
logic [COUNT_WIDTH-1:0] count;
assign Data_out = count;

always_ff @ (posedge Clk or negedge Reset)
begin
if (~Reset)
	count <= 0;
else if (Enable)
	if (count_init > 0 & count_init % 16 == 0) begin
		count <= count + 1'b1;
	end else if (count_init == 0) begin
		count <= 0;
	end
end

endmodule
