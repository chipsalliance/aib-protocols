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
// Functional Descript:
//
// Note, this code assumes the widest channel wil be 320 bits wide.
// Everything is sized up to 320 and then only the lower most
// portion is used.
//
// Note if wd_sel and bit_sel are not fixed and are controlled by CSR, this will result in a
// very large MUX array. Flexibility comes at a cost.
//
////////////////////////////////////////////////////////////

module ca_tx_mux #(parameter CH_WIDTH=80) (

    // Data In / out
    input logic [CH_WIDTH-1:0]  data_in,
    output logic [CH_WIDTH-1:0] data_out,

    // Control signals
    input logic [8:0]           stb_loc,

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
assign max_wid_bitfield_loc = (320'h1 << stb_loc);

// This should be be all zeros except for USER bit.
assign max_wid_user_data     = max_wid_bitfield_loc & {320{tx_userbit}};

// Upsize the vector to the max channel width vector for consistency
//////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////
// Calculate Non Persistent (i.e. Recoverable) Insertion
wire [319:0] max_wid_non_persist;

assign max_wid_non_persist  = (max_wid_user_data | ((~max_wid_bitfield_loc) & max_wid_din)) ;

// Calculate Non Persistent (i.e. Recoverable) Insertion
//////////////////////////////////////////////////////////////////////

assign max_wid_dout = max_wid_non_persist;

assign data_out = max_wid_dout[CH_WIDTH-1:0];

endmodule // ca_tx_mux
