###
if [ "$SUN" = "y" ]
then
  echo
  if [ "$SUN5" = "y" ]
  then
    export COMPOPT="-xO1 -Xc"
  else if [ "$SUNZX" = "y" ]
       then
         export COMPOPT="-xO1 -Xc -xcg92"
       else
         export COMPOPT="-O1"
         export EXECOPT=-L/usr/5lib
       fi
  fi
fi
###

#echo "\n\tGENERAL CI make ..."        # To avoid confusion with /bin/make

#check shell variables

if [ -z "$EXNUC" ]
then
  echo "Variable \$EXNUC not set!"
  exit
fi

if [ -z "$GRNUC" ]
then
  echo "Variable \$GRNUC not set!"
  exit
fi

#so that makemake will work with cci.m

if [ ! -r $GRTARG/src/pplsrc/cci/ciy.h ]
then
  touch $GRTARG/src/pplsrc/cci/ciy.h
fi

#link spec files into appropiate source directories

ln spec/ciexpr.S      ciexpr    2>/dev/null
ln spec/ci_executor.S executor  2>/dev/null
ln spec/ci_listener.S listener  2>/dev/null
ln spec/COcisetup.S   setup     2>/dev/null
ln spec/COcidgnop.S   src       2>/dev/null
ln spec/super_ci.S    src       2>/dev/null
ln spec/ci.S          src       2>/dev/null
ln spec/COci.S        src       2>/dev/null
ln spec/user_data.S   user_data 2>/dev/null

mkdir $GRTARG/src/pplsrc/lib $GRTARG/src/pplsrc/bin 2>/dev/null

for i in  com src setup cinotify ciexpr listener executor user_data cci
do
  echo "---------------- $GRTARG/src/pplsrc/$i ---------------------"
  cd $GRTARG/src/pplsrc/$i

  grmake -r -k -f $GRNUC/src/makefile

  if [ "$i" = "src" ]
  then
    if [ "$SUN5" = "y" ] || [ "$ISL" = "y" ] || [ "$SUNZX" = "y" ]
    then
      grmake -r -k -f makeimp
    fi
  fi
done

if [ "$SUN" = "y" -o "$ISL" = "y" ]
then
  ncp $GRTARG/src/pplsrc/cci/SUN_libPW.o $GRTARG/lib/isl
  ncp $GRTARG/src/pplsrc/cci/SUNregex/libregexp.a $GRTARG/lib/isl
fi
