/* ###################   APOGEE COMPILED   ################## */
class implementation EMSchatch;

# include "EMS.h"
# ifndef msdef_include
# include "msdef.h"             /* MS error codes   */
# endif

# ifndef EMSmsgdef_include
# include "EMSmsgdef.h"         /* EMS error codes  */
# endif

# ifndef EMSfrtdef_include
# include "EMSfrtdef.h"         /* RLT_BUFFER_SIZE  */
# endif

# ifndef EMSlogic_include
# include "EMSlogic.h"          /* EMSmsgReport     */
# endif

# ifndef EMStypedef_include
# include "EMStypedef.h"        /* EMSmsgReport     */
# endif

# ifndef EMScmacros_include
# include "EMScmacros.h"        /* EMSmsgReport     */
# endif

extern IGRchar  EMSrltBuffer[RLT_BUFFER_SIZE];
extern IGRchar  EMScrossHatchPlaneBuffer[CROSS_HATCH_PLANE_BUFFER_SIZE];

from EMSloop import EMtree_traverse;
from EMSedge import EMlocate;

method EMlocate(IGRlong *EMmsg; struct IGRbsp_surface *surface;
                struct GRlc_info *loc_parms; struct GRlc_cvl *cvl;
                IGRlong *prism_rel; IGRboolean *inside, *outside,
                *overlap, *was_located; struct GRid *window_id)
/*
History

    03 Oct  1992    msm     ANSI-C conversion.
    15 July 1987    AIC     Creation Date
*/
{
  IGRlong                   sts;
  struct IGResqbs           *rlt;
  struct IGRbsp_surface     *new_surface;

  void EFlocateRLT();

  /*
   * Initialize
   */
  sts = OM_S_SUCCESS;
  *EMmsg = MSSUCC;
  new_surface = (struct IGRbsp_surface *) EMScrossHatchPlaneBuffer;
  rlt = (struct IGResqbs *) EMSrltBuffer;

  /*
   * Get my rule line table
   */
  sts = om$send(msg = message EMSgradata.EMgetRLT(EMmsg,
                EMSrltBuffer, RLT_BUFFER_SIZE, &rlt), targetid=my_id);
  if(! (1 & *EMmsg & sts)) goto wrapup;

  /*
   * Get the transformed surface
   */
  {
    void EFget_xh_sf_geom();

    IGRint                  total_bytes;

    EMSbs_size(surface->u_order, surface->v_order,
               surface->u_num_poles, surface->v_num_poles,
               surface->rational, 0, (IGRlong *)NULL, total_bytes)

    if(total_bytes > CROSS_HATCH_PLANE_BUFFER_SIZE)
    {
      new_surface = (struct IGRbsp_surface *)om$malloc(size=total_bytes);
      if(! (new_surface)) { *EMmsg = EMS_E_NoDynamicMemory; goto wrapup; }
    }

    EMSbs_partition(surface->u_order, surface->v_order,
                    surface->u_num_poles, surface->v_num_poles,
                    surface->rational, 0, (IGRlong *) NULL,
                    new_surface)

    EFget_xh_sf_geom(EMmsg, me->angle, NULL, NULL, surface, new_surface);
  }

  /*
   * Call the function that determines if a locate took place
   */
  EFlocateRLT(EMmsg, rlt, new_surface, loc_parms, cvl, prism_rel,
              inside, outside, overlap, was_located);
  if(! (1 & *EMmsg)) goto wrapup;

# define OLD_LOCATE_PATH    0

# if OLD_LOCATE_PATH
  /*
   * If the locate failed based on the rule lines, try the edges
   */
  if(! *was_located)
  {
    OM_S_CHANSELECT to_requesters;

    to_requesters.type = OM_e_addr;
    to_requesters.u_sel.addr = &me^^EMShelper.to_requesters;
    *EMmsg = EMS_I_NoResponse;
    sts = om$send(msg = message
                  EMSloop.EMtree_traverse(EMmsg,message EMSedge.EMlocate
                  (EMmsg, surface, NULL, NULL, loc_parms, cvl, prism_rel,
                  inside, outside, overlap, TRUE, was_located),
                  2, 1, &OPP_EMSedge_class_id, TRUE, NULL, NULL, NULL),
                  p_chanselect = &to_requesters, from = 1, to = 1);
    if (sts == OM_E_NOSUCHOBJ) sts = OM_S_SUCCESS;
    if(! (1 & *EMmsg & sts)) goto wrapup;

    if(*EMmsg IS EMS_I_NoResponse)
    {
      struct IGResqbs   nat_edge_rlt;
      IGRint            num_bound[2];
      IGRdouble         rule_values[2];

      /*
       * Set up a rule line table to locate natural edges
       */
      num_bound[0] = num_bound[1] = 0;
      rule_values[0] = 0;
      rule_values[1] = 1;
      nat_edge_rlt.u_rules = 2;
      nat_edge_rlt.v_rules = 2;
      nat_edge_rlt.is_polydis = FALSE;
      nat_edge_rlt.is_surfdis = TRUE;
      nat_edge_rlt.is_slowdis = FALSE;
      nat_edge_rlt.type = NULL;
      nat_edge_rlt.rules_specified = TRUE;
      nat_edge_rlt.u_rule_values = rule_values;
      nat_edge_rlt.v_rule_values = rule_values;
      nat_edge_rlt.u_num_bound = num_bound;
      nat_edge_rlt.v_num_bound = num_bound;
      nat_edge_rlt.u_bdrys = NULL;
      nat_edge_rlt.v_bdrys = NULL;

      EFlocateRLT(EMmsg,&nat_edge_rlt,surface,loc_parms,cvl,prism_rel,
                  inside, outside, overlap, was_located);
      if(! (1 & *EMmsg)) goto wrapup;
    }
  }
# endif

  if(*was_located) sts = OM_I_STOP_SENDING;

wrapup:
  if(rlt && (rlt ISNT (struct IGResqbs *) EMSrltBuffer))
    om$dealloc(ptr = rlt);
  if(new_surface && ((IGRchar *)new_surface ISNT EMScrossHatchPlaneBuffer))
    om$dealloc (ptr = new_surface);
  EMSmsgReport(sts, "EMSchatch.EMlocate", FALSE);
  if EMSmsgReport(*EMmsg, "EMSchatch.EMlocate", FALSE) sts = OM_E_ABORT;
  return(OM_S_SUCCESS);
}

end implementation EMSchatch;
