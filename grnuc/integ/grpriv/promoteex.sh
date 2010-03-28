NEWPRODLOC="ems130.n24ex.mdem"
for file in exnuc exnucdp libxc dignuc
do
  rm -f $file/*
  cd $file
  fmu -v $NEWPRODLOC rec $file/*
  cd ~
done
