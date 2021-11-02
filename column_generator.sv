module column_generator #(GRID_DIM=16, ADDRESS_WIDTH=$clog2(GRID_DIM*GRID_DIM))
								 (input Clk, start,
								  input [ADDRESS_WIDTH-1:0] count_init,
								  output [ADDRESS_WIDTH-1:0] column);

logic busy;
logic valid;
logic dbz;
logic ovf;
logic signed [ADDRESS_WIDTH-1:0] divisor;
logic signed col;
logic signed q;

assign column = col;
assign divisor = GRID_DIM;

fp_div #(.WIDTH(ADDRESS_WIDTH), .FBITS(0)) divider (.clk(Clk), .start(start), .busy(busy),
         .valid(valid), .dbz(dbz), .ovf(ovf), .x(count_init), .y(divisor), .q(q), .r(col));

endmodule
