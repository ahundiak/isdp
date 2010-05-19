if [ -f BMGform ]; then
   cat BMGform		>	BeamDwg.rpt
   rm  BMGform
   cat BMGheader	>>	BeamDwg.rpt
   rm  BMGheader
fi

cat $1			>>	BeamDwg.rpt
