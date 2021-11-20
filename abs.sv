module abs #(DATA_WIDTH=32)
	(input logic signed [DATA_WIDTH-1:0] non_abs,
	 output logic signed [DATA_WIDTH-1:0] abs);

always @* begin
  if (non_abs[DATA_WIDTH-1] == 1'b1) begin
    abs = -non_abs;
  end
  else begin
    abs = non_abs;
  end
end

endmodule

