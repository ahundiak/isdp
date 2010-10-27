/***************************************************************************
 * I/VDS
 *
 * File:        include/VDobj.h
 *
 * Description:	Object Processing
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDobj.h,v $
 *      Revision 1.2  2002/05/01 19:54:00  ahundiak
 *      ah
 *
 *      Revision 1.1.1.1  2001/01/04 21:07:30  cvs
 *      Initial import to CVS
 *
 * Revision 1.5  1999/04/26  20:41:28  pinnacle
 * ah
 *
 * Revision 1.4  1999/01/28  22:27:42  pinnacle
 * spades
 *
 * Revision 1.3  1999/01/27  17:47:40  pinnacle
 * spades
 *
 * Revision 1.1  1998/11/29  14:40:58  pinnacle
 * ah
 *
 * Revision 1.2  1998/10/08  17:39:10  pinnacle
 * ah
 *
 * Revision 1.1  1998/04/29  16:27:20  pinnacle
 * VDS 2.5.1
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 04/09/98  ah      Creation
 * 04/16/98  ah      Add some get routines
 * 10/08/98  ah      Add get foot routine
 * 11/25/98  ah      Add delete   routines
 * 01/27/99  ah      Add display  routines
 * 01/28/99  ah      Add VDobjGetTemplate
 * 04/26/99  ah      Add VDobjGetPretendParent
 ***************************************************************************/
#ifndef VDobj_include
#define VDobj_include

#ifndef   VDtypedef_include
#include "VDtypedef.h"
#endif

#ifndef   VDvla_include
#include "VDvla.h"
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

} TVDobjInfo;

#if defined(__cplusplus)
extern "C" {
#endif

/* -----------------------------------------------------------
 * Given a pretend object, get it's parent (not the foot)
 */
extern IGRstat VDobjGetPretendParent __((TGRid *pretendID, 
					 TGRid *parentID));

#omdef vdobj$GetPretendParent(pretendID,
			      parentID)

VDobjGetPretendParent((pretendID),(parentID))
#endomdef

/* ------------------------------------------------------------------------
 * Specialized routine for retrieving parents through sources
 * Avoid using this, it was really for a special case
 */
extern IGRstat VDobjGetParent
__((TGRobj_env *a_objOE,
    TGRid      *a_objID,
    IGRint      a_idx,
    
    TGRid      *a_parentID,  // The real parent object
    TGRid      *a_sourceID,  // If ASsource  or ASsourcein
    TGRid      *a_pretendID  // If ACpretend or ACpretendin
));

#omdef vdobj$GetParent(objOE = NULL,
		       objID = NULL,
		       idx,
		       parentID  = NULL,
		       sourceID  = NULL,
		       pretendID = NULL
		       )

VDobjGetParent((objOE),(objID),(idx),(parentID),(sourceID),(pretendID))
#endomdef

/* ----------------------------------------------------
 * More useful routine for getting template object
 */
extern IGRstat VDobjGetTemplate 
__((TGRobj_env *objOE,
    TGRid      *objID,  // Not yet implemented
    IGRint      nth,
    TGRobj_env *templateOE
));

#omdef vdobj$GetTemplate(objOE = NULL,
		         objID = NULL,
		         nth,
		         templateOE)

VDobjGetTemplate((objOE),(objID),(nth),(templateOE))
#endomdef

/* ------------------------------------------------------------------------
 * Change the name with the option of preserving it's directory
 */
extern IGRstat VDobjChgName
__((
 IGRlong    *a_msg,
 TGRobj_env *a_objOE,
 TGRid      *a_objID,
 IGRchar    *newName,
 IGRint      keepDir
));

#omdef vdobj$ChgName(msg   = NULL,
		     objOE = NULL,
		     objID = NULL,
		     name,
		     keepDir = 0
		     )

VDobjChgName((msg),(objOE),(objID),(name),(keepDir))
#endomdef

/* ------------------------------------------------------
 * Get various info
 */
extern IGRstar VDobjGetDesc __((TVDobjInfo *info, IGRchar *desc));
extern IGRstar VDobjGetInfo __((TGRobj_env *objOE,TVDobjInfo *info));

extern IGRstar VDobjGet __((
  TGRobj_env    *a_objOE,
  TGRid         *a_objID,
  TGRmd_env     *a_objENV,

  TVDobjInfo    *info,
  IGRchar       *desc,

  IGRchar       *className,
  IGRchar       *category,
  VDclassid     *classID,

  IGRchar       *macName,
  IGRchar       *objName,
  IGRchar       *objPath,
  IGRchar       *disName,

  TGRsymbology *symb
));

#omdef vdobj$Get(objOE      = NULL,
		 objID      = NULL,
		 objENV     = NULL,
		 info       = NULL,
		 desc       = NULL,
		 className  = NULL,
		 category   = NULL,
		 classID    = NULL,
		 macName    = NULL,
		 objName    = NULL,
		 objPath    = NULL,
		 disName    = NULL,
                 symb       = NULL
		 )

VDobjGet((objOE),(objID),(objENV),(info),(desc),
	 (className),(category),(classID),
	 (macName),(objName),(objPath),(disName),
         (symb))
#endomdef


/* -------------------------------------------------
 * Pretty print the object
 */
extern IGRstar VDobjPrint __((
  TGRobj_env  *a_objOE,
  TGRid       *a_objID,
  TGRmd_env   *a_objENV,

  IGRboolean   a_trace,
  IGRboolean   a_cr,

  IGRchar     *a_buf,
  FILE        *a_file,
  TVDobjInfo  *a_info
));

#omdef vdobj$Print(objOE  = NULL,
		   objID  = NULL,
		   objENV = NULL,
		   trace  = TRUE,
		   cr     = TRUE,
		   str    = NULL,
		   file   = stdout,
		   info   = NULL
		   )

VDobjPrint((objOE),(objID),(objENV),(trace),(cr),(str),(file),(info))
#endomdef

/* ----------------------------------------------------
 * Validate ancestor with either class id or class name
 */
extern IGRstat VDobjIsAncestryValid
__((TGRobj_env *a_objOE, 
    TGRid      *a_objID,
    VDclassid   a_classID,
    IGRchar    *a_className
));

#omdef vdobj$IsAncestryValid(objOE = NULL,
			     objID = NULL,
			     superClassID   = OM_K_NOTUSING_CLASSID,
			     superClassName = NULL
			     )

VDobjIsAncestryValid((objOE),(objID),(superClassID),(superClassName))
#endomdef

/* ----------------------------------------------------
 * Generic method for getting named foot with md_env
 * filled in properly
 */
extern IGRstat VDobjGetFoot
__((TGRobj_env *objOE, 
    TGRid      *objID,
    IGRchar    *footName,
    TGRobj_env *footOE
));

#omdef vdobj$GetFoot(objOE = NULL,
		     objID = NULL,
		     footName = NULL,
		     footOE)

VDobjGetFoot((objOE),(objID),(footName),(footOE))
#endomdef

/* --------------------------------------------------
 * Generic method for deleting one or more objects
 */
extern IGRstar VDobjDelete __((
  TGRobj_env *objOEs, 
  TGRid      *objIDs, 
  OM_S_OBJID *objSIDs,
  TGRmd_env  *objENV,
  IGRint      objCNT,
  TVDvlaID   *vlaID,
  TVDvlaOE   *vlaOE
));

#omdef vdobj$Delete(objOE = NULL,
		    objID = NULL,
		    objSID = NULL,
		    objENV = NULL,
		    objCNT = 1,
		    vlaID  = NULL,
		    vlaOE  = NULL)
		    
VDobjDelete((objOE),(objID),(objSID),(objENV),(objCNT),(vlaID),(vlaOE))
#endomdef

/* --------------------------------------------------
 * Generic method for displaying one or more objects
 */

/* Copied this from grnuc/include/dp.h
 * Trying to avoid some compilier problems
 * when using the GR stuff
 */
typedef enum {
  VDbd,    VDbe,   VDhd,  VDhe,  VDbdhd, VDbehe,
  VDbdhe,  VDbehd, VDhhd, VDhdo, VDhhdo, VDheo, 
  VDbdheo, VDbeheo
} VDdpmode;


extern IGRstar VDobjDisplay __((
  TGRobj_env *objOEs, 
  TGRid      *objIDs, 
  OM_S_OBJID *objSIDs,
  TGRmd_env  *objENV,
  IGRint      objCNT,
  TVDvlaID   *vlaID,
  TVDvlaOE   *vlaOE,
  VDdpmode    mode
));

#omdef vdobj$Display(objOE  = NULL,
		     objID  = NULL,
		     objSID = NULL,
		     objENV = NULL,
		     objCNT = 1,
		     vlaID  = NULL,
		     vlaOE  = NULL,
		     mode   = VDbd)
		    
VDobjDisplay((objOE),(objID),(objSID),(objENV),(objCNT),(vlaID),(vlaOE),*mode))
#endomdef

/* ----------------------------------------------------
 * Clean up
 */
#if defined(__cplusplus)
}
#endif

#endif
