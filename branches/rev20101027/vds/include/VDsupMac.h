/* $Id: VDsupMac.h,v 1.1.1.1 2001/01/04 21:07:30 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        include/VDsupMac.h
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDsupMac.h,v $
 *      Revision 1.1.1.1  2001/01/04 21:07:30  cvs
 *      Initial import to CVS
 *
 * Revision 1.1  1998/04/29  16:27:20  pinnacle
 * VDS 2.5.1
 *
 * Revision 1.3  1997/12/17  19:07:24  pinnacle
 * VDsupEtc
 *
 * Revision 1.2  1997/10/28  19:05:38  pinnacle
 * Added Headers
 *
 *
 * History:
 *      MM/DD/YY  AUTHOR  DESCRIPTION
 *      10/28/97  ah      Added header
 *	12/17/97  ah      Added VDsupEtc information
 ***************************************************************************/

#define VDSUP_MAC_NAME "VDsupGen"

#define VDSUP_MAC_NAME_CRV "VDsupCrv"
#define VDSUP_MAC_NAME_OFF "VDsupOff"
#define VDSUP_MAC_NAME_EQU "VDsupEqu"
#define VDSUP_MAC_NAME_ETC "VDsupEtc"

#define VDSUP_MAC_TYPE_CRV 1
#define VDSUP_MAC_TYPE_OFF 2
#define VDSUP_MAC_TYPE_EQU 3
#define VDSUP_MAC_TYPE_ETC 4

#define VDSUP_I_MAX  200

#define VDSUP_I_COL    0
#define VDSUP_I_SURF   2

#define VDSUP_I_REF1   4
#define VDSUP_I_REF2   6

/* Same as first two trace curves */
#define VDSUP_I_TRIM1  50
#define VDSUP_I_TRIM2  52

#define VDSUP_I_PT_DIR 12
#define VDSUP_I_PT_SEL 14

#define VDSUP_I_DIS1   18
#define VDSUP_I_DIS2   19

#define VDSUP_I_CUT1   20
#define VDSUP_I_CUT2   21
#define VDSUP_I_CUTF   22

#define VDSUP_I_CNT    23
#define VDSUP_I_LAW    24
#define VDSUP_I_MET    25
#define VDSUP_I_INT    26

#define VDSUP_I_PROJ_CS  21
#define VDSUP_I_PROJ_DIR 22

#define VDSUP_I_TRACE_BEG 50
#define VDSUP_I_TRACE_END 149

#define VDSUP_I_TWEAK_BEG 150

#define VDSUP_MAC_MAX_NUM_TEMP 100
#define VDSUP_MAC_MAX_NUM_FEET 100
