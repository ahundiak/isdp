/* ###################   APOGEE COMPILED   ################## */
class implementation EMSgradata;

# include "msdef.h"             /* MS error codes   */
# include "EMSmsgdef.h"         /* EMS error codes  */
# include "EMSfrtdef.h"         /* RLT_BUFFER_SIZE  */
# include "EMSlogic.h"          /* EMSmsgReport     */
# include "EMStypedef.h"        /* EMSmsgReport     */
# include "EMScmacros.h"        /* EMSmsgReport     */

extern IGRchar  EMSrltBuffer[RLT_BUFFER_SIZE];

from EMSloop import EMtree_traverse;
from EMSedge import EMlocate;

method EMlocate(IGRlong *EMmsg; struct IGRbsp_surface *surface;
                struct GRlc_info *loc_parms; struct GRlc_cvl *cvl;
                IGRlong *prism_rel; IGRboolean *inside, *outside,
                *overlap, *was_located; struct GRid *window_id)
/*
History

    15 July 1987    AIC     Creation Date
    05-June-91     Jack     Exit with success if rule line display is 
                            off.  2.0.1 Horizon Loops.
    06/26/91        DLB     Yeah, but first you better set rlt=NULL pal.
    20-July-91      AIC     Make rule lines on/off window-specific.
*/
{
  IGRlong           sts,
                    msg = MSSUCC;
  struct IGResqbs   *rlt=NULL;

  void              EFlocateRLT();
  IGRint            EFrule_lines_on_off();

  /*
   * Initialize
   */
  sts = OM_S_SUCCESS;
  *EMmsg = EMS_S_Success;


  if(EFrule_lines_on_off(cvl->button.objid, cvl->button.osnum))
  { /* only want to come in here if rule line display is on */

    rlt = (struct IGResqbs *) EMSrltBuffer;

    /*
     * Get my rule line table
     */
    sts = om$send(msg = message EMSgradata.EMgetRLT(&msg,
                  EMSrltBuffer, RLT_BUFFER_SIZE, &rlt), targetid=my_id);
    if(! (1 & msg & sts)) goto wrapup;

    /*
     * Call the function that determines if a locate took place
     */
    EFlocateRLT(&msg, rlt, surface, loc_parms, cvl, prism_rel,
                inside, outside, overlap, was_located);
    if(! (1 & msg)) goto wrapup;

    if(*was_located) sts = OM_I_STOP_SENDING;

  } /* end if( EFrule_lines_on_off ) */

wrapup:
  if(rlt ISNT (struct IGResqbs *) EMSrltBuffer)
    om$dealloc(ptr = rlt);
  EMSmsgReport(sts, "EMSgradata.EMlocate", FALSE);
  if EMSmsgReport(msg, "EMSgradata.EMlocate", FALSE) msg = EMS_S_Success;
  return(OM_S_SUCCESS);
}

end implementation EMSgradata;
