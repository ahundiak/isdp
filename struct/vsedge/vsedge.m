/* $Id: vsedge.m,v 1.8 2001/10/22 22:57:40 ramarao Exp $  */

/***************************************************************************
 * I/STRUCT
 *
 * File:        vsedge/vsedge.m
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: vsedge.m,v $
 *      Revision 1.8  2001/10/22 22:57:40  ramarao
 *      Fixed TR# 5663.
 *
 *      Revision 1.7  2001/05/14 15:29:52  ramarao
 *      Fixed TR# 5009.
 *
 *      Revision 1.6  2001/05/04 18:22:17  ramarao
 *      Removed a warning message.
 *
 *      Revision 1.5  2001/04/28 17:06:51  ramarao
 *      Fixed ETL# 7962.
 *
 *      Revision 1.4  2001/04/17 17:09:52  ramarao
 *      Fixed CR# 5016.
 *
 *      Revision 1.3  2001/03/03 21:23:40  ramarao
 *      Handled Neat Plate Recompute Process.
 *
 *      Revision 1.2  2001/01/22 16:27:51  ramarao
 *      Added SP entries.
 *
 *      Revision 1.1.1.1  2001/01/04 21:10:35  cvs
 *      Initial import to CVS
 *
# Revision 1.4  2000/02/11  00:16:14  pinnacle
# ylong
#
# Revision 1.3  2000/02/07  14:34:58  pinnacle
# ylong
#
# Revision 1.2  1999/04/09  20:34:24  pinnacle
# CR_179900195
#
# Revision 1.1  1998/04/30  10:08:06  pinnacle
# STRUCT 2.5.1
#
# Revision 1.3  1997/10/31  14:33:46  pinnacle
# Update include list
#
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *      10/31/97        ah              added header
 *      04/09/99        ejm             CR_179900195: added VSbevMod.I
 *	02/07/99	ylong		added VSbevel.I
 *	02/10/99	ylong		added INCLUDE FORMS
 ***************************************************************************/

SOURCE
#if ISDP_MAKE_SP
VSbvlFunk.I
VSbevel.I
VSbevel2.I
VSchkNeatPlBvl.I
VSbevelMisc.I
VSchkNeatTemp.I
#else
VSedge3Datt.S
VSedgetobjdf.I
VSedcnstfeet.I
VSedgetparam.I
VSedapi.I
VSedgebevel.I
VSbevMod.I
VSbevel.I
VSbevel2.I
VSbevelAttr.I
VSbevelMisc.I
VSbevelVer.I
VSmodBvlAttr.I
VSchkNeatPlBvl.I
VSbvlFunk.I
VSchkNeatTemp.I
#endif

LIB
#if ISDP_MAKE_SP
$(SPXS)/lib/vsedge.o
#else
$(STRUCT)/lib/vsedge.o
#endif

SPEC
$(EXNUC)/spec
$(GRNUC)/spec
$(MODEL)/spec
$(VDS)/spec
$(STRUCT)/spec

INCLUDE
#if ISDP_MAKE_SP
$(SPXV)/include
$(SPXV)/include/prototypes
$(SPXS)/include
$(SPXS)/include/prototypes
#endif
$(BS)/include
$(BS)/include/prototypes
$(EXNUC)/include
$(GRNUC)/include
$(GRNUC)/src/assoc/include_priv
$(MODEL)/include
$(VDS)/include
$(VDS)/include/prototypes
$(VDS)/vdinclude
$(STRUCT)/include
$(STRUCT)/include/prototypes
$(FORMS)/include

OPP
$(EXNUC)/bin/opp

OMCPP
$(EXNUC)/bin/omcpp

/*
 * "CLIX" : -D switch for BS
 */
DOPT
CLIX SYSV BSD ENV5 LITTLE_ENDIAN

CC
acc -ansi -O3
