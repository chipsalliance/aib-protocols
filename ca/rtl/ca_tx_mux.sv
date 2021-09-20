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
// Functional Descript:
//
// MUX functionality to either mux in a Strobe or Marker (PERSISTENT == 0)
// or to route the data around the inserted Strobe or Marker (PERSISTENT == 1)
//
// Note, this code assumes the widest channel wil be 320 bits wide.
// Everything is sized up to 320 and then only the lower most
// portion is used.
//
// Note if wd_sel and bit_sel are not fixed and are controlled by CSR, this will result in a
// very large MUX array. Flexibility comes at a cost.
//
////////////////////////////////////////////////////////////

module ca_tx_mux #(parameter PERSISTENT=0, parameter CH_WIDTH=80, parameter ENABLE=1) (

    // Data In / out
    input logic [CH_WIDTH-1:0]  data_in,
    output logic [CH_WIDTH-1:0] data_out,

    // Control signals
    input logic                 online, // Set to 1 to disable non-persistent strobe/markers
    input logic                 m_gen2_mode, // Set to 1 to be in gen2 mode and use gen2_loc or else use gen1_loc
    input logic [8:0]           gen1_loc,
    input logic [8:0]           gen2_loc,

    // Control signals
    input logic                 tx_userbit
);


//////////////////////////////////////////////////////////////////////
// Upsize the vector to the max channel width vector for consistency
wire [319:0] max_wid_din;
wire [319:0] max_wid_dout;

wire [319:0] max_wid_bitfield_loc;
wire [319:0] max_wid_user_data;

// Put the data into a common max sized structure.
// This should result in a 320 bit vector.
assign max_wid_din = data_in | '0;

// This should generate a 1 hot, 320 bit wide vector
// where the persistent strobe/ marker should go.
assign max_wid_bitfield_loc = m_gen2_mode ? (320'h1 << gen2_loc) : (320'h1 << gen1_loc);

// This should be be all zeros except for USER bit.
assign max_wid_user_data     = max_wid_bitfield_loc & {320{tx_userbit}};

// Upsize the vector to the max channel width vector for consistency
//////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////
// Calculate Non Persistent (i.e. Recoverable) Insertion
wire [319:0] max_wid_non_persist;

// This looks like effectively 320 2-input muxes. But since gen2_loc
// should be constants, this should synthesize down to exactly one or TWO muxes depending on gen1/gen2_loc.
assign max_wid_non_persist  = online ? max_wid_din : (max_wid_user_data | ((~max_wid_bitfield_loc) & max_wid_din)) ;

// Calculate Non Persistent (i.e. Recoverable) Insertion
//////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////
// Calculate Persistent (i.e. non-Recoverable) Insertion

// This is a piece of logic that makes a lower mask and upper mask for the data in on either side of the strobe bit
// the resulting vector is the anded with the data. The lower portion stays in "place" the upper portion is shifted up
// one bit. The USER bit goes inbetween
//
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
    // If we found the location, set this bit
    if (found_loc == 1'b0)
      begin
      found_loc = max_wid_bitfield_loc[index0];
      end

      if (found_loc) begin
      max_wid_pers_mask_low[index0]  = 1'b0;
      max_wid_pers_mask_high[index0] = 1'b1;
      end else begin
      max_wid_pers_mask_low[index0]  = 1'b1;
      max_wid_pers_mask_high[index0] = 1'b0;
      end
    end
  end

assign max_wid_pesist_lo  =  max_wid_pers_mask_low  & max_wid_din;
assign max_wid_pesist_hi  = (max_wid_pers_mask_high & max_wid_din) << 1;

// Combine resulting vectors.
// This should result in no logic, only wires (assuming gen2_loc are constants).
assign max_wid_persist  = max_wid_user_data | max_wid_pesist_hi | max_wid_pesist_lo ;

// Calculate Persistent (i.e. non-Recoverable) Insertion
//////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////
// Selected between Persistent and Non Persistent and Resize

assign max_wid_dout = PERSISTENT ? max_wid_persist : max_wid_non_persist;

assign data_out = ENABLE ? max_wid_dout[CH_WIDTH-1:0] : data_in;

// Selected between Persistent and Non Persistent and Resize
//////////////////////////////////////////////////////////////////////

endmodule // ca_tx_mux
