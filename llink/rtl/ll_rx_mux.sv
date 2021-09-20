////////////////////////////////////////////////////////////
//
//        Copyright (C) 2021 Eximius Design
//                All Rights Reserved
//
// This entire notice must be reproduced on all copies of this file
// and copies of this file may only be made by a person if such person is
// permitted to do so under the terms of a subsisting license agreement
// from Eximius Design
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
//Functional Descript:
//
// This is effectivele a DEMUX functionality to either demux in a Strobe or Marker (PERSISTENT == 0)
// or to remove the PERSISTENT strobe route the data around the inserted Strobe or Marker (PERSISTENT == 1)
//
// The code will output each channel's strobe or marker which may be of interest in the system. This
// will exit as rx_userbit. If left disconnected, the rx_userbit logic should syntheize away.
//
// Note, this code assumes the widest channel wil be 320 bits wide.
// Everything is sized up to 320 and then only the lower most
// portion is used.
//
// Note if wd_sel and bit_sel are not fixed and are controlled by CSR, this will result in a
// very large MUX array. Flexibility comes at a cost.
//
////////////////////////////////////////////////////////////

module ll_rx_mux #(parameter PERSISTENT=0, parameter CH_WIDTH=80, parameter GEN2_LOC=0, parameter GEN1_LOC=0, parameter ENABLE=1) (

    // Data In / out
    input  logic [CH_WIDTH-1:0]                 data_in,
    output logic [CH_WIDTH-1:0]                 data_out,

    // Control signals
    output logic                                rx_userbit,
    input logic                                 m_gen2_mode            // Set to 1 to be in gen2 mode and use GEN2_LOC or else use GEN1_LOC
);

//////////////////////////////////////////////////////////////////////
// Upsize the vector to the max channel width vector for consistency
wire [319:0] max_wid_din;
wire [319:0] max_wid_dout;

wire [319:0] max_wid_bitfield_loc;

wire [319:0] max_wid_non_persist;

assign max_wid_din         = data_in | '0;

// This should generate a 1 hot, 320 bit wide vector
// where the persistent strobe/ marker should be extracted from.
assign max_wid_bitfield_loc = m_gen2_mode ? (320'h1 << GEN2_LOC) : (320'h1 << GEN1_LOC);

// Upsize the vector to the max channel width vector for consistency
//////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////
// Extract user bit
// This simply pulls out the user bit.

always_comb
begin
  rx_userbit = 0;
  for (integer index0=0; index0<320; index0=index0+1)
  begin
    if (max_wid_bitfield_loc[index0] == 1'b1)
    begin
      rx_userbit = max_wid_din[index0];
    end
  end
end

// Extract user bit
//////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////
// Calculate non-persist case (recoverable)

// This is trivial (non-persit is same as data in), but for symmetry with
// TX_MUX we'll calculate it.

// Put the data into a common max sized structure.
assign max_wid_non_persist = data_in | '0;

// Extract user bit
//////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////
// Calculate Persistent case (non-recoverable)

// This is a piece of logic that makes a lower mask and upper mask. If OR'd together, the two masks
// should have 1 blank bit in the middle, which is the Strobe/Marker.
// The lower mask is ANDed with the incomming data and that is the resulting data.
// The upper mask is ANDed with the incomming data and shifted down by 1 bit and that is the resulting data.

reg          found_loc;
reg [319:0]  max_wid_pers_mask_low;
reg [319:0]  max_wid_pers_mask_high;

wire [319:0] max_wid_pesist_lo;
wire [319:0] max_wid_pesist_hi;
wire [319:0] max_wid_persist;

always_comb
begin
  found_loc = 0;
  for (integer index0=0; index0<320; index0=index0+1)
  begin

    if (found_loc == 1'b0)
    begin
      found_loc = max_wid_bitfield_loc[index0];
    end

    if (max_wid_bitfield_loc[index0])
    begin // Skip Strobe/Marker Bit
      max_wid_pers_mask_low[index0]  = 1'b0;
      max_wid_pers_mask_high[index0] = 1'b0;
    end
    else if (found_loc)
    begin           // If above Strobe Bit, set high vector
      max_wid_pers_mask_low[index0]  = 1'b0;
      max_wid_pers_mask_high[index0] = 1'b1;
    end
    else
    begin                      // If below Strobe Bit, set low vector
      max_wid_pers_mask_low[index0]  = 1'b1;
      max_wid_pers_mask_high[index0] = 1'b0;
    end
  end
end

assign max_wid_pesist_lo  =  max_wid_pers_mask_low  & max_wid_din;
assign max_wid_pesist_hi  = (max_wid_pers_mask_high & max_wid_din) >> 1;

assign max_wid_persist  = max_wid_pesist_hi | max_wid_pesist_lo ;
// Calculate Persistent case (non-recoverable)
//////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////
// Selected between Persistent and Non Persistent and Resize

assign max_wid_dout = PERSISTENT ? max_wid_persist : max_wid_non_persist;

assign data_out = ENABLE ? max_wid_dout[CH_WIDTH-1:0] : data_in;

// Selected between Persistent and Non Persistent and Resize
//////////////////////////////////////////////////////////////////////


endmodule

