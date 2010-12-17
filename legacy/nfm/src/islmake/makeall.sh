C100_ARGS='CPUFLAG=-D__cpu_c100__
  OBJEXT=1
  LIBDIR=../libc100
  BINDIR=../binc100
  TARGSTR=-Atarg=c100'

C400_ARGS='CPUFLAG=-D__cpu_c400__
  OBJEXT=4
  LIBDIR=../libc400
  BINDIR=../binc400
  TARGSTR=-Atarg=c400'

Make_libraries ()
{ # function to make libraries

echo
echo "grmake $1 version ..."
cd ../version
if [ "$1" = "C100" ]
    then
        grmake $C100_ARGS -f makefile
    else
        grmake $C400_ARGS -f makefile
fi

echo
echo "grmake $1 alpha ..."
cd ../alpha
if [ "$1" = "C100" ]
    then
        grmake $C100_ARGS -f makefile
    else
        grmake $C400_ARGS -f makefile
fi

echo
echo "grmake $1 alphas ..."
cd ../alphas
if [ "$1" = "C100" ]
    then
        grmake $C100_ARGS -f makefile COMBINE_FLAG=-DCOMBINED_MAKE
    else
        grmake $C400_ARGS -f makefile COMBINE_FLAG=-DCOMBINED_MAKE
fi

echo
echo "grmake $1 cmdtools ..."
cd ../cmdtools
if [ "$1" = "C100" ]
    then
        grmake $C100_ARGS -f makefile
    else
        grmake $C400_ARGS -f makefile
fi

echo
echo "grmake $1 dbtools ..."
cd ../dbtools
if [ "$1" = "C100" ]
    then
        grmake $C100_ARGS -f makefile
    else
        grmake $C400_ARGS -f makefile
fi

echo
echo "grmake $1 initial ..."
cd ../initial
if [ "$1" = "C100" ]
    then
        grmake $C100_ARGS -f makefile
    else
        grmake $C400_ARGS -f makefile
fi

echo
echo "grmake $1 libmem ..."
cd ../libmem
if [ "$1" = "C100" ]
    then
        grmake $C100_ARGS -f makefile
    else
        grmake $C400_ARGS -f makefile
fi

echo
echo "grmake $1 libnet ..."
cd ../libnet
if [ "$1" = "C100" ]
    then
        grmake $C100_ARGS -f makefile
    else
        grmake $C400_ARGS -f makefile
fi

echo
echo "grmake $1 libsql ..."
cd ../libsql
if [ "$1" = "C100" ]
    then
        grmake $C100_ARGS -f makefile
    else
        grmake $C400_ARGS -f makefile
fi

echo
echo "grmake $1 liberr ..."
cd ../liberr
if [ "$1" = "C100" ]
    then
        grmake $C100_ARGS -f makefile
    else
        grmake $C400_ARGS -f makefile
fi

echo
echo "grmake $1 fserver ..."
cd ../fserver
if [ "$1" = "C100" ]
    then
        grmake $C100_ARGS -f makefile
    else
        grmake $C400_ARGS -f makefile
fi

echo
echo "grmake $1 filetransfer ..."
cd ../filetransfer
if [ "$1" = "C100" ]
    then
        grmake $C100_ARGS -f makefile
    else
        grmake $C400_ARGS -f makefile
fi

echo
echo "grmake $1 nfma ..."
cd ../nfma
if [ "$1" = "C100" ]
    then
        grmake $C100_ARGS -f makefile
    else
        grmake $C400_ARGS -f makefile
fi

echo
echo "grmake $1 nfmd ..."
cd ../nfmd
if [ "$1" = "C100" ]
    then
        grmake $C100_ARGS -f makefile
    else
        grmake $C400_ARGS -f makefile
fi

echo
echo "grmake $1 nfmlist ..."
cd ../nfmlist
if [ "$1" = "C100" ]
    then
        grmake $C100_ARGS -f makefile
    else
        grmake $C400_ARGS -f makefile
fi

echo 
echo "grmake $1 nfmr ..."
cd ../nfmr
if [ "$1" = "C100" ]
    then
        grmake $C100_ARGS -f makefile
    else
        grmake $C400_ARGS -f makefile
fi

echo
echo "grmake $1 nfms ..."
cd ../nfms
if [ "$1" = "C100" ]
    then
        grmake $C100_ARGS -f makefile
    else
        grmake $C400_ARGS -f makefile
fi

echo
echo "grmake $1 nfmtools ..."
cd ../nfmtools
if [ "$1" = "C100" ]
    then
        grmake $C100_ARGS -f makefile
    else
        grmake $C400_ARGS -f makefile
fi

echo
echo "grmake $1 nfmu ..."
cd ../nfmu
if [ "$1" = "C100" ]
    then
        grmake $C100_ARGS -f makefile
    else
        grmake $C400_ARGS -f makefile
fi


echo
echo "grmake $1 acad ..."
cd ../acad
if [ "$1" = "C100" ]
    then
        grmake $C100_ARGS -f makefile
    else
        grmake $C400_ARGS -f makefile
fi

echo 
echo "grmake $1 sc ..."
cd ../sc
if [ "$1" = "C100" ]
    then
        grmake $C100_ARGS -f makefile
    else
        grmake $C400_ARGS -f makefile
fi

# SCcpp is a compiler level preprocessor for NFMfunctions. 
# No need to make the c400 version for our builds.
echo 
echo "grmake $1 scpp ..."
cd ../scpp
if [ "$1" = "C100" ]
    then
        grmake $C100_ARGS -f makefile
fi

echo
echo "grmake $1 systools ..."
cd ../systools
if [ "$1" = "C100" ]
    then
        grmake $C100_ARGS -f makefile
    else
        grmake $C400_ARGS -f makefile
fi

echo
echo "grmake $1 utilities ..."
cd ../utilities
if [ "$1" = "C100" ]
    then
        grmake $C100_ARGS -f makefile_r
        grmake $C100_ARGS -f makefile_s
        grmake $C100_ARGS -f makefile_c
    else
        grmake $C400_ARGS -f makefile_r
        grmake $C400_ARGS -f makefile_s
        grmake $C400_ARGS -f makefile_c
fi

echo
echo "grmake $1 workflow ..."
cd ../workflow
if [ "$1" = "C100" ]
    then
        grmake $C100_ARGS -f makefile
    else
        grmake $C400_ARGS -f makefile
fi

echo
echo "grmake $1 wff ..."
cd ../wff
if [ "$1" = "C100" ]
    then
        grmake $C100_ARGS -f makefile
    else
        grmake $C400_ARGS -f makefile
fi

echo
echo "grmake $1 wff_x ..."
cd ../wff_x
if [ "$1" = "C100" ]
    then
        grmake $C100_ARGS -f makefile XWINDOWS_FLAG=-DXWINDOWS
    else
        grmake $C400_ARGS -f makefile XWINDOWS_FLAG=-DXWINDOWS
fi

echo
echo "grmake $1 wfg ..."
cd ../wfg
if [ "$1" = "C100" ]
    then
        grmake $C100_ARGS -f makefile
    else
        grmake $C400_ARGS -f makefile
fi

echo
echo "grmake $1 nfmfi ..."
cd ../nfmfi
if [ "$1" = "C100" ]
    then
        grmake $C100_ARGS -f makefile
    else
        grmake $C400_ARGS -f makefile
fi

echo
echo "grmake $1 nfmfis ..."
cd ../nfmfis
if [ "$1" = "C100" ]
    then
        grmake $C100_ARGS -f makefile COMBINE_FLAG=-DCOMBINED_MAKE
    else
        grmake $C400_ARGS -f makefile COMBINE_FLAG=-DCOMBINED_MAKE
fi

echo
echo "grmake $1 nfmfi_x ..."
cd ../nfmfi_x
if [ "$1" = "C100" ]
    then
        grmake $C100_ARGS -f makefile XWINDOWS_FLAG=-DXWINDOWS
    else
        grmake $C400_ARGS -f makefile XWINDOWS_FLAG=-DXWINDOWS
fi

echo
echo "grmake $1 nfmfis_x ..."
cd ../nfmfis_x
if [ "$1" = "C100" ]
    then
        grmake $C100_ARGS -f makefile COMBINE_FLAG=-DCOMBINED_MAKE XWINDOWS_FLAG=-DXWINDOWS
    else
        grmake $C400_ARGS -f makefile COMBINE_FLAG=-DCOMBINED_MAKE XWINDOWS_FLAG=-DXWINDOWS
fi

echo
echo "grmake $1 bulkload ..."
cd ../bulkload
if [ "$1" = "C100" ]
    then
        grmake $C100_ARGS -f makefile
    else
        grmake $C400_ARGS -f makefile
fi

echo
echo "grmake $1 admin ..."
cd ../admin
if [ "$1" = "C100" ]
    then
        grmake $C100_ARGS -f makefile
    else
        grmake $C400_ARGS -f makefile
fi

echo
echo "grmake $1 v_nfms ..."
cd ../v_nfms
if [ "$1" = "C100" ]
    then
        grmake $C100_ARGS -f makefile
    else
        grmake $C400_ARGS -f makefile
fi

# Needed by PDM !
echo
echo "grmake $1 SAC ..."
cd ../SAC
if [ "$1" = "C100" ]
    then
        grmake $C100_ARGS -f makefile
    else
        grmake $C400_ARGS -f makefile
fi

echo
echo "grmake $1 libqui ..."
cd ../libqui
if [ "$1" = "C100" ]
    then
        grmake $C100_ARGS -f makefile
    else
        grmake $C400_ARGS -f makefile
fi

echo
echo "grmake $1 libquis ..."
cd ../libquis
if [ "$1" = "C100" ]
    then
        grmake $C100_ARGS -f makefile COMBINE_FLAG=-DCOMBINED_MAKE
    else
        grmake $C400_ARGS -f makefile COMBINE_FLAG=-DCOMBINED_MAKE
fi

echo
echo "grmake $1 CLI ..."
cd ../nfmcli
if [ "$1" = "C100" ]
    then
        grmake $C100_ARGS -f unixmakefile
    else
        grmake $C400_ARGS -f unixmakefile
fi

echo
echo "grmake $1 Converter ..."
cd ../convert
if [ "$1" = "C100" ]
    then
        grmake $C100_ARGS -f makefile
    else
        grmake $C400_ARGS -f makefile
fi

echo
echo "grmake $1 Update Utility ..."
cd ../update_utility
if [ "$1" = "C100" ]
    then
        grmake $C100_ARGS -f makefile
    else
        grmake $C400_ARGS -f makefile
fi

echo
echo "grmake $1 REDLINE Utility ..."
cd ../RLtmp_util
if [ "$1" = "C100" ]
    then
        grmake $C100_ARGS -f makefile
    else
        grmake $C400_ARGS -f makefile
fi

echo
echo "grmake $1 NFMmonitor ..."
cd ../nfmmonitor
if [ "$1" = "C100" ]
    then
        grmake $C100_ARGS -f makefile
    else
        grmake $C400_ARGS -f makefile
fi

}

Make_ScoSolSun_Libs ()
{
   for dir in   acad admin alpha alter alphas bulkload cmdtools convert \
		dbtools initial libmem libnet libqui libquis libsql liberr \
		libtli fserver filetransfer marcomp nfma nfmcli nfmd \
		nfmlist nfmmonitor nfmr nfms nfmu nfmtools nft sc systools \
                nfmfi_x nfmfis_x update_util v_nfms version wfg workflow wff_x 
   do
	cd ../$dir
	echo "grmake $1 $dir ..."
	grmake -f makefile.$1
   done

   if test $1 = "sco"
   then 
	for dir in pc_server pcinstall
	do
		cd ../$dir
		echo "grmake $1 $dir ..."
		grmake -f makefile.$1
	done
   fi

   cd ../utilities
   grmake -f makefile_r.$1
   grmake -f makefile_s.$1
   grmake -f makefile_c.$1
}

echo "Make SCO Libraries (y/n) ? [n] \c"
read SCOans; : ${SCOans:=n}
SCOans=`echo $SCOans | cut -c1-1`

if [ "$SCOans" = "y" -o "SCOans" = "Y" ]
then
        Make_ScoSolSun_Libs  sco
else
	echo "Make SOLARIS Libraries (y/n) ? [n] \c"
	read SOLans; : ${SOLans:=n}
	SOLans=`echo $SOLans | cut -c1-1`

	if [ "$SOLans" = "y" -o "SOLans" = "Y" ]
	then
		Make_ScoSolSun_Libs  sol
	else
		echo "Make SUNOS Libraries (y/n) ? [n] \c"
		read SUNans; : ${SUNans:=n}
		SUNans=`echo $SUNans | cut -c1-1`

		if [ "$SUNans" = "y" -o "SUNans" = "Y" ]
		then
			Make_ScoSolSun_Libs  sun
		else

			echo "Make Intel Solaris Libraries (y/n) ? [n] \c"
			read ISLans; : ${ISLans:=n}
			ISLans=`echo $ISLans | cut -c1-1`
	
			if [ "$ISLans" = "y" -o "ISLans" = "Y" ]
			then
				Make_ScoSolSun_Libs  isl
			else

				echo "Make C100 Libraries (y/n) ? [n] \c"
				read c100ans; : ${c100ans:=n}
				c100ans=`echo $c100ans | cut -c1-1`
	
				echo "Make C400 Libraries (y/n) ? [y] \c"
				read c400ans; : ${c400ans:=y}
				c400ans=`echo $c400ans | cut -c1-1`

				if [ "$c100ans" = "y" -o "$c100ans" = "Y" ]
				  then
				    Make_libraries C100
				fi

				if [ "$c400ans" = "y" -o "$c400ans" = "Y" ]
				  then
				    Make_libraries C400
				fi
			fi
		fi
	fi
fi

