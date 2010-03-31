/* ###################   APOGEE COMPILED   ################## */
class implementation GRsubbc;

# include "EMS.h"
# include "msdef.h"
# include "gocmacros.h"
# include "OMmacros.h"

method GRptprocess(IGRlong          *EMmsg;
                   IGRshort         *matrix_type;
                   IGRmatrix        matrix;
                   IGRdouble        *acc_tolerance;
                   IGRpoint         point,
                                    surf_pt;
                   struct GRparms   *proj_parms)
/*
    Abstract

        This method performs point locate for EMS curves.

    History

        31 Oct 1988 AIC Halloween
        02 Mar 1989 Modified to add conditional compilation statements
                    for the I/DRAW product.
*/
{
  IGRboolean        was_located = FALSE;
  IGRlong           sts = OM_S_SUCCESS;
  struct IGResbc    esbc;

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
    struct IGRpolyline  pline;
    struct IGRbsp_curve *curve;

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
    pline.num_points = curve->num_poles;
    pline.points = curve->poles;

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

    cvl.attributes.type = GR_pt_loc;
    cvl.attributes.acc_point[0] = point[0];
    cvl.attributes.acc_point[1] = point[1];
    cvl.attributes.acc_point[2] = point[2];
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
    sts = om$send(msg = message GRsubbc.GRptprocess(
                    EMmsg,
                    matrix_type,
                    matrix,
                    acc_tolerance,
                    point,
                    surf_pt,
                    proj_parms),
                  mode = OM_e_wrt_parent,
                  targetid = my_id);
  }

wrapup:
  EMWRAPUP(*EMmsg, sts, "GRsubbc.GRptprocess")
  return sts;
}

end implementation GRsubbc;
