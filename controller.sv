module controller #(DATA_WIDTH=32, GRID_DIM = 16*16, ADDRESS_WIDTH=$clog2(GRID_DIM)) (input Clk, Reset,
						 input logic [ADDRESS_WIDTH-1:0] count_init,
						 output logic WE_p_mem, WE_ux_mem, WE_uy_mem, WE_fin_mem, WE_fout_mem, WE_feq_mem,
						 output logic select_p, select_ux, select_uy, select_fin,
						 output logic count_init_en,
						 output logic LD_EN_P);
						 
	enum logic [1:0] {START, CALC_MOMENT} State, Next_state;
	
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
				Next_state <= CALC_MOMENT;
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
	select_p = 1'b0;
	select_ux = 1'b0;
	select_uy = 1'b0;
	select_fin = 1'b0;
	count_init_en = 1'b0;
	LD_EN_P = 1'b0;
	
	case (State)
	START :
			begin
				WE_p_mem = 1'b1;
				WE_ux_mem = 1'b1;
				WE_uy_mem = 1'b1;
				WE_fin_mem = 1'b1;
				select_p = 1'b1;
				select_ux = 1'b1;
				select_uy = 1'b1;
				select_fin = 1'b1;
				count_init_en = 1'b1;
			end
	CALC_MOMENT:
			begin
				WE_p_mem = 1'b0;
				WE_ux_mem = 1'b0;
				WE_uy_mem = 1'b0;
				WE_fin_mem = 1'b0;
				select_p = 1'b0;
				select_ux = 1'b0;
				select_uy = 1'b0;
				select_fin = 1'b0;
				count_init_en = 1'b0;
				LD_EN_P = 1'b1;
			end
		endcase
	end
	
endmodule
