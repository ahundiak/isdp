/* $Id: vdex.m,v 1.6 2002/06/10 14:46:38 hans Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/emsfixes/exnuc / vdex.m
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: vdex.m,v $
 *	Revision 1.6  2002/06/10 14:46:38  hans
 *	Cleanup; removed all files that have been integrated into EMS
 *	
 *	Revision 1.5  2002/01/22 19:19:46  hans
 *	*** empty log message ***
 *	
 *	Revision 1.4  2001/02/19 22:58:35  build
 *	Added $GRNUC/include entry.
 *	
 *	Revision 1.3  2001/01/22 19:16:53  ahundiak
 *	ah
 *	
 *	Revision 1.2  2001/01/12 23:20:53  hans
 *	SP16 modifications
 *	
 *	Revision 1.1.1.1  2001/01/04 21:07:27  cvs
 *	Initial import to CVS
 *
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.4  1996/03/21  10:25:56  pinnacle
# Replaced: emsfixes/exnuc/vdex.m for:  by rgade for vds.240
#
# Revision 1.3  1995/11/03  17:18:26  pinnacle
# Replaced: ./emsfixes/exnuc/vdex.m for:  by azuurhou for vds.240
#
# Revision 1.2  1995/08/28  13:14:58  pinnacle
# Replaced: emsfixes/exnuc/vdex.m for:  by azuurhou for vds.240
#
# Revision 1.1  1994/11/14  22:42:32  pinnacle
# Create vds.240 from vds.232
#
# Revision 1.1  1994/11/08  16:07:00  pinnacle
# create vds.232
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *	08/26/95	adz		Add IGEwncons.I	TR# 179527193
 *      03/21/96        Ravi		Added DIrename.I TR#179600963
 *      01/22/01        ah              Moved library to vds/lib
 *
 *      01/22/2002      HF              The following list of files/fixes have been
 *                                      integrated into the CVS ems/exnuc source-tree:

  20 -rw-rw-rw-       9637 Jan 12  2001 DIbsti.I
   8 -rw-rw-rw-       3706 Jan 22 11:56 DIrename.I
  18 -rw-rw-rw-       8854 Jan 12  2001 IGEwncons.I

 * with the exception of:

  24 -rw-rw-rw-      11303 Mar 23  2001 OMrtree3df.C  ==>> VDS    specific changes
  52 -rw-rw-rw-      26434 Jan 12  2001 OMrtreei.I    ==>> VDS    specific changes
  60 -rw-rw-rw-      30158 Jan 12  2001 modulei.I     ==>> VDS    specific changes

 * so, in future, when a new EMS release is available, only these need to be
 * delivered as emsfixes !!
 *
 * 06/10/2002 HF     Cleanup:
 *                   For PLOAD ISPD 02.06.03.07 & EMS 03.04.00.12 removed files.
 *
 * -------------------------------------------------------------------*/

SOURCE

OMrtree3df.C
OMrtreei.I
modulei.I

LIB
#if 0
$VDS/etc/needed_dload/dloadexnuc.o
#else
$VDS/lib/vdidloadexnuc.o
#endif

SPEC
$EXNUC/spec

INCLUDE
$BS/include
$EXNUC/include
$FORMS/include
$GRNUC/include
$VDS/include
$VDS/vdinclude

OPP
$EXNUC/bin/opp

OMCPP
$EXNUC/bin/omcpp

CC
acc -ansi
