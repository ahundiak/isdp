/* ###################   APOGEE COMPILED   ################## */
class implementation EMSchatch;

#include "EMS.h"
# ifndef OMmacros_include
# include "OMmacros.h"      /* OM_BLOCK_MOVE                    */
# endif

# ifndef EMSmsgdef_include
# include "EMSmsgdef.h"     /* EMS error codes                  */
# endif

# ifndef EMSfrtdef_include
# include "EMSfrtdef.h"     /* EMGD_UPTODATE, RLT_BUFFER_SIZE  */
# endif

# ifndef EMSlogic_include
# include "EMSlogic.h"      /* EMSmsgReport                     */
# endif

# ifndef EMStypedef_include
# include "EMStypedef.h"    /* EMSmsgReport                     */
# endif

# ifndef EMScmacros_include
# include "EMScmacros.h"    /* EMSmsgReport                     */
# endif

# ifndef emsdef_include
# include "emsdef.h"        /* MAXDOUBLE                        */
# endif

extern IGRchar  EMSrltBuffer[RLT_BUFFER_SIZE];
extern IGRchar  EMScrossHatchPlaneBuffer[CROSS_HATCH_PLANE_BUFFER_SIZE];

from EMSloop import EMtree_traverse;
from EMSedge import EMkeypoint;

method EMkeypoint(IGRlong *EMmsg; struct IGRbsp_surface *surf;
                  IGRshort *matrix_type; IGRmatrix matrix;
                  struct IGRline *boreline; IGRdouble *dist;
                  IGRpoint keypoint; struct GRparms *key_parm;
                  struct GRid *window_id)
/*
History

    03 Oct  1992    msm     ANSI-C conversion.
    28 Apr  1988    AIC     Changed EMFRT_UPTODATE to EMGD_UPTODATE
    15 July 1987    AIC     Creation Date
*/
{
  IGRlong                   sts;
  struct IGResqbs           *rlt = NULL;
  struct IGRbsp_surface     *new_surf;

  extern   void BSsfeval();

  /*
   * Initialize
   */
  sts = OM_S_SUCCESS;
  *EMmsg = EMS_S_Success;
  new_surf = (struct IGRbsp_surface *) EMScrossHatchPlaneBuffer;

  /*
   * Do the rule lines
   */
  if(me->num_u_rules || me->num_v_rules)
  {

    /*
     * Get the transformed surface
     */
    {
      void EFget_xh_sf_geom();

      IGRint                  total_bytes;

      EMSbs_size(surf->u_order, surf->v_order,
                 surf->u_num_poles, surf->v_num_poles,
                 surf->rational, 0, (IGRlong *)NULL, total_bytes)

      if(total_bytes > CROSS_HATCH_PLANE_BUFFER_SIZE)
      {
        new_surf = (struct IGRbsp_surface *)om$malloc(size = total_bytes);
        if(! (new_surf)){*EMmsg = EMS_E_NoDynamicMemory; goto wrapup;}
      }

      EMSbs_partition(surf->u_order, surf->v_order,
                      surf->u_num_poles, surf->v_num_poles,
                      surf->rational, 0, (IGRlong *) NULL,
                      new_surf)

      EFget_xh_sf_geom(EMmsg, me->angle, NULL, NULL, surf, new_surf);
      if(! (1 & *EMmsg)) goto wrapup;
    }

    if(me^^EMShelper.props & EMGD_UPTODATE)
    {

      /*
       * Get my rule line table
       */
      sts = om$send(msg = message EMSgradata.EMgetRLT(EMmsg, EMSrltBuffer,
                    RLT_BUFFER_SIZE, &rlt), targetid = my_id);
      if(! (1 & *EMmsg & sts)) goto wrapup;

      /*
       * Call the keypoint function
       */
      EFrltKeyPt(new_surf, rlt, boreline, keypoint, key_parm, dist, EMmsg);
      if(! (1 & *EMmsg)) goto wrapup;
    }

  }

  /*
   * Do the edges
   */
  {
    OM_S_CHANSELECT to_requesters;

    to_requesters.type = OM_e_addr;
    to_requesters.u_sel.addr = &me^^EMShelper.to_requesters;
    *EMmsg = EMS_I_NoResponse;
    sts = om$send(msg = message EMSloop.EMtree_traverse(EMmsg,
                  message EMSedge.EMkeypoint(EMmsg,surf,boreline,keypoint,
                  key_parm, dist), 2, 1, &OPP_EMSedge_class_id, TRUE,
                  NULL, NULL, NULL), p_chanselect = &to_requesters,from=1,to=1);
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

      EFrltKeyPt(surf, &nat_edge_rlt, boreline, keypoint, key_parm,
                 dist, EMmsg);
    }
  }

wrapup:
  if(new_surf && ((IGRchar *)new_surf ISNT EMScrossHatchPlaneBuffer))
    om$dealloc (ptr = new_surf);
  if(rlt && ((IGRchar *)rlt ISNT EMSrltBuffer)) om$dealloc(ptr = rlt);
  EMSmsgReport(sts, "EMSchatch.EMkeypoint", FALSE);
  if EMSmsgReport(sts, "EMSchatch.EMkeypoint", FALSE) sts = OM_E_ABORT;
  return(sts);
}

end implementation EMSchatch;

