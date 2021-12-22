////////////////////////////////////////////////////////////
//
//        Copyright (C) 2021 Eximius Design
//
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
////////////////////////////////////////////////////////////

module p2p_lite (

  // Phy Clock... For Gen1 = 1GHz, for Gen2 = 2GHz
  input  logic         fwd_clk                  ,
  input  logic         ns_adapter_rstn                ,

  // Master Interface Clock (div by 1, 2 or 4 of fwd_clk)
  input  logic         m_wr_clk                 ,

  // Slave Interface Clock (div by 1, 2 or 4 of fwd_clk)
  input  logic         s_wr_clk                 ,

  // Transfer enable ... used for auto sync
  output logic         master_sl_tx_transfer_en ,
  output logic         master_ms_tx_transfer_en ,
  output logic         slave_sl_tx_transfer_en  ,
  output logic         slave_ms_tx_transfer_en  ,
  // We set the PHYs to max size, but only pieces may be used depending on config
  input  logic [319:0] m2s_data_in              ,
  output logic [319:0] s2m_data_out             ,

  input  logic [319:0] s2m_data_in              ,
  output logic [319:0] m2s_data_out             ,



  // Marker Location (needed for asymmetric only)
  input  logic [7:0]   tb_m2s_marker_loc           ,
  input  logic [7:0]   tb_s2m_marker_loc           ,

  // master / slave rate
  input  logic [3:0]   tb_master_rate              ,
  input  logic [3:0]   tb_slave_rate               ,

  // Gen2 or gen1 (if low)
  input  logic         m_gen2_mode                 ,

  // Latency in terms of s_wr_clk
  input  logic [7:0]   tb_m2s_latency              ,
  input  logic [7:0]   tb_s2m_latency              ,

  // Time after reset for the DLL to "sync" and assert Transfer En
  input  logic [7:0]   tb_master_rx_dll_time       ,
  input  logic [7:0]   tb_slave_rx_dll_time        ,

  // Enable asymmetric. If low, many other signals are unused
  input  logic         tb_en_asymmetric

);

parameter FULL          = 4'h1;
parameter HALF          = 4'h2;
parameter QUARTER       = 4'h4;


logic [31:0] ready_count;
logic begin_m2s=0;
logic begin_s2m=0;

always @(posedge fwd_clk or negedge ns_adapter_rstn)
if (!ns_adapter_rstn)
  ready_count <= 0;
else if (&ready_count != 1)
  ready_count <= ready_count + 1;

// Master RX Ready after S2M sends its data, through M2S Latency and then Master RX DLL completes
assign master_ms_tx_transfer_en = (ready_count > (tb_master_rx_dll_time + (tb_s2m_latency * tb_master_rate)));
// Slave is informed of Slave RX Tranfer Enable after transfer back to Slave
assign slave_ms_tx_transfer_en  = (ready_count > (tb_master_rx_dll_time + (tb_s2m_latency * tb_master_rate) + (tb_m2s_latency * tb_slave_rate)));

// Slave RX Ready after M2S sends its data, through M2S Latency and then Slave RX DLL completes
assign slave_sl_tx_transfer_en  = (ready_count > (tb_slave_rx_dll_time + (tb_m2s_latency * tb_slave_rate) ));
// Master is informed of Slave RX Tranfer Enable after transfer back to Master
assign master_sl_tx_transfer_en = (ready_count > (tb_slave_rx_dll_time + (tb_m2s_latency * tb_slave_rate) + (tb_s2m_latency * tb_master_rate)));


logic [319:0] m2s_phy_delay_array [$];
logic [319:0] s2m_phy_delay_array [$];

// initial
// begin
//   #1;
//   repeat (tb_m2s_latency*tb_master_rate) m2s_phy_delay_array.push_back ( '0 ) ;
//   repeat (tb_s2m_latency*tb_slave_rate)  s2m_phy_delay_array.push_back ( '0 ) ;
// end
//



logic [319:0] m2s_data_filter_in ;
logic [319:0] s2m_data_filter_in ;

always_comb
if (m_gen2_mode)
  case (tb_master_rate)
    FULL    : m2s_data_filter_in = m2s_data_in[79:0]  | 320'h0;
    HALF    : m2s_data_filter_in = m2s_data_in[159:0] | 320'h0;
    QUARTER : m2s_data_filter_in = m2s_data_in[319:0] | 320'h0;
  endcase
else
  case (tb_master_rate)
    FULL    : m2s_data_filter_in = m2s_data_in[39:0]  | 320'h0;
    HALF    : m2s_data_filter_in = m2s_data_in[79:0]  | 320'h0;
  endcase

always_comb
if (m_gen2_mode)
  case (tb_slave_rate)
    FULL    : s2m_data_filter_in = s2m_data_in[79:0]  | 320'h0;
    HALF    : s2m_data_filter_in = s2m_data_in[159:0] | 320'h0;
    QUARTER : s2m_data_filter_in = s2m_data_in[319:0] | 320'h0;
  endcase
else
  case (tb_slave_rate)
    FULL    : s2m_data_filter_in = s2m_data_in[39:0]  | 320'h0;
    HALF    : s2m_data_filter_in = s2m_data_in[79:0]  | 320'h0;
  endcase






event m2s_tx;
event m2s_tx_f2f_gen2;
event m2s_tx_f2h_gen2;
event m2s_tx_f2q_gen2;
event m2s_tx_h2f_0_gen2;
event m2s_tx_h2f_1_gen2;
event m2s_tx_h2h_gen2;
event m2s_tx_h2q_gen2;
event m2s_tx_q2f_0_gen2;
event m2s_tx_q2f_1_gen2;
event m2s_tx_q2f_2_gen2;
event m2s_tx_q2f_3_gen2;
event m2s_tx_q2h_0_gen2;
event m2s_tx_q2h_1_gen2;
event m2s_tx_q2q_gen2;
event m2s_tx_f2f_gen1;
event m2s_tx_f2h_gen1;
event m2s_tx_h2f_0_gen1;
event m2s_tx_h2f_1_gen1;
event m2s_tx_h2h_gen1;
event m2s_rx;

// Master to Slave AIB "PHY"
reg [319:0] m2s_buffer_phy0=0;
reg [3:0]   m2s_marker_state=0; // This keeps previous marker state (so marker can stop)

reg [4:0] m2s_marker_check_count;
wire      update_m2s_marker;

always @(posedge m_wr_clk or negedge ns_adapter_rstn)
if (!ns_adapter_rstn)
  m2s_marker_check_count <= 5'h0f;
else if ((m2s_marker_state != 0) && (m2s_marker_check_count != 0))
  m2s_marker_check_count <= m2s_marker_check_count - 1;

assign update_m2s_marker = (m2s_marker_check_count != 0);













always @(posedge m_wr_clk & ns_adapter_rstn)
begin
  if (tb_en_asymmetric == 1'b0)
  begin
     m2s_phy_delay_array.push_back ( m2s_data_filter_in ) ;
     ->m2s_tx;
  end
  else if (m_gen2_mode)
  begin
    // F2F
    if ((tb_master_rate == FULL) && (tb_slave_rate == FULL))
    begin
      m2s_buffer_phy0[(80*0)+:80] = m2s_data_filter_in;

      if (update_m2s_marker ? m2s_buffer_phy0[(80*0)+tb_m2s_marker_loc] : m2s_marker_state[3])
      begin
        m2s_phy_delay_array.push_back ( m2s_buffer_phy0 [(80*0)+:80] ) ;
        if (update_m2s_marker) m2s_marker_state[3:0] = m2s_marker_state[3:0] | 4'b1000;
        ->m2s_tx;
        -> m2s_tx_f2f_gen2;
      end
    end

    // F2H
    else if ((tb_master_rate == FULL) && (tb_slave_rate == HALF))
    begin
      m2s_buffer_phy0[(80*0)+:80] = m2s_buffer_phy0[(80*1)+:80];
      m2s_buffer_phy0[(80*1)+:80] = m2s_data_filter_in;

      if (update_m2s_marker ? m2s_buffer_phy0[(80*1)+tb_m2s_marker_loc] : m2s_marker_state[1])
      begin
        m2s_phy_delay_array.push_back ( m2s_buffer_phy0 [(80*0)+:160]) ;
        if (update_m2s_marker) m2s_marker_state[3:0] = m2s_marker_state[3:0] | 4'b0010;
        ->m2s_tx;
        -> m2s_tx_f2h_gen2;
      end
    end

    // F2Q
    else if ((tb_master_rate == FULL) && (tb_slave_rate == QUARTER))
    begin
      m2s_buffer_phy0[(80*0)+:80] = m2s_buffer_phy0[(80*1)+:80];
      m2s_buffer_phy0[(80*1)+:80] = m2s_buffer_phy0[(80*2)+:80];
      m2s_buffer_phy0[(80*2)+:80] = m2s_buffer_phy0[(80*3)+:80];
      m2s_buffer_phy0[(80*3)+:80] = m2s_data_filter_in;

      if (update_m2s_marker ? m2s_buffer_phy0[(80*3)+tb_m2s_marker_loc] : m2s_marker_state[3])
      begin
        m2s_phy_delay_array.push_back ( m2s_buffer_phy0 [(80*0)+:320]) ;
        if (update_m2s_marker) m2s_marker_state[3:0] = m2s_marker_state[3:0] | 4'b1000;
        ->m2s_tx;
        -> m2s_tx_f2q_gen2;
      end
    end


    // H2F
    else if ((tb_master_rate == HALF) && (tb_slave_rate == FULL))
    begin
      m2s_buffer_phy0[(80*0)+:160] = m2s_data_filter_in;

      if (update_m2s_marker ? m2s_buffer_phy0[(80*0)+tb_m2s_marker_loc] : m2s_marker_state[0])
      begin
        m2s_phy_delay_array.push_back ( m2s_buffer_phy0 [(80*0)+:80]) ;
        if (update_m2s_marker) m2s_marker_state[3:0] = m2s_marker_state[3:0] | 4'b0001;
        ->m2s_tx;
        -> m2s_tx_h2f_0_gen2;
      end

      if (update_m2s_marker ? m2s_buffer_phy0[(80*1)+tb_m2s_marker_loc] : m2s_marker_state[1])
      begin
        m2s_phy_delay_array.push_back ( m2s_buffer_phy0 [(80*1)+:80]) ;
        if (update_m2s_marker) m2s_marker_state[3:0] = m2s_marker_state[3:0] | 4'b0010;
        ->m2s_tx;
        -> m2s_tx_h2f_1_gen2;
      end
    end

    // H2H
    else if ((tb_master_rate == HALF) && (tb_slave_rate == HALF))
    begin
      m2s_buffer_phy0[(80*0)+:160] = m2s_data_filter_in;

      // We'll cheat and use Channel0's Markers for all Channels.
      if (update_m2s_marker ? m2s_buffer_phy0[(80*1)+tb_m2s_marker_loc] : m2s_marker_state[3])
      begin
        m2s_phy_delay_array.push_back ( m2s_buffer_phy0 [(80*0)+:160]) ;
        if (update_m2s_marker) m2s_marker_state[3:0] = m2s_marker_state[3:0] | 4'b1000;
        ->m2s_tx;
        -> m2s_tx_h2h_gen2;
      end
    end

    // H2Q
    else if ((tb_master_rate == HALF) && (tb_slave_rate == QUARTER))
    begin
      m2s_buffer_phy0[(80*0)+:160] = m2s_buffer_phy0[(80*2)+:160];
      m2s_buffer_phy0[(80*2)+:160] = m2s_data_filter_in;

      // We'll cheat and use Channel0's Markers for all Channels.
      if (update_m2s_marker ? m2s_buffer_phy0[(80*3)+tb_m2s_marker_loc] : m2s_marker_state[3])
      begin
        m2s_phy_delay_array.push_back ( m2s_buffer_phy0 [(80*0)+:320]) ;
        if (update_m2s_marker) m2s_marker_state[3:0] = m2s_marker_state[3:0] | 4'b1000;
        ->m2s_tx;
        -> m2s_tx_h2q_gen2;
      end
    end


    // Q2F
    else if ((tb_master_rate == QUARTER) && (tb_slave_rate == FULL))
    begin
      m2s_buffer_phy0[(80*0)+:320] = m2s_data_filter_in;

      if (update_m2s_marker ? m2s_buffer_phy0[(80*0)+tb_m2s_marker_loc] : m2s_marker_state[0])
      begin
        m2s_phy_delay_array.push_back ( m2s_buffer_phy0[(80*0)+:80] ) ;
        if (update_m2s_marker) m2s_marker_state = m2s_marker_state | 4'b0001;
        ->m2s_tx;
        -> m2s_tx_q2f_0_gen2;
      end

      if (update_m2s_marker ? m2s_buffer_phy0[(80*1)+tb_m2s_marker_loc] : m2s_marker_state[1])
      begin
        m2s_phy_delay_array.push_back ( m2s_buffer_phy0[(80*1)+:80] ) ;
        if (update_m2s_marker) m2s_marker_state = m2s_marker_state | 4'b0010;
        ->m2s_tx;
        -> m2s_tx_q2f_1_gen2;
      end

      if (update_m2s_marker ? m2s_buffer_phy0[(80*2)+tb_m2s_marker_loc] : m2s_marker_state[2])
      begin
        m2s_phy_delay_array.push_back ( m2s_buffer_phy0[(80*2)+:80] ) ;
        if (update_m2s_marker) m2s_marker_state = m2s_marker_state | 4'b0100;
        ->m2s_tx;
        -> m2s_tx_q2f_2_gen2;
      end

      if (update_m2s_marker ? m2s_buffer_phy0[(80*3)+tb_m2s_marker_loc] : m2s_marker_state[3])
      begin
        m2s_phy_delay_array.push_back ( m2s_buffer_phy0[(80*3)+:80] ) ;
        if (update_m2s_marker) m2s_marker_state = m2s_marker_state | 4'b1000;
        ->m2s_tx;
        -> m2s_tx_q2f_3_gen2;
      end
    end

    // Q2H
    else if ((tb_master_rate == QUARTER) && (tb_slave_rate == HALF))
    begin
      m2s_buffer_phy0[(80*0)+:320] = m2s_data_filter_in;

      if (update_m2s_marker ? m2s_buffer_phy0[(80*1)+tb_m2s_marker_loc] : m2s_marker_state[1])
      begin
        m2s_phy_delay_array.push_back ( m2s_buffer_phy0[(80*0)+:160] ) ;
        if (update_m2s_marker) m2s_marker_state = m2s_marker_state | 4'b0010;
        ->m2s_tx;
        -> m2s_tx_q2h_0_gen2;
      end

      if (update_m2s_marker ? m2s_buffer_phy0[(80*3)+tb_m2s_marker_loc] : m2s_marker_state[3])
      begin
        m2s_phy_delay_array.push_back ( m2s_buffer_phy0[(80*2)+:160] ) ;
        if (update_m2s_marker) m2s_marker_state = m2s_marker_state | 4'b1000;
        ->m2s_tx;
        -> m2s_tx_q2h_1_gen2;
      end
    end

    // Q2Q
    else if ((tb_master_rate == QUARTER) && (tb_slave_rate == QUARTER))
    begin
      m2s_buffer_phy0[(80*0)+:320] = m2s_data_filter_in;

      if (update_m2s_marker ? m2s_buffer_phy0[(80*3)+tb_m2s_marker_loc] : m2s_marker_state[3])
      begin
        m2s_phy_delay_array.push_back ( m2s_buffer_phy0[(80*0)+:320] ) ;
        if (update_m2s_marker) m2s_marker_state = m2s_marker_state | 4'b1000;
        ->m2s_tx;
        -> m2s_tx_q2q_gen2;
      end
    end

    else
    begin
        $display ("ERROR: Unsupported rates %m.  tb_master_rate=%d  tb_slave_rate=%d", tb_master_rate, tb_slave_rate);
    end
    m2s_marker_state[3:0] = {m2s_marker_state[2:0], m2s_marker_state[3]};
  end
  else if (m_gen2_mode == 0) // GEN1
  begin
    // F2F
    if ((tb_master_rate == FULL) && (tb_slave_rate == FULL))
    begin
      m2s_buffer_phy0[(40*0)+:40] = m2s_data_filter_in;

      if (update_m2s_marker ? m2s_buffer_phy0[(40*0)+tb_m2s_marker_loc] : m2s_marker_state[3])
      begin
        m2s_phy_delay_array.push_back ( m2s_buffer_phy0 [(40*0)+:40] ) ;
        if (update_m2s_marker) m2s_marker_state[3:0] = m2s_marker_state[3:0] | 4'b1000;
        ->m2s_tx;
        -> m2s_tx_f2f_gen1;
      end
    end

    // F2H
    else if ((tb_master_rate == FULL) && (tb_slave_rate == HALF))
    begin
      m2s_buffer_phy0[(40*0)+:40] = m2s_buffer_phy0[(40*1)+:40];
      m2s_buffer_phy0[(40*1)+:40] = m2s_data_filter_in;

      if (update_m2s_marker ? m2s_buffer_phy0[(40*1)+tb_m2s_marker_loc] : m2s_marker_state[1])
      begin
        m2s_phy_delay_array.push_back ( m2s_buffer_phy0 [(40*0)+:80]) ;
        if (update_m2s_marker) m2s_marker_state[3:0] = m2s_marker_state[3:0] | 4'b0010;
        ->m2s_tx;
        -> m2s_tx_f2h_gen1;
      end
    end


    // H2F
    else if ((tb_master_rate == HALF) && (tb_slave_rate == FULL))
    begin
      m2s_buffer_phy0[(40*0)+:80] = m2s_data_filter_in;

      if (update_m2s_marker ? m2s_buffer_phy0[(40*0)+tb_m2s_marker_loc] : m2s_marker_state[0])
      begin
        m2s_phy_delay_array.push_back ( m2s_buffer_phy0 [(40*0)+:40]) ;
        if (update_m2s_marker) m2s_marker_state[3:0] = m2s_marker_state[3:0] | 4'b0001;
        ->m2s_tx;
        -> m2s_tx_h2f_0_gen1;
      end

      if (update_m2s_marker ? m2s_buffer_phy0[(40*1)+tb_m2s_marker_loc] : m2s_marker_state[1])
      begin
        m2s_phy_delay_array.push_back ( m2s_buffer_phy0 [(40*1)+:40]) ;
        if (update_m2s_marker) m2s_marker_state[3:0] = m2s_marker_state[3:0] | 4'b0010;
        ->m2s_tx;
        -> m2s_tx_h2f_1_gen1;
      end
    end

    // H2H
    else if ((tb_master_rate == HALF) && (tb_slave_rate == HALF))
    begin
      m2s_buffer_phy0[(40*0)+:160] = m2s_data_filter_in;

      // We'll cheat and use Channel0's Markers for all Channels.
      if (update_m2s_marker ? m2s_buffer_phy0[(40*1)+tb_m2s_marker_loc] : m2s_marker_state[3])
      begin
        m2s_phy_delay_array.push_back ( m2s_buffer_phy0 [(40*0)+:80]) ;
        if (update_m2s_marker) m2s_marker_state[3:0] = m2s_marker_state[3:0] | 4'b1000;
        ->m2s_tx;
        -> m2s_tx_h2h_gen1;
      end
    end


    else
    begin
        $display ("ERROR: Unsupported rates %m.  tb_master_rate=%d  tb_slave_rate=%d", tb_master_rate, tb_slave_rate);
    end
    m2s_marker_state[3:0] = {m2s_marker_state[2:0], m2s_marker_state[3]};
  end
end

initial
begin
  begin_m2s = 0;
  wait (m2s_phy_delay_array.size() > tb_m2s_latency);
  begin_m2s = 1;
end

always @(posedge s_wr_clk & ns_adapter_rstn)
if (m2s_phy_delay_array.size() && begin_m2s)
begin
  m2s_data_out <= m2s_phy_delay_array.pop_front() ;

  ->m2s_rx;
end


// always @(posedge s_wr_clk & ns_adapter_rstn)
//   $display (" %m slave m2s_phy_delay_array.size = %d", m2s_phy_delay_array.size());
//
// always @(posedge m_wr_clk & ns_adapter_rstn)
//   $display (" %m master m2s_phy_delay_array.size = %d", m2s_phy_delay_array.size());
//
//
// always @(posedge m_wr_clk & ns_adapter_rstn)
//   $display (" %m slave s2m_phy_delay_array.size = %d", s2m_phy_delay_array.size());
//
// always @(posedge s_wr_clk & ns_adapter_rstn)
//   $display (" %m master s2m_phy_delay_array.size = %d", s2m_phy_delay_array.size());



event s2m_tx;
event s2m_tx_f2f_gen2;
event s2m_tx_f2h_gen2;
event s2m_tx_f2q_gen2;
event s2m_tx_h2f_0_gen2;
event s2m_tx_h2f_1_gen2;
event s2m_tx_h2h_gen2;
event s2m_tx_h2q_gen2;
event s2m_tx_q2f_0_gen2;
event s2m_tx_q2f_1_gen2;
event s2m_tx_q2f_2_gen2;
event s2m_tx_q2f_3_gen2;
event s2m_tx_q2h_0_gen2;
event s2m_tx_q2h_1_gen2;
event s2m_tx_q2q_gen2;
event s2m_tx_f2f_gen1;
event s2m_tx_f2h_gen1;
event s2m_tx_h2f_0_gen1;
event s2m_tx_h2f_1_gen1;
event s2m_tx_h2h_gen1;
event s2m_rx;

reg [319:0] s2m_buffer_phy0=0;
reg [3:0]   s2m_marker_state=0;

reg [4:0] s2m_marker_check_count;
wire      update_s2m_marker;

always @(posedge s_wr_clk or negedge ns_adapter_rstn)
if (!ns_adapter_rstn)
  s2m_marker_check_count <= 5'h1f;
else if ((s2m_marker_state != 0) && (s2m_marker_check_count != 0))
  s2m_marker_check_count <= s2m_marker_check_count - 1;

assign update_s2m_marker = (s2m_marker_check_count != 0);


always @(posedge s_wr_clk & ns_adapter_rstn)
begin
  if (tb_en_asymmetric == 1'b0)
  begin
     s2m_phy_delay_array.push_back ( s2m_data_filter_in ) ;
     ->s2m_tx;
  end
  else if (m_gen2_mode)
  begin
    // F2F
    if ((tb_slave_rate == FULL) && (tb_master_rate == FULL))
    begin
      s2m_buffer_phy0[(80*0)+:80] = s2m_data_filter_in;

      if (update_s2m_marker ? s2m_buffer_phy0[(80*0)+tb_s2m_marker_loc] : s2m_marker_state[3])
      begin
        s2m_phy_delay_array.push_back ( s2m_buffer_phy0 [(80*0)+:80] ) ;
        if (update_s2m_marker) s2m_marker_state[3:0] = s2m_marker_state[3:0] | 4'b1000;
        ->s2m_tx;
        -> s2m_tx_f2f_gen2;
      end
    end

    // F2H
    else if ((tb_slave_rate == FULL) && (tb_master_rate == HALF))
    begin
      s2m_buffer_phy0[(80*0)+:80] = s2m_buffer_phy0[(80*1)+:80];
      s2m_buffer_phy0[(80*1)+:80] = s2m_data_filter_in;

      if (update_s2m_marker ? s2m_buffer_phy0[(80*1)+tb_s2m_marker_loc] : s2m_marker_state[1])
      begin
        s2m_phy_delay_array.push_back ( s2m_buffer_phy0 [(80*0)+:160]) ;
        if (update_s2m_marker) s2m_marker_state[3:0] = s2m_marker_state[3:0] | 4'b0010;
        ->s2m_tx;
        -> s2m_tx_f2h_gen2;
      end
    end

    // F2Q
    else if ((tb_slave_rate == FULL) && (tb_master_rate == QUARTER))
    begin
      s2m_buffer_phy0[(80*0)+:80] = s2m_buffer_phy0[(80*1)+:80];
      s2m_buffer_phy0[(80*1)+:80] = s2m_buffer_phy0[(80*2)+:80];
      s2m_buffer_phy0[(80*2)+:80] = s2m_buffer_phy0[(80*3)+:80];
      s2m_buffer_phy0[(80*3)+:80] = s2m_data_filter_in;

      if (update_s2m_marker ? s2m_buffer_phy0[(80*3)+tb_s2m_marker_loc] : s2m_marker_state[3])
      begin
        s2m_phy_delay_array.push_back ( s2m_buffer_phy0 [(80*0)+:320]) ;
        if (update_s2m_marker) s2m_marker_state[3:0] = s2m_marker_state[3:0] | 4'b1000;
        ->s2m_tx;
        -> s2m_tx_f2q_gen2;
      end
    end


    // H2F
    else if ((tb_slave_rate == HALF) && (tb_master_rate == FULL))
    begin
      s2m_buffer_phy0[(80*0)+:160] = s2m_data_filter_in;

      if (update_s2m_marker ? s2m_buffer_phy0[(80*0)+tb_s2m_marker_loc] : s2m_marker_state[0])
      begin
        s2m_phy_delay_array.push_back ( s2m_buffer_phy0 [(80*0)+:80]) ;
        if (update_s2m_marker) s2m_marker_state[3:0] = s2m_marker_state[3:0] | 4'b0001;
        ->s2m_tx;
        -> s2m_tx_h2f_0_gen2;
      end

      if (update_s2m_marker ? s2m_buffer_phy0[(80*1)+tb_s2m_marker_loc] : s2m_marker_state[1])
      begin
        s2m_phy_delay_array.push_back ( s2m_buffer_phy0 [(80*1)+:80]) ;
        if (update_s2m_marker) s2m_marker_state[3:0] = s2m_marker_state[3:0] | 4'b0010;
        ->s2m_tx;
        -> s2m_tx_h2f_1_gen2;
      end
    end

    // H2H
    else if ((tb_slave_rate == HALF) && (tb_master_rate == HALF))
    begin
      s2m_buffer_phy0[(80*0)+:160] = s2m_data_filter_in;

      // We'll cheat and use Channel0's Markers for all Channels.
      if (update_s2m_marker ? s2m_buffer_phy0[(80*1)+tb_s2m_marker_loc] : s2m_marker_state[3])
      begin
        s2m_phy_delay_array.push_back ( s2m_buffer_phy0 [(80*0)+:160]) ;
        if (update_s2m_marker) s2m_marker_state[3:0] = s2m_marker_state[3:0] | 4'b1000;
        ->s2m_tx;
        -> s2m_tx_h2h_gen2;
      end
    end

    // H2Q
    else if ((tb_slave_rate == HALF) && (tb_master_rate == QUARTER))
    begin
      s2m_buffer_phy0[(80*0)+:160] = s2m_buffer_phy0[(80*2)+:160];
      s2m_buffer_phy0[(80*2)+:160] = s2m_data_filter_in;

      // We'll cheat and use Channel0's Markers for all Channels.
      if (update_s2m_marker ? s2m_buffer_phy0[(80*3)+tb_s2m_marker_loc] : s2m_marker_state[3])
      begin
        s2m_phy_delay_array.push_back ( s2m_buffer_phy0 [(80*0)+:320]) ;
        if (update_s2m_marker) s2m_marker_state[3:0] = s2m_marker_state[3:0] | 4'b1000;
        ->s2m_tx;
        -> s2m_tx_h2q_gen2;
      end
    end


    // Q2F
    else if ((tb_slave_rate == QUARTER) && (tb_master_rate == FULL))
    begin
      s2m_buffer_phy0[(80*0)+:320] = s2m_data_filter_in;

      if (update_s2m_marker ? s2m_buffer_phy0[(80*0)+tb_s2m_marker_loc] : s2m_marker_state[0])
      begin
        s2m_phy_delay_array.push_back ( s2m_buffer_phy0[(80*0)+:80] ) ;
        s2m_marker_state = s2m_marker_state | 4'b0001;
        ->s2m_tx;
        -> s2m_tx_q2f_0_gen2;
      end

      if (update_s2m_marker ? s2m_buffer_phy0[(80*1)+tb_s2m_marker_loc] : s2m_marker_state[1])
      begin
        s2m_phy_delay_array.push_back ( s2m_buffer_phy0[(80*1)+:80] ) ;
        s2m_marker_state = s2m_marker_state | 4'b0010;
        ->s2m_tx;
        -> s2m_tx_q2f_1_gen2;
      end

      if (update_s2m_marker ? s2m_buffer_phy0[(80*2)+tb_s2m_marker_loc] : s2m_marker_state[2])
      begin
        s2m_phy_delay_array.push_back ( s2m_buffer_phy0[(80*2)+:80] ) ;
        s2m_marker_state = s2m_marker_state | 4'b0100;
        ->s2m_tx;
        -> s2m_tx_q2f_2_gen2;
      end

      if (update_s2m_marker ? s2m_buffer_phy0[(80*3)+tb_s2m_marker_loc] : s2m_marker_state[3])
      begin
        s2m_phy_delay_array.push_back ( s2m_buffer_phy0[(80*3)+:80] ) ;
        s2m_marker_state = s2m_marker_state | 4'b1000;
        ->s2m_tx;
        -> s2m_tx_q2f_3_gen2;
      end
    end

    // Q2H
    else if ((tb_slave_rate == QUARTER) && (tb_master_rate == HALF))
    begin
      s2m_buffer_phy0[(80*0)+:320] = s2m_data_filter_in;

      if (update_s2m_marker ? s2m_buffer_phy0[(80*1)+tb_s2m_marker_loc] : s2m_marker_state[1])
      begin
        s2m_phy_delay_array.push_back ( s2m_buffer_phy0[(80*0)+:160] ) ;
        s2m_marker_state = s2m_marker_state | 4'b0010;
        ->s2m_tx;
        -> s2m_tx_q2h_0_gen2;
      end

      if (update_s2m_marker ? s2m_buffer_phy0[(80*3)+tb_s2m_marker_loc] : s2m_marker_state[3])
      begin
        s2m_phy_delay_array.push_back ( s2m_buffer_phy0[(80*2)+:160] ) ;
        s2m_marker_state = s2m_marker_state | 4'b1000;
        ->s2m_tx;
        -> s2m_tx_q2h_1_gen2;
      end
    end

    // Q2Q
    else if ((tb_slave_rate == QUARTER) && (tb_master_rate == QUARTER))
    begin
      s2m_buffer_phy0[(80*0)+:320] = s2m_data_filter_in;

      if (update_s2m_marker ? s2m_buffer_phy0[(80*3)+tb_s2m_marker_loc] : s2m_marker_state[3])
      begin
        s2m_phy_delay_array.push_back ( s2m_buffer_phy0[(80*0)+:320] ) ;
        s2m_marker_state = s2m_marker_state | 4'b1000;
        ->s2m_tx;
        -> s2m_tx_q2q_gen2;
      end
    end

    else
    begin
        $display ("ERROR: Unsupported rates %m.  tb_slave_rate=%d  tb_master_rate=%d", tb_slave_rate, tb_master_rate);
    end
    s2m_marker_state[3:0] = {s2m_marker_state[2:0], s2m_marker_state[3]};
  end
  else if (m_gen2_mode == 0) // GEN1
  begin
    // F2F
    if ((tb_slave_rate == FULL) && (tb_master_rate == FULL))
    begin
      s2m_buffer_phy0[(40*0)+:40] = s2m_data_filter_in;

      if (update_s2m_marker ? s2m_buffer_phy0[(40*0)+tb_s2m_marker_loc] : s2m_marker_state[3])
      begin
        s2m_phy_delay_array.push_back ( s2m_buffer_phy0 [(40*0)+:40] ) ;
        if (update_s2m_marker) s2m_marker_state[3:0] = s2m_marker_state[3:0] | 4'b1000;
        ->s2m_tx;
        -> s2m_tx_f2f_gen1;
      end
    end

    // F2H
    else if ((tb_slave_rate == FULL) && (tb_master_rate == HALF))
    begin
      s2m_buffer_phy0[(40*0)+:40] = s2m_buffer_phy0[(40*1)+:40];
      s2m_buffer_phy0[(40*1)+:40] = s2m_data_filter_in;

      if (update_s2m_marker ? s2m_buffer_phy0[(40*1)+tb_s2m_marker_loc] : s2m_marker_state[1])
      begin
        s2m_phy_delay_array.push_back ( s2m_buffer_phy0 [(40*0)+:160]) ;
        if (update_s2m_marker) s2m_marker_state[3:0] = s2m_marker_state[3:0] | 4'b0010;
        ->s2m_tx;
        -> s2m_tx_f2h_gen1;
      end
    end


    // H2F
    else if ((tb_slave_rate == HALF) && (tb_master_rate == FULL))
    begin
      s2m_buffer_phy0[(40*0)+:80] = s2m_data_filter_in;

      if (update_s2m_marker ? s2m_buffer_phy0[(40*0)+tb_s2m_marker_loc] : s2m_marker_state[0])
      begin
        s2m_phy_delay_array.push_back ( s2m_buffer_phy0 [(40*0)+:40]) ;
        if (update_s2m_marker) s2m_marker_state[3:0] = s2m_marker_state[3:0] | 4'b0001;
        ->s2m_tx;
        -> s2m_tx_h2f_0_gen1;
      end

      if (update_s2m_marker ? s2m_buffer_phy0[(40*1)+tb_s2m_marker_loc] : s2m_marker_state[1])
      begin
        s2m_phy_delay_array.push_back ( s2m_buffer_phy0 [(40*1)+:40]) ;
        if (update_s2m_marker) s2m_marker_state[3:0] = s2m_marker_state[3:0] | 4'b0010;
        ->s2m_tx;
        -> s2m_tx_h2f_1_gen1;
      end
    end

    // H2H
    else if ((tb_slave_rate == HALF) && (tb_master_rate == HALF))
    begin
      s2m_buffer_phy0[(40*0)+:160] = s2m_data_filter_in;

      // We'll cheat and use Channel0's Markers for all Channels.
      if (update_s2m_marker ? s2m_buffer_phy0[(40*1)+tb_s2m_marker_loc] : s2m_marker_state[3])
      begin
        s2m_phy_delay_array.push_back ( s2m_buffer_phy0 [(40*0)+:160]) ;
        if (update_s2m_marker) s2m_marker_state[3:0] = s2m_marker_state[3:0] | 4'b1000;
        ->s2m_tx;
        -> s2m_tx_h2h_gen1;
      end
    end


    else
    begin
        $display ("ERROR: Unsupported rates %m.  tb_slave_rate=%d  tb_master_rate=%d", tb_slave_rate, tb_master_rate);
    end
    s2m_marker_state[3:0] = {s2m_marker_state[2:0], s2m_marker_state[3]};
  end
end


initial
begin
  begin_s2m = 0;
  wait (s2m_phy_delay_array.size() > tb_s2m_latency);
  begin_s2m = 1;
end

always @(posedge m_wr_clk & ns_adapter_rstn)
if (s2m_phy_delay_array.size() && begin_s2m)
begin
  s2m_data_out <= s2m_phy_delay_array.pop_front() ;
  ->s2m_rx;
end







endmodule
