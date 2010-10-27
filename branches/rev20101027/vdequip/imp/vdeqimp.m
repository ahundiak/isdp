/* $Id: vdeqimp.m,v 1.2 2001/01/26 14:31:22 build Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdequip/imp / vdeqimp.m
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: vdeqimp.m,v $
 *	Revision 1.2  2001/01/26 14:31:22  build
 *	*** empty log message ***
 *	
 *	Revision 1.1.1.1  2001/01/04 21:08:43  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.2  1997/09/29  14:55:44  pinnacle
# Replaced: vdequip/imp/vdeqimp.m for:  by jwfrosch for vds
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.7  1995/07/30  19:51:36  pinnacle
# Replaced: vdequip/imp/vdeqimp.m for:  by hverstee for vds.240
#
# Revision 1.6  1995/02/22  21:11:16  pinnacle
# Replaced: vdequip/imp/vdeqimp.m by rmanem r#
#
# Revision 1.5  1995/01/10  14:40:44  pinnacle
# Replaced: vdequip/imp by azuurhou r#
#
# Revision 1.4  1994/12/14  23:39:28  pinnacle
# Replaced: vdequip/imp/vdeqimp.m by tdumbach r#
#
# Revision 1.3  1994/12/14  23:28:24  pinnacle
# Replaced:  vdequip/imp/vdeqimp.m r#
#
# Revision 1.2  1994/12/14  21:59:14  pinnacle
# Replaced:  vdequip/imp r#
#
# Revision 1.1  1994/11/08  16:07:00  pinnacle
# create vds.232
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *	12/14/94	adz		Add files in compilation list.
 *	02/16/95	rmn		Added VDeqParams.I
 *	09/29/97	adz/sundar	Added VDUpdEquip.I
 *
 * -------------------------------------------------------------------*/

SOURCE
VDequipment.S
VDequip.I
VDeqUsrAttr.I
VDeqParams.I
VDUpdEquip.I
VDm_refresh.C

LIB
$VDS/lib/vdieqimp.o

SPEC
$EXNUC/spec
$GRNUC/spec
$MODEL/spec
$VDS/spec

INCLUDE
$BS/include
$EXNUC/include
$GRNUC/include
$MODEL/include
$PDU/include
$PDUDP/include
$NFM/include
$NFMDP/include
$VDS/include
$VDS/include/prototypes
$VDS/vdinclude

OPP
$EXNUC/bin/opp

OMCPP
$EXNUC/bin/omcpp

OPPFLAGS
/*-l*/

