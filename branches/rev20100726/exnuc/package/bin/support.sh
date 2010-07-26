########################  Do Not want sh   #!/bin/sh
#
#	Creates the support files needed for newprod.
#
###########################################################################
#	Tunables:
#

CPIOEXT=.p	#	Default filename extension for cpio files.
SHEXT=.sh	#	Filename extension for cpio install scripts.

###########################################################################

TMPDIR=${TMPDIR:-/usr/tmp}
WRKDIR=$TMPDIR/$$support
ARGV0="`basename $0`"
USAGE="Usage: $ARGV0 [-e ext] -o dir -d dir [-i ext] prepack.env ...\n\
-e ext\t\tExtension for cpio files.  Default [$CPIOEXT].\n\
-o dir\t\tDestination directory for cpio files.\n\
-d dir\t\tSource directory for support template files.\n\
-i ext\t\tExtension for install files.  Default [$SHEXT].\n\
prepack.env ...\tList of prepackage environment files.\n\
"

mkdir $WRKDIR
trap "rm -rf $WRKDIR" 15 0
trap "rm -rf $WRKDIR; exit 2" 2

OPTIONS="o:e:d:i:"
set -- `getopt $OPTIONS $* 2>/dev/null`
if test $? != 0
then
	echo $USAGE >&2
	exit 2
fi
set -e

#	Validate the command line args.

DEST=
SRC=
for ARG in $*
do
	case $ARG
	in
	-o)	DEST=$2;	shift 2;;
	-e)	CPIOEXT=$2;	shift 2;;
	-d)	SRC=$2;	shift 2;;
	-i)	SHEXT=$2;	shift 2;;
	--)	shift;		break;;
	esac
done
if test -z "$DEST" -o ! -d "$DEST" -o -z "$CPIOEXT" -o -z "$*" -o -z "$SRC" \
   -o ! -d "$SRC" -o -z "$SHEXT"
then
	echo $USAGE >&2
	exit 2
fi

#	Create all the support files.
#(product.def,README,install.*,remove.*)
#	Create product.def
FILE_LIST=
while test -n "$*"
do
	CPIO=`basename $1 .env`		#  Cpio name as found in the itb.
	PFILE=${CPIO}${CPIOEXT}		#  Name of the cpio file to create

	FILE_LIST="$PFILE $FILE_LIST"
	shift
done

if test "$VARIANT" = "rt"
then
	DELattr="invisible"
	export DELattr
else
	DELattr="shared|preprocess"
	export DELattr
fi

cat <<- EOF > $DEST/product.def
	IDnumber=$IDnumber
	IDname=$IDname
	IDtitle="$IDtitle"
	IDversion=$IDversion
	IDdate=$IDdate
	IDclass="$IDclass"
	IDassoc="$IDassoc"
EOF
cat $DEST/DELsize >> $DEST/product.def
cat <<- EOF >> $DEST/product.def
	DELdir=$DELdir
	DELloadp=$DELloadp
	DELattr="$DELattr"
	DELarch="$DELarch"
EOF
cat $SRC/prod1.def >> $DEST/product.def
cat <<- EOF >> $DEST/product.def
	#README	$IDdate	"ALL ascii text"
	#product.def	$IDdate	"ALL ascii text"
EOF

export LIST="`echo $DELarch | sed 's/|/ /g'`"
for SYS in $LIST
do
if [ "$SYS" = "CLIPPER" ]
then
	echo "#install.sh	$IDdate	\"CLIPPER shell script\"" >> $DEST/product.def
	echo "#remove.sh	$IDdate	\"CLIPPER shell script\"" >> $DEST/product.def
	echo "#product.clip	$IDdate	\"CLIPPER shell script\"" >> $DEST/product.def
fi
if [ "$SYS" = "SUN" ]
then
	echo "#install.sun	$IDdate	\"SUN shell script\"" >> $DEST/product.def
	echo "#remove.sun	$IDdate	\"SUN shell script\"" >> $DEST/product.def
fi
if [ "$SYS" = "SPARC_SOLARIS" ]
then
	echo "#install.ssl	$IDdate	\"SPARC_SOLARIS shell script\"" >> $DEST/product.def
	echo "#remove.ssl	$IDdate	\"SPARC_SOLARIS shell script\"" >> $DEST/product.def
	echo "#product.ssl	$IDdate	\"SPARC_SOLARIS shell script\"" >> $DEST/product.def
fi
if [ "$SYS" = "MIPS_IRIX" ]
then
	echo "#install.sgi	$IDdate	\"MIPS_IRIX shell script\"" >>$DEST/product.def
	echo "#remove.sgi	$IDdate	\"MIPS_IRIX shell script\"" >>$DEST/product.def
	echo "#product.sgi	$IDdate	\"MIPS_IRIX shell script\"" >>$DEST/product.def
fi
if [ "$SYS" = "INTEL_SOLARIS" ]
then
	echo "#install.isl	$IDdate	\"INTEL_SOLARIS shell script\"" >>$DEST/product.def
	echo "#remove.isl	$IDdate	\"INTEL_SOLARIS shell script\"" >>$DEST/product.def
	echo "#product.isl	$IDdate	\"INTEL_SOLARIS shell script\"" >>$DEST/product.def
fi
done
echo "#ish.p	$IDdate	\"ALL compressed cpio archive\"">>$DEST/product.def
for file in $FILE_LIST
do
	PROCTYPE=`echo $file | cut -c1-2`
	case $PROCTYPE in
	c1)
		echo "#$file	$IDdate	\"CLIPPER compressed cpio archive\""
	;;
	c4)
		echo "#$file	$IDdate	\"CLIPPER compressed cpio archive\""
	;;
	s4)
		echo "#$file	$IDdate	\"SUN compressed cpio archive\""
	;;
	s5)
		echo "#$file	$IDdate	\"SPARC_SOLARIS compressed cpio archive\""
	;;
	m4)
		echo "#$file	$IDdate	\"MIPS_IRIX compressed cpio archive\""
	;;
	m5)
		echo "#$file	$IDdate	\"MIPS_IRIX compressed cpio archive\""
	;;
        i5)
		echo "#$file	$IDdate	\"INTEL_SOLARIS compressed cpio archive\""
	;;
       	*)
		echo "#$file	$IDdate	\"ALL compressed cpio archive\""
	;;
	esac
done >> $DEST/product.def
cat <<- EOF >> $DEST/product.def
	#END OF FILE INFORMATION

	#TAPE ORDER
	##sequential order of files on tape
EOF
########## Removed from TAPE ORDER, 25-Oct-93 JWW ###############
	#README
	#product.def
########## Removed 25-Oct-93 JWW ###############
#for SYS in $LIST
#do
#if [ "$SYS" = "CLIPPER" ]
#then
#	echo "#install.sh">> $DEST/product.def
#	echo "#remove.sh">> $DEST/product.def
#fi
#if [ "$SYS" = "SUN" ]
#then
#	echo "#install.sun">> $DEST/product.def
#	echo "#remove.sun">> $DEST/product.def
#fi
#if [ "$SYS" = "SPARC_SOLARIS" ]
#then
#	echo "#install.ssl">> $DEST/product.def
#	echo "#remove.ssl">> $DEST/product.def
#fi
#if [ "$SYS" = "MIPS_IRIX" ]
#then
#	echo "#install.sgi">> $DEST/product.def
#	echo "#remove.sgi">> $DEST/product.def
#fi
#done
########## Removed 25-Oct-93 JWW ###############
echo "#ish.p" >> $DEST/product.def
for file in $FILE_LIST
do
	echo "#$file"
done >> $DEST/product.def
cat <<- EOF >> $DEST/product.def
	#END OF TAPE ORDER

	#FLOPPY ORDER
	##sequential order of files on floppy
EOF
########## Removed from TAPE ORDER, 25-Oct-93 JWW ###############
	#README
	#product.def
########## Removed 25-Oct-93 JWW ###############
#for SYS in $LIST
#do
#if [ "$SYS" = "CLIPPER" ]
#then
#	echo "#install.sh">> $DEST/product.def
#	echo "#remove.sh">> $DEST/product.def
#fi
#if [ "$SYS" = "SUN" ]
#then
#	echo "#install.sun">> $DEST/product.def
#	echo "#remove.sun">> $DEST/product.def
#fi
#if [ "$SYS" = "SPARC_SOLARIS" ]
#then
#	echo "#install.ssl">> $DEST/product.def
#	echo "#remove.ssl">> $DEST/product.def
#fi
#if [ "$SYS" = "MIPS_IRIX" ]
#then
#	echo "#install.sgi">> $DEST/product.def
#	echo "#remove.sgi">> $DEST/product.def
#fi
#done
########## Removed 25-Oct-93 JWW ###############
echo "#ish.p" >> $DEST/product.def
for file in $FILE_LIST
do
	echo "#$file"
done >> $DEST/product.def
cat $SRC/prod2.def >> $DEST/product.def
set +x
cat <<- EOF > $DEST/README
Copyright `date +%Y` Intergraph Corporation
All Rights Reserved

Including software, file formats, and audio-visual displays;
may only be used pursuant to applicable software license agreement;
contains confidential and proprietary information of Intergraph
and/or third parties which is protected by copyright and trade
secret law and may not be provided or otherwise made available
without proper authorization.

Warranties and Liabilities
All warranties given by Intergraph Corporation about equipment or software
are set forth in your purchase contract, and nothing stated in, or implied by,
this README file or its contents shall be considered or deemed a modification
or amendment of such warranties.

The information and the software discussed in this README file are subject to
change without notice and should not be considered commitments by Intergraph
Corporation.  Intergraph Corporation assumes no responsibility for any error
that may appear in this document.

The software discussed in this README file is furnished under a license and
may be used or copied only in accordance with the terms of this license.

No responsibility is assumed by Intergraph for the use or reliability of
software on equipment that is not supplied by Intergraph or its affiliated
companies.

RESTRICTED RIGHTS LEGENDS

Use, duplication, or disclosure by the Government is subject to
restrictions as set forth in subparagraph (c) (1) (ii) of The Rights
in Technical Data and Computer Software clause at DFARS 252.227-7013
or subparagraphs (c) (1) and (2) of Commercial Computer Software --
Restricted Rights at 48 CFR 52.227-19, as applicable.

Unpublished -- rights reserved under the Copyright Laws of the
United States.

Intergraph Corporation
Huntsville, Alabama   35894-0001

-------------------
Version Information
-------------------
===============================================================================
Product:     $IDname	$IDtitle
Version:     $IDversion
Date:        $IDdate
Description:
EOF
awk '{FS=" "};($1=="PRODUCT" && $2=="MANAGER:") {exit};NR > 6 {print $0}' \
 $SRC/${IDname}.sdn >> $DEST/README
cat <<- EOF >> $DEST/README
===============================================================================

--------------------------
End of Version Information
--------------------------
EOF
cat $SRC/README1 >> $DEST/README

if [ "$IDname" = "EXNUC" ]
then
  # Put new version & time stamp in the $WRKDIR/Fixes.tmp file
  VERSION=`echo ${IDversion} | cut -c1-11`
  TIME=`date '+%T'`
  cat <<- EOF > $WRKDIR/Fixes.tmp

===========================================
Version $VERSION -- $IDdate $TIME
===========================================
EOF
  #GET NEW FIXES
  #UpdChgHx.sh
  #cd $SRC
  #Create $REL/package/prodinfo/FixHx.210${BLDNUMB}
  #GenFixHx.sh
  #Add $REL/package/prodinfo/FixHx.210${BLDNUMB} to $SRC/FixHx.dat
  #cat $WRKDIR/Fixes.tmp $SRC/FixHx.210${BLDNUMB} $SRC/FixHx.dat >$WRKDIR/Fixes.tmp1
  if test ! -f $SRC/FixHx.dat
  then
    > $SRC/FixHx.dat
  fi
  cat $WRKDIR/Fixes.tmp $SRC/FixHx.dat >$WRKDIR/Fixes.tmp1
  mv  $WRKDIR/Fixes.tmp1 $SRC/FixHx.dat
fi
cat $SRC/FixHx.dat >> $DEST/README
cat $SRC/README2 >> $DEST/README
rm -f $WRKDIR/Fixes.tmp*
# Now checkout & checkin the new Fixes.info

#	Create install.sh
cat <<- EOF > $DEST/install.sh
	IDnumber=$IDnumber
	IDname=$IDname
	IDtitle="$IDtitle"
	IDversion=$IDversion
	IDdate=$IDdate
	IDclass="$IDclass"
	IDassoc="$IDassoc"
	DELdir=$DELdir
	DELloadp=$DELloadp
	DELattr="$DELattr"
	DELarch="$DELarch"
	VARIANT=$VARIANT
	PDkey=$PDkey
EOF
for file in $FILE_LIST
do
	cat $DEST/`basename $file .p`Size
done >> $DEST/install.sh
cat $SRC/install.sh >> $DEST/install.sh

#	Create remove.sh
cat <<- EOF > $DEST/remove.sh
	IDnumber=$IDnumber
	IDname=$IDname
	IDtitle="$IDtitle"
	IDversion=$IDversion
	IDdate=$IDdate
	IDclass="$IDclass"
	IDassoc="$IDassoc"
	DELdir=$DELdir
	DELloadp=$DELloadp
	DELattr="$DELattr"
	DELarch="$DELarch"
	VARIANT=$VARIANT
	PDkey=$PDkey
EOF
cat $SRC/remove.sh >> $DEST/remove.sh

# Make the shell scripts executable
chmod 775 $DEST/install.sh
chmod 775 $DEST/remove.sh

for SYS in $LIST
do
if [ "$SYS" = "SUN" ]
then
	sed 's/IDnumber=SN01/IDnumber=SN05/' $DEST/install.sh | \
	sed 's/IDassoc="\(.*\)"/IDassoc="05"/' | \
	sed 's/DELarch="\(.*\)"/DELarch="SUN"/' > $DEST/install.sun
	sed 's/IDnumber=SN01/IDnumber=SN05/' $DEST/remove.sh | \
	sed 's/IDassoc="\(.*\)"/IDassoc="05"/' | \
	sed 's/DELarch="\(.*\)"/DELarch="SUN"/' > $DEST/remove.sun
fi
if [ "$SYS" = "SPARC_SOLARIS" ]
then
	sed 's/IDnumber=SN01/IDnumber=SN05/' $DEST/install.sh | \
	sed 's/IDassoc="\(.*\)"/IDassoc="05"/' | \
	sed 's#DELdir=ip32/exnuc#DELdir=exnuc#' | \
	sed 's/DELarch="\(.*\)"/DELarch="SPARC_SOLARIS"/' > $DEST/install.ssl
	sed 's/IDnumber=SN01/IDnumber=SN05/' $DEST/remove.sh | \
	sed 's/IDassoc="\(.*\)"/IDassoc="05"/' | \
	sed 's#DELdir=ip32/exnuc#DELdir=exnuc#' | \
	sed 's/DELarch="\(.*\)"/DELarch="SPARC_SOLARIS"/' > $DEST/remove.ssl
fi
if [ "$SYS" = "INTEL_SOLARIS" ]
then
	sed 's/IDnumber=SN01/IDnumber=SN0S/' $DEST/install.sh | \
	sed 's/IDassoc="\(.*\)"/IDassoc="0S"/' | \
	sed 's#DELdir=ip32/exnuc#DELdir=exnuc#' | \
	sed 's/DELarch="\(.*\)"/DELarch="INTEL_SOLARIS"/' > $DEST/install.isl
	sed 's/IDnumber=SN01/IDnumber=SN0S/' $DEST/remove.sh | \
	sed 's/IDassoc="\(.*\)"/IDassoc="0S"/' | \
	sed 's#DELdir=ip32/exnuc#DELdir=exnuc#' | \
	sed 's/DELarch="\(.*\)"/DELarch="INTEL_SOLARIS"/' > $DEST/remove.isl
fi
if [ "$SYS" = "MIPS_IRIX" ]
then
	sed 's/IDnumber=SN01/IDnumber=SN0H/' $DEST/install.sh | \
	sed 's/IDassoc="\(.*\)"/IDassoc="0H"/' | \
	sed 's/DELarch="\(.*\)"/DELarch="MIPS_IRIX"/' > $DEST/install.sgi
	sed 's/IDnumber=SN01/IDnumber=SN0H/' $DEST/remove.sh | \
	sed 's/IDassoc="\(.*\)"/IDassoc="0H"/' | \
	sed 's/DELarch="\(.*\)"/DELarch="MIPS_IRIX"/' > $DEST/remove.sgi
fi
done
