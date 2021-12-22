README.txt
Nov. 4th, 2021

===========================================================
Revision history:
Revision 1.0: Initial release
===========================================================
Revision 1.1 11/19/2021:
1) Modify SPI master and SPI slave core so that miso pins are seperated 
   instead of shared and tristated. If package pins are not limited, this
   can be easy for debugging. 
2) Changed spi clock to 100MHz. (User can specify accordingly base on application)
3) Correct some typo in user guide CSR.
============================================================
Revision 1.2 12/21/2021
1) Created app_avmm_csr rtl block. This block is to mimic what SPI follower (slave)
   can connect to user application layer avmm register block instead of AIB model.
   In this app registeter block, user can provide status register, so that SPI leader
   can read. SPI leader can also provide control regiser to user application side.
2) Test cases has been provided for how to program this module. See README.txt under
   dv/sims  

Included in this package are :

spi-aib
├── doc              --User guide and HAS specification
├── dv               --DV For Design Example
│   ├── flist
│   ├── interface
│   ├── sims         --Run directory for design example
│   ├── tb           --Top level testbench
│   └── test
│       ├── data
│       ├── task
│       └── test_cases -- test cases
├── rtl              -- RTL for spi_master and spi_slave RTL
└── syn              -- Synthesis dir
    └── quartus
        └── sdc_files -- Time constraint

User can download from github:
https://github.com/chipsalliance/aib-phy-hardware

After download, the file structure on top level should looks like this:

drwxr-s--- 5 xxxxxxxx xxxxxx 4096 Sep 26 22:37 aib-phy-hardware-master
drwxr-s--- 6 xxxxxxxx xxxxxx 4096 Oct 26 22:43 spi-aib
