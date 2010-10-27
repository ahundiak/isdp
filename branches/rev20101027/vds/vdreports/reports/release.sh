# $Id: release.sh,v 1.1.1.1 2001/01/04 21:09:07 cvs Exp $

# -------------------------------------------------------------------
# I/VDS
#
# File:	vds/vdreports/reports/release.sh 
#
# Description:
#
# Dependencies:
#
# Revision History:
#	$Log: release.sh,v $
#	Revision 1.1.1.1  2001/01/04 21:09:07  cvs
#	Initial import to CVS
#	
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.1  1994/11/14  22:42:32  pinnacle
# Create vds.240 from vds.232
#
# Revision 1.1  1994/11/08  16:07:00  pinnacle
# create vds.232
#
#
# History:
#	MM/DD/YY	AUTHOR		DESCRIPTION
#
# -------------------------------------------------------------------

export TMPDIR=/usr/tmp

echo "CGH or Apogee compilation (c/a) ? : \c"
read compilo
case $compilo in
   c )
      export RPTCMP='cc -ga -w -OML -c'
      ;;
   a )
      export RPTCMP='acc -ga -w -knr -c'
      ;;
   * )
      exit
      ;;
esac


    rm reports/*.4ge
    make -f makefile
    ln rpt/*.4ge reports

rm reports/*.log
rm reports/*.rpt
rm fgl/*.o
rm fgl/*.c
rm fgl/*.ec
rm fgl/*.ic
rm fgl/*.err
rm per/*.frm

find * -print | cpio -ov | compress > ~backup/VDSrpt.all

su backup -c "fmu -av fournier.backup send ~backup/* ."
