module clk_gate (
input clkin,
input clken,
output gatedclk
);

logic clken_latched;

always_latch begin
 if (!clkin) begin
  clken_latched = clken;
 end
end

assign gatedclk = clkin & clken_latched;

endmodule
