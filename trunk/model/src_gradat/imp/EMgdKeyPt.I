/* ###################   APOGEE COMPILED   ################## */
class implementation EMSgradata;

# include "OMmacros.h"      /* OM_BLOCK_MOVE                    */
# include "EMSmsgdef.h"     /* EMS error codes                  */
# include "EMSfrtdef.h"     /* EMGD_UPTODATE, RLT_BUFFER_SIZE  */
# include "EMSlogic.h"      /* EMSmsgReport                     */
# include "EMStypedef.h"    /* EMSmsgReport                     */
# include "EMScmacros.h"    /* EMSmsgReport                     */
# include "emsdef.h"        /* MAXDOUBLE                        */

from EMSloop import EMtree_traverse;
from EMSedge import EMkeypoint;

extern IGRchar  EMSrltBuffer[RLT_BUFFER_SIZE];

method EMkeypoint(IGRlong *EMmsg; struct IGRbsp_surface *surf;
                  IGRshort *matrix_type; IGRmatrix matrix;
                  struct IGRline *boreline; IGRdouble *dist;
                  IGRpoint keypoint; struct GRparms *key_parm;
                  struct GRid *window_id)
/*
History

    03 Oct 1992     msm     ANSI C conversion.
    20-July-91      AIC     Make rule lines on/off window-specific.
    05-June-91     Jack     Exit with success if rule line display is
                            off.  2.0.1 Horizon Loops. 
    28 Apr 1988     AIC     Change EMFRT_UPTODATE to EMGD_UPTODATE.
    15 July 1987    AIC     Creation Date
*/
{
  IGRlong           sts;
  struct IGResqbs   *rlt = NULL;

  extern void       BSsfeval();
  IGRint            EFrule_lines_on_off();
 

  /*
   * Initialize
   */
  sts = OM_S_SUCCESS;
  *EMmsg = EMS_S_Success;

  if( EFrule_lines_on_off(window_id->objid, window_id->osnum) )
  {  /* only want to come in here if rule line display is on */

    if(me^^EMShelper.props & EMGD_UPTODATE)
    {

      /*
       * Do the rule lines
       */
      if(me^^EMSgradata.num_u_rules || me^^EMSgradata.num_v_rules)
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
        EFrltKeyPt(surf, rlt, boreline, keypoint, key_parm, dist, EMmsg);
      }
    }

    /*
     * Do the edges
     */
    {
      OM_S_CHANSELECT to_requesters;

      EMmake_chanselect(EMShelper_to_requesters, &to_requesters);
      sts = om$send(msg = message EMSloop.EMtree_traverse(EMmsg,
                      message EMSedge.EMkeypoint(EMmsg,surf,boreline,keypoint,
                        key_parm, dist),
                      2, 1, &OPP_EMSedge_class_id, TRUE, NULL, NULL, NULL),
                    p_chanselect = &to_requesters,from=1,to=1);
    }

  } /* end if( EFrule_lines_on_off ) */

wrapup:
  if(rlt && (rlt ISNT (struct IGResqbs *)EMSrltBuffer)) om$dealloc(ptr = rlt);
  EMSmsgReport(sts, "EMSgradata.EMkeypoint", FALSE);
  if EMSmsgReport(sts, "EMSgradata.EMkeypoint", FALSE) sts = OM_E_ABORT;
  return(sts);
}

end implementation EMSgradata;
