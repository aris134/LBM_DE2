# LBM_DE2

Authors: Aristotle Martin, Adam Krekorian

Description: This is a SystemVerilog implementation
of a Lattice Boltzmann method (LBM) solver for a 2D cavity
flow targeted at the Altera DE2-115 FPGA board. This system
employs Q8.24 fixed-point arithmetic.

LBM Details:
Grid: D2Q9
	-- 2 spatial dimensions (x,y)
	-- 9 discrete velocities (c0,c1,..c8)
	
BGK single-relaxation model

This was a project for the class COMPSCI 550 (Advanced Computer Architecture I) at Duke University.
