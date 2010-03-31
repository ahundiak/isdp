/* ###################   APOGEE COMPILED   ################## */
/*
 Description

 This method constructs a conic by:

 1) 5 points
 2) 3 points and 2 tangents
    Order of points is p1, p2, p3, t1, t2
 3) 4 points and 1 tangent
    Order of points is p1, p2, p3, p4, t1
 4) 2 points, 2 tangents, and a rho value
    Order is p1, t1, p2, t2, rho

 Notes 

 Points are expected for the tangents.  The tangent vector
 is calculated by the math.

 If the method determines that the conic is an circular or elliptical
 arc then it will change to that class.

 See EMScnc5input.h for the options.

 History

 ??/??/86 : jbk : The beginning
 11/17/87 : rlw : Documented this file and spec file, 
                  and reworked the method.
 Sudha  06/16/93     Modified for BSprototype ansification 

 */

class implementation GRsubbc;

#include "EMS.h"
#include "msdef.h"
#include "bserr.h"
#include "bsconic.h"
#include "bsconicgenx.h"
#include "EMScnc5input.h"
#include "bsxln.h"
#include "bsconicrho.h"
#include "bsconic50.h"
#include "bsconic41.h"
#include "bsconic32.h"

extern OMuword OPP_GR3dcirarc_class_id;
extern OMuword OPP_GR3dellarc_class_id;

method EMgenConicBy5inputs(
struct		GRvg_construct *construct_list; 
IGRint		option;
IGRpoint	points[5];
IGRdouble	rho;
OM_S_OBJID	*constructed_object)

{
 IGRboolean	found, changed_ids;
 IGRlong	msg, loc_msg, sts;
 IGRdouble	weights[BSPOLESMXCONICGEN], knots[BSKNOTSMXCONICGEN];
 IGRpoint	poles[BSPOLESMXCONICGEN];
 IGRvector	unit_plane_normal;
 IGRint		type;
 struct		IGRbsp_curve conic;
/*
 * Initialize
 */
 msg = MSSUCC;
 changed_ids = FALSE;
 conic.poles = poles[0];
 conic.knots = knots;
 conic.weights = weights;
/*
 * Get the bspline curve representing the
 * conic
 */
 switch (option)
  {
   case EMSconic_by_32:
    {

     found = BSconic32(
      &loc_msg, 
      points[0],
      points[1],
      points[2],
      points[3],
      points[4],
      &conic,
      unit_plane_normal, 
      &type);
    }
    break;
   case EMSconic_by_41:
    {

     found = BSconic41(
      &loc_msg, 
      points[0], 
      points[1],
      points[2],
      points[3],
      points[4], 
      &conic,
      unit_plane_normal,
      &type);
    }
    break;
   case EMSconic_by_50:
    {

     found = BSconic50(
      &loc_msg, 
      points[0],
      points[1],
      points[2],
      points[3], 
      points[4], 
      &conic,
      unit_plane_normal, 
      &type);
    }
    break;
   case EMSconic_by_22Rho:
    {
     IGRpoint	intersection_point;

     found = BSxln(
       &loc_msg,
       points[0],
       points[1],
       points[2],
       points[3],
       intersection_point);
      if (found)
       {
        found = BSconicrho(
         &loc_msg, 
         points[0],
         intersection_point,
         points[2],
         &rho,
         &conic,
         unit_plane_normal, 
         &type);
       } /* if (found) */
    }
    break;
   default:
    msg = MSINARG;
    goto wrapup;
  } /* switch (option) */
/*
 * Quit if no conic was possible
 */
 if (!found)
  {
   msg = MSFAIL;
   goto wrapup;
  }
/*
 * Post the geometry
 */
 switch (type)
  {
   case BSCARCCIRCULAR:
    sts = om$construct(
      classid = OPP_GR3dcirarc_class_id,
      p_objid = constructed_object);
     if (! (1 & sts))
      {
       msg = MSFAIL;
       goto wrapup;
      }
    changed_ids = TRUE;
    break;
   case BSCARCELLIPTIC:
    sts = om$construct(
      classid = OPP_GR3dellarc_class_id,
      p_objid = constructed_object);
     if (! (1 & sts))
      {
       msg = MSFAIL;
       goto wrapup;
      }
    changed_ids = TRUE;
    break;
   default:
    *constructed_object = my_id;
    break;
  } /* switch (type) */
/*
 * Post the geometry
 */
 construct_list->geometry = (IGRchar *) &conic;
 sts = om$send(
   msg = message GRbspline.GRconstruct(
    construct_list),
   targetid = *constructed_object);
  if (! (1 & sts))
   {
    msg = MSFAIL;
    goto wrapup;
   }
/*
 * eof
 */
wrapup:
 {
  IGRboolean	error;

  *construct_list->msg = msg;
  error = (! (1 & msg));
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
   return(OM_E_ABORT);
  else
   return(OM_S_SUCCESS);
 }
}

end implementation GRsubbc;
