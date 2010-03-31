/* ###################   APOGEE COMPILED   ################## */
class implementation EMSchatch;

#include "EMS.h"
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

#include "emseligible.h"

extern IGRchar  EMScrossHatchPlaneBuffer[CROSS_HATCH_PLANE_BUFFER_SIZE];
extern IGRchar  EMSrltBuffer[RLT_BUFFER_SIZE];

from EMSloop import EMtree_traverse, EMexecuteCurveFunction;

method EMexecuteCurveFunction(IGRlong *EMmsg; struct IGRbsp_surface *surf;
                              IGRshort *mx_type; IGRmatrix mx;
                              GRobjid surf_id; IGRint (*f)();
                              IGRchar *args;
			      IGRushort eligible_edge_type)
/*
History
    02-Oct-92           msm     ANSI-C conversion.
    06 January 1988     AIC     Creation Date
    20-Jan-88		SM	added argument 'eligible_edge_type'.
    13-Sep-89		SM	Pass NULLs for curve types in both directions
				to EFexecuteCurveFunction(). Changed the
				function name to EFexecuteCurveFunc() due
				to argument change.
*/
{
  IGRlong                   sts;
  struct IGResqbs           *rlt;
  struct IGRbsp_surface     *new_surf;
  IGRboolean		    nat_rules_ok = FALSE;

  void EFexecuteCurveFunc();

  /*
   * Initialize
   */
  sts = OM_S_SUCCESS;
  *EMmsg = MSSUCC;
  new_surf = (struct IGRbsp_surface *) EMScrossHatchPlaneBuffer;
  rlt = (struct IGResqbs *) EMSrltBuffer;

  /*
   * Get my rule line table
   */
  sts = om$send(msg = message EMSchatch.EMgetRLT(EMmsg,
                EMSrltBuffer, RLT_BUFFER_SIZE, &rlt), targetid=my_id);
  if(! (1 & *EMmsg & sts)) goto wrapup;

  /*
   * Get the transformed surface
   */
  {
    void EFget_xh_sf_geom();

    IGRint                  total_bytes;

    EMSbs_size(surf->u_order, surf->v_order, surf->u_num_poles,
               surf->v_num_poles, surf->rational, 0, (IGRlong *)NULL,
               total_bytes)

    if(total_bytes > CROSS_HATCH_PLANE_BUFFER_SIZE)
    {
      new_surf = (struct IGRbsp_surface *)om$malloc(size=total_bytes);
      if(! (new_surf)) { *EMmsg = EMS_E_NoDynamicMemory; goto wrapup; }
    }

    EMSbs_partition(surf->u_order, surf->v_order, surf->u_num_poles,
                    surf->v_num_poles, surf->rational, 0,
                    (IGRlong *) NULL, new_surf)

    EFget_xh_sf_geom(EMmsg, me->angle, NULL, NULL, surf, new_surf);
  }


  /*
   * Call the function that traverses the rule line table
   */
  EFexecuteCurveFunc(EMmsg, rlt, new_surf, f, args, nat_rules_ok, 
			 NULL, NULL);
  if(! (1 & *EMmsg)) goto wrapup;

  if(*EMmsg IS EMS_I_Stop) sts = OM_I_STOP_SENDING;
  else
  {
    OM_S_CHANSELECT to_requesters;

    /*
     * Do the edges. Always natural edges also, even though the flag
     * coming in is EMSeligible_NonNatEdge because the natural edges
     * are not included in the RLT for cross hatch objects.
     */

    to_requesters.type = OM_e_addr;
    to_requesters.u_sel.addr = &me^^EMShelper.to_requesters;
    *EMmsg = EMS_I_NoResponse;
    eligible_edge_type &= ~EMSeligible_NonNatEdge;

    sts = om$send(msg = message EMSloop.EMtree_traverse(EMmsg,
          message EMSloop.EMexecuteCurveFunction(EMmsg, surf, mx_type, mx,
                            surf_id, f, args, eligible_edge_type),
          2, 1, &OPP_EMSloop_class_id, TRUE, NULL, NULL, NULL),
          p_chanselect = &to_requesters, from = 1, to = 1);
    if(sts == OM_E_NOSUCHOBJ) sts = OM_S_SUCCESS;
    if(! (1 & *EMmsg & sts)) goto wrapup;
    if(*EMmsg IS EMS_I_Stop) sts = OM_I_STOP_SENDING;

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

      /*
       * Call the function that traverses the rule line table
       */
      nat_rules_ok = TRUE;
      EFexecuteCurveFunc(EMmsg, &nat_edge_rlt, surf, f, args, nat_rules_ok,
			     NULL, NULL);
      if(! (1 & *EMmsg)) goto wrapup;
      if(*EMmsg IS EMS_I_Stop) sts = OM_I_STOP_SENDING;
    }
  }

wrapup:
  if(rlt && (rlt ISNT (struct IGResqbs *) EMSrltBuffer))
    om$dealloc(ptr = rlt);
  if(new_surf && ((IGRchar *)new_surf ISNT EMScrossHatchPlaneBuffer))
    om$dealloc (ptr = new_surf);
  EMSmsgReport(sts, "EMSchatch.EMexecuteCurveFunction", FALSE);
  if EMSmsgReport(*EMmsg, "EMSchatch.EMexecuteCurveFunction", FALSE)
    *EMmsg = EMS_S_Success;
  return(sts);
}

end implementation EMSchatch;
