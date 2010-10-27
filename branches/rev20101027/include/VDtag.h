/***************************************************************************
 * I/VDS
 *
 * File:        include/VDtag.h
 *
 * Description:	Tag System Interface
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDtag.h,v $
 *      Revision 1.2  2001/02/22 23:00:44  ahundiak
 *      ah
 *
 *      Revision 1.1.1.1  2001/01/04 21:07:30  cvs
 *      Initial import to CVS
 *
 * Revision 1.1  2000/03/17  17:55:20  pinnacle
 * ah
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 03/17/00  ah      Creation
 ***************************************************************************/
#ifndef VDtag_include
#define VDtag_include

#ifndef   VDtypedef_include
#ifndef   VDtypedefc_include
#include "VDtypedef.h"
#endif
#endif

#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ---------------------------------------------
 * Some typedefs
 * Assume a tag of 0 means no tag
 */
typedef OMuint  TVDtagNum;
typedef OMuword TVDtagVer;

typedef struct
{
  TVDtagNum num;
  TVDtagVer ver;
} TVDtag;

typedef struct
{
  TVDtag tag;
  TGRid  id;
  IGRchar path[128];
} TVDtagInfo;

/* ----------------------------------------------------
 * Gets assorted tag information
 */
extern IGRstat VDtagGetInfo __((TGRobj_env *i_objOE, 
				TGRid      *i_objID,
				TVDtag     *o_tag,
				TVDtagInfo *o_info));

#ifndef c_ONLY
#omdef vdtag$GetInfo(objOE = NULL,
		     objID = NULL,
		     tag   = NULL,
		     info  = NULL)

VDtagGetInfo((objOE),(objID),(tag),(info))
#endomdef
#endif

/* ----------------------------------------------------
 * Clean up
 */
#if defined(__cplusplus)
}
#endif

#endif
