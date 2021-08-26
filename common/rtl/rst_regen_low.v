module rst_regen_low
(
 clk,
 async_rst_n, rst_n
);

  input  clk;          // Clock
  input  async_rst_n;  // Asynchronous Reset Signal Input (active-low)
  output rst_n;         // Synchronized Reset Signal Output (active-low)

  levelsync
    #(
      .RESET_VALUE(1'b0)
     ) levelsync_i
     (
      .clk_dest   (clk),
      .rst_dest_n (async_rst_n),
      .src_data   (1'b1),
      .dest_data  (rst_n)
     );

endmodule // rst_regen_low
