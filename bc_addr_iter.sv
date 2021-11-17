module bc_addr_iter #(GRID_DIM=16*16, ADDRESS_WIDTH=$clog2(GRID_DIM))
					(input logic Clk, Reset, Enable,
					output logic [ADDRESS_WIDTH-1:0] address);
					
always_ff @ (posedge Clk or negedge Reset)
begin
if (~Reset)
	address <= 0;
else if (Enable) begin
		if (address > 0 && address < 240 && address % 16 == 0) begin
			address <= address + 15;
		end else
			address <= address + 1'b1;
	end
end

endmodule

					
					
					
					