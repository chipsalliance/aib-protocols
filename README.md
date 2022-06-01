## Advanced Interface Bus (AIB) Protocol IP
This repository contains RTL and examples for AIB Protocol IP.
Check README.txt in each IP sub directory for details.
May 31, 2022, Version 1.0 

## Revision 1.0 (rev1)

The rev1 aib protocol IP directory structure is:                                    
```aib-protocols
├── CHIPS Alliance - CCLA v7.pdf
├── LICENSE
├── README.md      -- This file
├── axi4-mm
│   ├── README.txt         
│   ├── axi_lite_a32_d32
│   ├── axi_mm_a32_d128
│   ├── axi_mm_a32_d128_packet
│   ├── axi_mm_a32_d128_packet_gen1
│   ├── axi_mm_multi
│   ├── build_examples.sh
│   ├── cfg
│   ├── doc
│   └── dv
├── axi4-st
│   ├── README.txt
│   ├── axi_st_d256_gen1_gen2
│   ├── axi_st_d256_gen2_only
│   ├── axi_st_d256_multichannel
│   ├── axi_st_d64
│   ├── axi_st_d64_nordy
│   ├── build_examples.sh
│   ├── cfg
│   ├── doc
│   └── dv
├── backup       -- obsolete iuse spi-aib instead
│   └── spi
├── ca
│   ├── README
│   ├── doc
│   ├── dv
│   ├── fpga
│   └── rtl
├── common
│   ├── README
│   ├── dv
│   └── rtl
├── llink
│   ├── fpga
│   ├── rtl
│   └── script
├── lpif
│   ├── README
│   ├── doc
│   ├── fpga
│   └── rtl
├── run_smoke.sh
└── spi-aib
    ├── README.txt
    ├── doc
    ├── dv
    ├── rtl
    └── syn

```

Note the aib-phy-hardware is a seperate repo available from GitHut here: https://github.com/chipsalliance/aib-phy-hardware
For correct simulation, please ensure it is organized as shown below.
```aib-protocols-main
├── axi4-mm
├── axi4-st
├── ca
├── common
├── llink
├── lpif
├── run_smoke.sh
└── spi-aib
aib-phy-hardware-master
├── README.md
├── v1.0
└── v2.0
```
See the [AIB Spec](https://github.com/chipsalliance/AIB-specification/blob/master/AIB_Specification%202_0_DRAFT3.pdf) and 
[AIB Usage Note](https://github.com/chipsalliance/aib-phy-hardware/blob/master/docs/AIB_Usage_Note_v1_2_1.pdf). for information about AIB.


