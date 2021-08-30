Run these commands:

./setup.sh

rm -Rf qdb
rm -Rf synth_dumps
rm -Rf tmp-clearbox

qsub -V -cwd -b y -o /dev/null -e stderr.log quartus two_axi_mm_chiplet &
