module scrambler2 (input logic signed [24:0] lfsr_out,
						 output logic signed [24:0] scramble_out);

	assign scramble_out[0] = lfsr_out[8];
	assign scramble_out[1] = lfsr_out[19];
	assign scramble_out[2] = lfsr_out[0];
	assign scramble_out[3] = lfsr_out[16];
	assign scramble_out[4] = lfsr_out[15];
	assign scramble_out[5] = lfsr_out[1];
	assign scramble_out[6] = lfsr_out[3];
	assign scramble_out[7] = lfsr_out[20];
	assign scramble_out[8] = lfsr_out[23];
	assign scramble_out[9] = lfsr_out[12];
	assign scramble_out[10] = lfsr_out[4];
	assign scramble_out[11] = lfsr_out[13];
	assign scramble_out[12] = lfsr_out[18];
	assign scramble_out[13] = lfsr_out[24];
	assign scramble_out[14] = lfsr_out[7];
	assign scramble_out[15] = lfsr_out[11];
	assign scramble_out[16] = lfsr_out[6];
	assign scramble_out[17] = lfsr_out[22];
	assign scramble_out[18] = lfsr_out[9];
	assign scramble_out[19] = lfsr_out[17];
	assign scramble_out[20] = lfsr_out[21];
	assign scramble_out[21] = lfsr_out[5];
	assign scramble_out[22] = lfsr_out[10];
	assign scramble_out[23] = lfsr_out[14];
	assign scramble_out[24] = lfsr_out[2];

endmodule
