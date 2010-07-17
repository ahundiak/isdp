/* $Id: aimsircmd.m,v 1.4 2002/05/29 21:55:48 ylong Exp $  */

/* --------------------------------------------------------------------
 * I/AIMSIR
 *
 * File:	src/cmd/aimsircmd.m
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: aimsircmd.m,v $
 *	Revision 1.4  2002/05/29 21:55:48  ylong
 *	*** empty log message ***
 *	
 *	Revision 1.3  2001/06/04 19:35:30  tlstalli
 *	Updated .m files to reflect sp constant
 *	

 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *
 * -------------------------------------------------------------------*/

SOURCE
AIMCmdStrt.S
AIMCmdStrti.I
AIMprodinfo.C

LIB
$AIM_PATH/src/lib/aimsircmd.o

SPEC
$EXNUC/spec
$GRNUC/spec
$MODEL/spec
$VDS/spec

INCLUDE
#if ISDP_MAKE_SP
$SPXV/include
$SPXV/vdinclude
#endif
$BS/include
$BS/include/prototypes
$EXNUC/include
$GRNUC/include
$GRNUC/src/assoc/include_priv
$MODEL/include
$VDS/include
$VDS/vdinclude
$UMS/include
$AIM/include

OPP
$EXNUC/bin/opp

OMCPP
$EXNUC/bin/omcpp
