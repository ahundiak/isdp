/* ###################   APOGEE COMPILED   ################## */
/*
Notes
        This method initializes a loop. The properties bit mask should be
 sent to this method.The range box of the loop is updated.The method also
 checks whether the loop is open or closed and sets that property
 accordingly.If the loop is closed its type is set.

History
        SM      03/09/87        creation date.
        SM      15-Jun-88       Set the P/C property of the loop even if
                                it is inactive.
        SM      08-Aug-88       Support options to supress selective parts
                                of the processing. See file
                                include/emslpinitdef.h for options.
        SS      20-Oct-88       Point outside the paramteric space is better
                                related to the loop's range-box. Also,
                                The point is asymmetrically derived
                                so that ray-casting or minimum-distance from
                                that point has a lesser probability of going
                                through a severe key-point.

*/
class implementation EMSloop;

#include "EMS.h"
#include "EMSopt.h"
#include "EMSbnddef.h"
#include "bs.h"
#include "bsparameters.h"
#include "emsmacros.h"
#include "emsdef.h"
#include "emslpinitdef.h"

/*
 * A value that would give a non-symmetric value between 0 and 1.
 * Used to compute a good point that is outside the range box of
 * this loop. Also a safety factor which applied to the tolerance
 * gives a definitely safe tolerance.
 */

#define NON_SYMMETRIC_VAL 0.63
#define SAFETY_FACTOR 75

from EMSedge import EMgetrange;

method EMlpinit(IGRlong *EMmsg;IGRushort props;
                struct EMSpartolbasis *partolbasis;
                IGRushort options)
{
  IGRlong               sts,rc,i;
  OMuint		count;
  IGRboolean            partol_extracted,EFextract_par();
  OM_S_CHANSELECT       to_edges;
  IGRdouble             range[4],partollen,begin_pt[2],end_pt[2];
  extern OM_S_OBJID     current_creator;


  sts = OM_S_SUCCESS;
  *EMmsg = EMS_S_Success;
  partol_extracted = FALSE;

  ME.EMSboundary->creator_id = current_creator;

  to_edges.type = OM_e_addr;
  to_edges.u_sel.addr = &ME.EMSbd_owner->to_comps;

  if(!(options & EMLpInit_IgnoreInProps))
    ME.EMSloop->lp_props = props;

  if(!(options & EMLpInit_NoRange))
   {
     /* Update my range box
     */
    sts = om$get_channel_count(object = me,p_chanselect = &to_edges,
                                 count = &count);
    if(!(1&sts))goto wrapup;

   /* decide my min max values */

    ME.EMSloop->range[0] = MAXFLOAT;     /* Any big number */
    ME.EMSloop->range[1] = MAXFLOAT;
    ME.EMSloop->range[2] = MINFLOAT;    /* Any small number*/
    ME.EMSloop->range[3] = MINFLOAT;
    for(i=0;i<count;i++)
     {
      sts = om$send(msg = message EMSedge.EMgetrange(EMmsg,range,NULL),
                       p_chanselect = &to_edges,from = i,to = i);
      if( !(1 & *EMmsg & sts)) goto wrapup;
      if(range[0] < ME.EMSloop->range[0]) ME.EMSloop->range[0] = range[0];
      if(range[1] < ME.EMSloop->range[1]) ME.EMSloop->range[1] = range[1];
      if(range[2] > ME.EMSloop->range[2]) ME.EMSloop->range[2] = range[2];
      if(range[3] > ME.EMSloop->range[3]) ME.EMSloop->range[3] = range[3];
     }
   }

  if(!(options & EMLpInit_NoClosureTest))
   {
        
    /* Get the proper tolerance
    */
    if (!partol_extracted)
      {
       if(!partolbasis->is_valid)
        {
         sts = om$send(msg=message EMSboundary.EMgetsurface_info(EMmsg,NULL,
                        partolbasis),
                        targetid=my_id);
         EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_LoopError,wrapup);
        }
       sts = EFextract_par(BSTOLLENVEC,partolbasis->tol,&partollen,&rc);
       partol_extracted = TRUE;
      }

    /* Check whether I am open or closed
    */
    sts = om$send(msg=message EMSloop.EMendpts
                                (EMmsg, begin_pt, end_pt, NULL, NULL),
                        targetid = my_id);
    if(!(1&*EMmsg&sts)) goto wrapup;
    if(EM2ddistptpt(begin_pt,end_pt)<partollen) 
        ME.EMSloop->lp_props &= ~EMLP_OPEN;
    else ME.EMSloop->lp_props |= EMLP_OPEN;
   }

  if( (!(ME.EMSloop->lp_props & EMLP_OPEN)) &&
      (!(options & EMLpInit_NoLoopType)))
  {
    struct EMSptloc_info        location;
    IGRdouble                   pt[2],*lprange,hor_range,ver_range,safetol;

    /* Get the proper tolerance
    */
    if (!partol_extracted)
      {
       if(!partolbasis->is_valid)
        {
         sts = om$send(msg=message EMSboundary.EMgetsurface_info(EMmsg,NULL,
                        partolbasis),
                        targetid=my_id);
         EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_LoopError,wrapup);
        }
       sts = EFextract_par(BSTOLLENVEC,partolbasis->tol,&partollen,&rc);
       partol_extracted = TRUE;
      }

   /* Set my type
   */
    
    lprange = ME.EMSloop->range;
    hor_range = lprange[2] - lprange[0];
    ver_range = lprange[3] - lprange[1];
    safetol = SAFETY_FACTOR * partollen;

    pt[0] = lprange[0] + hor_range + hor_range + safetol;
    pt[1] = lprange[1] + NON_SYMMETRIC_VAL * ver_range + safetol;

    location.options = EMS_PTLOC_NOLOOPTYPE;
    sts = om$send(msg=message EMSloop.EMpt_location
                                (EMmsg,pt,&location,partolbasis),
                        targetid = my_id);
    if(!(1&*EMmsg&sts)) goto wrapup;
    switch(location.location)
     {
       case EMS_L_INSIDE:
         if(ME.EMSloop->lp_props & EMLP_PLOOP)
                ME.EMSloop->lp_props &= ~EMLP_PLOOP;
         else
                ME.EMSloop->lp_props |= EMLP_PLOOP;
       break;

       case EMS_L_OUTSIDE:
         break;

       case EMS_L_ONVRTX: case EMS_L_ONEDGE:
         *EMmsg = EMS_E_InvalidCase;
         goto wrapup;
         break;
     }

  }


wrapup:
  EMWRAPUP(*EMmsg,sts,"In EMSloop.EMlpinit")
  return(sts);
}

end implementation EMSloop;


