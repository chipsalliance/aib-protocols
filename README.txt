This is a repository with multiple independant pieces of IP. Generally, each IP has its own
directory complete with READMEs and the IP user guide is within.

The IPs are:

axi4-st - AHMB AXI4-ST over AIB based off of the LLINK design
axi4-mm - AHMB AXI4 (memory mapped) over AIB based off of the LLINK design
ca - Channel Alignment module (used in multiple AIB channel designs)
lpif - Logical PHY interface adapter to AIB

For DV resources, look at:
ca/dv
llink/dv
lpif/dv







Below is the expected directory heirarchy. Note the aib-phy-hardware is a
seperate repo available from GitHut here: https://github.com/chipsalliance/aib-phy-hardware
For correct simulation, please ensure it is organized as shown below.

|-- aib-protocols
|   |-- axi4-mm
|   |   |-- cfg
|   |   |-- doc
|   |   |-- dv
|   |   `-- README.txt
|   |-- axi4-st
|   |   |-- cfg
|   |   |-- doc
|   |   |-- dv
|   |   `-- README.txt
|   |-- ca
|   |   |-- doc
|   |   |-- dv
|   |   |-- README
|   |   `-- rtl
|   |-- common
|   |   |-- README
|   |   |-- dv
|   |   `-- rtl
|   |-- llink
|   |   |-- dv
|   |   |-- rtl
|   |   `-- script
|   |-- lpif
|       |-- doc
|   |   |-- dv
|   |   |-- README
|   |   `-- rtl
|   |-- README.txt
|   `-- setup.sh
`-- aib-phy-hardware (seperate repository)
    |-- docs
    |-- v1.0
    `-- v2.0
