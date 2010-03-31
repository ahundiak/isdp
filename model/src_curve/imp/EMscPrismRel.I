/* ###################   APOGEE COMPILED   ################## */
class implementation GRsubbc;

# include "EMS.h"
# include "grerr.h"
# include "msdef.h"
# include "gocmacros.h"
# include "OMmacros.h"
# include "EMSlcdef.h"  /* relation codes   */
# include "bstypes.h"
#include "bsunwght_p.h"

# define BUFFER_SIZE 100

method GRprismrel(IGRlong          *EMmsg;
                  IGRshort         *matrix_type;
                  IGRmatrix        matrix;
                  IGRlong          *prism_rel;
                  IGRshort         *type_prism;
                  IGRchar          *prism;
                  IGRlong          *relationship)
/*
    Abstract

        This method evaluates prism relationships for EMS curves.

    History

        13 Mar 1989 RC  Return relative relative relationship, if asked
                        for.
        02 Mar 1989 Modified to add conditional compilation statements
                    for the I/DRAW product.
        17 Jan 1989 AIC Fix for rational curves
        31 Oct 1988 AIC Halloween
    Sudha  06/16/93     Modified for BSprototype ansification

*/
{
  IGRboolean            inside, outside, overlap, was_located;
  IGRboolean            allocated_rational_points = FALSE;
  IGRlong               sts = OM_S_SUCCESS;
  struct IGRbsp_curve   *curve;
  struct IGResbc        esbc;
  struct IGRpolyline    pline;
  IGRdouble             buffer[BUFFER_SIZE * 3];
  extern IGRlong        GRcheckrel();

  pline.points = NULL;

  inside =      /* FALSE */
  outside =     /* FALSE */
  overlap =     /* FALSE */
  was_located =    FALSE;

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

# define RIGHT_PRISM 0

    if(*type_prism IS RIGHT_PRISM)
    {
      cvl.attributes.type = GR_rp_loc;
      OM_BLOCK_MOVE(prism,
                    &cvl.attributes.acc_rt_prism,
                    sizeof(struct IGRrt_prism));
    }
    else
    {
      cvl.attributes.type = GR_cv_loc;
      OM_BLOCK_MOVE(prism,
                    &cvl.attributes.acc_cv_prism,
                    sizeof(struct IGRcv_prism));
    }
/*    cvl.attributes.acc_tolerance = *acc_tolerance; */

    /*
     * Locate the poles polyline.
     */
    EFpolylineLocate(EMmsg,
                     &pline,
                     &lc_info,
                     &cvl,
                     prism_rel,
                     &inside,
                     &outside,
                     &overlap,
                     &was_located);
    if(! (1 & *EMmsg)) goto wrapup;

  }
#endif
  if(! was_located)
  {
    sts = om$send(msg = message GRsubbc.GRprismrel(
                      EMmsg,
                      matrix_type,
                      matrix,
                      prism_rel,
                      type_prism,
                      prism,
                      relationship),
                  mode = OM_e_wrt_parent,
                  targetid = my_id);

  } /* if(! was_located) */
  else
  {
    /*
     * Convert the true relationship into relative relationship,
     * if asked for.
     */

    *relationship = overlap ? OVERLAP : (inside ? INSIDE : OUTSIDE);
    sts = GRcheckrel (EMmsg, prism_rel, relationship);

  }
/*  
    if(*EMmsg IS GR_E_INV_REQUEST){ *EMmsg = MSSUCC; sts = OM_S_SUCCESS; }
    if(! (1 & sts)) goto wrapup;

    switch(*relationship)
    {
      case INSIDE:
        if(outside) overlap = TRUE;
        inside = TRUE;
        break;

      case OUTSIDE:
        if(inside) overlap = TRUE;
        outside = TRUE;
        break;

      case OVERLAP:
        inside = outside = overlap = TRUE;
        break;
    }
  }

  *relationship = inside ?
                (outside ? OVERLAP : INSIDE) :
                (outside ? OUTSIDE : BAD_RELATION);
  if(*relationship IS BAD_RELATION) *EMmsg = EMS_E_Fail;
*/

wrapup:
  if(allocated_rational_points) om$dealloc(ptr = pline.points);
/*
  EMWRAPUP(*EMmsg, sts, "GRsubbc.GRprismrel")
*/
  return sts;
}

end implementation GRsubbc;
