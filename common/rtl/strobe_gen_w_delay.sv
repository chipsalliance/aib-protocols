////////////////////////////////////////////////////////////
//Module:	level_delay
//Created:	Mar 19 2021
//Author:	John Archambeault
//
////////////////////////////////////////////////////////////

module strobe_gen_w_delay (

    input logic        clk,
    input logic        rst_n,

    input logic  [7:0] interval,          // Set to 0 for back to back strobes. Otherwise, interval is the time between strobes (so if you want a strobe every 10 cycles, set to 9)
    input logic  [7:0] delay_value,       // Delay after online before we start sending strobes.
    input logic        user_marker,       // Effectiely the OR reduction of all user_marker bits. We only increment strobe count when we send a remote side word
    input logic        online,            // Set to 1 to begin strobe generation (0 to stop)

    output logic       user_strobe

   );


logic delayed_online;


   level_delay level_delay (
        .delayed_en  (delayed_online),
        .clk_core    (clk),
        .rst_core_n  (rst_n),
        .enable      (online),
        .delay_value (delay_value) );

   strobe_gen strobe_gen (
        .user_strobe    (user_strobe),
        .clk            (clk),
        .rst_n          (rst_n),
        .interval       (interval),
        .user_marker    (user_marker),
        .online         (delayed_online) );


endmodule // strobe_gen_w_delay //

////////////////////////////////////////////////////////////
//Module:	level_delay
//$Id$
////////////////////////////////////////////////////////////

