10/26/2021

==============================================================================================
Test bench(top_tb.sv) description. See user_guide under doc for detail.
==============================================================================================
                                    
                 ---------------   PAIR1 (p1)              ---------------
    random       |             |                           |             |-----> rx data checker
    data  tx---->| dut_master1 |<=========================>| dut_slave1  |
                 |             |                           |             |-----> tx random data
    data  rx<----| or app_reg  |                           | FPGA        |
    checker      |             |                           |             |
                 ---------------                           ---------------
                 master aka leader                         slave aka follower

                 ---------------   PAIR2 (p2)              ---------------
    random       |             |                           |             |-----> rx data checker
    data  tx---->| dut_master2 |<=========================>| dut_slave2  |
                 |             |                           |             |-----> tx random data
    data  rx<----|             |                           |             |
    checker      |             |                           |             |
                 ---------------                           ---------------
                 master aka leader                         slave aka follower

      |----------|         |----------|
      |          |         |          |---------> avmm config dut_master1
      |          |=========>spi_slave |---------> avmm config dut_slave2
      |          |         |          |---------> avmm config dut_master2
      |spi_master|         |----------|
      |          |
      |          |         |----------|
      |          |         |spi_slave1|
      |          |=========>          |
      |----------|         |----------| 
           

===========================================================
 Test Vectors and how to run test
===========================================================

Three test vectors provided 
spi-aib/dv/test/
test_cases/
├── basic_spi_test.inc   --Cover all basic spi commands
|── fifo2x_test.inc      --Program dut_master1, dut_master2, dut_slave2 all 24 channels and run traffic for pair1 and pair2.
|── app_reg_test.inc     --Test Application Register Block.
|── wrap_around_test.inc --Test Application Register Block with 256 auto write and 256 auto read (overflow test)
|── non_auto_test.inc    --Test equivalent of auto write and auto test with multi-step configuration

Commands to run vcs:
go to sims directory.

ln -s ../test/test_cases/basic_spi_test.inc test.inc   or
ln -s ../test/test_cases/fifo2x_test.inc test.inc
ln -s ../test/test_cases/app_reg_test.inc test.inc

./run_compile
