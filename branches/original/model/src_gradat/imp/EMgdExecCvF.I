/* ###################   APOGEE COMPILED   ################## */
class implementation EMSgradata;

# include "msdef.h"             /* MS error codes   */
# include "EMSmsgdef.h"         /* EMS error codes  */
# include "EMSfrtdef.h"         /* RLT_BUFFER_SIZE  */
# include "EMSlogic.h"          /* EMSmsgReport     */
# include "EMStypedef.h"        /* EMSmsgReport     */
# include "EMScmacros.h"        /* EMSmsgReport     */
# include "emseligible.h"
# include "OMmacros.h"
# include "emsdef.h"            /* Channel definitions for EMmake_chanselect */

extern IGRchar  EMSrltBuffer[RLT_BUFFER_SIZE];

from EMSloop import EMtree_traverse, EMexecuteCurveFunction;
from EMSsubbs import EMget_natedge_info;

method EMexecuteCurveFunction(IGRlong *EMmsg; struct IGRbsp_surface *surf;
                              IGRshort *mx_type; IGRmatrix mx;
                              GRobjid surf_id; IGRint (*f)();
                              IGRchar *args;
                              IGRushort eligible_edge_type)
/*
History

    06 January 1988     AIC     Creation Date
    20-Jan-88           SM      added argument 'eligible_edge_type'.
    13-Sep-89           SM      Get curve types from the surface and
                                pass them to EFexecuteCurveFunction().
                                Changed function name to EFexecuteCurveFunc().
    05-June-91          Jack    If rule line display is off, just return
                                success. 2.0.1 Horizon Loops.
    26-June-91          Jack    Initialized the rlt ptr to NULL.
    20-July-91          AIC     Make rule lines on/off window-specific.
*/
{
  IGRlong               sts;
  GRobjid               window_id;
  GRspacenum            window_os;
  struct IGResqbs       *rlt = NULL;
  IGRboolean            nat_rules_ok = FALSE;
  IGRuchar      cvtype[4], *utype_ptr = NULL, *vtype_ptr = NULL;
  IGRushort     edprops[4];
  struct GRmdenv_info   env;

  void                  EFexecuteCurveFunc();
  void                  EMSsubbs_get_locate_window();
  IGRint                EFrule_lines_on_off();

  /*
   * Initialize
   */
  sts = OM_S_SUCCESS;
  *EMmsg = MSSUCC;

  /* replace this with Mike's KLUGE */
  EMSsubbs_get_locate_window(&window_id, &window_os);
  if( EFrule_lines_on_off(window_id, window_os) &&
      (! (eligible_edge_type & EMSeligible_NoGradata)))
  {  /* only want to come in here if rule line display is on */

    rlt = (struct IGResqbs *) EMSrltBuffer;
    env.matrix_type = *mx_type;
    OM_BLOCK_MOVE(mx, env.matrix, sizeof(IGRmatrix));

    /*
     * Get my rule line table
     */
    sts = om$send(msg = message EMSgradata.EMgetRLT(EMmsg, EMSrltBuffer,
                    RLT_BUFFER_SIZE, &rlt), targetid=my_id);
    if(! (1 & *EMmsg & sts)) goto wrapup;

    /* Get the curve types in U (same as for natural edges v=0 v=1) and V (same
       as for natural edges u=0 u=1) direction.
    */
    if(IF_NULL_OBJID(surf_id))
    {
      OMuword           junk;
      OM_S_CHANSELECT   to_requesters;

      EMmake_chanselect(EMShelper_to_requesters, &to_requesters);

      sts = om$get_objid_at_index(object = me, p_chanselect = &to_requesters, 
                                  index = 0, objidaddr = &surf_id, 
                                  osnumaddr = &junk);
    }

    if(!IF_NULL_OBJID(surf_id))
    {
      sts = om$send(msg = message EMSsubbs.EMget_natedge_info(EMmsg, &env, 
                          cvtype, edprops), targetid = surf_id);
      if(1&*EMmsg&sts)
      {
        utype_ptr = &cvtype[0];
        vtype_ptr = &cvtype[1];
      }
    }

    /*
     * Call the function that traverses the rule line table
     */
    EFexecuteCurveFunc(EMmsg, rlt, surf, f, args, nat_rules_ok, utype_ptr, 
                       vtype_ptr);
    if(! (1 & *EMmsg)) goto wrapup;

  } /* end if( EFrule_lines_on_off ) */


wrapup:
  if(rlt ISNT (struct IGResqbs *) EMSrltBuffer)
    om$dealloc(ptr = rlt);
  EMSmsgReport(sts, "EMSgradata.EMexecuteCurveFunction", FALSE);
  if EMSmsgReport(*EMmsg, "EMSgradata.EMexecuteCurveFunction", FALSE)
    *EMmsg = EMS_S_Success;
  return(sts);
}

end implementation EMSgradata;
