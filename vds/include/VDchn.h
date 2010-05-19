/* $Id: VDchn.h,v 1.2 2001/01/09 22:10:26 art Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        include/VDchn.h
 *
 * Description: Channel tool kit
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDchn.h,v $
 *      Revision 1.2  2001/01/09 22:10:26  art
 *      ah
 *
 *      Revision 1.1.1.1  2001/01/04 21:07:30  cvs
 *      Initial import to CVS
 *
 * Revision 1.1  2000/08/16  15:17:18  pinnacle
 * Created: vds/include/VDchn.h by aharihar for Service Pack
 *
 * Revision 1.4  1999/10/26  14:48:24  pinnacle
 * ah
 *
 * Revision 1.3  1999/01/27  17:32:02  pinnacle
 * spades
 *
 * Revision 1.1  1998/04/29  16:27:20  pinnacle
 * VDS 2.5.1
 *
 * Revision 1.1  1998/04/02  21:19:08  pinnacle
 * ah
 *
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 03/31/98  ah      Creation
 * 05/22/98  ah      Include VDtypedef not VDmaster
 * 10/26/99  ah      Misc Updates
 * Aug 10 2k Anand   Modified macro vdchn$GetList. Added prototype for function
 * 		     VDchnGetFilteredList. This function gets conditionally
 * 		     called by the updated macro.
 * 01/09/01  ah      sp merge
 ***************************************************************************/
#ifndef VDchn_include
#define VDchn_include

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

#define VDCHN_IDX_NONE          -1
#define VDCHN_IDX_FATHER         0
#define VDCHN_IDX_PARENT         0
#define VDCHN_IDX_CHILDREN       1
#define VDCHN_IDX_CHILD          1
#define VDCHN_IDX_NOTIFICATION   2
#define VDCHN_IDX_LISTENER       3
#define VDCHN_IDX_TO_OWNERS      4
#define VDCHN_IDX_TO_COMPONENTS  5
#define VDCHN_IDX_BT_TO_NOTIFY   6
#define VDCHN_IDX_TO_LOOPSET     7
#define VDCHN_IDX_CT1_TO_NOTIFY  8

#define VDCHN_NAME_FATHER         "NDfather.father"
#define VDCHN_NAME_PARENT         "NDfather.father"
#define VDCHN_NAME_CHILDREN       "NDchildren.children"
#define VDCHN_NAME_CHILD          "NDchildren.children"
#define VDCHN_NAME_NOTIFICATION   "GRnotify.notification"
#define VDCHN_NAME_LISTENER       "ASsource.listeners"
#define VDCHN_NAME_TO_OWNERS      "GRconnector.to_owners"
#define VDCHN_NAME_TO_COMPONENTS  "GRcmpowner.to_components"
#define VDCHN_NAME_BT_TO_NOTIFY   "VDbtBase.to_notify"
#define VDCHN_NAME_TO_LOOPSET     "EMSsubbs.to_loopset"
#define VDCHN_NAME_CT1_TO_NOTIFY  "VDct1Base.to_notify"

#if defined(__cplusplus)
extern "C" {
#endif

extern IGRstat VDchnGet __((
  TGRobj_env *il_objOE,
  TGRid      *il_objID,

  IGRchar    *ic_NAME,
  IGRint      ic_IDX,

  IGRint     *oc_CNT,

  IGRint      ir_objIDX,
  TGRid      *or_objID,

  TVDvlaID   *or_vlaID,

  OM_S_CHANSELECT **oc_SEL

));

#if defined(__cplusplus)
}
#endif

/* -------------------------------------------------
 * Public Interface
 * No semicolons!
 */
#omdef vdchn$Get(il_objOE  = NULL,
		 il_objID  = NULL,

                 ic_NAME   = NULL,
                 ic_IDX    = VDCHN_IDX_NONE,

		 oc_CNT    = NULL,

                 ir_objIDX = -1,
                 or_objID  = NULL,
                 or_vlaID  = NULL,
		 oc_SEL    = NULL
	        )

VDchnGet((il_objOE), (il_objID),
         (ic_NAME),  (ic_IDX),  (oc_CNT),
         (ir_objIDX),(or_objID),(or_vlaID),(oc_SEL))

#endomdef

/* --------------------------------------------
 * Never got used to the first set of args, try again
 */
#omdef vdchn$Get2(objOE   = NULL,
		  objID   = NULL,

                  chnName = NULL,
                  chnIDx  = VDCHN_IDX_NONE,

		  nth     = -1,

		  cnt     = NULL,
		  outID   = NULL,
		  outVLA  = NULL,
		  outSel  = NULL
	        )

VDchnGet((objOE),   (objID),
         (chnName), (chnIDx),  (cnt),
         (nth),(outID),(outVLA),(outSel))

#endomdef

/* --------------------------------------------------
 * Make it easier to get a list of objects
 */
extern IGRstat VDchnGetList __((
  TGRobj_env *objOE,
  TGRid      *objID,

  IGRchar    *chnName,
  IGRint      chnIDx,
  IGRint      maxCnt,

  IGRint     *cnt,
  TGRid      *outIDs));

/* --------------------------------------------------
 * Use the "easier way of getting a list of objects" to obtain a filtered list
 * of objects. This list would contain all the objects belonging to a specified
 * class that lie on a specified channel of a given object.	Anand (Aug, 2k)
 * --------------------------------------------------
 */
extern IGRstat VDchnGetFilteredList __((
  TGRobj_env *objOE,
  TGRid      *objID,

  IGRchar    *chnName,
  IGRint      chnIDx,
  IGRint      maxCnt,

  IGRint     *cnt,
  TGRid      *outIDs,

  GRclassid  FltrClsId,
  IGRchar    *FltrClNam ));

#omdef vdchn$GetList(objOE   = NULL,
		     objID   = NULL,

		     chnName = NULL,
		     chnIDx  = VDCHN_IDX_NONE,
		     maxCnt,

		     cnt,
		     outIDs  = NULL,
		     
			/* Below line added by Anand */
		     FltrClsId = NULL , FltrClNam = NULL )

#if	om$specified ( FltrClsId ) || om$specified ( FltrClNam )

VDchnGetFilteredList((objOE),(objID),
		     (chnName), (chnIDx),(maxCnt),
		     (cnt),(outIDs),
		     (FltrClsId),(FltrClNam))

#else

VDchnGetList((objOE),(objID),
	     (chnName), (chnIDx),(maxCnt),
	     (cnt),(outIDs))

#endif

#endomdef

/* -----------------------------------------------
 * Search child channel for object or objects of given class
 * Searched through ACpretendin's as well
 * Does not currently support ASsource or ASsourcein
 */

extern IGRstar VDchnGetChildrenByClass __((
  TGRobj_env *i_objOE, 
  TGRid      *i_objID,
  VDclassid   i_classID,
  IGRchar    *i_className,
  TGRid      *o_childID,
  TVDvlaID   *o_vla
));

#omdef vdchn$GetChildrenByClass(
  objOE     = NULL,
  objID     = NULL,
  classID   = OM_K_NOTUSING_CLASSID,
  className = NULL,
  childID   = NULL,
  vla       = NULL
)

VDchnGetChildrenByClass((objOE),(objID),(classID),(className),(childID),(vla))
#endomdef

#if defined(__cplusplus)
}
#endif

#endif










