module controller #(DATA_WIDTH=32, GRID_DIM = 16*16, ADDRESS_WIDTH=$clog2(GRID_DIM)) (input Clk, Reset,
						 input logic [ADDRESS_WIDTH-1:0] count_init,
						 input logic div_valid,
						 input logic LID, BOTTOM_WALL, LEFT_WALL, RIGHT_WALL,
						 output logic WE_p_mem, WE_ux_mem, WE_uy_mem, WE_fin_mem, WE_fout_mem, WE_feq_mem,
						 output logic select_p_mem, select_ux_mem, select_uy_mem, select_fin,
						 output logic select_p_reg, select_uy_reg,
						 output logic [1:0] select_ux_reg,
						 output logic count_init_en,
						 output logic div_start,
						 output logic LD_EN_P, LD_EN_PUX, LD_EN_PUY, LD_EN_UX, LD_EN_UY,
						 output logic LD_EN_FEQ0, LD_EN_FEQ1, LD_EN_FEQ2, LD_EN_FEQ3, LD_EN_FEQ4,
						 output logic LD_EN_FEQ5, LD_EN_FEQ6, LD_EN_FEQ7, LD_EN_FEQ8);
						 
	enum logic [3:0] {START, CALC_MOMENT_1, CALC_MOMENT_2, CALC_MOMENT_3,
							CALC_MOMENT_4, CALC_MOMENT_5, CALC_MOMENT_6, CALC_EQUIL_1,
							CALC_EQUIL_2, CALC_COLL_1} State, Next_state;
	
	// variable declarations
	
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
		CALC_COLL_1:
				;
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
	select_fin = 1'b0;
	count_init_en = 1'b0;
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
	
	case (State)
	START :
			begin
				WE_p_mem = 1'b1;
				WE_ux_mem = 1'b1;
				WE_uy_mem = 1'b1;
				WE_fin_mem = 1'b1;
				select_p_mem = 1'b1;
				select_ux_mem = 1'b1;
				select_uy_mem = 1'b1;
				select_fin = 1'b1;
				count_init_en = 1'b1;
			end
	CALC_MOMENT_1:
			begin
				WE_p_mem = 1'b0;
				WE_ux_mem = 1'b0;
				WE_uy_mem = 1'b0;
				WE_fin_mem = 1'b0;
				select_p_mem = 1'b0;
				select_ux_mem = 1'b0;
				select_uy_mem = 1'b0;
				select_fin = 1'b0;
				count_init_en = 1'b0;
				if (LID | BOTTOM_WALL | LEFT_WALL | RIGHT_WALL) begin
					select_p_reg = 1'b1;
				end
				LD_EN_P = 1'b1;
				LD_EN_PUX = 1'b1;
				LD_EN_PUY = 1'b1;
			end
	CALC_MOMENT_2:
			begin
			// filler state for allowing p, pux, puy registers time to load data
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
			end
	CALC_COLL_1:
			begin
			end
		endcase
	end
	
endmodule
