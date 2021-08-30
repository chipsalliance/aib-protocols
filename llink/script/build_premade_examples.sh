cd ../script ; rm -Rf premade_examples/axi_mm_a32_d128_packet ; python llink_gen.py --cfg cfg/axi_mm_a32_d128_packet.cfg          --odir premade_examples/axi_mm_a32_d128_packet ; cd -
cd ../script ; rm -Rf premade_examples/axi_mm_a32_d128        ; python llink_gen.py --cfg cfg/axi_mm_a32_d128.cfg                 --odir premade_examples/axi_mm_a32_d128        ; cd -
cd ../script ; rm -Rf premade_examples/axi_st_d128_asym       ; python llink_gen.py --cfg cfg/axi_st_d128_asym.cfg                --odir premade_examples/axi_st_d128_asym       ; cd -
cd ../script ; rm -Rf premade_examples/axi_mm_a48_d512_packet ; python llink_gen.py --cfg cfg/axi_mm_a48_d512_packet_variant1.cfg --odir premade_examples/axi_mm_a48_d512_packet_variant1 ; cd -
cd ../script ; rm -Rf premade_examples/axi_mm_a48_d512_packet ; python llink_gen.py --cfg cfg/axi_mm_a48_d512_packet_variant2.cfg --odir premade_examples/axi_mm_a48_d512_packet_variant2 ; cd -
cd ../script ; rm -Rf premade_examples/axi_mm_a48_d512_packet ; python llink_gen.py --cfg cfg/axi_mm_a48_d512_packet_variant3.cfg --odir premade_examples/axi_mm_a48_d512_packet_variant3 ; cd -
cd ../script ; rm -Rf premade_examples/axi_mm_a48_d512_packet ; python llink_gen.py --cfg cfg/axi_mm_a48_d512_packet.cfg          --odir premade_examples/axi_mm_a48_d512_packet ; cd -
cd ../script ; rm -Rf premade_examples/axi_st_d256            ; python llink_gen.py --cfg cfg/axi_st_d256_gen1_gen2.cfg           --odir premade_examples/axi_st_d256_gen1_gen2  ; cd -
cd ../script ; rm -Rf premade_examples/axi_st_d64             ; python llink_gen.py --cfg cfg/axi_st_d64.cfg                      --odir premade_examples/axi_st_d64             ; cd -




cd ../script ; rm -Rf premade_examples/axi_fourchan_tier1_a32_d32_packet ; python llink_gen.py --cfg cfg/axi_fourchan_tier1_a32_d32_packet.cfg --odir premade_examples/axi_fourchan_tier1_a32_d32_packet ; cd -
cd ../script ; rm -Rf premade_examples/axi_fourchan_tier2                ; python llink_gen.py --cfg cfg/axi_fourchan_tier2.cfg                --odir premade_examples/axi_fourchan_tier2                ; cd -

echo "Running Autos"
cd ../script/premade_examples/axi_fourchan_tier_top ; /usr/bin/emacs -batch axi_fourchan_tier_master_top.sv -f verilog-auto -f save-buffer         ; cd -
cd ../script/premade_examples/axi_fourchan_tier_top ; /usr/bin/emacs -batch axi_fourchan_tier_slave_top.sv  -f verilog-auto -f save-buffer         ; cd -
echo "\${PROJ_DIR}/llink/script/premade_examples/axi_fourchan_tier2/axi_fourchan_tier2_master_top.sv" > ../script/premade_examples/axi_fourchan_tier_top/axi_fourchan_tier_master_top.f
echo "\${PROJ_DIR}/llink/script/premade_examples/axi_fourchan_tier2/axi_fourchan_tier2_slave_top.sv"  > ../script/premade_examples/axi_fourchan_tier_top/axi_fourchan_tier_slave_top.f
cat ../script/premade_examples/axi_fourchan_tier1_a32_d32_packet/*master.f >> ../script/premade_examples/axi_fourchan_tier_top/axi_fourchan_tier_master_top.f
cat ../script/premade_examples/axi_fourchan_tier1_a32_d32_packet/*slave.f  >> ../script/premade_examples/axi_fourchan_tier_top/axi_fourchan_tier_slave_top.f
cat ../script/premade_examples/axi_fourchan_tier2/*master.f                >> ../script/premade_examples/axi_fourchan_tier_top/axi_fourchan_tier_master_top.f
cat ../script/premade_examples/axi_fourchan_tier2/*slave.f                 >> ../script/premade_examples/axi_fourchan_tier_top/axi_fourchan_tier_slave_top.f

