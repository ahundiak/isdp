#
# This shell script builds the libraries, that are created by extraction of
# specific source from EMS (MODEL and GRNUC). This source conceptually consists
# of two parts -- 1) BaseEMS, which gives basic the EMS data-base read/write
# functionality along with some core functions and 2) Pathway API, which is
# the uniform API available to the external world to do useful things within
# EMS (Pathway is the name of the project that generated these API). A miniEMS
# executable is built that in the minimum reads in EMS files examines and
# manipulates them without a graphics interface. The extent of the 
# functionality is limited by the commands coded in the command-loop of 
# miniEMS's 'main'. To build the executable, one must run the Makefile in the
# "miniEMS" directory.
#
# None of the messages or functions of BaseEMS are directly accessed. The
# layer - Pathway - is built on top of BaseEMS. It is more than a thin veneer. 
# Some new functionality, and a lot of re-work has gone into this layer. 
#
# One of the aims of this testbed is to test this Pathway API layer. This is
# the layer we want to expose to the world. All the commands in this testbed 
# will use either the APIs from Pathway or the APIs from BSPMATH and no other
# function calls or message sends. This strict discipline has to be followed
# in order to prove the completeness of the API. Conspicuous by their absence
# are the OM primitives, messages, complex function calls from EMS, etc.
#
# The testbed is built on top of:
# EXNUC -- Basic OM
# *BSPMATH  -- All of the math
# BaseEMS  -- Select set of messages and functions
# *Pathway  -- The outer layer on EMS with some enhanced functionality.
# (the starred items are the only ones that offer the APIs)
#

verifyenv CLIPPER MDTARG MODEL EXNUC BS

GRNUC=/usr2/ip32/grnucsource
export MINIEMS=/usr3/ip32/modelsource/miniems
export MINIEMSSRC=/usr3/ip32/miniEMSsrc/miniems
export MINIEMSTARG=/usr3/ip32/miniEMS34/miniems

if [ $CLIPPER = "y" ]
then

if [ ! -d ${MINIEMSSRC} ]
then
  echo Creating ${MINIEMSSRC}
  mkdir -p ${MINIEMSSRC}
  if [ ! -d ${MINIEMSSRC} ]
  then
    echo Could not create ${MINIEMSSRC}
    exit 1
  fi
fi

#
# --------- Populate the include/grnuc ---------
#

if [ ! -d ${MINIEMSSRC}/include/grnuc ]
then
  echo Creating ${MINIEMSSRC}/include/grnuc
  mkdir -p ${MINIEMSSRC}/include/grnuc
fi

rm ${MINIEMS}/include/grnuc/*
echo Linking GRNUC include files
for i in `cat ${MINIEMS}/list_grH`
do
  ln ${GRNUC}/$i ${MINIEMSSRC}/include/grnuc
done

#
# --------- Populate the include/model ---------
#

if [ ! -d ${MINIEMSSRC}/include/model ]
then
  echo Creating ${MINIEMSSRC}/include/model
  mkdir -p ${MINIEMSSRC}/include/model
fi

rm ${MINIEMSSRC}/include/model/*
echo Linking MODEL include files
for i in `cat ${MINIEMS}/list_mdH`
do
  ln ${MODEL}/$i ${MINIEMSSRC}/include/model
done

#
# --------- Populate the include/api ---------
#

if [ ! -d ${MINIEMSSRC}/include/api ]
then
  echo Creating ${MINIEMSSRC}/include/api
  mkdir -p ${MINIEMSSRC}/include/api
fi

if [ ! -d ${MINIEMSSRC}/include/api/PWapi ]
then
  echo Creating ${MINIEMSSRC}/include/api/PWapi
  mkdir -p ${MINIEMSSRC}/include/api/PWapi
fi

rm ${MINIEMSSRC}/include/api/*
echo Linking API include files
for i in `cat ${MINIEMS}/list_apiH`
do
  ln ${MODEL}/$i ${MINIEMSSRC}/include/api
done

rm ${MINIEMSSRC}/include/api/PWapi/*
echo Linking API-prototypes
for i in `cat ${MINIEMS}/list_apiprotoH`
do
  ln ${MODEL}/$i ${MINIEMSSRC}/include/api/PWapi
done

#
# ---------- Populate the spec/grnuc -------------
#

if [ ! -d ${MINIEMSSRC}/spec/grnuc ]
then 
  echo Creating ${MINIEMSSRC}/spec/grnuc
  mkdir -p ${MINIEMSSRC}/spec/grnuc
fi

rm ${MINIEMSSRC}/spec/grnuc/*.S
echo Linking GRNUC spec files
for i in `cat ${MINIEMS}/list_grS`
do
  ln ${GRNUC}/$i ${MINIEMSSRC}/spec/grnuc
done

rm ${MINIEMSSRC}/spec/grnuc/spec.m
echo Generating ${MINIEMSSRC}/spec/grnuc/spec.m
cp ${MINIEMS}/grspec.m ${MINIEMSSRC}/spec/grnuc/spec.m
for i in `cat ${MINIEMS}/list_grS`
do
  echo `basename $i` >> ${MINIEMSSRC}/spec/grnuc/spec.m
done



#
# -----------  Populate the spec/model --------------
#

if [ ! -d ${MINIEMSSRC}/spec/model ]
then 
  echo Creating ${MINIEMSSRC}/spec/model
  mkdir -p ${MINIEMSSRC}/spec/model
fi

rm ${MINIEMSSRC}/spec/model/*.S
echo Linking MODEL spec files
for i in `cat ${MINIEMS}/list_mdS`
do
  ln ${MODEL}/$i ${MINIEMSSRC}/spec/model
done

echo Generating ${MINIEMSSRC}/spec/model/spec.m
cp ${MINIEMS}/mdspec.m ${MINIEMSSRC}/spec/model/spec.m
for i in `cat ${MINIEMS}/list_mdS`
do
  echo `basename $i` >> ${MINIEMSSRC}/spec/model/spec.m
done


#
# ---------- Populate the spec/uom -------------
#

if [ ! -d ${MINIEMSSRC}/spec/uom ]
then 
  echo Creating ${MINIEMSSRC}/spec/uom
  mkdir -p ${MINIEMSSRC}/spec/uom
fi

rm ${MINIEMSSRC}/spec/uom/*.S
echo Linking UOM spec files
for i in `cat ${MINIEMS}/list_uomS`
do
  ln ${GRNUC}/$i ${MINIEMSSRC}/spec/uom
done

rm ${MINIEMSSRC}/spec/uom/spec.m
echo Generating ${MINIEMSSRC}/spec/uom/spec.m
cp ${MINIEMS}/uomspec.m ${MINIEMSSRC}/spec/uom/spec.m
for i in `cat ${MINIEMS}/list_uomS`
do
  echo `basename $i` >> ${MINIEMSSRC}/spec/uom/spec.m
done


#
# ---------- Populate the imp/grnuc -------------
#

if [ ! -d ${MINIEMSSRC}/imp/grnuc ]
then 
  echo Creating ${MINIEMSSRC}/imp/grnuc
  mkdir -p ${MINIEMSSRC}/imp/grnuc
fi

rm ${MINIEMSSRC}/imp/grnuc/*.I
echo Linking GRNUC implementation files
for i in `cat ${MINIEMS}/list_grI`
do
  ln ${GRNUC}/$i ${MINIEMSSRC}/imp/grnuc
done

rm ${MINIEMSSRC}/imp/grnuc/imp.m
echo Generating ${MINIEMSSRC}/imp/grnuc/imp.m
cp ${MINIEMS}/grimp.m ${MINIEMSSRC}/imp/grnuc/imp.m
for i in `cat ${MINIEMS}/list_grI`
do
  echo `basename $i` >> ${MINIEMSSRC}/imp/grnuc/imp.m
done


#
# ---------- Populate the imp/model -------------
#

if [ ! -d ${MINIEMSSRC}/imp/model ]
then 
  echo Creating ${MINIEMSSRC}/imp/model
  mkdir -p ${MINIEMSSRC}/imp/model
fi

rm ${MINIEMSSRC}/imp/model/*.I
echo Linking MODEL implementation files
for i in `cat ${MINIEMS}/list_mdI`
do
  ln ${MODEL}/$i ${MINIEMSSRC}/imp/model
done

rm ${MINIEMSSRC}/imp/model/imp.m
echo Generating ${MINIEMSSRC}/imp/model/imp.m
cp ${MINIEMS}/mdimp.m ${MINIEMSSRC}/imp/model/imp.m
for i in `cat ${MINIEMS}/list_mdI`
do
  echo `basename $i` >> ${MINIEMSSRC}/imp/model/imp.m
done


#
# ---------- Populate the imp/uom -------------
#

if [ ! -d ${MINIEMSSRC}/imp/uom ]
then 
  echo Creating ${MINIEMSSRC}/imp/uom
  mkdir -p ${MINIEMSSRC}/imp/uom
fi

rm ${MINIEMSSRC}/imp/uom/*.I
echo Linking UOM implementation files
for i in `cat ${MINIEMS}/list_uomI`
do
  ln ${GRNUC}/$i ${MINIEMSSRC}/imp/uom
done

rm ${MINIEMSSRC}/imp/uom/imp.m
echo Generating ${MINIEMSSRC}/imp/uom/imp.m
cp ${MINIEMS}/uomimp.m ${MINIEMSSRC}/imp/uom/imp.m
for i in `cat ${MINIEMS}/list_uomI`
do
  echo `basename $i` >> ${MINIEMSSRC}/imp/uom/imp.m
done

#
# ---------- Populate the funk/grnuc -------------
#

if [ ! -d ${MINIEMSSRC}/funk/grnuc ]
then 
  echo Creating ${MINIEMSSRC}/funk/grnuc
  mkdir -p ${MINIEMSSRC}/funk/grnuc
fi

rm ${MINIEMSSRC}/funk/grnuc/*.[ICc]
echo Linking GRNUC function files
for i in `cat ${MINIEMS}/list_grF`
do
  ln ${GRNUC}/$i ${MINIEMSSRC}/funk/grnuc
done

rm ${MINIEMSSRC}/funk/grnuc/funk.m
echo Generating ${MINIEMSSRC}/funk/grnuc/funk.m
cp ${MINIEMS}/grfunk.m ${MINIEMSSRC}/funk/grnuc/funk.m
for i in `cat ${MINIEMS}/list_grF`
do
  echo `basename $i` >> ${MINIEMSSRC}/funk/grnuc/funk.m
done


#
# ---------- Populate the funk/model -------------
#

if [ ! -d ${MINIEMSSRC}/funk/model ]
then 
  echo Creating ${MINIEMSSRC}/funk/model
  mkdir -p ${MINIEMSSRC}/funk/model
fi

rm ${MINIEMSSRC}/funk/model/*.[ICc]
echo Linking MODEL function files
for i in `cat ${MINIEMS}/list_mdF`
do
  ln ${MODEL}/$i ${MINIEMSSRC}/funk/model
done

rm ${MINIEMSSRC}/funk/model/funk.m
echo Generating ${MINIEMSSRC}/funk/model/funk.m
cp ${MINIEMS}/mdfunk.m ${MINIEMSSRC}/funk/model/funk.m
for i in `cat ${MINIEMS}/list_mdF`
do
  echo `basename $i` >> ${MINIEMSSRC}/funk/model/funk.m
done

#
# ---------- Populate the api -------------
#

for i in $(< ${MINIEMS}/list_apiD)
do
  if [ ! -d ${MINIEMSSRC}/api/`basename $i` ]
  then 
    echo Creating ${MINIEMSSRC}/api/`basename $i`
      mkdir -p ${MINIEMSSRC}/api/`basename $i`
  fi

  rm ${MINIEMSSRC}/api/`basename $i`/*.[ICc]
  echo Linking API -- `basename $i` files
  ln ${MODEL}/$i/*.[ICc] ${MINIEMSSRC}/api/`basename $i`

  rm ${MINIEMSSRC}/api/`basename $i`/funk.m
  echo Generating ${MINIEMSSRC}/api/`basename $i`/funk.m
  funkm=${MINIEMSSRC}/api/`basename $i`/funk.m
  cp ${MINIEMS}/api.m ${funkm}
  echo >> ${funkm}
  echo SRC >> ${funkm}
  echo '$(MINIEMSSRC)/api/'`basename $i` >> ${funkm}
  echo >> ${funkm}
  echo '#ifdef NT' >> ${funkm}
  echo ARCHIVE >> ${funkm} 
  echo '$(MINIEMSTARG)/lib/'`basename $i`.lib >> ${funkm}
  echo '#else' >> ${funkm}
  echo LIB >> ${funkm}
  echo '$(MINIEMSTARG)/lib/'`basename $i`.o >> ${funkm}
  echo '#endif /* NT */' >> ${funkm}
  echo >> ${funkm}
  echo SOURCE >> ${funkm}
  for j in `ls ${MODEL}/$i/*.[ICc]`
  do
       echo `basename $j` >> ${funkm}
  done

done

#
# ---------- Populate the stubs directory -------------
#

if [ ! -d ${MINIEMSSRC}/stubs ]
then
  echo Creating ${MINIEMSSRC}/stubs
  mkdir -p ${MINIEMSSRC}/stubs
fi

rm ${MINIEMSSRC}/stubs/*.[ICcSh]
cd ${MINIEMS}/stubs

echo  "Copying EXNUC related files..."

cp $EXNUC/exec/IGEcolor/IGEchgclr.I .
SCfetch miniems/stubs/IGEchgclr.I

cp $EXNUC/spec/global_class.S .
SCfetch miniems/stubs/global_class.S

cp $EXNUC/spec/IGEcolor2.S .
SCfetch miniems/stubs/IGEcolor2.S

cp $EXNUC/include/igecolor.h .
SCfetch miniems/stubs/igecolor.h

echo  "Copying of EXNUC Files Done."

echo Linking stubs files
for i in `ls *.[ICcSh]`
do
  ln $i ${MINIEMSSRC}/stubs
done

rm ${MINIEMSSRC}/stubs/stubs.m
echo Generating ${MINIEMSSRC}/stubs/stubs.m
cp ${MINIEMS}/stubs.m ${MINIEMSSRC}/stubs/stubs.m
cd ${MINIEMS}/stubs
for i in `ls *.[ICcS]`
do
  echo $i >> ${MINIEMSSRC}/stubs/stubs.m
done
cd -

#
#------------ Building the miniEMS directory -----------
#

if [ ! -d ${MINIEMSSRC}/miniEMS ]
then 
  echo Creating ${MINIEMSSRC}/miniEMS
  mkdir -p ${MINIEMSSRC}/miniEMS
fi

cd ${MINIEMSSRC}/miniEMS
rm ${MINIEMSSRC}/miniEMS/*.[ICcSh]



fi # if [ $CLIPPER = y ]

banner COMPILING


#
#-------------- Generate the makefiles ------------------
#

if [ ! -d ${MINIEMSTARG}/spec/model ]
then
  echo Creating ${MINIEMSTARG}/spec/model
  mkdir -p ${MINIEMSTARG}/spec/model
  if [ ! -d ${MINIEMSTARG}/spec/model ]
  then
    echo Could not create ${MINIEMSTARG}/spec/model
    exit 1
  fi
fi

rm ${MINIEMSTARG}/spec/model/makefile
cd ${MINIEMSSRC}/spec/model
grmakemake spec.m ${MINIEMSTARG}/spec/model/makefile

if [ ! -d ${MINIEMSTARG}/spec/grnuc ]
then
  echo Creating ${MINIEMSTARG}/spec/grnuc
  mkdir -p ${MINIEMSTARG}/spec/grnuc
  if [ ! -d ${MINIEMSTARG}/spec/grnuc ]
  then
    echo Could not create ${MINIEMSTARG}/spec/grnuc
    exit 1
  fi
fi

rm ${MINIEMSTARG}/spec/grnuc/makefile
cd ${MINIEMSSRC}/spec/grnuc
grmakemake spec.m ${MINIEMSTARG}/spec/grnuc/makefile

if [ ! -d ${MINIEMSTARG}/spec/uom ]
then
  echo Creating ${MINIEMSTARG}/spec/uom
  mkdir -p ${MINIEMSTARG}/spec/uom
  if [ ! -d ${MINIEMSTARG}/spec/uom ]
  then
    echo Could not create ${MINIEMSTARG}/spec/uom
    exit 1
  fi
fi

rm ${MINIEMSTARG}/spec/uom/makefile
cd ${MINIEMSSRC}/spec/uom
grmakemake spec.m ${MINIEMSTARG}/spec/uom/makefile

if [ ! -d ${MINIEMSTARG}/imp/grnuc ]
then
  echo Creating ${MINIEMSTARG}/imp/grnuc
  mkdir -p ${MINIEMSTARG}/imp/grnuc
  if [ ! -d ${MINIEMSTARG}/imp/grnuc ]
  then
    echo Could not create ${MINIEMSTARG}/imp/grnuc
    exit 1
  fi
fi

rm ${MINIEMSTARG}/imp/grnuc/makefile
cd ${MINIEMSSRC}/imp/grnuc
grmakemake imp.m ${MINIEMSTARG}/imp/grnuc/makefile

if [ ! -d ${MINIEMSTARG}/imp/model ]
then
  echo Creating ${MINIEMSTARG}/imp/model
  mkdir -p ${MINIEMSTARG}/imp/model
  if [ ! -d ${MINIEMSTARG}/imp/model ]
  then
    echo Could not create ${MINIEMSTARG}/imp/model
    exit 1
  fi
fi

rm ${MINIEMSTARG}/imp/model/makefile
cd ${MINIEMSSRC}/imp/model
grmakemake imp.m ${MINIEMSTARG}/imp/model/makefile

if [ ! -d ${MINIEMSTARG}/imp/uom ]
then
  echo Creating ${MINIEMSTARG}/imp/uom
  mkdir -p ${MINIEMSTARG}/imp/uom
  if [ ! -d ${MINIEMSTARG}/imp/uom ]
  then
    echo Could not create ${MINIEMSTARG}/imp/uom
    exit 1
  fi
fi

rm ${MINIEMSTARG}/imp/uom/makefile
cd ${MINIEMSSRC}/imp/uom
grmakemake imp.m ${MINIEMSTARG}/imp/uom/makefile

if [ ! -d ${MINIEMSTARG}/funk/grnuc ]
then
  echo Creating ${MINIEMSTARG}/funk/grnuc
  mkdir -p ${MINIEMSTARG}/funk/grnuc
  if [ ! -d ${MINIEMSTARG}/funk/grnuc ]
  then
    echo Could not create ${MINIEMSTARG}/funk/grnuc
    exit 1
  fi
fi

rm ${MINIEMSTARG}/funk/grnuc/makefile
cd ${MINIEMSSRC}/funk/grnuc
grmakemake funk.m ${MINIEMSTARG}/funk/grnuc/makefile

if [ ! -d ${MINIEMSTARG}/funk/model ]
then
  echo Creating ${MINIEMSTARG}/funk/model
  mkdir -p ${MINIEMSTARG}/funk/model
  if [ ! -d ${MINIEMSTARG}/funk/model ]
  then
    echo Could not create ${MINIEMSTARG}/funk/model
    exit 1
  fi
fi

rm ${MINIEMSTARG}/funk/model/makefile
cd ${MINIEMSSRC}/funk/model
grmakemake funk.m ${MINIEMSTARG}/funk/model/makefile

if [ ! -d ${MINIEMSTARG}/stubs ]
then
  echo Creating ${MINIEMSTARG}/stubs
  mkdir -p ${MINIEMSTARG}/stubs
  if [ ! -d ${MINIEMSTARG}/stubs ]
  then
    echo Could not create ${MINIEMSTARG}/stubs
    exit 1
  fi
fi

rm ${MINIEMSTARG}/stubs/makefile
cd ${MINIEMSSRC}/stubs
grmakemake stubs.m ${MINIEMSTARG}/stubs/makefile

for i in $(< ${MINIEMS}/list_apiD)
do

  if [ ! -d ${MINIEMSTARG}/api/`basename $i` ]
  then 
    echo Creating ${MINIEMSTARG}/api/`basename $i`
    mkdir -p ${MINIEMSTARG}/api/`basename $i`
  fi

  rm -f ${MINIEMSTARG}/api/`basename $i`/makefile
  cd ${MINIEMSSRC}/api/`basename $i`
  grmakemake funk.m ${MINIEMSTARG}/api/`basename $i`/makefile
done

#
#-------------- Build the libraries ------------------
#

if [ ! -d ${MINIEMSTARG}/lib ]
then
  echo Creating ${MINIEMSTARG}/lib
  mkdir -p ${MINIEMSTARG}/lib
  if [ ! -d ${MINIEMSTARG}/lib ]
  then
    echo Could not create ${MINIEMSTARG}/lib
    exit 1
  fi
fi

echo Building GRNUC spec library
cd ${MINIEMSTARG}/spec/grnuc
grmake 
cd -

echo Building MODEL spec library
cd ${MINIEMSTARG}/spec/model
grmake 
cd -

echo Building UOM spec library
cd ${MINIEMSTARG}/spec/uom
grmake 
cd -

echo Building GRNUC imp library
cd ${MINIEMSTARG}/imp/grnuc
grmake 
cd -

echo Building MODEL imp library
cd ${MINIEMSTARG}/imp/model
grmake 
cd -

echo Building UOM imp library
cd ${MINIEMSTARG}/imp/uom
grmake 
cd -

echo Building GRNUC funk library
cd ${MINIEMSTARG}/funk/grnuc
grmake 
cd -

echo Building MODEL funk library
cd ${MINIEMSTARG}/funk/model
grmake 
cd -

echo Building stubs library
cd ${MINIEMSTARG}/stubs
grmake 
cd -

echo Building API libraries
for i in $(< ${MINIEMS}/list_apiD)
do
  echo `basename $i`:
  cd ${MINIEMSTARG}/api/`basename $i`
  grmake 
  cd -
done

if [ ! -d ${MINIEMSTARG}/miniEMS ]
then
  echo Creating ${MINIEMSTARG}/miniEMS
  mkdir -p ${MINIEMSTARG}/miniEMS
  if [ ! -d ${MINIEMSTARG}/miniEMS ]
  then
    echo Could not create ${MINIEMSTARG}/miniEMS
    exit 1
  fi
fi

cp $MINIEMS/miniEMS/Makefile $MINIEMSTARG/miniEMS/Makefile
cp $MINIEMS/miniEMS/main.c $MINIEMSTARG/miniEMS/main.c
cp $MINIEMS/miniEMS/main.c $MINIEMSSRC/miniEMS/main.c

if [ ! -d ${MINIEMSTARG}/bin ]
then
  echo Creating ${MINIEMSTARG}/bin
  mkdir -p ${MINIEMSTARG}/bin
  if [ ! -d ${MINIEMSTARG}/bin ]
  then
    echo Could not create ${MINIEMSTARG}/bin
    exit 1
  fi
fi

if [ ! -d ${MINIEMSSRC}/nt ]
then
	mkdir -p ${MINIEMSSRC}/nt/build/vb
	cp ${MINIEMS}/nt/build/* ${MINIEMSSRC}/nt/build
	cp ${MINIEMS}/nt/build/vb/* ${MINIEMSSRC}/nt/build/vb
	mkdir -p ${MINIEMSSRC}/nt/src
	cp ${MINIEMS}/nt/src/* ${MINIEMSSRC}/nt/src
fi

cd $MINIEMSTARG/miniEMS
rm -f $MINIEMSTARG/miniEMS/miniEMS
make

if [ ! -f $MINIEMSTARG/miniEMS/miniEMS ]
then
  banner FAILURE
else
  banner SUCCESS
fi
