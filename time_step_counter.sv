module time_step_counter #(MAX_TIME=100, TIME_COUNT_WIDTH=$clog2(MAX_TIME)) (input Clk, Reset, Enable,
					  output logic [TIME_COUNT_WIDTH:0] Data_out);
					  
logic [TIME_COUNT_WIDTH:0] count;
assign Data_out = count;

always_ff @ (posedge Clk or negedge Reset)
begin
if (~Reset)
	count <= 0;
else if (Enable)
	if (count == MAX_TIME) begin
		count <= count;
	end else begin
		count <= count + 1'b1;
	end
end

endmodule
