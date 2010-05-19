/* $Id: VDbro1.h,v 1.1.1.1 2001/01/04 21:07:30 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:         include/VDbro1.h
 *
 * Description:  Browser Prototypes
 *
 * Dependencies: VDtypedef.h
 *
 * Revision History:
 * $Log: VDbro1.h,v $
 * Revision 1.1.1.1  2001/01/04 21:07:30  cvs
 * Initial import to CVS
 *
 * Revision 1.1  1998/04/29  16:27:20  pinnacle
 * VDS 2.5.1
 *
 * Revision 1.8  1998/04/17  12:57:44  pinnacle
 * ah
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 10/29/97  ah      Added header
 * 03/15/98  ah      Includes VDtypedef if required
 ***************************************************************************/

#ifndef VDbro1_include
#define VDbro1_include

#ifndef   VDtypedef_include
#include "VDtypedef.h"
#endif

#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

/* Information structure */
typedef struct {

  TGRobj_env objOE;

  IGRboolean  sts;

  GRclassid classID;
  IGRchar   className[32];

  IGRchar   objName[1024];
  IGRchar   macName  [80];
  IGRchar   downScan [80];
  IGRchar   expStr [1024];

  TGRid macID;

} TVDbroObjInfo;

/* ------------------------------------------------------
 * Skip for ppl
 */

#if defined(__cplusplus)
extern "C" {
#endif

extern IGRlong VDbroGetObjDesc1 __((TVDbroObjInfo *info, IGRchar *desc));

extern IGRlong VDbroGetObjInfo1 __((
  TGRobj_env    *a_objOE,
  TGRid         *a_objID, 
  TGRmd_env     *a_objENV,
  TVDbroObjInfo *info
));

extern IGRlong VDbroPrintObject __((
  TGRobj_env    *a_objOE,
  TGRid         *a_objID,
  TGRmd_env     *a_objENV,

  IGRboolean     a_trace,
  IGRboolean     a_cr,

  IGRchar       *a_buf,
  FILE          *a_file,
  TVDbroObjInfo *a_info
));
extern IGRlong VDbroPrintObj1 __((TGRid *a_objID));

extern IGRstat VDbroIsAncestryValid
__((TGRobj_env *a_objOE, 
    TGRid      *a_objID,
    VDclassid   a_classID,
    IGRchar    *a_className
));

#if defined(__cplusplus)
}
#endif

/* -------------------------------------------------
 * Public Interface
 * No semicolons!
 */
#omdef vdbro$PrintObject(
			 objOE  = NULL,
			 objID  = NULL,
			 objENV = NULL,
			 trace  = TRUE,
			 cr     = TRUE,
			 str    = NULL,
			 file   = stdout,
			 info   = NULL
			 )

VDbroPrintObject((objOE),(objID),(objENV),(trace),(cr),(str),(file),(info))
#endomdef

#omdef vdbro$IsAncestryValid(
			     objOE = NULL,
			     objID = NULL,
			     superClassID   = OM_K_NOTUSING_CLASSID,
			     superClassNAME = NULL
			     )

VDbroIsAncestryValid((objOE),(objID),(superClassID),(superClassNAME))
#endomdef

#endif








