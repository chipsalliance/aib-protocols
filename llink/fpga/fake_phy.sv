module fake_phy (
  input logic clk_wr,

  input logic [79:0]    tx_phy_master_0,
  input logic [79:0]    tx_phy_master_1,
  input logic [79:0]    tx_phy_master_2,
  input logic [79:0]    tx_phy_master_3,
  input logic [79:0]    tx_phy_slave_0,
  input logic [79:0]    tx_phy_slave_1,
  input logic [79:0]    tx_phy_slave_2,
  input logic [79:0]    tx_phy_slave_3,

  output logic [79:0]   rx_phy_slave_0,
  output logic [79:0]   rx_phy_slave_1,
  output logic [79:0]   rx_phy_slave_2,
  output logic [79:0]   rx_phy_slave_3,
  output logic [79:0]   rx_phy_master_0,
  output logic [79:0]   rx_phy_master_1,
  output logic [79:0]   rx_phy_master_2,
  output logic [79:0]   rx_phy_master_3
  );


always @(posedge clk_wr)
begin
  rx_phy_slave_0  <= tx_phy_master_0 ;
  rx_phy_slave_1  <= tx_phy_master_1 ;
  rx_phy_slave_2  <= tx_phy_master_2 ;
  rx_phy_slave_3  <= tx_phy_master_3 ;
  rx_phy_master_0 <= tx_phy_slave_0  ;
  rx_phy_master_1 <= tx_phy_slave_1  ;
  rx_phy_master_2 <= tx_phy_slave_2  ;
  rx_phy_master_3 <= tx_phy_slave_3  ;

end

endmodule
