/* ###################   APOGEE COMPILED   ################## */
/*
    gupta : 05/09/88 : Creation
            03/08/90 : check for edge end point dist and if within tol
                       skip trimming
*/

class implementation EMSedge;

#include "EMS.h"
#include "OMmacros.h"
#include "emsdef.h"
#include "emserr.h"
#include "emsdattyp.h"
#include "emsinterdef.h"
#include "emsinter.h"
#include "EMSbnddef.h"
#include "EMSbnd.h"
#include "EMSmsgdef.h"
#include "emsmacros.h"
#include "emssfint.h"
#include "EMSopt.h"

IGRint EMtrim_two_edges (EMmsg, edge1, edge2, at_stop1, at_stop2, bastol)

IGRlong     *EMmsg;
struct GRid *edge1, *edge2;
IGRboolean  at_stop1, at_stop2;
IGRdouble   *bastol;
 
{
  IGRlong               stat_OM, msg;
  IGRint                num_inters, inx;
  IGRdouble             ed1_begpt[2], ed1_endpt[2];
  IGRdouble             ed2_begpt[2], ed2_endpt[2];
  IGRdouble             comp_parm[2];
  struct EMSpartolbasis partol;
  struct EMSsfintedpar  *inters1, *inters2;
  void                  EMsfintedpar_free();

/*--------------------------------------------------------------------*/

  *EMmsg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  stat_OM = om$send(msg = message EMSedge.EMendpts(&msg, ed1_begpt,
                          ed1_endpt, NULL, NULL, NULL),
                    senderid = NULL_OBJID,
                    targetid = edge1->objid);
  EMerr_hndlr (! (1 & stat_OM & msg), *EMmsg, EMS_E_EdgeError, wrapup);

  stat_OM = om$send(msg = message EMSedge.EMendpts(&msg, ed2_begpt,
                          ed2_endpt, NULL, NULL, NULL),
                    senderid = NULL_OBJID,
                    targetid = edge2->objid);
  EMerr_hndlr (! (1 & stat_OM & msg), *EMmsg, EMS_E_EdgeError, wrapup);

  if (at_stop1)
   {
    if (EM2ddistptpt(ed1_endpt, ed2_begpt) <= *bastol)
        return (OM_S_SUCCESS);
    comp_parm[0] = ed1_endpt[0]; comp_parm[1] = ed1_endpt[1];
   }
  else
   {
    if (EM2ddistptpt(ed1_begpt, ed2_endpt) <= *bastol)
        return (OM_S_SUCCESS);
    comp_parm[0] = ed1_begpt[0]; comp_parm[1] = ed1_begpt[1];
   }

  inx = 0;
  num_inters = 0;
  inters1 = NULL;
  inters2 = NULL;

  partol.tol = *bastol;
  partol.is_valid = TRUE;

  stat_OM = om$send (msg = message EMSboundary.EMobint (&msg, &partol,
                           edge2->objid, &partol, NULL,
                           &num_inters, &inters1, &inters2),
                     senderid = NULL_OBJID,
                     targetid = edge1->objid); 
  EMerr_hndlr (! (1 & stat_OM & msg), *EMmsg, EMS_E_EdgeError, wrapup);

  if (num_inters > 0)
   {
    if (num_inters > 1)
     {
      if ((inters1[0].intloc == EMScvint_middle) &&
          (inters1[0].next[0].intloc == EMScvint_middle) &&
          (inters2[0].intloc == EMScvint_middle) &&
          (inters2[0].next[0].intloc == EMScvint_middle))
       {
        if (EM2ddistptpt(comp_parm, inters1[0].next[0].point) <
            EM2ddistptpt(comp_parm, inters1[0].point))
         {
          inx = 1; 
         }
       }
     }

    if ((inters1[0].intloc == EMScvint_middle) ||
        (inters1[0].intloc == EMScvint_overlap))
     {
      stat_OM = om$send (msg = message EMSedge.EMalter_geometry (&msg,
                               (inx) ? &inters1[0].next[0] : &inters1[0],
                               at_stop1),
                         senderid = NULL_OBJID,
                         targetid = edge1->objid); 
      EMerr_hndlr (! (1 & stat_OM & msg), *EMmsg, EMS_E_EdgeError,wrapup);

     }
    if ((inters2[0].intloc == EMScvint_middle) ||
        (inters2[0].intloc == EMScvint_overlap))
     {
      stat_OM = om$send (msg = message EMSedge.EMalter_geometry (&msg,
                               (inx) ? &inters2[0].next[0] : &inters2[0],
                               at_stop2),
                         senderid = NULL_OBJID,
                         targetid = edge2->objid); 
      EMerr_hndlr (! (1 & stat_OM & msg), *EMmsg, EMS_E_EdgeError,wrapup);
     }
   }
  else
    *EMmsg = EMS_I_NoIntersection;
  
wrapup:
  if (inters1)
    EMsfintedpar_free (inters1, NULL);
  if (inters2)
    EMsfintedpar_free (inters2, NULL);

  EMWRAPUP (*EMmsg, stat_OM, "EMtrim_two_edges");
  return (stat_OM);
}

end implementation EMSedge;
