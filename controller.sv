/*
	This is the state machine controller
	that orchestrates system operation
*/

module controller #(DATA_WIDTH=32, GRID_DIM = 16*16, ADDRESS_WIDTH=$clog2(GRID_DIM),
						  ADDRESS_WIDTH2=$clog2(GRID_DIM)+1, MAX_TIME=100, TIME_COUNT_WIDTH=$clog2(MAX_TIME)) 
						 (input Clk, Reset,
						 input logic [ADDRESS_WIDTH-1:0] count_init,
						 input logic [TIME_COUNT_WIDTH:0] time_count,
						 input logic [ADDRESS_WIDTH-1:0] wall_address,
						 input logic div_valid,
						 input logic LID, BOTTOM_WALL, LEFT_WALL, RIGHT_WALL,
						 input logic [ADDRESS_WIDTH2-1:0] stream_addr0,
						 input logic [ADDRESS_WIDTH2-1:0] stream_addr1,
						 input logic [ADDRESS_WIDTH2-1:0] stream_addr2,
						 input logic [ADDRESS_WIDTH2-1:0] stream_addr3,
						 input logic [ADDRESS_WIDTH2-1:0] stream_addr4,
						 input logic [ADDRESS_WIDTH2-1:0] stream_addr5,
						 input logic [ADDRESS_WIDTH2-1:0] stream_addr6,
						 input logic [ADDRESS_WIDTH2-1:0] stream_addr7,
						 input logic [ADDRESS_WIDTH2-1:0] stream_addr8,
						 input logic signed [DATA_WIDTH-1:0] p_mem_array [GRID_DIM-1:0],
						 input logic signed [DATA_WIDTH-1:0] ux_mem_array [GRID_DIM-1:0],
						 input logic signed [DATA_WIDTH-1:0] uy_mem_array [GRID_DIM-1:0],
						 output logic WE_p_mem, WE_ux_mem, WE_uy_mem, WE_fin_mem, WE_fout_mem, WE_feq_mem, WE_f_streamed,
						 output logic select_p_mem, select_uy_mem,
						 output logic [1:0] select_ux_mem,
						 output logic [1:0] select_fin_mem,
						 output logic [3:0] select_f_streamed,
						 output logic select_p_reg, select_uy_reg,
						 output logic [1:0] select_ux_reg,
						 output logic [3:0] select_fin_addr,
						 output logic select_moment_addr,
						 output logic count_init_en, row_count_en, time_count_en, bc_addr_iter_en,
						 output logic div_start,
						 output logic LD_EN_P, LD_EN_PUX, LD_EN_PUY, LD_EN_UX, LD_EN_UY,
						 output logic LD_EN_FEQ0, LD_EN_FEQ1, LD_EN_FEQ2, LD_EN_FEQ3, LD_EN_FEQ4,
						 output logic LD_EN_FEQ5, LD_EN_FEQ6, LD_EN_FEQ7, LD_EN_FEQ8,
						 output logic LD_EN_FOUT0, LD_EN_FOUT1, LD_EN_FOUT2, LD_EN_FOUT3, LD_EN_FOUT4,
						 output logic LD_EN_FOUT5, LD_EN_FOUT6, LD_EN_FOUT7, LD_EN_FOUT8,
						 output logic LD_EN_f_streamed_REG_0, LD_EN_f_streamed_REG_1, LD_EN_f_streamed_REG_2, LD_EN_f_streamed_REG_3, LD_EN_f_streamed_REG_4, 
						 output logic LD_EN_f_streamed_REG_5, LD_EN_f_streamed_REG_6, LD_EN_f_streamed_REG_7, LD_EN_f_streamed_REG_8, 
						 output logic FINISH);
						 
	enum logic [5:0] {START, FLUFF_1, CALC_MOMENT_1, CALC_MOMENT_2, CALC_MOMENT_3,
							CALC_MOMENT_4, CALC_MOMENT_5, CALC_MOMENT_6, CALC_EQUIL_1,
							CALC_EQUIL_2, FLUFF_2, CALC_EQUIL_3, FLUFF_3, FLUFF_4, CALC_COLL_1, CALC_COLL_2, CALC_COLL_3, STREAM_0,
							STREAM_0B, STREAM_0C, STREAM_1, STREAM_1B, STREAM_1C, STREAM_2, STREAM_2B, STREAM_2C, STREAM_3, STREAM_3B, STREAM_3C, STREAM_4,
							STREAM_4B, STREAM_4C, STREAM_5, STREAM_5B, STREAM_5C, STREAM_6, STREAM_6B, STREAM_6C, STREAM_7, STREAM_7B, STREAM_7C,
							STREAM_8, STREAM_8B, STREAM_8C, INCREMENT_POS, SWAP_0, SWAP_1,
							INCREMENT_TIME, STOP} State, Next_state;
	
	 always_ff @ (posedge Clk or negedge Reset)
    begin 
        if (~Reset) 
            State <= START;
        else 
            State <= Next_state;
    end
	
	//***** STATE TRANSITIONS ****//
		
	always_comb
	begin
	Next_state = State;
	
	unique case (State)
		START		:
			if (count_init == GRID_DIM - 1)
				Next_state <= FLUFF_1;
		FLUFF_1	:
			Next_state <= CALC_MOMENT_1;
		CALC_MOMENT_1	:
			Next_state <= CALC_MOMENT_2;
		CALC_MOMENT_2	:
			Next_state <= CALC_MOMENT_3;
		CALC_MOMENT_3	:
			Next_state <= CALC_MOMENT_4;
		CALC_MOMENT_4	:
			if (div_valid)
				Next_state <= CALC_MOMENT_5;
		CALC_MOMENT_5	:
				Next_state <= CALC_MOMENT_6;
		CALC_MOMENT_6	:
				Next_state <= CALC_EQUIL_1;
		CALC_EQUIL_1:
				Next_state <= CALC_EQUIL_2;
		CALC_EQUIL_2:
			if (LID | BOTTOM_WALL | LEFT_WALL | RIGHT_WALL) begin
				Next_state <= FLUFF_4;
			end else begin
				Next_state <= FLUFF_2;
			end
		FLUFF_4:
				Next_state <= CALC_EQUIL_3;
		FLUFF_2:
				Next_state <= CALC_COLL_1;
		CALC_EQUIL_3:
				Next_state <= FLUFF_3;
		FLUFF_3:
				Next_state <= CALC_COLL_1;
		CALC_COLL_1:
				Next_state <= CALC_COLL_2;
		CALC_COLL_2:
				Next_state <= CALC_COLL_3;
		CALC_COLL_3:
				Next_state <= STREAM_0;
		STREAM_0:
			if (stream_addr0[ADDRESS_WIDTH2-1] != 1'b1) begin
				Next_state <= STREAM_0B;
			end else begin
				Next_state <= STREAM_1;
			end
		STREAM_0B:
				Next_state <= STREAM_0C;
		STREAM_0C:
				Next_state <= STREAM_1;
		STREAM_1:
			if (stream_addr1[ADDRESS_WIDTH2-1] != 1'b1) begin
				Next_state <= STREAM_1B;
			end else begin
				Next_state <= STREAM_2;
			end
		STREAM_1B:
				Next_state <= STREAM_1C;
		STREAM_1C:
				Next_state <= STREAM_2;
		STREAM_2:
			if (stream_addr2[ADDRESS_WIDTH2-1] != 1'b1) begin
				Next_state <= STREAM_2B;
			end else begin
				Next_state <= STREAM_3;
			end
		STREAM_2B:
				Next_state <= STREAM_2C;
		STREAM_2C:
				Next_state <= STREAM_3;
		STREAM_3:
			if (stream_addr3[ADDRESS_WIDTH2-1] != 1'b1) begin
				Next_state <= STREAM_3B;
			end else begin
				Next_state <= STREAM_4;
			end
		STREAM_3B:
				Next_state <= STREAM_3C;
		STREAM_3C:
				Next_state <= STREAM_4;
		STREAM_4:
			if (stream_addr4[ADDRESS_WIDTH2-1] != 1'b1) begin
				Next_state <= STREAM_4B;
			end else begin
				Next_state <= STREAM_5;
			end
		STREAM_4B:
				Next_state <= STREAM_4C;
		STREAM_4C:
				Next_state <= STREAM_5;
		STREAM_5:
			if (stream_addr5[ADDRESS_WIDTH2-1] != 1'b1) begin
				Next_state <= STREAM_5B;
			end else begin
				Next_state <= STREAM_6;
			end
		STREAM_5B:
				Next_state <= STREAM_5C;
		STREAM_5C:
				Next_state <= STREAM_6;
		STREAM_6:
			if (stream_addr6[ADDRESS_WIDTH2-1] != 1'b1) begin
				Next_state <= STREAM_6B;
			end else begin
				Next_state <= STREAM_7;
			end
		STREAM_6B:
				Next_state <= STREAM_6C;
		STREAM_6C:
				Next_state <= STREAM_7;
		STREAM_7:
			if (stream_addr7[ADDRESS_WIDTH2-1] != 1'b1) begin
				Next_state <= STREAM_7B;
			end else begin
				Next_state <= STREAM_8;
			end
		STREAM_7B:
				Next_state <= STREAM_7C;
		STREAM_7C:
				Next_state <= STREAM_8;
		STREAM_8:
			if (stream_addr8[ADDRESS_WIDTH2-1] != 1'b1) begin
				Next_state <= STREAM_8B;
			end else begin
				Next_state <= INCREMENT_POS;
			end
		STREAM_8B:
				Next_state <= STREAM_8C;
		STREAM_8C:
				Next_state <= INCREMENT_POS;
		INCREMENT_POS:
				if (count_init < GRID_DIM - 1) begin
					Next_state <= FLUFF_1;
				end else begin
					Next_state <= SWAP_0;
				end
		SWAP_0:
					Next_state <= SWAP_1;
		SWAP_1:
			if (count_init == GRID_DIM - 1)
				Next_state <= INCREMENT_TIME;
			else
				Next_state <= SWAP_0;
		INCREMENT_TIME:
				if (time_count < MAX_TIME) begin
					Next_state <= FLUFF_1;
				end else begin
					Next_state <= STOP;
				end
		STOP:
				Next_state <= STOP;
		endcase
	end
	
	//**** STATE DEFINITIONS ****//
	
	always_comb
	begin
	WE_p_mem = 1'b0;
	WE_ux_mem = 1'b0;
	WE_uy_mem = 1'b0;
	WE_fin_mem = 1'b0;
	WE_fout_mem = 1'b0;
	WE_feq_mem = 1'b0;
	WE_f_streamed = 1'b0;
	select_p_mem = 1'b0;
	select_ux_mem = 2'b00;
	select_uy_mem = 1'b0;
	select_p_reg = 1'b0;
	select_ux_reg = 2'b00;
	select_uy_reg = 1'b0;
	select_fin_mem = 2'b00;
	select_f_streamed = 4'b0000;
	select_fin_addr = 4'b0000;
	select_moment_addr = 1'b0;
	count_init_en = 1'b0;
	row_count_en = 1'b0;
	time_count_en = 1'b0;
	bc_addr_iter_en = 1'b0;
	LD_EN_P = 1'b0;
	LD_EN_PUX = 1'b0;
	LD_EN_PUY = 1'b0;
	LD_EN_UX = 1'b0;
	LD_EN_UY = 1'b0;
	LD_EN_FEQ0 = 1'b0;
	LD_EN_FEQ1 = 1'b0;
	LD_EN_FEQ2 = 1'b0;
	LD_EN_FEQ3 = 1'b0;
	LD_EN_FEQ4 = 1'b0;
	LD_EN_FEQ5 = 1'b0;
	LD_EN_FEQ6 = 1'b0;
	LD_EN_FEQ7 = 1'b0;
	LD_EN_FEQ8 = 1'b0;
	div_start = 1'b0;
	LD_EN_FOUT0 = 1'b0;
	LD_EN_FOUT1 = 1'b0;
	LD_EN_FOUT2 = 1'b0;
	LD_EN_FOUT3 = 1'b0;
	LD_EN_FOUT4 = 1'b0;
	LD_EN_FOUT5 = 1'b0;
	LD_EN_FOUT6 = 1'b0;
	LD_EN_FOUT7 = 1'b0;
	LD_EN_FOUT8 = 1'b0;
	LD_EN_f_streamed_REG_0 = 1'b0;
	LD_EN_f_streamed_REG_1 = 1'b0;
	LD_EN_f_streamed_REG_2 = 1'b0;
	LD_EN_f_streamed_REG_3 = 1'b0;
	LD_EN_f_streamed_REG_4 = 1'b0;
	LD_EN_f_streamed_REG_5 = 1'b0;
	LD_EN_f_streamed_REG_6 = 1'b0;
	LD_EN_f_streamed_REG_7 = 1'b0;
	LD_EN_f_streamed_REG_8 = 1'b0;
	FINISH = 1'b0;
	
	case (State)
	START :
			begin
				WE_p_mem = 1'b1;
				WE_ux_mem = 1'b1;
				WE_uy_mem = 1'b1;
				WE_fin_mem = 1'b1;
				WE_feq_mem = 1'b1; //
				WE_fout_mem = 1'b1; //
				WE_f_streamed = 1'b1; //
				count_init_en = 1'b1;
			end
	FLUFF_1:
			;
	CALC_MOMENT_1:
			begin
				row_count_en = 1'b1;
				if (LID | BOTTOM_WALL | LEFT_WALL | RIGHT_WALL) begin
					select_p_reg = 1'b1;
				end
				LD_EN_P = 1'b1;
				LD_EN_PUX = 1'b1;
				LD_EN_PUY = 1'b1;
			end
	CALC_MOMENT_2:
			begin
			select_p_mem = 1'b1;
			WE_p_mem = 1'b1;
			end
	CALC_MOMENT_3:
			begin
				div_start = 1'b1;
			end
	CALC_MOMENT_4:
			begin
				div_start = 1'b0;
			end
	CALC_MOMENT_5:
			begin
				if (LID) begin
					select_ux_reg = 2'b01;
					select_uy_reg = 1'b1;
				end else if (BOTTOM_WALL | LEFT_WALL | RIGHT_WALL) begin
					select_ux_reg = 2'b10;
					select_uy_reg = 1'b1;
				end
				LD_EN_UX = 1'b1;
				LD_EN_UY = 1'b1;
			end
	CALC_MOMENT_6:
			begin
				select_ux_mem = 2'b01;
				select_uy_mem = 1'b1;
				WE_ux_mem = 1'b1;
				WE_uy_mem = 1'b1;
			end
	CALC_EQUIL_1:
			begin
				LD_EN_FEQ0 = 1'b1;
				LD_EN_FEQ1 = 1'b1;
				LD_EN_FEQ2 = 1'b1;
				LD_EN_FEQ3 = 1'b1;
				LD_EN_FEQ4 = 1'b1;
				LD_EN_FEQ5 = 1'b1;
				LD_EN_FEQ6 = 1'b1;
				LD_EN_FEQ7 = 1'b1;
				LD_EN_FEQ8 = 1'b1;
			end
	CALC_EQUIL_2:
			begin
				WE_feq_mem = 1'b1;
			end
	FLUFF_2:
			;
	FLUFF_4:
			;
	CALC_EQUIL_3:
			begin
				select_fin_mem = 2'b01;
				WE_fin_mem = 1'b1;
			end
	FLUFF_3:
			;
	CALC_COLL_1:
			begin
				LD_EN_FOUT0 = 1'b1;
				LD_EN_FOUT1 = 1'b1;
				LD_EN_FOUT2 = 1'b1;
				LD_EN_FOUT3 = 1'b1;
				LD_EN_FOUT4 = 1'b1;
				LD_EN_FOUT5 = 1'b1;
				LD_EN_FOUT6 = 1'b1;
				LD_EN_FOUT7 = 1'b1;
				LD_EN_FOUT8 = 1'b1;
			end
	CALC_COLL_2:
			begin
				WE_fout_mem = 1'b1;
			end
	CALC_COLL_3:
			begin
			end
	STREAM_0: // stream address 0
			begin
				// if stream address is invalid then leave WE deasserted
				if (stream_addr0[ADDRESS_WIDTH2-1] != 1'b1) begin
					select_fin_addr = 4'b0001;
				end
			end
	STREAM_0B:
			begin
					LD_EN_f_streamed_REG_0 = 1'b1;
					LD_EN_f_streamed_REG_1 = 1'b1;
					LD_EN_f_streamed_REG_2 = 1'b1;
					LD_EN_f_streamed_REG_3 = 1'b1;
					LD_EN_f_streamed_REG_4 = 1'b1;
					LD_EN_f_streamed_REG_5 = 1'b1;
					LD_EN_f_streamed_REG_6 = 1'b1;
					LD_EN_f_streamed_REG_7 = 1'b1;
					LD_EN_f_streamed_REG_8 = 1'b1;
			end
	STREAM_0C:
			begin
					select_fin_addr = 4'b0001;
					select_f_streamed = 4'b0010;
					WE_f_streamed = 1'b1;
			end
	STREAM_1:
			begin
				if (stream_addr1[ADDRESS_WIDTH2-1] != 1'b1) begin
					select_fin_addr = 4'b0010;
				end
			end
	STREAM_1B:
			begin
					LD_EN_f_streamed_REG_0 = 1'b1;
					LD_EN_f_streamed_REG_1 = 1'b1;
					LD_EN_f_streamed_REG_2 = 1'b1;
					LD_EN_f_streamed_REG_3 = 1'b1;
					LD_EN_f_streamed_REG_4 = 1'b1;
					LD_EN_f_streamed_REG_5 = 1'b1;
					LD_EN_f_streamed_REG_6 = 1'b1;
					LD_EN_f_streamed_REG_7 = 1'b1;
					LD_EN_f_streamed_REG_8 = 1'b1;
			end
	STREAM_1C:
			begin
					select_fin_addr = 4'b0010;
					select_f_streamed = 4'b0011;
					WE_f_streamed = 1'b1;
			end
	STREAM_2:
			begin
				if (stream_addr2[ADDRESS_WIDTH2-1] != 1'b1) begin
					select_fin_addr = 4'b0011;
				end
			end
	STREAM_2B:
			begin
					LD_EN_f_streamed_REG_0 = 1'b1;
					LD_EN_f_streamed_REG_1 = 1'b1;
					LD_EN_f_streamed_REG_2 = 1'b1;
					LD_EN_f_streamed_REG_3 = 1'b1;
					LD_EN_f_streamed_REG_4 = 1'b1;
					LD_EN_f_streamed_REG_5 = 1'b1;
					LD_EN_f_streamed_REG_6 = 1'b1;
					LD_EN_f_streamed_REG_7 = 1'b1;
					LD_EN_f_streamed_REG_8 = 1'b1;
			end
	STREAM_2C:
			begin
					select_fin_addr = 4'b0011;
					select_f_streamed = 4'b0100;
					WE_f_streamed = 1'b1;
			end
	STREAM_3:
			begin
				if (stream_addr3[ADDRESS_WIDTH2-1] != 1'b1) begin
					select_fin_addr = 4'b0100;
				end
			end
	STREAM_3B:
			begin
					LD_EN_f_streamed_REG_0 = 1'b1;
					LD_EN_f_streamed_REG_1 = 1'b1;
					LD_EN_f_streamed_REG_2 = 1'b1;
					LD_EN_f_streamed_REG_3 = 1'b1;
					LD_EN_f_streamed_REG_4 = 1'b1;
					LD_EN_f_streamed_REG_5 = 1'b1;
					LD_EN_f_streamed_REG_6 = 1'b1;
					LD_EN_f_streamed_REG_7 = 1'b1;
					LD_EN_f_streamed_REG_8 = 1'b1;
			end
	STREAM_3C:
			begin
					select_fin_addr = 4'b0100;
					select_f_streamed = 4'b0101;
					WE_f_streamed = 1'b1;
			end
	STREAM_4:
			begin
				if (stream_addr4[ADDRESS_WIDTH2-1] != 1'b1) begin
					select_fin_addr = 4'b0101;
				end
			end
	STREAM_4B:
			begin
					LD_EN_f_streamed_REG_0 = 1'b1;
					LD_EN_f_streamed_REG_1 = 1'b1;
					LD_EN_f_streamed_REG_2 = 1'b1;
					LD_EN_f_streamed_REG_3 = 1'b1;
					LD_EN_f_streamed_REG_4 = 1'b1;
					LD_EN_f_streamed_REG_5 = 1'b1;
					LD_EN_f_streamed_REG_6 = 1'b1;
					LD_EN_f_streamed_REG_7 = 1'b1;
					LD_EN_f_streamed_REG_8 = 1'b1;
			end
	STREAM_4C:
			begin
					select_fin_addr = 4'b0101;
					select_f_streamed = 4'b0110;
					WE_f_streamed = 1'b1;
			end
	STREAM_5:
			begin
				if (stream_addr5[ADDRESS_WIDTH2-1] != 1'b1) begin
					select_fin_addr = 4'b0110;
				end
			end
	STREAM_5B:
			begin
					LD_EN_f_streamed_REG_0 = 1'b1;
					LD_EN_f_streamed_REG_1 = 1'b1;
					LD_EN_f_streamed_REG_2 = 1'b1;
					LD_EN_f_streamed_REG_3 = 1'b1;
					LD_EN_f_streamed_REG_4 = 1'b1;
					LD_EN_f_streamed_REG_5 = 1'b1;
					LD_EN_f_streamed_REG_6 = 1'b1;
					LD_EN_f_streamed_REG_7 = 1'b1;
					LD_EN_f_streamed_REG_8 = 1'b1;
			end
	STREAM_5C:
			begin
					select_fin_addr = 4'b0110;
					select_f_streamed = 4'b0111;
					WE_f_streamed = 1'b1;
			end
	STREAM_6:
			begin
				if (stream_addr6[ADDRESS_WIDTH2-1] != 1'b1) begin
					select_fin_addr = 4'b0111;
				end
			end
	STREAM_6B:
			begin
					LD_EN_f_streamed_REG_0 = 1'b1;
					LD_EN_f_streamed_REG_1 = 1'b1;
					LD_EN_f_streamed_REG_2 = 1'b1;
					LD_EN_f_streamed_REG_3 = 1'b1;
					LD_EN_f_streamed_REG_4 = 1'b1;
					LD_EN_f_streamed_REG_5 = 1'b1;
					LD_EN_f_streamed_REG_6 = 1'b1;
					LD_EN_f_streamed_REG_7 = 1'b1;
					LD_EN_f_streamed_REG_8 = 1'b1;
			end
	STREAM_6C:
			begin
					select_fin_addr = 4'b0111;
					select_f_streamed = 4'b1000;
					WE_f_streamed = 1'b1;
			end
	STREAM_7:
			begin
				if (stream_addr7[ADDRESS_WIDTH2-1] != 1'b1) begin
					select_fin_addr = 4'b1000;
				end
			end
	STREAM_7B:
			begin
					LD_EN_f_streamed_REG_0 = 1'b1;
					LD_EN_f_streamed_REG_1 = 1'b1;
					LD_EN_f_streamed_REG_2 = 1'b1;
					LD_EN_f_streamed_REG_3 = 1'b1;
					LD_EN_f_streamed_REG_4 = 1'b1;
					LD_EN_f_streamed_REG_5 = 1'b1;
					LD_EN_f_streamed_REG_6 = 1'b1;
					LD_EN_f_streamed_REG_7 = 1'b1;
					LD_EN_f_streamed_REG_8 = 1'b1;
			end
	STREAM_7C:
			begin
					select_fin_addr = 4'b1000;
					select_f_streamed = 4'b1001;
					WE_f_streamed = 1'b1;
			end
	STREAM_8:
			begin
				if (stream_addr8[ADDRESS_WIDTH2-1] != 1'b1) begin
					select_fin_addr = 4'b1001;
				end
			end
	STREAM_8B:
			begin
					LD_EN_f_streamed_REG_0 = 1'b1;
					LD_EN_f_streamed_REG_1 = 1'b1;
					LD_EN_f_streamed_REG_2 = 1'b1;
					LD_EN_f_streamed_REG_3 = 1'b1;
					LD_EN_f_streamed_REG_4 = 1'b1;
					LD_EN_f_streamed_REG_5 = 1'b1;
					LD_EN_f_streamed_REG_6 = 1'b1;
					LD_EN_f_streamed_REG_7 = 1'b1;
					LD_EN_f_streamed_REG_8 = 1'b1;
			end
	STREAM_8C:
			begin
					select_fin_addr = 4'b1001;
					select_f_streamed = 4'b1010;
					WE_f_streamed = 1'b1;
			end
	INCREMENT_POS:
			begin
				count_init_en = 1'b1; // increment the grid position counter
			end		
	SWAP_0:
			begin // read f_streamed
				;
			end
	SWAP_1:
			begin
				count_init_en = 1'b1;
				select_fin_mem = 2'b10; // select f_streamed_out to feed into fin_ram
				WE_fin_mem = 1'b1;
			end
	INCREMENT_TIME:
			begin
				time_count_en = 1'b1; // increment the time counter once we've covered the grid
			end
	STOP: // done
		begin
			FINISH = 1'b1;
			$writememh("p_mem_h.txt", p_mem_array); // write out final p values
			$writememh("ux_mem_h.txt", ux_mem_array); // write out final ux values
			$writememh("uy_mem_h.txt", uy_mem_array); // write out final uy values
		end
	default:
			;
		endcase
	end

endmodule
