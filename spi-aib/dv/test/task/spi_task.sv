// SPDX-License-Identifier: Apache-2.0
// Copyright (C) 2021 Intel Corporation.
/*    task auto_write (input [18:0] addr, input [31:0] wdata);
        begin
             avmm_if_mspi.cfg_write(17'h200, 4'hf, {4'h7, 9'h0, addr});
             avmm_if_mspi.cfg_write(17'h204, 4'hf, wdata); //Write spim wbuf
             avmm_if_mspi.cfg_write(17'h000, 4'hf, 32'h0000_0005); //burst_len is bit[15:2]
             @(posedge top_tb.dut_mspi.spi_inta);
        end
    endtask
*/ 
    task slave_cmd_rd ();
        begin
            avmm_if_mspi.cfg_write(17'h200, 4'hf, 32'h0000_0000);
            avmm_if_mspi.cfg_write(17'h000, 4'hf, 32'h0000_0005);
            master_polling ();
            avmm_if_mspi.cfg_read (17'h1004, 4'hf, rdata_reg);
        end
    endtask

/*    task auto_read (input [18:0] addr, output [31:0] rdata_reg);
        begin
            avmm_if_mspi.cfg_write(17'h200, 4'hf, {4'h6, 9'h0, addr});
            avmm_if_mspi.cfg_write(17'h000, 4'hf, 32'h0000_000d); //burst_len 2 two dummy plus a read

            @(posedge top_tb.dut_mspi.spi_inta);
            avmm_if_mspi.cfg_read (17'h1008, 4'hf, rdata_reg);
            avmm_if_mspi.cfg_read (17'h100c, 4'hf, rdata_reg);
        end
    endtask
*/
    task slave_polling ();
        begin
          status = " SPI Slave Polling ";
          slave_cmd_rd (); 
          while (rdata_reg[0] !== 1'b0) begin
             slave_cmd_rd ();
             $display("%0t: slave cmd polling:  rdata_reg =  %x", $time, rdata_reg);
          end
        end
    endtask

    task master_polling ();
        begin
          status = " SPI Master Polling ";
          avmm_if_mspi.cfg_read (17'h000, 4'hf, rdata_reg);
          while (rdata_reg[0] !== 1'b0) begin
             avmm_if_mspi.cfg_read (17'h000, 4'hf, rdata_reg);
             $display("%0t: master cmd polling:  rdata_reg =  %x", $time, rdata_reg);
          end
        end
    endtask
    task sl_single_auto_write(
       input [18:0] addr,
       input [31:0] wdata);
       
       begin
          avmm_if_mspi.cfg_write(17'h200, 4'hf, {4'h7, 9'h0, addr});
          avmm_if_mspi.cfg_write(17'h204, 4'hf, wdata); //Write spim wbuf
          avmm_if_mspi.cfg_write(17'h000, 4'hf, 32'h0000_0005); //burst_len is bit[15:2]
          master_polling ();              //Check if write command/data has been sent to slave
          slave_polling ();

       end
    endtask
