/* ###################   APOGEE COMPILED   ################## */
class implementation EMSedge;

# include "emsdef.h"
# include "igetypedef.h"    /* GRlc...          */
# include "igrtypedef.h"    /* GRlc...          */
# include "ex.h"            /* GRlc...          */
# include "griodef.h"       /* GRlc...          */
# include "grio.h"          /* GRlc...          */
# include "gr.h"            /* GRlc...          */
# include "igrdp.h"         /* GRlc...          */
# include "dp.h"            /* GRlc...          */
# incldeu "godef.h"         /* GRlc...          */
# incldeu "go.h"            /* GRlc...          */
# include "lcdef.h"         /* GRlc...          */
# include "lc.h"            /* GRlc...          */
# include "OMerrordef.h"    /* OM error codes   */
# include "EMSmsgdef.h"     /* EMS error codes  */
# include "EMSlogic.h"      /* EMSmsgReport     */
# include "EMStypedef.h"    /* EMSmsgReport     */
# include "EMScmacros.h"    /* EMSmsgReport     */

extern IGRint   EFrule_lines_on_off();

method EMlocate(IGRlong *EMmsg; struct IGRbsp_surface *surface;
                struct GRmdenv_info *env_info; struct GRid *surface_id;
                struct GRlc_info *loc_parms; struct GRlc_cvl *cvl;
                IGRlong *prism_rel; IGRboolean *inside, *outside,
                *overlap, locate_natural_edges, *was_located)
{
  IGRlong               sts;
  struct IGRbsp_curve   edge_geometry;

  /*
   * Initialize
   */
  sts = OM_S_SUCCESS;
  *EMmsg = EMS_S_Success;
  edge_geometry.poles = NULL;
  edge_geometry.weights = NULL;
  edge_geometry.knots = NULL;
  edge_geometry.num_boundaries = 0;
  edge_geometry.bdrys = NULL;

  if(! locate_natural_edges && (me->ed_props & EMED_NATURAL)) goto wrapup;

  if(me->ed_props & EMED_NO_DISPLAY) goto wrapup;

  if((me->ed_props & EMED_SEAM) && (me->ed_props & EMED_TANGENT))
    if(! EFrule_lines_on_off(cvl->button.objid, cvl->button.osnum))
      goto wrapup;

  /* block */
  {
    IGRshort              relation;
    IGRdouble             intersection_param;

    void EFisoCurveLocate(), EFinterpretRelation();

    sts = om$send(msg = message EMSedge.EMget_bcxyz_geom(EMmsg, env_info,
                  surface_id, surface, 0, MAXINT, FALSE, NULL,
                  &edge_geometry), targetid = my_id);
    if(! (1 & *EMmsg & sts)) goto wrapup;

    EFisoCurveLocate(EMmsg, &edge_geometry, cvl, loc_parms, TRUE,
                     &intersection_param, &relation);

    EFinterpretRelation(EMmsg, relation, cvl->attributes.type, 0, NULL,
                        intersection_param, prism_rel, inside, outside,
                        overlap, was_located);

    if(*was_located) sts = OM_I_STOP_SENDING;
  }

wrapup:
  if(edge_geometry.poles) om$dealloc(ptr = edge_geometry.poles);
  if(edge_geometry.weights) om$dealloc(ptr = edge_geometry.weights);
  if(edge_geometry.knots) om$dealloc(ptr = edge_geometry.knots);
  EMSmsgReport(sts, "EMSedge.EMlocate", FALSE);
  if EMSmsgReport(*EMmsg, "EMSedge.EMlocate", FALSE) sts = OM_E_ABORT;
  return(sts);
}

end implementation EMSedge;
