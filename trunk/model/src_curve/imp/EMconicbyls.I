/*
 Description

 This method constructs a conic given a linestring as input data.
 It is assumed that the caller knows that the input data represents
 a conic section.  

 Notes 

 If the method determines that the conic is a circle, ellipse, circular 
 arc, or elliptical arc then it will change to that class.

 This method places the least emphasis on the accuracy of the endpoints, 
 i.e. as long as you input at least 7 points the endpoints are not
 required to lie exactly on the conic section.

 History

 03/22/88 : rlw : The beginning
 05/30/88 : rlw : Reworked to put functionality into a function so that
                  Siki could use it for model space counterparts.
 Sudha  06/16/93     Modified for BSprototype ansification
 */

class implementation GRsubbc;

#include "EMS.h"
#include "OMmacros.h"			/* OM_BLOCK_MOVE macro */
#include "msdef.h"			/* Has MSSUCC, MSFAIL */
#include "bserr.h"
#include "bsconic.h"
#include "bsconicgenx.h"
#include "bsunwght_p.h"
#include "bsnorkts.h"
#include "bsfullarc.h"
#include "bsdistnct2.h"
#include "bscv_copy.h"
#include "bsconic50.h"
#include "bscncxttpt.h"
#include "bschgcvewts.h"

#define MAX_CONIC_POLES BSPOLESMXCONICGEN + 24
#define MAX_CONIC_KNOTS MAX_CONIC_POLES + BSORDERCONICGEN

extern OMuword OPP_GRbcsubbc_class_id;
extern OMuword OPP_GR3dcircle_class_id;
extern OMuword OPP_GR3dcirarc_class_id;
extern OMuword OPP_GR3dellipse_class_id;
extern OMuword OPP_GR3dellarc_class_id;

method EMconic_by_linestring(
 IGRlong	number_of_points;
 IGRpoint	*input_points;
 struct		GRlc_info *linestring;
 struct		GRvg_construct *construct_list; 
 OM_S_OBJID	*constructed_object)

{
 IGRboolean	changed_ids, delete_abstract;
 IGRlong	*msg, sts, num_points;
 IGRdouble	weights[MAX_CONIC_POLES], knots[MAX_CONIC_KNOTS];
 IGRpoint	poles[MAX_CONIC_POLES], *points;
 struct		IGRbsp_curve conic;
/*
 * Initialize
 */
 msg = construct_list->msg;
 *msg = MSSUCC;
 delete_abstract = FALSE;
 changed_ids = FALSE;
 conic.poles = poles[0];
 conic.knots = knots;
 conic.weights = weights;
/*
 * Get the points
 */
 if (input_points)
  {
   num_points = number_of_points;
   points = input_points;
  }
 else
  {
   IGRboolean	status;
   struct	GRid *id;
   struct	GRmdenv_info *mdenv_info;
   struct	IGRbsp_curve *curve;

   id = &linestring->located_obj;
   mdenv_info = &linestring->module_info.md_env;
   sts = om$send(
     msg = message GRvg.GRgenabsg(
      msg,
      &mdenv_info->matrix_type,
      mdenv_info->matrix,
      (IGRchar **) &curve),
     targetid = id->objid,
     targetos = id->osnum);
    if (! (1 & sts)) goto wrapup;
   if (curve->rational)
    {
     IGRlong	loc_msg;

     status = BSunwght_p(
      &loc_msg,
      curve->poles,
      curve->weights,
      &curve->num_poles,
      curve->poles);
     delete_abstract = TRUE;
    } /* if (curve->rational) */
   num_points = curve->num_poles;
   points = (IGRpoint *) curve->poles;
  }
/*
 * Post the geometry
 */
 {
  IGRlong   RLW_get_conic_from_linestring();
  OMuword	classid;

  sts = RLW_get_conic_from_linestring(
    num_points,
    points,
    &classid,
    &conic,
    msg);
   if (! (1 & sts)) goto wrapup;
  if (classid == OPP_GRbcsubbc_class_id)
   *constructed_object = my_id;
  else
   {
    sts = om$construct(
      classid = classid,
      p_objid = constructed_object);
     if (! (1 & sts))
      {
       *msg = MSFAIL;
       goto wrapup;
      }
    changed_ids = TRUE;
   }
  construct_list->geometry = (IGRchar *) &conic;
  sts = om$send(
    msg = message GRbspline.GRconstruct(
     construct_list),
    targetid = *constructed_object);
   if (! (1 & sts))
    {
     *msg = MSFAIL;
     goto wrapup;
    }
 }
/*
 * eof
 */
wrapup:
 {
  IGRboolean	error;
 extern  IGRboolean  GRabsg_del_all();
  IGRboolean	status;

  if (delete_abstract) status = GRabsg_del_all();
  error = (! (1 & *msg));
  if (error || changed_ids)
   {
    sts = om$send(
     msg = message Root.delete(1),
     targetid = my_id);
   }
  if (error && changed_ids)
   {
    sts = om$send(
     msg = message Root.delete(1),
     targetid = *constructed_object);
   }
  if (error)
   {
    *constructed_object = NULL_OBJID;
    return(OM_E_ABORT);
   }
  else
   return(OM_S_SUCCESS);
 }
}
/*
 Given a set of points this function, if successful, will
 return the resulting conic and the class that should
 be created to represent the conic.  Note that memory
 for the conic should be preallocated by the caller.

 rlw : 05/30/88 : Maul date

 */
IGRlong RLW_get_conic_from_linestring(
 num_points,
 points,
 classid,
 conic,
 msg)

IGRlong		num_points;
IGRpoint	points[];
OMuword		*classid;
struct		IGRbsp_curve *conic;
IGRlong		*msg;

{
 IGRlong	loc_msg;
 IGRint		type;
 IGRshort	stype;
 IGRpoint	conic_points[5];
/*
 * Initialize
 */
 *msg = MSSUCC;
/*
 * Sampling logic
 *
 * I am trying to do a best fit by getting a good distribution of
 * the input points.  I cannot rely on the endpoints to be accurate,
 * since they may have been involved in a trimming operation.
 */
 if (num_points < 5)
  {
   *msg = MSINARG;
   goto wrapup;
  }
 else if (num_points < 7)
  {
   OM_BLOCK_MOVE(
    points,
    conic_points,
    5 * sizeof(IGRpoint));
  }
 else
  {
   IGRlong	index[5], delta, i;

   delta = (num_points - 2) / 4;
   index[0] = 1;
   index[1] = index[0] + delta;
   index[2] = index[1] + delta;
   index[3] = index[2] + delta;
   index[4] = num_points - 2;
   for (i = 0; i < 5; i++)
    {
     OM_BLOCK_MOVE(
      points[index[i]],
      conic_points[i],
      sizeof(IGRpoint));
    } /* for (i = 0; i < 5; i++) */
  } /* ELSE FOR else if (num_points < 7) */
/*
 * Get the bspline curve representing the
 * conic
 */
 {
  IGRboolean	found;
  IGRvector	unit_plane_normal;

   found = BSconic50(
     &loc_msg, 
     conic_points[0],
     conic_points[1],
     conic_points[2],
     conic_points[3], 
     conic_points[4], 
     conic,
     unit_plane_normal, 
     &type);
    if (!found)
     {
      *msg = MSINARG;
      goto wrapup;
     }
  }

  stype = type;

/*
 * Determine if the input curve is physically closed.  If so then
 * we must generate a closed conic.
 */
 {
  IGRboolean	status, physically_closed;
  IGRdouble	t_weights[MAX_CONIC_POLES], t_knots[MAX_CONIC_KNOTS];
  IGRpoint	t_poles[MAX_CONIC_POLES];
  struct	IGRbsp_curve tmp_conic;

  tmp_conic.poles = t_poles[0];
  tmp_conic.knots = t_knots;
  tmp_conic.weights = t_weights;
  status = BSdistnct2(
   &loc_msg,
   points[0],
   points[num_points - 1]);
  physically_closed = !status;
  if (physically_closed)
   {
    status = BSfullarc(
      &loc_msg,
      conic,
      &tmp_conic);
     if (!status)
      {
       *msg = MSFAIL;
       goto wrapup;
      }
    status = BScv_copy(
     &loc_msg,
     &tmp_conic,
     conic);
   } /* if (physically_closed) */
/*
 * The conic is not physically closed.  We must extend the open conic
 * so that it extends to the ends of the input data.
 */
  else if (num_points != 5)
   {
    if (num_points != 6)
     {
      status = BScncxttpt(
        &loc_msg,
        &stype,
        conic,
        points[0],
        &conic->knots[conic->order - 1],
        &tmp_conic);
       if (! status)
        {
         *msg = MSFAIL;
         goto wrapup;
        }
     } /* if (num_points != 6) */
    else
     status = BScv_copy(
      &loc_msg,
      conic,
      &tmp_conic);
    status = BScncxttpt(
      &loc_msg,
      &stype,
      &tmp_conic,
      points[num_points - 1],
      &tmp_conic.knots[tmp_conic.num_poles],
      conic);
     if (! status)
      {
       *msg = MSFAIL;
       goto wrapup;
      }
   } /* ELSE FOR if (physically_closed) */
 }
/*
 * Determine the construction class
 */
 switch (type)
  {
   case BSCARCCIRCULAR:
    *classid = conic->phy_closed ? OPP_GR3dcircle_class_id : 
               OPP_GR3dcirarc_class_id;
    break;
   case BSCARCELLIPTIC:
    *classid = conic->phy_closed ? OPP_GR3dellipse_class_id : 
               OPP_GR3dellarc_class_id;
    break;
   default:
    *classid = OPP_GRbcsubbc_class_id;
    break;
  } /* switch (type) */
/*
 * Prepare the geometry
 */
 {
  IGRboolean	status;

  status = BSnorkts(
    &loc_msg,
    &conic->order,
    &conic->num_poles,
    conic->knots);
   if (loc_msg != BSSUCC)
    {
     *msg = MSFAIL;
     goto wrapup;
    }
  if (conic->rational)
   {
    BSchgcvewts(
      conic,
      conic,
      &loc_msg);
     if (loc_msg != BSSUCC)
      {
       *msg = MSFAIL;
       goto wrapup;
      }
   } /* if (conic->rational) */
 }
/*
 * eof
 */
wrapup:
 if (! (1 & *msg))
  return(FALSE);
 else
  return(TRUE);
}

end implementation GRsubbc;
