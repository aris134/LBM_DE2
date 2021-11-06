module controller #(DATA_WIDTH=32, GRID_DIM = 16*16, ADDRESS_WIDTH=$clog2(GRID_DIM),
						  ADDRESS_WIDTH2=$clog2(GRID_DIM)+1, MAX_TIME=10, TIME_COUNT_WIDTH=$clog2(MAX_TIME)) 
						 (input Clk, Reset,
						 input logic [ADDRESS_WIDTH-1:0] count_init,
						 input logic [TIME_COUNT_WIDTH-1:0] time_count,
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
						 output logic WE_p_mem, WE_ux_mem, WE_uy_mem, WE_fin_mem, WE_fout_mem, WE_feq_mem,
						 output logic select_p_mem, select_ux_mem, select_uy_mem,
						 output logic [3:0] select_fin_mem,
						 output logic select_p_reg, select_uy_reg,
						 output logic [1:0] select_ux_reg,
						 output logic [3:0] select_fin_addr,
						 output logic count_init_en, row_count_en, time_count_en,
						 output logic div_start,
						 output logic LD_EN_P, LD_EN_PUX, LD_EN_PUY, LD_EN_UX, LD_EN_UY,
						 output logic LD_EN_FEQ0, LD_EN_FEQ1, LD_EN_FEQ2, LD_EN_FEQ3, LD_EN_FEQ4,
						 output logic LD_EN_FEQ5, LD_EN_FEQ6, LD_EN_FEQ7, LD_EN_FEQ8,
						 output logic LD_EN_FOUT0, LD_EN_FOUT1, LD_EN_FOUT2, LD_EN_FOUT3, LD_EN_FOUT4,
						 output logic LD_EN_FOUT5, LD_EN_FOUT6, LD_EN_FOUT7, LD_EN_FOUT8);
						 
	enum logic [4:0] {START, CALC_MOMENT_1, CALC_MOMENT_2, CALC_MOMENT_3,
							CALC_MOMENT_4, CALC_MOMENT_5, CALC_MOMENT_6, CALC_EQUIL_1,
							CALC_EQUIL_2, CALC_COLL_1, CALC_COLL_2, STREAM_0, STREAM_1, STREAM_2,
							STREAM_3, STREAM_4, STREAM_5, STREAM_6, STREAM_7, STREAM_8, INCREMENT_POS,
							INCREMENT_TIME, STOP} State, Next_state;
	
	 // fairly simple controller that orchestrates the LBM algorithm
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
				Next_state <= CALC_COLL_1;
		CALC_COLL_1:
				Next_state <= CALC_COLL_2;
		CALC_COLL_2:
				Next_state <= STREAM_0;
		STREAM_0:
				Next_state <= STREAM_1;
		STREAM_1:
				Next_state <= STREAM_2;
		STREAM_2:
				Next_state <= STREAM_3;
		STREAM_3:
				Next_state <= STREAM_4;
		STREAM_4:
				Next_state <= STREAM_5;
		STREAM_5:
				Next_state <= STREAM_6;
		STREAM_6:
				Next_state <= STREAM_7;
		STREAM_7:
				Next_state <= STREAM_8;
		STREAM_8:
				Next_state <= INCREMENT_POS;
		INCREMENT_POS:
				if (count_init < GRID_DIM - 1) begin
					Next_state <= CALC_MOMENT_1;
				end else begin
					Next_state <= INCREMENT_TIME;
				end
		INCREMENT_TIME:
				if (time_count < MAX_TIME) begin
					Next_state <= CALC_MOMENT_1;
				end else begin
					Next_state <= STOP;
				end
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
	select_p_mem = 1'b0;
	select_ux_mem = 1'b0;
	select_uy_mem = 1'b0;
	select_p_reg = 1'b0;
	select_ux_reg = 2'b00;
	select_uy_reg = 1'b0;
	select_fin_mem = 4'b0000;
	select_fin_addr = 4'b0000;
	count_init_en = 1'b0;
	row_count_en = 1'b0;
	time_count_en = 1'b0;
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
	
	case (State)
	START :
			begin
				WE_p_mem = 1'b1;
				WE_ux_mem = 1'b1;
				WE_uy_mem = 1'b1;
				WE_fin_mem = 1'b1;
				count_init_en = 1'b1;
			end
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
				select_ux_mem = 1'b1;
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
				if (LID | BOTTOM_WALL | LEFT_WALL | RIGHT_WALL) begin
					select_fin_mem = 4'b0001;
					WE_fin_mem = 1'b1;
				end
			end
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
	STREAM_0: // stream address 0
			begin
				// if stream address is invalid (=-1) then leave WE deasserted
				if (stream_addr0 != -1) begin
					select_fin_mem = 4'b0010;
					select_fin_addr = 4'b0001;
					WE_fin_mem = 1'b1;
				end
			end
	STREAM_1:
			begin
				if (stream_addr1 != -1) begin
					select_fin_mem = 4'b0011;
					select_fin_addr = 4'b0010;
					WE_fin_mem = 1'b1;
				end
			end
	STREAM_2:
			begin
				if (stream_addr2 != -1) begin
					select_fin_mem = 4'b0100;
					select_fin_addr = 4'b0011;
					WE_fin_mem = 1'b1;
				end
			end
	STREAM_3:
			begin
				if (stream_addr3 != -1) begin
					select_fin_mem = 4'b0101;
					select_fin_addr = 4'b0100;
					WE_fin_mem = 1'b1;
				end
			end
	STREAM_4:
			begin
				if (stream_addr4 != -1) begin
					select_fin_mem = 4'b0110;
					select_fin_addr = 4'b0101;
					WE_fin_mem = 1'b1;
				end
			end
	STREAM_5:
			begin
				if (stream_addr5 != -1) begin
					select_fin_mem = 4'b0111;
					select_fin_addr = 4'b0110;
					WE_fin_mem = 1'b1;
				end
			end
	STREAM_6:
			begin
				if (stream_addr6 != -1) begin
					select_fin_mem = 4'b1000;
					select_fin_addr = 4'b0111;
					WE_fin_mem = 1'b1;
				end
			end
	STREAM_7:
			begin
				if (stream_addr7 != -1) begin
					select_fin_mem = 4'b1001;
					select_fin_addr = 4'b1000;
					WE_fin_mem = 1'b1;
				end
			end
	STREAM_8:
			begin
				if (stream_addr8 != -1) begin
					select_fin_mem = 4'b1010;
					select_fin_addr = 4'b1001;
					WE_fin_mem = 1'b1;
				end
			end
	INCREMENT_POS:
			begin
				count_init_en = 1'b1; // increment the grid position counter
			end
	INCREMENT_TIME:
			begin
				time_count_en = 1'b1; // increment the time counter once we've covered the grid
			end
		endcase
	end
	
endmodule
