/* ###################   APOGEE COMPILED   ################## */
/*
 Description

 This method constucts a plane which is normal or tangent to
 a curve or surface.

 History

 10/03/86 : lst : Wrote EMplane_tan_to_curve method
 10/10/86 : pp  : Wrote EMtantosf method
 03/23/88 : rlw : Did something
 01/24/89 : rlw : Error return codes from math were not being checked.
 05/19/89 : DLB : Copied pos orient over to new surface.
 05/16/90 :Inasu: Replaced the math routine BSpl_nor_tc() with BSbdplnotc()
                  as a fix for TR 90n0615.
 */

class implementation EMSplane;

#include "EMS.h"
#include "msdef.h"			/* Has MSSUCC, MSFAIL */
#include "bserr.h"



method EMplane_normal_and_tangent_to(
 IGRboolean	want_tangent_plane;
 IGRboolean	have_curve;
 IGRboolean	u_partial;
 struct		GRlc_info *the_object;
 struct		GRparms *proj_parms;
 IGRdouble	length, width;
 struct		GRvg_construct *construct_list)

{
 IGRchar	*generic_pointer;
 IGRlong	sts, *msg, loc_msg;
 IGRdouble	u_knots[4], v_knots[4];
 IGRpoint	poles[4];
 struct		IGRbsp_surface plane;
/*
 * Initialize
 */
 msg = construct_list->msg;
 *msg = MSSUCC;
 plane.poles = poles[0];
 plane.u_knots = u_knots;
 plane.v_knots = v_knots;
/*
 * Get the objects geometry
 */
 {
  struct	GRid *id;
  struct	GRmdenv_info *mdenv_info;

  id = &the_object->located_obj;
  mdenv_info = &the_object->module_info.md_env;
  sts = om$send(
    msg = message GRvg.GRgenabsg(
     msg,
     &mdenv_info->matrix_type,
     mdenv_info->matrix,
     &generic_pointer),
    targetid = id->objid,
    targetos = id->osnum);
   if (! (1 & sts)) goto wrapup;
 }
/*
 * Branch based on the type of input geometry
 */
 if (have_curve)
  {
   struct	IGRbsp_curve *curve;

   curve = (struct IGRbsp_curve *) generic_pointer;
   if (want_tangent_plane)
    {
     extern      void BSpl_tan_tc();

     BSpl_tan_tc(
      curve,
      proj_parms->u,
      length,
      width,
      &plane,
      &loc_msg);
    } /* if (want_tangent_plane) */
   else
    {
     extern    void  BSbdplnortc();

     BSbdplnortc(
            curve,
            proj_parms->u,
            length,       /* length of the plane */
            width,        /* width  of the plane */
            &plane,
            &loc_msg);

    } /* ELSE FOR if (want_tangent_plane) */
  } /* if (have_curve) */
 else
  {
   struct	IGRbsp_surface *surface;

   surface = (struct IGRbsp_surface *) generic_pointer;
   if (want_tangent_plane)
    {
     extern      void BSpl_tan_ts();

     BSpl_tan_ts(
      surface,
      proj_parms->u,
      proj_parms->v,
      length,
      width,
      &plane,
      &loc_msg);
    } /* if (want_tangent_plane) */
   else
    {
     extern	void BSpl_nor_ts();

     BSpl_nor_ts(
      surface,
      proj_parms->u,
      proj_parms->v,
      length,
      width,
      u_partial ? 1 : 2,
      &plane,
      &loc_msg);
    } /* ELSE FOR if (want_tangent_plane) */
  } /* ELSE FOR if (have_curve) */
 if (loc_msg != BSSUCC)
  {
   *msg = MSFAIL;
   goto wrapup;
  }
/*
 * Copy over pos orient to new surface. - DLB
 */
 plane.pos_orient = ((struct IGRbsp_surface *) generic_pointer)->pos_orient;

/*
 * Load my instance data
 */
 construct_list->geometry = (IGRchar *) &plane;
 sts = om$send(
   msg = message GRvg.GRconstruct(construct_list),
   targetid = my_id);
  if (! (1 & sts)) goto wrapup;
/*
 * End of routine
 */
wrapup:
 if (! (1 & *msg))
  {
   sts = om$send(
    msg = message Root.delete(1),
    targetid = my_id);
   return(OM_E_ABORT);
  }
 else
  return(OM_S_SUCCESS);
}

end implementation EMSplane;
