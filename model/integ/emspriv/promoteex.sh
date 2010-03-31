NEWPRODLOC="exnuc.v230.distrib"
#for file in exnuc exnucdp libxc
for file in exnucdp libxc
do
  rm -f $file/*
  cd $file
  fmu -v $NEWPRODLOC rec $file/*
  cd ~
done
