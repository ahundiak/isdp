
curuser=`grep nfmadmin /etc/passwd`
fp=`echo $curuser | cut -f6 -d":"`
for i in /usr/lib/nodes/owned/nfme_*
  do
  env=`echo $i | cut -c27-36`
  if [ ! -d $fp/$env/dmd_ftr ]; then
  echo Creating FTR Directory for Environment: $env
  mkdir -p $fp/$env/dmd_ftr; fi
  chmod 777 $fp/$env/dmd_ftr
  chown nfmadmin $fp/$env/dmd_ftr

  if [ ! -d $fp/$env/dmd_ftr ]; then echo Cannot create $fp/$env/dmd_ftr;
  fi
  done
