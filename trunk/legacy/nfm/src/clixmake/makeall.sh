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
echo "make $1 version ..."
cd ../version
if [ "$1" = "C100" ]
    then
        make $C100_ARGS -f makefile
    else
        make $C400_ARGS -f makefile
fi

echo
echo "make $1 alpha ..."
cd ../alpha
mv ../alpha.obj/*.1 .
mv ../alpha.obj/*.4 .
if [ "$1" = "C100" ]
    then
        make $C100_ARGS -f ../alpha.obj/makefile
    else
        make $C400_ARGS -f ../alpha.obj/makefile
fi
mv *.1 ../alpha.obj
mv *.4 ../alpha.obj

echo
echo "make $1 alphas ..."
cd ../alpha
mv ../alphas.obj/*.1 .
mv ../alphas.obj/*.4 .
if [ "$1" = "C100" ]
    then
        make $C100_ARGS -f ../alphas.obj/makefile COMBINE_FLAG=-DCOMBINED_MAKE
    else
        make $C400_ARGS -f ../alphas.obj/makefile COMBINE_FLAG=-DCOMBINED_MAKE
fi
mv *.1 ../alphas.obj
mv *.4 ../alphas.obj
 
echo
echo "make $1 cmdtools ..."
cd ../cmdtools
if [ "$1" = "C100" ]
    then
        make $C100_ARGS -f makefile
    else
        make $C400_ARGS -f makefile
fi

echo
echo "make $1 dbtools ..."
cd ../dbtools
if [ "$1" = "C100" ]
    then
        make $C100_ARGS -f makefile
    else
        make $C400_ARGS -f makefile
fi

echo
echo "make $1 initial ..."
cd ../initial
if [ "$1" = "C100" ]
    then
        make $C100_ARGS -f makefile
    else
        make $C400_ARGS -f makefile
fi

echo
echo "make $1 libmem ..."
cd ../libmem
if [ "$1" = "C100" ]
    then
        make $C100_ARGS -f makefile
    else
        make $C400_ARGS -f makefile
fi

echo
echo "make $1 libnet ..."
cd ../libnet
if [ "$1" = "C100" ]
    then
        make $C100_ARGS -f makefile
    else
        make $C400_ARGS -f makefile
fi

echo
echo "make $1 libsql ..."
cd ../libsql
if [ "$1" = "C100" ]
    then
        make $C100_ARGS -f makefile
    else
        make $C400_ARGS -f makefile
fi

echo
echo "make $1 liberr ..."
cd ../liberr
if [ "$1" = "C100" ]
    then
        make $C100_ARGS -f makefile
    else
        make $C400_ARGS -f makefile
fi

echo
echo "make $1 fserver ..."
cd ../fserver
if [ "$1" = "C100" ]
    then
        make $C100_ARGS -f makefile
    else
        make $C400_ARGS -f makefile
fi

echo
echo "make $1 filetransfer ..."
cd ../filetransfer
if [ "$1" = "C100" ]
    then
        make $C100_ARGS -f makefile
    else
        make $C400_ARGS -f makefile
fi

echo
echo "make $1 nfma ..."
cd ../nfma
if [ "$1" = "C100" ]
    then
        make $C100_ARGS -f makefile
    else
        make $C400_ARGS -f makefile
fi

echo
echo "make $1 nfmd ..."
cd ../nfmd
if [ "$1" = "C100" ]
    then
        make $C100_ARGS -f makefile
    else
        make $C400_ARGS -f makefile
fi

echo
echo "make $1 nfmlist ..."
cd ../nfmlist
if [ "$1" = "C100" ]
    then
        make $C100_ARGS -f makefile
    else
        make $C400_ARGS -f makefile
fi

echo 
echo "make $1 nfmr ..."
cd ../nfmr
if [ "$1" = "C100" ]
    then
        make $C100_ARGS -f makefile
    else
        make $C400_ARGS -f makefile
fi

echo
echo "make $1 nfms ..."
cd ../nfms
if [ "$1" = "C100" ]
    then
        make $C100_ARGS -f makefile
    else
        make $C400_ARGS -f makefile
fi

echo
echo "make $1 nfmtools ..."
cd ../nfmtools
if [ "$1" = "C100" ]
    then
        make $C100_ARGS -f makefile
    else
        make $C400_ARGS -f makefile
fi

echo
echo "make $1 nfmu ..."
cd ../nfmu
if [ "$1" = "C100" ]
    then
        make $C100_ARGS -f makefile
    else
        make $C400_ARGS -f makefile
fi


echo
echo "make $1 acad ..."
cd ../acad
if [ "$1" = "C100" ]
    then
        make $C100_ARGS -f makefile
    else
        make $C400_ARGS -f makefile
fi

echo 
echo "make $1 sc ..."
cd ../sc
if [ "$1" = "C100" ]
    then
        make $C100_ARGS -f makefile
    else
        make $C400_ARGS -f makefile
fi

echo 
echo "make $1 scs ..."
cd ../scs
if [ "$1" = "C100" ]
    then
        make $C100_ARGS -f makefile COMBINE_FLAG=-DCOMBINED_MAKE
    else
        make $C400_ARGS -f makefile COMBINE_FLAG=-DCOMBINED_MAKE
fi

# SCcpp is a compiler level preprocessor for NFMfunctions. 
# No need to make the c400 version for our builds.
echo 
echo "make $1 scpp ..."
cd ../scpp
if [ "$1" = "C100" ]
    then
        make $C100_ARGS -f makefile
fi

echo
echo "make $1 systools ..."
cd ../systools
if [ "$1" = "C100" ]
    then
        make $C100_ARGS -f makefile
    else
        make $C400_ARGS -f makefile
fi

echo
echo "make $1 utilities ..."
cd ../utilities
if [ "$1" = "C100" ]
    then
        make $C100_ARGS -f makefile_r
        make $C100_ARGS -f makefile_s
        make $C100_ARGS -f makefile_c
    else
        make $C400_ARGS -f makefile_r
        make $C400_ARGS -f makefile_s
        make $C400_ARGS -f makefile_c
fi

echo
echo "make $1 workflow ..."
cd ../workflow
if [ "$1" = "C100" ]
    then
        make $C100_ARGS -f makefile
    else
        make $C400_ARGS -f makefile
fi

echo
echo "make $1 wff..."
cd ../wff_x
if [ "$1" = "C100" ]
    then
        mv ../wff.obj/*.1 .
        make $C100_ARGS -f ../wff.obj/makefile
        mv *.1 ../wff.obj
    else
        mv ../wff.obj/*.4 .
        make $C400_ARGS -f ../wff.obj/makefile
        mv *.4 ../wff.obj
fi

echo
echo "make $1 wff_x ..."
cd ../wff_x
if [ "$1" = "C100" ]
    then
        mv ../wff_x.obj/*.1 .
        make $C100_ARGS -f ../wff_x.obj/makefile XWINDOWS_FLAG=-DXWINDOWS
        mv *.1 ../wff_x.obj
    else
        mv ../wff_x.obj/*.4 .
        make $C400_ARGS -f ../wff_x.obj/makefile XWINDOWS_FLAG=-DXWINDOWS
        mv *.4 ../wff_x.obj
fi

echo
echo "make $1 wfg ..."
cd ../wfg
if [ "$1" = "C100" ]
    then
        make $C100_ARGS -f makefile
    else
        make $C400_ARGS -f makefile
fi

echo
echo "make $1 nfmfi ..."
cd ../nfmfi_x
if [ "$1" = "C100" ]
    then
        mv ../nfmfi.obj/*.1 .
        make $C100_ARGS -f ../nfmfi.obj/makefile
        mv *.1 ../nfmfi.obj
    else
        mv ../nfmfi.obj/*.4 .
        make $C400_ARGS -f ../nfmfi.obj/makefile
        mv *.4 ../nfmfi.obj
fi
  
echo
echo "make $1 nfmfis ..."
cd ../nfmfi_x
if [ "$1" = "C100" ]
    then
       mv ../nfmfis.obj/*.1 .
       make $C100_ARGS -f ../nfmfis.obj/makefile COMBINE_FLAG=-DCOMBINED_MAKE
       mv *.1 ../nfmfis.obj
    else
        mv ../nfmfis.obj/*.4 .
        make $C400_ARGS -f ../nfmfis.obj/makefile COMBINE_FLAG=-DCOMBINED_MAKE
        mv *.4 ../nfmfis.obj
fi

echo
echo "make $1 nfmfi_x ..."
cd ../nfmfi_x


if [ "$1" = "C100" ]
    then
        mv ../nfmfi_x.obj/*.1 .
        make $C100_ARGS -f ../nfmfi_x.obj/makefile XWINDOWS_FLAG=-DXWINDOWS
        mv *.1 ../nfmfi_x.obj
    else
        mv ../nfmfi_x.obj/*.4 .
        make $C400_ARGS -f ../nfmfi_x.obj/makefile XWINDOWS_FLAG=-DXWINDOWS
        mv *.4 ../nfmfi_x.obj
fi

echo
echo "make $1 nfmfis_x ..."
cd ../nfmfi_x
if [ "$1" = "C100" ]
    then
        mv ../nfmfis_x.obj/*.1 .
        make $C100_ARGS -f ../nfmfis_x.obj/makefile COMBINE_FLAG=-DCOMBINED_MAKE XWINDOWS_FLAG=-DXWINDOWS
        mv *.1 ../nfmfis_x.obj
    else
        mv ../nfmfis_x.obj/*.4 .
        make $C400_ARGS -f ../nfmfis_x.obj/makefile COMBINE_FLAG=-DCOMBINED_MAKE XWINDOWS_FLAG=-DXWINDOWS
        mv *.4 ../nfmfis_x.obj
fi

echo
echo "make $1 bulkload ..."
cd ../bulkload
if [ "$1" = "C100" ]
    then
        make $C100_ARGS -f makefile
    else
        make $C400_ARGS -f makefile
fi

echo
echo "make $1 admin ..."
cd ../admin
if [ "$1" = "C100" ]
    then
        make $C100_ARGS -f makefile
    else
        make $C400_ARGS -f makefile
fi

echo
echo "make $1 v_nfms ..."
cd ../v_nfms
if [ "$1" = "C100" ]
    then
        make $C100_ARGS -f makefile
    else
        make $C400_ARGS -f makefile
fi

# Needed by PDM !
echo
echo "make $1 SAC ..."
cd ../SAC
if [ "$1" = "C100" ]
    then
        make $C100_ARGS -f makefile
    else
        make $C400_ARGS -f makefile
fi

echo
echo "make $1 libqui ..."
cd ../libqui


if [ "$1" = "C100" ]
    then
        mv ../libqui.obj/*.1 .
        make $C100_ARGS -f ../libqui.obj/makefile
        mv *.1 ../libqui.obj
    else
        mv ../libqui.obj/*.4 .
        make $C400_ARGS -f ../libqui.obj/makefile
        mv *.4 ../libqui.obj
fi
echo
echo "make $1 libquis ..."
cd ../libqui
if [ "$1" = "C100" ]
    then
        mv ../libquis.obj/*.1 .
        make $C100_ARGS -f ../libquis.obj/makefile COMBINE_FLAG=-DCOMBINED_MAKE
        mv *.1 ../libquis.obj
    else
       mv ../libquis.obj/*.4 .
        make $C400_ARGS -f ../libquis.obj/makefile COMBINE_FLAG=-DCOMBINED_MAKE
        mv *.4 ../libquis.obj
fi

echo
echo "make $1 CLI ..."
cd ../nfmcli
if [ "$1" = "C100" ]
    then
        make $C100_ARGS -f unixmakefile
    else
        make $C400_ARGS -f unixmakefile
fi

echo
echo "make $1 Converter ..."
cd ../convert
if [ "$1" = "C100" ]
    then
        make $C100_ARGS -f makefile
    else
        make $C400_ARGS -f makefile
fi

echo
echo "make $1 Update Utility ..."
cd ../update_utility
if [ "$1" = "C100" ]
    then
        make $C100_ARGS -f makefile
    else
        make $C400_ARGS -f makefile
fi

echo
echo "make $1 REDLINE Utility ..."
cd ../RLtmp_util
if [ "$1" = "C100" ]
    then
        make $C100_ARGS -f makefile
    else
        make $C400_ARGS -f makefile
fi

echo
echo "make $1 NFMmonitor ..."
cd ../clhtodat
if [ "$1" = "C100" ]
    then
        make $C100_ARGS -f makefile
    else
        make $C400_ARGS -f makefile
fi

}

PlatForm="$1"

if echo "$PlatForm" | grep '[cC]100' 1> /dev/null
then
    Make_libraries C100
    exit
fi;

if echo "$PlatForm" | grep '[cC]400' 1> /dev/null
then
   Make_libraries C400
   exit
fi;



echo "Make C100 Libraries (y/n) ? [n] \c"
if [ "$c100ans" != "y" ] ;then read c100ans ;fi;  : ${c100ans:=n}
c100ans=`echo $c100ans | cut -c1-1`

echo "Make C400 Libraries (y/n) ? [y] \c"
if [ "$c400ans" != "y" ] ;then read c400ans ;fi;  : ${c400ans:=n}
c400ans=`echo $c400ans | cut -c1-1`

if [ "$c100ans" = "y" -o "$c100ans" = "Y" ]
  then
    Make_libraries C100
fi

if [ "$c400ans" = "y" -o "$c400ans" = "Y" ]
  then
    Make_libraries C400
fi
