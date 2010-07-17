/* $Id: vsjoint.m,v 1.1.1.1 2001/01/04 21:10:50 cvs Exp $  */

/*************************************************************************
 * I/STRUCT
 *
 * File:	$STRUCT/vsjoint/vsjoint.m
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: vsjoint.m,v $
 *      Revision 1.1.1.1  2001/01/04 21:10:50  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:08:06  pinnacle
# STRUCT 2.5.1
#
# Revision 1.8  1998/04/02  10:39:28  pinnacle
# Replaced: vsjoint/vsjoint.m for:  by svkadamb for struct
#
# Revision 1.7  1998/01/02  12:00:10  pinnacle
# Replaced: vsjoint/vsjoint.m for:  by svkadamb for struct
#
# Revision 1.6  1997/12/26  10:46:14  pinnacle
# Replaced: vsjoint/vsjoint.m for:  by rchennup for struct
#
# Revision 1.5  1997/12/15  22:37:18  pinnacle
# VDGetCenterLine
#
# Revision 1.4  1997/11/21  04:32:02  pinnacle
# Replaced: vsjoint/vsjoint.m for:  by svkadamb for struct
#
# Revision 1.3  1997/11/20  11:26:16  pinnacle
# Replaced: vsjoint/vsjoint.m for:  by svkadamb for struct
#
# Revision 1.2  1997/11/14  13:40:32  pinnacle
# Replaced: vsjoint/vsjoint.m for:  by svkadamb for struct
#
# Revision 1.1  1997/05/08  14:03:58  pinnacle
# Struct 250
#
# Revision 1.5  1997/01/30  09:39:12  pinnacle
# Replaced: vsjoint/vsjoint.m for:  by svkadamb for struct
#
# Revision 1.4  1996/05/22  19:03:06  pinnacle
# Replaced: vsjoint/vsjoint.m for:  by svkadamb for struct
#
# Revision 1.3  1995/10/27  15:35:08  pinnacle
# Replaced: vsjoint/*.m for:  by tdumbach for struct
#
# Revision 1.2  1995/10/27  15:16:04  pinnacle
# Replaced: vsjoint/*.m for:  by tdumbach for struct
#
 *
 * History:
 *	MM/DD/YY   	AUTHOR	DESCRIPTION
 *	27-Oct-95	TRD	Adding $VDS/include to include list. 
 *	12/14/97	ah	Added VSjnGetCL.I
 *************************************************************************/

SOURCE
/*
	Abstract joint.
*/
VSjoint.S
VSjnGetCL.I
VSjncnstfeet.I
VSjngetobjdf.I
VSjngivestrc.I
VSjngetjoind.I
VSjnplpljnt.I
VSjnplbmjnt.I
VSjnbmbmjnt.I
VSjnntfylis.I
VSjnputjoint.I
VSjnputmdjns.I
VSjnputdvjns.I
VSjngetjnts.I
VSjnmassprop.I
VSjndescfoot.I
VSjntprefix.I
VSjnttentrie.I
VSsjmvtoroot.I
VSjnsdlfunk.I
VSjnfindcoll.I
VSjngetcolid.I
VSjnpreconst.I
/*
	Source joint.
*/
VSsrcJoint.S
VSsjgetobjdf.I
VSsjgetedatt.I
VSsjputattr.I
VSsjgetattr.I
VSplplwldtyp.I
VSgetjnttype.I
VSgetjnfrint.C
/*
	Modified joint.
*/
VSmodJoint.S
VSmjgetobjdf.I
VSmjcnstfeet.I
VSmjgetjoind.I

/*
	Divided joint.
*/
VSdivJoint.S
VSdjcnstfeet.I
VSdjgetobjdf.I
VSdjconst.I

/*
	Sub-joint.
*/
VSsubJoint.S
VSujgetobjdf.I
VSujcnstfeet.I
VSujgetjoind.I
VSujgetopmgr.I
/*
	Utilities.
*/
VScopybc.C
VSmatchedlst.C
VSdocvsovlap.C
VScstgrfred.I
VSfndovlpeds.I
VScstgroup.I
VSfndsfsfjns.C
VSedsbyprops.I
VSrejoin.I
VSjoinafdiv.I
VSdrwvwindls.C
VSedsdmatch.I
VScvsfmindst.C
VSfndplpljns.C
VSfndplbmjns.C
VSfndbmbmjns.C
VSmkjntname.I
VSweldcodes.C
VSweldprocs.C
VSjnctntype.I
VSjntlength.I
VSprjcvtosf.C
VSjnfillattr.C
VSgivejntype.I
VSwldfrfiles.C
VSfndlfrtsfs.I

LIB
$(STRUCT)/lib/vsjoint.o

SPEC
$(EXNUC)/spec
$(GRNUC)/spec
$(MODEL)/spec
$(VDS)/spec
$(STRUCT)/spec

INCLUDE
$(BS)/include
$(BS)/include/prototypes
$(EXNUC)/include
$(GRNUC)/include
$(GRNUC)/proto_priv
$(GRNUC)/src/assoc/include_priv
$(MODEL)/include
$(VDS)/include
$(VDS)/include/prototypes
$(VDS)/vdinclude
$(STRUCT)/include
$(STRUCT)/include/prototypes

OPP
$(EXNUC)/bin/opp

OMCPP
$(EXNUC)/bin/omcpp

/*
 * "CLIX" : -D switch for BS
 */
DOPT
CLIX SYSV BSD ENV5 LITTLE_ENDIAN _INGR_EXTENSIONS

CC
acc -ansi -O3
