/* $Id: VDvlaInfo.h,v 1.1 2001/01/10 16:24:27 art Exp $ */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:  include/VDvla3.h
 *
 * Description: Info vla structure
 *
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDvlaInfo.h,v $
 *	Revision 1.1  2001/01/10 16:24:27  art
 *	sp merge
 *	
 * Revision 1.2  2000/12/01  13:53:04  pinnacle
 * ah
 *
 * Revision 1.1  2000/07/11  14:22:36  pinnacle
 * ah
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 07/06/00  ah      Created
 * 01/10/01  ah      sp merge
 * -------------------------------------------------------------------*/
#ifndef VDvlaInfo_include
#define VDvlaInfo_include

/* -------------------------------------------------------------------
 * Usual BS
 */
#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* -----------------------------------------------
 * Include file for growable list of data
 */
typedef struct 
{
  IGRint max;  // Total number of pointers allocated
  IGRint inc;  // Increment when increasing pointer list
  IGRint size; // Size of 1 data element
  IGRint cnt;  // Actual number of elements
  IGRint i;    // For looping
  void   **data;
} TVDvlaInfo;

extern IGRstat VDvlaInitInfo __((TVDvlaInfo *info, IGRint size, IGRint max, IGRint inc));
#ifndef c_ONLY
#omdef vdvla$InitInfo(info, size = 0, max = 0, inc = 100)
VDvlaInitInfo((info),(size),(max),(inc))
#endomdef
#endif

extern IGRstat VDvlaFreeInfo __((TVDvlaInfo *info));
#ifndef c_ONLY
#omdef vdvla$FreeInfo(info)
VDvlaFreeInfo((info))
#endomdef
#endif

extern IGRstat VDvlaAppendInfo __((TVDvlaInfo *info, void *data));
#ifndef c_ONLY
#omdef vdvla$AppendInfo(info,data)
VDvlaAppendInfo((info),(data))
#endomdef
#endif

extern IGRstat VDvlaGetInfoCnt __((TVDvlaInfo *info, IGRint *cnt));
#ifndef c_ONLY
#omdef vdvla$GetInfoCnt(info,cnt)
VDvlaGetInfoCnt((info),(cnt))
#endomdef
#endif
  
extern IGRstat VDvlaGetNthInfoData __((TVDvlaInfo *info, IGRint nth, void **data));
#ifndef c_ONLY
#omdef vdvla$GetNthInfoData(info,nth,data)
VDvlaGetNthInfoData((info),(nth),(data))
#endomdef
#endif

/* ----------------------------------------------------
 * Clean up
 */
#if defined(__cplusplus)
}
#endif
#endif




