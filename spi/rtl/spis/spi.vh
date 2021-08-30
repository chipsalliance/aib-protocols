// Protocol Definitions
`define SPI_CMD_HIGH_BIT	0
`define SPI_CMD_LOW_BIT		7

`define SPI_LC_HIGH_BIT		8
`define SPI_LC_LOW_BIT		15

`define SPI_ADDR_HIGH_BIT	16
`define SPI_ADDR_LOW_BIT	31

`define SPI_ADDR `SPI_ADDR_HIGH_BIT:`SPI_ADDR_LOW_BIT
`define SPI_LC   `SPI_LC_HIGH_BIT:`SPI_LC_LOW_BIT
`define SPI_CMD  `SPI_CMD_HIGH_BIT:`SPI_CMD_LOW_BIT

`define TERM_COUNT	       5'b11111
`define ZERO_COUNT             5'b00000
