
/* $Id: VCCmdANA.h,v 1.1.1.1 2001/01/04 21:12:33 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/CABLE
 *
 * File:        vcinclude/VCCmdANA.h
 *
 * Description:
 *
 *  Include file for cabling analysis form
 *
 * Dependencies:
 *
 * Revision History:
 *     $Log: VCCmdANA.h,v $
 *     Revision 1.1.1.1  2001/01/04 21:12:33  cvs
 *     Initial import to CVS
 *
 * Revision 1.1  1998/04/30  10:52:34  pinnacle
 * ROUTE 2.5.1
 *
 * Revision 1.1  1997/10/30  05:21:40  pinnacle
 * Integ into Route 02040304
 *
 * Revision 1.4  1997/03/20  21:09:20  pinnacle
 * Replaced: vcinclude/VCCmdANA.h for:  by hverstee for cabling
 *
 * Revision 1.3  1997/03/19  14:42:54  pinnacle
 * Replaced: vcinclude/VCCmdANA.h for:  by hverstee for cabling
 *
 * Revision 1.2  1997/03/14  18:17:52  pinnacle
 * Replaced: vcinclude/VCCmdANA.h for:  by hverstee for cabling
 *
 * Revision 1.1  1996/10/25  13:42:50  pinnacle
 * Created: vcinclude/VCCmdANA.h by hverstee for cabling
 *
 *
 * History:
 *      MM/DD/YY        AUTHOR        DESCRIPTION
 *
 *      08/21/96          HV            New
 *
 * -------------------------------------------------------------------*/

#ifndef VCCmdANA_include

#define VCCmdANA_include

#define        VC_ANA_FNAM        "VCAnal" /* form name  */
#define        VC_ANA_FORM        0        /* form label */

/*     Gadget/group numbers    */

#define  VC_ANGD_SIGGRP       22
#define  VC_ANGD_TAGGRP       19
#define  VC_ANGD_DYNGRP       24
#define  VC_ANGD_PPLGRP       36

#define  VC_ANGD_SIG          21
#define  VC_ANGD_ORG          20
#define  VC_ANGD_DST          15
#define  VC_ANGD_PIN          14
#define  VC_ANGD_OUT          13
#define  VC_ANGD_FIL          38
#define  VC_ANGD_TXT          39
#define  VC_ANGD_SEL          11
#define  VC_ANGD_PPL          25

#define  VC_ANGD_PATH         30
#define  VC_ANGD_FUNC         31
#define  VC_ANGD_RESL         32

#define  VC_ANGD_MS1           9
#define  VC_ANGD_MS2          10

#define  VC_AN_DEFFILE        "CBanalyze.txt"

#define  VC_AN_DEFPATH        "api/VCAN_ppl"
#define  VC_AN_DEFFUNC        "prt"

#endif

