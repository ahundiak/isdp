if [ -f PPDform ]; then
  cat PPDform		>	PipeDat.rpt
  rm  PPDform
  cat PPDheader		>>	PipeDat.rpt
  rm  PPDheader
fi

cat $1			>>	PipeDat.rpt
