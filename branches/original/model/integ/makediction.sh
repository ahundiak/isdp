#
# makediction.sh - make dictionary directory
# 
#    Usage  : makediction.sh
#    Inputs : none
#    Output : error messages
#    Return : none
#      Code   
#
#    Tim McKee  02/13/93
# $Log: makediction.sh,v $
# Revision 1.1.1.1  2001/12/17 22:40:43  hans
# Initial import to CVS
#
# Revision 340.0  1997/05/28  16:07:33  root
# COMMENT : Initial checkin to 3.4.0 RCS from 3.3.0 src
#
# Revision 330.1  1996/12/20  17:36:40  model33
# COMMENT : Removed ID command objects from dictionary
#
# Revision 330.0  1996/01/11  23:15:24  root
# COMMENT : Initial checkin to 3.3.0 RCS from 3.2.0 src
#
# Revision 320.0  1994/12/12  22:48:04  root
# COMMENT : Initial checkin to 3.2 RCS from 3.1 src
#
# Revision 240.4  1994/10/29  04:41:13  scott
# COMMENT : Added SUNZX platform 3.2 ports
#
# Revision 240.3  1993/09/23  15:28:05  model20
# COMMENT : Fixed cpio problem transfering *.S on the Solaris
#
# Revision 240.2  1993/09/17  13:57:58  scott
# COMMENT : Added support for the integration and delivery of a Sparc Solaris platform
#
# Revision 240.1  1993/07/07  21:02:26  model20
# COMMENT : fixed build problems making dictionary on sun and newprod of iems/draft
#
# Revision 240.0  1993/03/26  21:30:43  model22
# COMMENT : initial checkin
#
# Revision 220.6  1993/02/24  18:46:53  model22
# COMMENT : build crap
#
# Revision 220.5  1993/02/23  23:52:13  model22
# COMMENT : make the dictionary correctly
#
# Revision 220.4  1993/02/18  21:10:53  model22
# COMMENT : fixed problems making dictionary
#
# Revision 220.3  1993/02/16  00:01:26  model22
# COMMENT : fixes for unit testing
#
# Revision 220.1  1993/02/14  20:26:32  tim
# COMMENT : put in unit test code
#
# Revision 220.0  1993/02/13  23:07:52  tim
# COMMENT : changes to integration scripts to do unit testing
#
#

verifyenv SUN5 SUNZX SGI MODEL MDTARG 

DICTFILE=

necho "- - - - - - - Making dict directory - - - - - - - "
nrm $MDTARG/config/class_defns

# copy .S files to dict directory
cd $MODEL/spec
DICTSPEC="*.S"

if [ "$SUN5" = "y" -o "$SUNZX" = "y" ]
then
   ls $DICTSPEC > /tmp/dict.$$
   for file in `cat /tmp/dict.$$`
   do 
      ncp $MODEL/spec/$file $MDTARG/dict
   done
   rm /tmp/dict.$$
else
   find $DICTSPEC -print | cpio -pml $MDTARG/dict
fi

DICTT="*.T"

# copy .T's to $MDTARG/dict
cd $MODEL/dict
ls $DICTT > /tmp/dict.$$
for file in `cat /tmp/dict.$$`
 do 
   ncp $MODEL/dict/$file $MDTARG/dict
done
rm /tmp/dict.$$

cd $MDTARG/dict
for file2rm in EC* CO* ID*
do
   nrm $file2rm
done

if [ -s $MODEL/dict/REMLIST ]
then
  necho "Removing files specified in REMLIST . . ."
  for file in `cat $MODEL/dict/REMLIST`
  do
    nrm $file
  done
fi

necho " "

$MODEL/integ/mkmkdict.sh > /tmp/bldlog 2>&1
grmakemake mddict.m makefile > /tmp/bldlog 2>&1
ncat /tmp/bldlog
make -k $DICTFILE > /tmp/bldlog 2>&1
ncat /tmp/bldlog
if [ "$ERRNOTI" = "on" ]
 then
   make -k $DICTFILE > /tmp/bldlog 2>&1
   errchk /tmp/bldlog dict
fi


