/* ###################   APOGEE COMPILED   ################## */
class implementation GRcurve;

#include "EMS.h"
#include <stdio.h>
#include "OMminimum.h"
#include "igrtypedef.h"
#include "gocmacros.h"
#include "OMerrordef.h"
#include "msdef.h"
#include "emserr.h"
#include "emsdef.h"
#include "bserr.h"
#include "bsparameters.h"
#include "EMSmsgdef.h"
#include "bsdistptpts.h"

IGRlong EMextend_to_int(msg, md_info, obj1, obj2, parm1, parm2, tol,
                        check_bounds, extend_both, end_pnt1, end_pnt2,
                        ext_point)
IGRlong  *msg;              /* return code */
struct GRmd_env  *md_info;  /* obj1 & obj2 module env */
struct GRid  *obj1, *obj2;  /* objid, osnum for obj1 & obj2 */
struct GRparms  *parm1;     /* parm on obj1 of end to intersect & extend */
struct GRparms  *parm2;     /* parm on obj2 of end to intersect & extend */
IGRdouble tol;              /* square tol extend point must be within */
IGRboolean  check_bounds;   /* wish to check for out of bounds? */
IGRboolean  extend_both;    /* wish to extend obj2's endpoint? */
IGRpoint  end_pnt1;         /* the 1st endpoint to extend */
IGRpoint  end_pnt2;         /* the 2nd endpoint to extend; also approximate
                               intersection point */
IGRpoint  ext_point;        /* the returned extension point */

/*
Abstract
	This function intersects 2 curves using their extended geometries.
    
It then extends the first curve to the intersection point and extends the
    second curve if extend_both is true.

Notes
	This function won't work for composite curves as such.  It will work on
	a curve owned be a composite.  Also, note that the method GRptextend
	posts the geometry of the two curves back and it also handles doing
	any sort of trim operation.

Files
	EMextoint.I, GR2objisect.C, EMscPExtend.I

History
	dhm		08/04/87	creation date.
	dhm		12/07/87	revised the call list and took out getgeom's.
    dhm     01/21/88    put in some checks for gaps after extensions.
    dhm     05/04/88    modified the arguments, added flag to determine
                        whether to check for out of bounds, and added flag
                        to determine whether to extend the second object.
    dhm     07/29/88    changed to check new endpoints against bas_tol_sq
                        using BSdistptpts().
    dhm     08/05/88    added checks to see if extension is needed; 
                        returns EMS_I_Useless if ext_point is the same
                        as both of the endpoints.
    rlw     10/11/88    Modified to modify linear elements to touch if
                        extension fails.
    dhm     01/26/89    Fixed a problem with new_endpnt1 not being set
                        if there was no gap between end_pnt1 and ext_point.
    pp      09/08/89    Removed the check to see if extension is necessary.
    Sudha   07/08/93    Modified for BSprototypes ansification 

*/

{
  IGRlong		status, msg_loc;
  IGRchar		errmsg[EMMAXERRMSG_LEN];
 extern  IGRboolean  GR2objisect();
  IGRboolean	sts, did_do1 = TRUE, did_do2 = TRUE;
  IGRpoint		new_endpnt1, new_endpnt2;
  IGRdouble		bas_tol, bas_tol_sq;

  *msg = MSSUCC;
  status = OM_S_SUCCESS;
  strcpy(errmsg, "EMextend_to_int error\n");

  sts = BSEXTRACTPAR(&msg_loc, BSTOLLENVEC, bas_tol);
  bas_tol_sq = bas_tol * bas_tol;

  /*
   * Check to see if the input end points are
   * within the extend tol if requested.
   */

  if ( check_bounds && (BSdistptpts(&msg_loc, end_pnt1, end_pnt2) > tol) )
  {
    *msg = EMS_E_InvalidArg;
    goto ret_end;
  }

  /*
   * Find the insection point of the 2 objects.
   * The approximate intersection point is taken
   * to be the 2nd object's end point.
   */

  sts = GR2objisect(&msg_loc, obj1, &md_info->md_env, parm1, obj2,
                    &md_info->md_env, parm2, end_pnt2, ext_point);
/*
 * Modified to attempt to modify linear geometry
 * if extension fails.  rlw  10/11/88
 */
   if ((! sts) || (EMis_error(msg_loc)))
    {
     IGRlong	EFmodify_linear_to_intersection();  /* It's in this file */

     sts = EFmodify_linear_to_intersection(
       obj1,
       md_info,
       (parm1->u == 0.0),
       obj2,
       md_info,
       (parm2->u == 0.0),
       extend_both,
       ext_point,
       msg);
      if (*msg == MANOSOLUTION) *msg = EMS_E_NoIntersection;
     goto ret_end;
    }
/*
 * Modified to attempt to modify linear geometry
 * if extension was successful but intersection was out
 * of search tolerance from endpoints.  rlw  10/11/88
 */
  if ( check_bounds && (BSdistptpts(&msg_loc, end_pnt1, ext_point) > tol) )
  {
     IGRlong	EFmodify_linear_to_intersection();  /* It's in this file */

     sts = EFmodify_linear_to_intersection(
       obj1,
       md_info,
       (parm1->u == 0.0),
       obj2,
       md_info,
       (parm2->u == 0.0),
       extend_both,
       ext_point,
       msg);
      if (*msg == MANOSOLUTION) *msg = EMS_I_OutOfBounds;
    goto ret_end;
  }

  /*
   * Extend the 1st object's end point to the intersection point if
   * needed.
   */

/*
  if (BSdistptpts(&msg_loc, end_pnt1, ext_point) > bas_tol_sq)
  {
  Removed pp (09/08/89)
*/
    status = om$send(msg = message GRcurve.GRptextend(&msg_loc, md_info,
                           end_pnt1, ext_point, new_endpnt1),
                     senderid = NULL_OBJID,
                     targetid = obj1->objid,
                     targetos = obj1->osnum);
    EMomerr_hndlr(status, ret_end, errmsg);
    EMerr_hndlr(EMis_error (msg_loc), *msg, MSFAIL, ret_end);
/*
  }
  else
  {
    did_do1 = FALSE;

    new_endpnt1[0] = ext_point[0];
    new_endpnt1[1] = ext_point[1];
    new_endpnt1[2] = ext_point[2];
  }
 Removed pp (09/08/89)
*/

  /*
   * Extend the 2nd object's end point to the insection point if requested
   * and needed.
   */

  if (extend_both)
  {
/*
    if (BSdistptpts(&msg_loc, end_pnt2, ext_point) > bas_tol_sq)
 Removed pp (09/08/89)
*/
      status = om$send(msg = message GRcurve.GRptextend(&msg_loc, md_info,
                             end_pnt2, ext_point, new_endpnt2),
                       senderid = NULL_OBJID,
                       targetid = obj2->objid,
                       targetos = obj2->osnum);
      EMomerr_hndlr(status, ret_end, errmsg);
      EMerr_hndlr(EMis_error(msg_loc), *msg, MSFAIL, ret_end);

      /*
       * Check to see if the newly extended end points are
       * within base tol.  This is done because of a problem Richard found
       * with arc's and lines not always intersecting exactly right.
       */

      if (BSdistptpts(&msg_loc, new_endpnt1, new_endpnt2) > bas_tol_sq)
      {
         *msg = EMS_E_Modified;
         goto ret_end;
      }
/*
    else
      did_do2 = FALSE;
*/

  }  /* end if extend_both */

  if (!did_do1 && !did_do2) *msg = EMS_I_Useless;


ret_end:
  return(status);
}

/*
 Description

 Given 2 bspline curves this function will attempt to modify them
 such that the specified endpoints are common.  This routine is
 called when the normal extend to intersection extension routine
 EMextend_to_int() fails because the extended curves do not intersect.
 If one or both of the curves is linear (order is 2) then this function
 will modify the curves such that they touch.

 Input arguments
 
 curve_1		Object id and space number for curve 1
 md_env_1		Module enviroment for curve 1
 beg_curve_1		If TRUE then the starting point of curve 1 is
                        to be modified or used as a reference, else the
                        end point is used.
 curve_2		Object id and space number for curve 2
 md_env_2		Module enviroment for curve 2
 beg_curve_2		If TRUE then the starting point of curve 2 is
                        to be modified or used as a reference, else the 
                        end point is used.
 modify_curve_2		Indicator telling if curve 2 can be modified

 Output arguments

 extension_point	Resulting common point
 msg			Error return code
                        MSSUCC - Was able to extend
                        MANOSOLUTION - Could not do it because of curve types
			MSFAIL - Something is wrong

 Notes

 Orthogonal and planar subtypes are not supported because these
 objects will potentially change class when modified.  The routines
 which call this routine rely on preservation of id's.

 History

 rlw : 10/11/88 : Creation date
 */

extern OMuword OPP_GR3dlinestr_class_id;
extern OMuword OPP_GR3dlineseg_class_id;
extern OMuword OPP_GRbcsubbc_class_id;

IGRlong EFmodify_linear_to_intersection(
 curve_1,
 md_env_1,
 beg_curve_1,
 curve_2,
 md_env_2,
 beg_curve_2,
 modify_curve_2,
 extension_point,
 msg)

struct		GRid *curve_1;
struct		GRmd_env *md_env_1;
IGRboolean	beg_curve_1;
struct		GRid *curve_2;
struct		GRmd_env *md_env_2;
IGRboolean	beg_curve_2;
IGRboolean	modify_curve_2;
IGRpoint	extension_point;
IGRlong		*msg;

{
 extern		IGRlong EMget_the_geometry();
 IGRboolean	curve_1_is_linear, curve_2_is_linear, modify_curve_1;
 IGRlong	sts;
 struct		GRlc_info lc_info;
 struct		IGRbsp_curve *curve_geometry_1, *curve_geometry_2;
/*
 * Initialize
 */
 *msg = MSSUCC;
 curve_geometry_1 = NULL;
 curve_geometry_2 = NULL;
/*
 * Get the geometry for curve 1 and ascertain if
 * it is a linear curve.
 */
 lc_info.located_obj = *curve_1;
 lc_info.module_info = *md_env_1;
 sts = EMget_the_geometry(
   &lc_info,
   TRUE,		/* Is a curve */
   FALSE,		/* Is not directed */
   FALSE,		/* Separate mallocs not necessary */
   NULL_OBJID,		/* I'm not telling */
   &curve_geometry_1,	/* The curve */
   msg);
  if (! (1 & sts)) goto wrapup;
 curve_1_is_linear = ((curve_geometry_1->order == 2) &&
  (! curve_geometry_1->rational));
 if (curve_1_is_linear)
  {
   OMuword	classid;

   sts = om$get_classid(
     objid = curve_1->objid,
     osnum = curve_1->osnum,
     p_classid = &classid);
    if (! (1 & sts))
     {
      *msg = MSFAIL;
      goto wrapup;
     }
   if (((classid != OPP_GR3dlinestr_class_id) &&
        (classid != OPP_GR3dlineseg_class_id) &&
        (classid != OPP_GRbcsubbc_class_id)) &&
       (curve_geometry_1->num_poles > 2))
    curve_1_is_linear = FALSE;
  } /* if (curve_1_is_linear) */
/*
 * Give it up if the first curve is not linear and we
 * are not allowed to modify the second curve
 */
 if (! (curve_1_is_linear || modify_curve_2))
  {
   *msg = MANOSOLUTION;
   goto wrapup;
  }
/*
 * Get the geometry for curve 2 and ascertain if
 * it is a linear curve.
 */
 lc_info.located_obj = *curve_2;
 lc_info.module_info = *md_env_2;
 sts = EMget_the_geometry(
   &lc_info,
   TRUE,		/* Is a curve */
   FALSE,		/* Is not directed */
   FALSE,		/* Separate mallocs not necessary */
   NULL_OBJID,		/* I'm not telling */
   &curve_geometry_2,	/* The curve */
   msg);
  if (! (1 & sts)) goto wrapup;
 curve_2_is_linear = ((curve_geometry_2->order == 2) &&
  (! curve_geometry_2->rational));
 if (curve_2_is_linear)
  {
   OMuword	classid;

   sts = om$get_classid(
     objid = curve_2->objid,
     osnum = curve_2->osnum,
     p_classid = &classid);
    if (! (1 & sts))
     {
      *msg = MSFAIL;
      goto wrapup;
     }
   if (((classid != OPP_GR3dlinestr_class_id) &&
        (classid != OPP_GR3dlineseg_class_id) &&
        (classid != OPP_GRbcsubbc_class_id)) &&
       (curve_geometry_2->num_poles > 2))
    curve_2_is_linear = FALSE;
  } /* if (curve_2_is_linear) */
/*
 * Compute the new endpoint.  If only one curve is 
 * linear then modify it if both curves are linear 
 * then modify them both to the average.
 */
 modify_curve_1 = curve_1_is_linear;
 modify_curve_2 = (curve_2_is_linear && modify_curve_2);
 if (modify_curve_1 && modify_curve_2)
  {
   IGRlong	index;
   IGRdouble	*pole_to_modify_1, *pole_to_modify_2;

   if (beg_curve_1)
    index = 0;
   else
    index = (curve_geometry_1->num_poles - 1) * 3;
   pole_to_modify_1 = &curve_geometry_1->poles[index];
   if (beg_curve_2)
    index = 0;
   else
    index = (curve_geometry_2->num_poles - 1) * 3;
   pole_to_modify_2 = &curve_geometry_2->poles[index];
   extension_point[0] = (pole_to_modify_1[0] + pole_to_modify_2[0]) / 2.0;
   extension_point[1] = (pole_to_modify_1[1] + pole_to_modify_2[1]) / 2.0;
   extension_point[2] = (pole_to_modify_1[2] + pole_to_modify_2[2]) / 2.0;
   pole_to_modify_1[0] = extension_point[0];
   pole_to_modify_1[1] = extension_point[1];
   pole_to_modify_1[2] = extension_point[2];
   pole_to_modify_2[0] = extension_point[0];
   pole_to_modify_2[1] = extension_point[1];
   pole_to_modify_2[2] = extension_point[2];
  }
 else if (modify_curve_1)
  {
   IGRlong	index;
   IGRdouble	*pole_to_modify, *new_point, weight;

   if (beg_curve_2)
    index = 0;
   else
    index = (curve_geometry_2->num_poles - 1) * 3;
   new_point = &curve_geometry_2->poles[index];
   if (curve_geometry_2->rational)
    {
     weight = curve_geometry_2->weights[index / 3];
     new_point[0] /= weight;
     new_point[1] /= weight;
     new_point[2] /= weight;
    }
   if (beg_curve_1)
    index = 0;
   else
    index = (curve_geometry_1->num_poles - 1) * 3;
   pole_to_modify = &curve_geometry_1->poles[index];
   pole_to_modify[0] = new_point[0];
   pole_to_modify[1] = new_point[1];
   pole_to_modify[2] = new_point[2];
   extension_point[0] = new_point[0];
   extension_point[1] = new_point[1];
   extension_point[2] = new_point[2];
  }
 else if (modify_curve_2)
  {
   IGRlong	index;
   IGRdouble	*pole_to_modify, *new_point, weight;

   if (beg_curve_1)
    index = 0;
   else
    index = (curve_geometry_1->num_poles - 1) * 3;
   new_point = &curve_geometry_1->poles[index];
   if (curve_geometry_1->rational)
    {
     weight = curve_geometry_1->weights[index / 3];
     new_point[0] /= weight;
     new_point[1] /= weight;
     new_point[2] /= weight;
    }
   if (beg_curve_2)
    index = 0;
   else
    index = (curve_geometry_2->num_poles - 1) * 3;
   pole_to_modify = &curve_geometry_2->poles[index];
   pole_to_modify[0] = new_point[0];
   pole_to_modify[1] = new_point[1];
   pole_to_modify[2] = new_point[2];
   extension_point[0] = new_point[0];
   extension_point[1] = new_point[1];
   extension_point[2] = new_point[2];
  }
 else
  {
   *msg = MANOSOLUTION;
   goto wrapup;
  }
/*
 * Post the geometry back into the curves
 */
 {
  GRobjid	new_objid;
  struct	GRpost_info info;

  info.construct_flag = FALSE;
  if (modify_curve_1)
   {
    sts = om$send(
      msg = message GRvg.GRpostabsg(
       msg,
       md_env_1,
       &info,
       (IGRchar *) curve_geometry_1,
       &new_objid),
      targetid = curve_1->objid,
      targetos = curve_1->osnum,
      senderid = NULL_OBJID);
     if (! (1 & sts)) goto wrapup;
    if (new_objid != curve_1->objid)
     {
      *msg = MSFAIL;
      goto wrapup;
     }
   } /* if (modify_curve_1) */
  if (modify_curve_2)
   {
    sts = om$send(
      msg = message GRvg.GRpostabsg(
       msg,
       md_env_2,
       &info,
       (IGRchar *) curve_geometry_2,
       &new_objid),
      targetid = curve_2->objid,
      targetos = curve_2->osnum,
      senderid = NULL_OBJID);
     if (! (1 & sts)) goto wrapup;
    if (new_objid != curve_2->objid)
     {
      *msg = MSFAIL;
      goto wrapup;
     }
   } /* if (modify_curve_2) */
 }
/*
 * eof
 */
wrapup:
 if (curve_geometry_1) free(curve_geometry_1);
 if (curve_geometry_2) free(curve_geometry_2);
 if (! (1 & *msg))
  return(FALSE);
 else
  return(TRUE);
}

end implementation GRcurve;
