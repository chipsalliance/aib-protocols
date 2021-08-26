////////////////////////////////////////////////////////////
//Module:	levelsync_sr
//Created:	Feb 03 2007
//Author:	johna
//$Id$
//$Date$
//$Source$
//$Revision$
//Functional Descript:
//  This seems like a trivial block, just two FF in a row.
// However, for timing checks / gate level sims, etc.,  it
// is _VERY_ advantageous to have all of these in a known local.
// like inside these blocks.
//
//  It is concieveable we may want to hardcode this, so that
// we can forcibly apply don't touches, etc.
//
// This block is the same as levelsync.v, except it has
// a set and a reset, with reset winning in a tie.
////////////////////////////////////////////////////////////

module levelsync_sr
   (/*AUTOARG*/ 
   //Outputs
   dest_data,
   //Inputs
   clk_dest, rst_dest_n, set_dest_n, src_data
   );

parameter RESET_VALUE = 1'b0;
parameter SET_VALUE   = 1'b1;

input   rst_dest_n;
input   set_dest_n;
input   clk_dest;
input   src_data;

output  dest_data;

reg             AsYnCiNpUt_ff0_reg;
reg             ff1_reg;

always @(posedge clk_dest or negedge rst_dest_n or negedge set_dest_n)
if (!rst_dest_n)
begin
  AsYnCiNpUt_ff0_reg <= RESET_VALUE;
  ff1_reg <= RESET_VALUE;
end
else if (!set_dest_n)
begin
  AsYnCiNpUt_ff0_reg <= SET_VALUE;
  ff1_reg <= SET_VALUE;
end
else
begin
  AsYnCiNpUt_ff0_reg <= src_data;
  ff1_reg <= AsYnCiNpUt_ff0_reg;
end

assign dest_data = ff1_reg;

// synopsys translate_off
`ifdef FIND_DFT_ASYNC
initial $display("ASYNC:levelsync_sr:%m");
`endif //FIND_DFT
// synopsys translate_on


endmodule // levelsync_sr //

////////////////////////////////////////////////////////////
//Module:	levelsync_sr
//$Id$
////////////////////////////////////////////////////////////

