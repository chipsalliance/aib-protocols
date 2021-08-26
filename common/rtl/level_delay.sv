////////////////////////////////////////////////////////////
//Module:	level_delay
//Created:	Mar 19 2021
//Author:	John Archambeault
//
//Functional Descript:
//  This is a simple delay element that implements an 8 bit counter
// that waits for enable to go high to begin counting. Once it
// Reaches delay_value, it will set delayed_en high. If enable
// goes back low, the counter resets. The counter does a simple
// compare to delay_value, so changing delay_value on the fly can
// have unpredictable results. delay_value == 0 necessarily means
// the counter is unused and should be synthesized away (assuming
// delay_value is a constant).
//
// It is assumed enable is synchronized to clk_core.
//
////////////////////////////////////////////////////////////

module level_delay
   (/*AUTOARG*/
   //Outputs
   delayed_en,
   //Inputs
   clk_core, rst_core_n, enable, delay_value
   );

input           rst_core_n;
input           clk_core;
input           enable;
input [7:0]     delay_value;

output          delayed_en;

reg  [7:0]      count_reg;

always @(posedge clk_core or negedge rst_core_n)
if (!rst_core_n)
  count_reg <= 8'h0;
else if (~enable)
  count_reg <= 8'h0;
else if (count_reg != delay_value)
  count_reg <= (count_reg + 8'h1);

assign delayed_en = (delay_value == 8'h0) ? enable : (count_reg == delay_value) ;

endmodule // level_delay //

////////////////////////////////////////////////////////////
//Module:	level_delay
//$Id$
////////////////////////////////////////////////////////////

