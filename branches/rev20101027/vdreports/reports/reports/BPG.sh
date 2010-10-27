if [ -f BPGform ]; then
   cat BPGform		>	BeamPlate.rpt
   rm  BPGform
   cat BPGheader	>> 	BeamPlate.rpt
   rm  BPGheader
fi

cat $1			>>	BeamPlate.rpt
