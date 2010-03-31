/* ###################   APOGEE COMPILED   ################## */
class implementation GRsubbc;

# include "EMS.h"
# include "msdef.h"
# include "gocmacros.h"
# include "OMmacros.h"
# include "bstypes.h"
#include "bsunwght_p.h"

# define BUFFER_SIZE 100

method GRlnprocess(IGRlong          *EMmsg;
                   IGRshort         *matrix_type;
                   IGRmatrix        matrix;
                   IGRdouble        *acc_tolerance;
                   struct IGRline   *line;
                   IGRpoint         line_pt,
                                    surf_pt;
                   IGRdouble        *t;
                   struct GRparms   *proj_parms)
/*
    Abstract

        This method performs boreline locate for EMS curves.

    History

        17 Jan 1989 AIC Fix for rational curves.
        31 Oct 1988 AIC Halloween
        01 Mar 1989 Modified to add conditional compilation statements
                    for the I/DRAW product.
    Sudha  06/16/93     Modified for BSprototype ansification

*/
{
  IGRboolean            was_located = FALSE;
  IGRboolean            allocated_rational_points = FALSE;
  IGRlong               sts = OM_S_SUCCESS;
  struct IGRbsp_curve   *curve;
  struct IGResbc        esbc;
  struct IGRpolyline    pline;
  IGRdouble             buffer[BUFFER_SIZE * 3];

  pline.points = NULL;

  sts = om$send(msg = message GRvg.GRgetattr(
                    EMmsg,
                    (IGRchar *) &esbc),
                targetid = my_id);
  if(! (1 & sts)) goto wrapup;
#ifndef IDRAW
  if(esbc.is_polydis)
  {
    struct GRlc_info    lc_info;
    struct GRlc_cvl     cvl;

    extern void EFpolylineLocate();

    /*
     * Get the curve's geometry.
     */
    GRgetabsg(EMmsg,
              matrix_type,
              matrix,
              (IGRchar **) &curve,
              0);
    if(! (1 & *EMmsg)) goto wrapup;

    /*
     * Set up the polyline, the lc_info and the cvl.
     */
    if(curve->rational)
    {
      BSrc  rc;

      if(curve->num_poles > BUFFER_SIZE)
      {
        pline.points = (IGRdouble *)
          om$malloc(size = curve->num_poles * sizeof(IGRdouble) * 3);
        if(! pline.points){ *EMmsg = EMS_E_NoDynamicMemory; goto wrapup; }
        allocated_rational_points = TRUE;
      }
      else pline.points = buffer;

      (void) BSunwght_p(&rc,
                        curve->poles,
                        curve->weights,
                        &curve->num_poles,
                        pline.points);
      if(rc) { *EMmsg = EMS_E_Fail; goto wrapup; }
    }
    else pline.points = curve->poles;
    pline.num_points = curve->num_poles;

    lc_info.located_obj.objid = my_id;
    lc_info.located_obj.osnum = OM_Gw_current_OS;
    lc_info.module_info.md_id.objid = NULL_OBJID;
    lc_info.module_info.md_env.matrix_type = *matrix_type;

    OM_BLOCK_MOVE(matrix,
                  lc_info.module_info.md_env.matrix,
                  sizeof(IGRmatrix));

    lc_info.geom_parms.polygon_inx = 3; /* defined in go.h as "not set" */

    OM_BLOCK_MOVE(&lc_info.module_info,
                  &cvl.module,
                  sizeof(struct GRmd_env));

    cvl.attributes.type = GR_bl_loc;
    cvl.attributes.acc_line = *line;
    cvl.attributes.acc_tolerance = *acc_tolerance;

    /*
     * Locate the poles polyline.
     */
    EFpolylineLocate(EMmsg,
                     &pline,
                     &lc_info,
                     &cvl,
                     NULL,
                     NULL,
                     NULL,
                     NULL,
                     &was_located);
    if(! (1 & *EMmsg)) goto wrapup;
  }
#endif
  if(! was_located)
  {
    sts = om$send(msg = message GRsubbc.GRlnprocess(
                    EMmsg,
                    matrix_type,
                    matrix,
                    acc_tolerance,
                    line,
                    line_pt,
                    surf_pt,
                    t,
                    proj_parms),
                  mode = OM_e_wrt_parent,
                  targetid = my_id);
  }

wrapup:
  if(allocated_rational_points) om$dealloc(ptr = pline.points);
  EMWRAPUP(*EMmsg, sts, "GRsubbc.GRlnprocess")
  return sts;
}

end implementation GRsubbc;
