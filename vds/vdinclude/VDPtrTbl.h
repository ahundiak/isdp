/* I/VDS
 *
 * File:        vdpinclude/VDPtrTbl.h
 *
 * Description:  
 *
 * Dependencies:
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *       9/95           MSM             Creation
 */

#ifndef VDPtrTbl_include
#define VDPtrTbl_include

#ifndef VDPdef_include
#include "VDPdef.h"
#endif

#define  VDP_CREATE	1
#define	 VDP_MODIFY	2
#define	 VDP_REPLACE	3
#define  VDP_DELETE	4
#define  VDP_FRPLLST	5
#define	 VDP_VERSION	6
#define	 VDP_DEL_COMP	7

struct VDPtrObjList
{
   IGRint	ActionCode;
   GRobjid	VDSobjid;
   GRobjid	oldVDSobjid;
   IGRchar	PMEobid[VDPOBID_LEN];
   IGRboolean	posted;
};

#endif  /* VDPtrTbl_include */
