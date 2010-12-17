Make_Makes ()
{
   for dir in   acad admin alpha alphas alter bulkload cmdtools dbtools \
                filetransfer fserver initial liberr libmem libnet libqui \
                libquis libsql marcomp nfma nfmcli nfmd nfmfi_x nfmfis_x \
                nfmlist nfmmonitor nfmr nfms nfmtools nfmu sc systools \
                update_utility version wff_x wfg workflow

   do
	cd ../$dir
	echo "make_make $1 $dir ..."
        dotm=`/bin/ls *.m`
	nfmmkmk < $dotm > makefile$1
   done

   cd ../utilities
   echo "make_make $1 utilities"
   nfmmkmk <NFMRuti.m > make_r$1
   nfmmkmk <NFMSuti.m > make_s$1
   nfmmkmk <NFMCuti.m > make_c$1
}

echo "Create SCO Makefiles (y/n) ? [n] \c"
read SCOans; : ${SCOans:=n}
SCOans=`echo $SCOans | cut -c1-1`

if [ "$SCOans" = "y" -o "SCOans" = "Y" ]
then
        Make_Makes .sco
        exit
fi


echo "Create Sun/SOLARIS Makefiles (y/n) ? [n] \c"
read SSLans; : ${SSLans:=n}
SSLans=`echo $SSLans | cut -c1-1`

if [ "$SSLans" = "y" -o "SSLans" = "Y" ]
then
	Make_Makes  .ssl
        exit
fi

echo "Create Intel/SOLARIS Makefiles (y/n) ? [n] \c"
read ISLans; : ${ISLans:=n}
ISLans=`echo $ISLans | cut -c1-1`

if [ "$ISLans" = "y" -o "ISLans" = "Y" ]
then
	Make_Makes  .isl
        exit
fi

echo "Create SUNOS Makefiles (y/n) ? [n] \c"
read SUNans; : ${SUNans:=n}
SUNans=`echo $SUNans | cut -c1-1`

if [ "$SUNans" = "y" -o "SUNans" = "Y" ]
then
	Make_Makes  .sun
	exit
fi

echo "Create HPUX Makefiles (y/n) ? [n] \c"
read HPans; : ${HPans:=n}
HPans=`echo $HPans | cut -c1-1`

if [ "$HPans" = "y" -o "HPans" = "Y" ]
then
	Make_Makes  .hp
	exit
fi

echo "Create CLIX Makefiles (y/n) ? [n] \c"
read clixans; : ${clixans:=n}
clixans=`echo $clixans | cut -c1-1`

if [ "$clixans" = "y" -o "$clixans" = "Y" ]
then
	Make_Makes .clx 
	exit
fi
