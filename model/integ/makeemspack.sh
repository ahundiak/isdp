#
# makeemspack.sh - make ems specific stuff
# 
#    Usage  : makeemspack.sh
#    Inputs : none
#    Output : error messages
#    Return : none
#      Code   
#
#    Tim McKee  02/13/93
# $Log: makeemspack.sh,v $
# Revision 1.1.1.1  2001/12/17 22:40:43  hans
# Initial import to CVS
#
# Revision 340.2  1997/07/10  14:03:02  scott
# COMMENT : Modified to conform to new integration configuration
#
# Revision 340.1  1997/06/05  14:09:43  model34
# COMMENT : Modified to look on the target side for exnuc executables
#
# Revision 340.0  1997/05/28  16:07:35  root
# COMMENT : Initial checkin to 3.4.0 RCS from 3.3.0 src
#
#

verifyenv MODEL MDTARG ISL SGI SUN5 SUNZX CLIPPER EXNUC EXTARG 
verifyenv COMPILER COMPOPT GRNUC

necho "- - - - - - - Making Ems packages - - - - - - - - "

if [ "$CLIPPER" = "y" ]
then
  #
  # copy function keys for ems low res
  #
  ncp $MODEL/ems/emsui02/config/functn_key.sun $MODEL/ems/emsui02l/config/functn_key.sun
  ncp $MODEL/ems/emsui02/config/functn2_sun    $MODEL/ems/emsui02l/config/functn2_sun
  ncp $MODEL/ems/emsui02/config/function_key   $MODEL/ems/emsui02l/config/function_key
  ncp $MODEL/ems/emsui02/config/functn2_key    $MODEL/ems/emsui02l/config/functn2_key
  #
  # copy function keys for ultra lite low res
  #
  ncp $MODEL/ems/emsuiu/config/functn_key.sun $MODEL/ems/emsuiul/config/functn_key.sun
  ncp $MODEL/ems/emsuiu/config/functn2_sun    $MODEL/ems/emsuiul/config/functn2_sun
  ncp $MODEL/ems/emsuiu/config/function_key   $MODEL/ems/emsuiul/config/function_key
  ncp $MODEL/ems/emsuiu/config/functn2_key    $MODEL/ems/emsuiul/config/functn2_key

fi

if [ "$ISL" = "y" -o "$SUN5" = "y" -o "$SUNZX" = "y" -o "$SGI" = "y" ]
then
  verifyenv DISPLAY
  #
  # ems
  ncp $MODEL/ems/emsui02/config/functn_key.sun $MDTARG/ems/emsui02/config/function_key
  ncp $MODEL/ems/emsui02/config/functn2_sun $MDTARG/ems/emsui02/config/functn2_key
  #
  # ultra lite
  ncp $MODEL/ems/emsuiu/config/functn_key.sun $MDTARG/ems/emsuiu/config/function_key
  ncp $MODEL/ems/emsuiu/config/functn2_sun $MDTARG/ems/emsuiu/config/functn2_key

  ncp $MODEL/ems/prompts.sun $MDTARG/ems/prompts.eng

  if [ "$ISL" = "y" ]
  then
    #
    # ems low res 
    ncp $MODEL/ems/emsui02l/config/functn_key.sun $MDTARG/ems/emsui02l/config/function_key
    ncp $MODEL/ems/emsui02l/config/functn2_sun $MDTARG/ems/emsui02l/config/functn2_key
    #
    # ulra lite low res
    ncp $MODEL/ems/emsuiul/config/functn_key.sun $MDTARG/ems/emsuiul/config/function_key
    ncp $MODEL/ems/emsuiul/config/functn2_sun $MDTARG/ems/emsuiul/config/functn2_key
  fi
else
  #
  # ems
  ncp $MODEL/ems/emsui02/config/function_key $MDTARG/ems/emsui02/config/function_key
  ncp $MODEL/ems/emsui02/config/functn2_key $MDTARG/ems/emsui02/config/functn2_key
  #
  # ultra lite 
  ncp $MODEL/ems/emsuiu/config/function_key $MDTARG/ems/emsuiu/config/function_key
  ncp $MODEL/ems/emsuiu/config/functn2_key $MDTARG/ems/emsuiu/config/functn2_key

  ncp $MODEL/ems/prompts.eng $MDTARG/ems/prompts.eng
fi

# copy echopath from Grnuc to $MDTARG
ncp $GRNUC/bin/echopath $MDTARG/ems/echopath
    
if [ "${CLIPPER}" = "y" ]
then
  chmod +x $MODEL/ems/bin/ems
fi

# if on isl then build both low and high res menus
if [ "$ISL" = "y" ]
then
  LIST="emspcs/config emsppp/config emsplt/config mds/config emsult/config ems/emsui02/config/english/menus ems/emsui02l/config/english/menus ems/emsuilt/config/english/menus ems/emsuiltl/config/english/menus ems/emsuiu/config/english/menus ems/emsuiul/config/english/menus emsapps"
  LFILE=
else
  LIST="emspcs/config emsppp/config emsplt/config mds/config emsult/config ems/emsui02/config/english/menus ems/emsuilt/config/english/menus ems/emsuiu/config/english/menus emsapps"
  LFILE=
fi

for file in $LIST
do
  cd $MDTARG/$file
  grmake -rk -f $MODEL/$file/Makefile $LFILE > /tmp/bldlog 2>&1
  ncat /tmp/bldlog
  if [ "$ERRNOTI" = "on" ]
  then
    grmake -rk -f $MODEL/$file/Makefile $LFILE > /tmp/bldlog 2>&1
    errchk /tmp/bldlog $file
    if [ -f gencmdtbl.err ]
    then 
      errchk gencmdtbl.err $file
    fi
  fi
done

if [ "$SGI" = "y" ]
then
  for file in ems/emsui02/config/english/menus ems/emsuilt/config/english/menus ems/emsuiu/config/english/menus
  do
    echo "\n\n\n\nKLUDGE KLUDGE KLUDGE KLUDGE " > /tmp/Kludge.$$
    echo "xgenmenu not working on SGI......" >> /tmp/Kludge.$$
    echo "xgenmenu not working on SGI......" >> /tmp/Kludge.$$
    echo "xgenmenu not working on SGI......" >> /tmp/Kludge.$$
    echo "xgenmenu not working on SGI......" >> /tmp/Kludge.$$
    echo "When xgenmenu is fixed you can remove this Kludge" >> /tmp/Kludge.$$
    cat /tmp/Kludge.$$
    errchk /tmp/Kludge.$$ $file
    cd $MODEL/../model34/$file
    ls > /tmp/L.$$
    for menu in `cat /tmp/L.$$`
    do 
      ncp $MODEL/../model34/$file/$menu $MDTARG/$file/$menu
    done
    rm /tmp/L.$$
  done
fi

necho "- - - - - - - Making Ems application command strings - - - - - - - - "

LIST="emspcs emsppp emsplt mds emsult"

for file in $LIST
do
  gen_string.sh $file
done

necho "- - - - - - - building Frame Buffer Sensor - - - - - - -"
if [ "$SUN" = "y" ]
then
  cd $MDTARG/ems
  grmake -rk -f $MODEL/ems/Makefile > /tmp/bldlog 2>&1
  ncat /tmp/bldlog
  if [ "$ERRNOTI" = "on" ]
  then
    grmake -rk -f $MODEL/ems/Makefile > /tmp/bldlog 2>&1
    errchk /tmp/bldlog $file
  fi
fi


necho "- - - - - - - building application OMprodinits - - - - - - -"

if [ "$ISL" = "y" ]
then
  LIST1="ems/emsui02 ems/emsui02l"
else
  LIST1="ems/emsui02"
fi

for file in $LIST1
do
  cd $MDTARG/$file
  echo "...make $file/OMprodinit.o\n"
  $EXTARG/bin/omcpp -I$EXNUC/include -I$INGRHOME/include $MODEL/$file/OMprodinit.C > $MDTARG/$file/OMprodinit.c
  $COMPILER $COMPOPT -I$EXNUC/include -I$INGRHOME/include -c $MDTARG/$file/OMprodinit.c
  nrm $MDTARG/$file/OMprodinit.c
  nls $MDTARG/$file/OMprodinit.o
  if [ "$?" != "0" ]
  then 
    errrpt $0 "$MDTARG/$file/OMprodinit.o did not make"
  fi
done

necho "- - - - - - - make Ems version numbers - - - - - - - - "
makeemsver.sh

if [ "$CLIPPER" = "y" ]
then
  necho "- - - - - - - linking Ems newprod files - - - - - - - - "
  ln -f $MODEL/ems/newprod/ems/install.sh $MODEL/ems/newprod/ems/install.ssl
  ln -f $MODEL/ems/newprod/ems/install.sh $MODEL/ems/newprod/ems/install.sgi
  ln -f $MODEL/ems/newprod/ems/install.sh $MODEL/ems/newprod/ems/install.isl
  ln -f $MODEL/ems/newprod/ems/remove.sh $MODEL/ems/newprod/ems/remove.ssl
  ln -f $MODEL/ems/newprod/ems/remove.sh $MODEL/ems/newprod/ems/remove.sgi
  ln -f $MODEL/ems/newprod/ems/remove.sh $MODEL/ems/newprod/ems/remove.isl
  ln -f $MODEL/ems/bin/lgshell $MODEL/ems/bin/.lgshell
  # verify link succeeded
  nls $MODEL/ems/newprod/ems/install.ssl
  nls $MODEL/ems/newprod/ems/install.sgi
  nls $MODEL/ems/newprod/ems/install.isl
  nls $MODEL/ems/newprod/ems/remove.ssl
  nls $MODEL/ems/newprod/ems/remove.sgi
  nls $MODEL/ems/newprod/ems/remove.isl
  nls $MODEL/ems/bin/.lgshell 
  for file in emspcs emsppp emsplt mds
  do
    ln -f $MODEL/$file/bin/lgshell $MODEL/$file/bin/.lgshell
    ln -f $MODEL/emsnewprod/components $MODEL/$file/newprod/$file
    ln -f $MODEL/emsnewprod/components.ssl $MODEL/$file/newprod/$file
    ln -f $MODEL/emsnewprod/components.sgi $MODEL/$file/newprod/$file
    ln -f $MODEL/emsnewprod/components.isl $MODEL/$file/newprod/$file
    ln -f $MODEL/emsnewprod/install.sh $MODEL/$file/newprod/$file/install.sh
    ln -f $MODEL/emsnewprod/install.sh $MODEL/$file/newprod/$file/install.ssl
    ln -f $MODEL/emsnewprod/install.sh $MODEL/$file/newprod/$file/install.sgi
    ln -f $MODEL/emsnewprod/install.sh $MODEL/$file/newprod/$file/install.isl
    ln -f $MODEL/emsnewprod/remove.sh $MODEL/$file/newprod/$file/remove.sh
    ln -f $MODEL/emsnewprod/remove.sh $MODEL/$file/newprod/$file/remove.ssl
    ln -f $MODEL/emsnewprod/remove.sh $MODEL/$file/newprod/$file/remove.sgi
    ln -f $MODEL/emsnewprod/remove.sh $MODEL/$file/newprod/$file/remove.isl
  # verify links succeed
    nls $MODEL/$file/bin/.lgshell
    nls $MODEL/$file/newprod/$file
    nls $MODEL/$file/newprod/$file
    nls $MODEL/$file/newprod/$file/install.sh
    nls $MODEL/$file/newprod/$file/install.ssl
    nls $MODEL/$file/newprod/$file/install.sgi
    nls $MODEL/$file/newprod/$file/install.isl
    nls $MODEL/$file/newprod/$file/remove.sh
    nls $MODEL/$file/newprod/$file/remove.ssl
    nls $MODEL/$file/newprod/$file/remove.sgi
    nls $MODEL/$file/newprod/$file/remove.isl
  done
fi

