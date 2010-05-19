/* $Id: smcompimp.m,v 1.1.1.1 2001/01/04 21:07:33 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/smcomp/imp / smcompimp.m
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: smcompimp.m,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:33  cvs
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
# Revision 1.3  1995/07/30  18:04:56  pinnacle
# Replaced: smcomp/imp/smcompimp.m for:  by hverstee for vds.240
#
# Revision 1.2  1995/02/22  21:15:36  pinnacle
# Replaced: smcomp/imp/smcompimp.m by rmanem r#
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
 *					Creation
 *	02/16/95	R. Manem	Added SMcompParams.I
 *
 * -------------------------------------------------------------------*/

SOURCE


SMcomp.S
SMcompi.I

SMCnstFeet.I
SMSetDwSymb.I
SMCompMac.I
SMCompMass.I
SMCompCol.I
SMMgrOver.I
SMCompDwCpGe.I
SMCGivePath.I
SMcompUsrAtt.I
SMcompParams.I


SMCompUpd.I		/* used to force recomputation */
SMNewComp.I


LIB
$VDS/lib/smicompimp.o

SPEC
$EXNUC/spec 
$GRNUC/spec
$MODEL/spec
$VDS/spec

INCLUDE
.
$BS/include
$BS/include/prototypes
$EXNUC/include 
$GRNUC/include
$GRNUC/src/assoc/include_priv
$MODEL/include
$PDU/include
$NFMDP/include
$VDS/include
$VDS/vdinclude

OPP
$EXNUC/bin/opp

OMCPP
$EXNUC/bin/omcpp

