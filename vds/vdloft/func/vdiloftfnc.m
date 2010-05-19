/* $Id: vdiloftfnc.m,v 1.3 2001/12/18 17:36:57 ylong Exp $  */
/*************************************************************************
 * I/VDS
 *
 * File:	vdloft/func/vdidwfnc.m
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: vdiloftfnc.m,v $
 *	Revision 1.3  2001/12/18 17:36:57  ylong
 *	*** empty log message ***
 *	
 *	Revision 1.2  2001/01/19 20:31:20  ramarao
 *	Added VDloftbk.I file.
 *	
 *	Revision 1.1.1.1  2001/01/04 21:08:55  cvs
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
# Revision 1.1  1996/03/24  19:31:12  pinnacle
# Created: ./vdloft/func/vdiloftfnc.m by azuurhou for vds.240
#
 *
 * History:
 *
 *************************************************************************/
SOURCE
#if ISDP_MAKE_SP
VDloftbk.I

#else
VD_CurvEv.I
VD_LnStrB.I
VD_OffCrv.I
VD_linesS.I
VDloftbk.I
#endif

SPEC
$(EXNUC)/spec
$(GRNUC)/spec
$(MODEL)/spec
$(VDS)/spec

INCLUDE
#if ISDP_MAKE_SP
$(SPXV)/include
$(SPXV)/include/prototypes
$(SPXV)/vdinclude
#endif
$(BS)/include
$(BS)/include/prototypes
$(EXNUC)/include
$(GRNUC)/include
$(GRNUC)/proto_priv
$(GRNUC)/ingrsys
$(MODEL)/include
$(VDS)/include
$(VDS)/include/prototypes
$(VDS)/vdinclude

OMCPP
$(EXNUC)/bin/omcpp

OPP
$(EXNUC)/bin/opp

LIB
#if ISDP_MAKE_SP
$(SPXV)/lib/vdiloftfnc.o
#else
$(VDS)/lib/vdiloftfnc.o
#endif

