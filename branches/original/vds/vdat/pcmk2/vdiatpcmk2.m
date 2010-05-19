/* $Id: vdiatpcmk2.m,v 1.11 2002/04/18 16:33:32 ahundiak Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdat/pcmk2/vdiatpcmk2.m
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: vdiatpcmk2.m,v $
 *      Revision 1.11  2002/04/18 16:33:32  ahundiak
 *      ah
 *
 *      Revision 1.10  2002/02/28 22:23:11  ahundiak
 *      ah
 *
 *      Revision 1.9  2001/11/09 18:14:56  ahundiak
 *      ah
 *
 *      Revision 1.8  2001/11/09 14:38:06  ahundiak
 *      ah
 *
 *      Revision 1.7  2001/04/12 19:12:27  ahundiak
 *      ah
 *
 *      Revision 1.6  2001/04/06 12:45:59  ahundiak
 *      ah
 *
 *      Revision 1.5  2001/04/04 14:16:31  ahundiak
 *      *** empty log message ***
 *
 *      Revision 1.4  2001/04/02 20:56:03  ahundiak
 *      ah
 *
 *      Revision 1.3  2001/03/22 14:42:19  ahundiak
 *      ah
 *
 *      Revision 1.2  2001/03/18 22:50:50  ahundiak
 *      ah
 *
 *      Revision 1.1  2001/03/16 17:10:46  ahundiak
 *      *** empty log message ***
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 02/15/01  ah      Creation
 ***************************************************************************/

SOURCE
VDatCmd.c
VDatStd.c
VDatLike.c
VDatForm.c
VDatStatus.c
VDatFillList.c

VDatTree.c
VDatInfo.c
VDatCompare.c
VDatVerStd.c
VDatVerNot.c
VDatVerLike.c
VDatVerLikeSS.c
VDatVerLikeMisc.c
VDatVerify.c
VDatValidate.c
VDatGenerate.c

VDatNextPcmk.c

VDefpSrfTran.C
VDefpSrfComp.C
VDgeomNatEd2.I
VDatStdVer.I

VDatCmdStdLib.c

LIB
#if ISDP_MAKE_SP
$SPXV/lib/vdiatpcmk2.o
#else
$VDS/lib/vdiatpcmk2.o
#endif

INCLUDE
#if ISDP_MAKE_SP
$SPXV/include
$SPXV/vdinclude
#endif
$LOCAL/include/glib-1.2
$BS/include
$BS/include/prototypes
$EXNUC/include
$GRNUC/include
$GRNUC/src/assoc/include_priv
$FORMS/include
$PDU/include
$NFMDP/include
$MODEL/include
$UMS/include
$VDS/include
$VDS/include/prototypes
$VDS/vdinclude
.

SPEC
$EXNUC/spec
$GRNUC/spec
$MODEL/spec
$VDS/spec


OPP
$EXNUC/bin/opp

OMCPP
$EXNUC/bin/omcpp
