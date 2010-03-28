NEWPRODLOC="ems130.n24bs.mdem"
for file in bspmath bspmathdp
do
  rm -f $file/*
  cd $file
  fmu -v $NEWPRODLOC rec $file/*
  cd ~
done
