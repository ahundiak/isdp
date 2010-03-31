/* ###################   APOGEE COMPILED   ################## */
/* ###################   ANSI COMPILED     ################## */
/*
 This file consists of the following three functions:

 EFplace_line_string
  Outputs a linestring, line, or point into the database
 EMoutput_linestring
  Outputs a set of linestrings into the database
 EMoutput_point
  Outputs a set of points into the database

 10/07/87 : rlw : Bound these three functions into one file and
                  reworked them to remove duplicate code
 07/08/93   Sudha Modified for BSprototypes ansification

 */

class implementation GRvg;

#include "EMS.h"
/* 
DESCRIPTION

   This function creates a linestring which passes through the input
   points.

   RETURN VALUES

   status               if TRUE then no problems else failure
   objid		Object id of the linestring object
   msg                  MSSUCC if success
                        MSFAIL if problems

HISTORY

   04/10/87 : rlw : creation date
   10/07/87 : rlw : Basically reworked.
 */

#include "msdef.h"
#include "bserr.h"
#include "bsparameters.h"
#include "bstst_plan.h"
#include "bsdistptpts.h"

extern OMuword OPP_GR3dlineseg_class_id;
extern OMuword OPP_GR3dlinestr_class_id;
extern OMuword OPP_GR3dpoint_class_id;

IGRboolean EFplace_line_string(
 my_id, 
 construct_list,
 number_of_points,
 points,
 objid,
 msg)

OM_S_OBJID	my_id;
struct		GRvg_construct *construct_list;
IGRlong		number_of_points;
IGRpoint	points[];
OM_S_OBJID	*objid;
IGRlong		*msg;

{
 OMuword	class_id;
 IGRboolean	status;
 IGRlong	sts, loc_msg;
 struct		IGRbsp_curve loc_curve;
 IGRdouble	scratch[3], dist_tol, distance;
/*
 * Initialize
 */
 *msg = MSSUCC;
 status = TRUE;
 *objid = NULL_OBJID;
 loc_curve.order          = 2;
 loc_curve.periodic       = FALSE;
 loc_curve.rational       = FALSE;
 loc_curve.non_uniform    = FALSE;
 loc_curve.num_poles      = number_of_points;
 loc_curve.poles          = (IGRdouble *) &points[0][0];
 loc_curve.num_knots      = 0;
 loc_curve.knots          = NULL;
 loc_curve.rational       = FALSE;
 loc_curve.weights        = NULL;
 loc_curve.num_boundaries = 0;
 loc_curve.bdrys          = NULL;
 construct_list->geometry = (IGRchar *) &loc_curve;
/*
 * Set the planar and physically closed information correctly
 */
 if (loc_curve.num_poles <= 2)
  loc_curve.planar = TRUE;	/* This is the way IGE defines it */
 else
  {
   BStst_plan(loc_curve.num_poles, 
              loc_curve.poles, 
              NULL,
              &loc_curve.planar, 
              scratch,
              &loc_msg);
    if (loc_msg != BSSUCC)
     {
      *msg = MSFAIL;
      goto wrapup;
     }
  }
 if (loc_curve.num_poles > 1)
  {
   status = BSEXTRACTPAR(&loc_msg, BSTOLSQLENVEC, dist_tol);
   distance = BSdistptpts(&loc_msg,
                          &loc_curve.poles[0],
                        &loc_curve.poles[3 * (loc_curve.num_poles - 1)]);
   if( distance <= dist_tol )
    loc_curve.phy_closed = TRUE;
   else
    loc_curve.phy_closed = FALSE;
  }
 else
  loc_curve.phy_closed = FALSE;
/*
 * Decide what to construct
 */
 if (loc_curve.num_poles == 1)
  class_id = OPP_GR3dpoint_class_id;
 else if (loc_curve.num_poles == 2)
  {
   if (loc_curve.phy_closed)
    {
     class_id = OPP_GR3dpoint_class_id;
     loc_curve.num_poles = 1;
     loc_curve.phy_closed = FALSE;
    }
   else
    class_id = OPP_GR3dlineseg_class_id;
  }
 else
  class_id = OPP_GR3dlinestr_class_id;
/*
 * Construct the linestring
 */
 {
  struct IGRdisplay local_display, *saved_display;

  saved_display = NULL;
  if ((class_id == OPP_GR3dpoint_class_id) &&
      (construct_list->display->weight < 3))
   {
    local_display = *(construct_list->display);
    local_display.weight = 3;
    saved_display = construct_list->display;
    construct_list->display = &local_display;
   }
  sts = om$construct(classid = class_id,
                     p_objid = objid,
                     osnum = construct_list->env_info->md_id.osnum,
                     msg = message GRgraphics.GRconstruct(construct_list));
  if (saved_display) construct_list->display = saved_display;
   if (! (1 & sts))
    {
     sts = om$send(mode = OM_e_wrt_object,
                   msg = message Root.delete(1),
                   senderid = my_id,
                   targetid = *objid);
     *msg = MSFAIL;
     goto wrapup;
    }
 }
/*
 * Eof
 */
wrapup:
 construct_list->geometry = NULL;
 if (! (1 & *msg))
  return(FALSE);
 else
  return(TRUE);
 }

/*
  This routine receives a pointer to an array of polyline structures and
  a prefilled construct list.  It constructs an object for each polyline
  and displays the polyline.

  I don't remember when I wrote this. But I have trashed almost all of it.

  rlw
 */

IGRlong EMoutput_linestring(
 msg, 
 my_id, 
 construct_list, 
 num_polylines, 
 poly_lines,
 object_type_ids)

IGRlong		*msg;
OM_S_OBJID	my_id;
struct		GRvg_construct *construct_list;
IGRlong		num_polylines;
struct		IGRpolyline *poly_lines;
struct		GRid *object_type_ids;

{
 IGRboolean	status, EFplace_line_string();
 IGRlong	i;

 status = TRUE;

 for (i = 0; i < num_polylines; i++)
  {
   status = EFplace_line_string(
     my_id, 
     construct_list,
     poly_lines[i].num_points,
     poly_lines[i].points,
     &object_type_ids[i].objid,
     msg);
    if (!status) break;
   object_type_ids[i].osnum = construct_list->env_info->md_id.osnum;
  } /* for (i = 0; i < num_polylines; i++) */
/*
 * eof
 */
 if (1 & *msg)
  *msg = BSSUCC;
 else
  *msg = BSFAIL;
 return(status);
}

/*

 This routine receives an array of points and
 a prefilled construct list.  It constructs an object for each point.

 10/15/86 : jbk : Fixed for more than one point.
 10/07/87 : rlw : Reworked

 */

IGRlong EMoutput_point(
 msg, 
 my_id, 
 construct_list, 
 num_points,
 points,
 object_type_ids)

IGRlong		*msg;
OM_S_OBJID	my_id;
struct		GRvg_construct *construct_list;
IGRlong		num_points;
IGRpoint	points[];
struct		GRid *object_type_ids;

{
 IGRboolean	status, EFplace_line_string();
 IGRlong	i;

 for (i = 0; i < num_points; i++)
  {
   status = EFplace_line_string(
     my_id, 
     construct_list,
     1,
     points[i],
     &object_type_ids[i].objid,
     msg);
    if (!status) break;
   object_type_ids[i].osnum = construct_list->env_info->md_id.osnum;
  } /* for (i = 0; i < num_points; i++) */
/*
 * eof
 */
 if (1 & *msg)
  *msg = BSSUCC;
 else
  *msg = BSFAIL;
 return(status);
}

end implementation GRvg;
