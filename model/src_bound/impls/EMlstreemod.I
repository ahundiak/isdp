/* ###################   APOGEE COMPILED   ################## */
/* 
Notes
      This method is intended to be a generic method for any modifications
   to be made to an existing loopset (looptree). It gets the loop id to
   be operated upon and the type of operation to be done.
        The method operates only on the loops under the loopset. The only
   operation which can be done by the loopset is ADD_CHILD.
        The operations like CHG_PARENT,EXTRACT,DELETE are done directly
   on the loop involved.

History
        SM      03/09/87        Creation date.
        AIC     15-Jul-87       Update FRT objects.
	AIC	24 September 87	Use EMSsubbs.EMmake_frt to allow surface
				control of FRT objects.
	SM	11-Dec-87	send EMSsubbs.EMmake_frt when a feature 
				loop is added, regardless of whether it 
				is a P or a C loop.
	SM	20-Jul-88	If a non natural loop is added under the
				loopset set the EMSIS_RANGE_MODIFIED bit
				on the surface.
*/
class implementation EMSloopset;

#include "EMS.h"
#include "OMmacros.h"
#include "EMSopt.h"
#include "emsmacros.h"
#include "EMSssprops.h"

from EMSsubbs import EMgetGRobjid, EMmake_frt, EMset_props;
from EMSloop import EMgivenestinfo, EMtreemod, EMnesting, EMset_props;
from EMSloop import EMget_props;


method EMtreemod(IGRlong *EMmsg;struct EMSnest_info *nesting; 
                   IGRint operation;struct EMSpartolbasis *partolbasis)
{

    IGRlong              sts;
    IGRint               count;
    IGRint               i,depth,buf_size;
    struct EMSnest_info  temp_nesting;
    OM_S_CHANSELECT      to_loops,to_outter,to_surf;
    GRobjid              *loopids;
    IGRushort    *props;
    IGRboolean		 featurelp;

   *EMmsg = EMS_S_Success;
   sts = OM_S_SUCCESS;
   loopids = NULL;
   props = NULL;

   to_surf.type = OM_e_addr;
   to_surf.u_sel.addr = &ME.EMSloopset->to_surface;

   to_loops.type = OM_e_addr;
   to_loops.u_sel.addr = &ME.EMSloopset->to_loops;

   sts = EMmake_chanselect (EMSloop_to_outter, &to_outter);
   EMerr_hndlr(!(1&sts),*EMmsg,EMS_E_OMerror,wrapup);

   featurelp = nesting->lp_props & EMLP_NOAREA_NOHOLE;

    switch (operation)
     {
       case ADD_CHILD:
/*
 Get all the UNSPLIT loops one level under me. If the incoming loop
 encloses any of them, then send a CHG_PARENT message to it. 
        When getting the unsplit loops, the split loops will be
 ignored for deciding the level.
        If the loop is open, it cannot enclose anybody nor can it be
 nested inside anybody. Same is true with a feature loop.
*/

     if(!(nesting->lp_props & EMLP_OPEN) && !featurelp)
      {
          depth = 1;
          buf_size = 0;
          count = 0;
          sts = om$send(msg=message EMSloopset.EMget_loops
                        (EMmsg,EMS_OPT_UNSPLIT,&depth,&loopids,&props,
                         &buf_size,&count),targetid = my_id);
         for(i=0;i<count;i++)
          {
            if(!(props[i] & EMLP_OPEN))
             {
               sts = om$send(msg = message EMSloop.EMgivenestinfo
                             (EMmsg,&temp_nesting),targetid=loopids[i]);
               EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_LoopError,wrapup);
               sts = om$send(msg = message EMSloop.EMnesting
                                (EMmsg,&temp_nesting,partolbasis),
                                targetid = nesting->loopid);
               EMerr_hndlr(!(1& *EMmsg & sts),*EMmsg,EMS_E_LoopError,wrapup);
               if(IF_EQ_OBJID(temp_nesting.parent,nesting->loopid))
               {
                temp_nesting = *nesting;
                temp_nesting.parent = nesting->loopid;
                sts = om$send(msg = message EMSloop.EMtreemod
                                (EMmsg,&temp_nesting,CHG_PARENT,partolbasis),
                                targetid = loopids[i]);
                 EMerr_hndlr(!(1&*EMmsg & sts),*EMmsg,EMS_E_LoopError,wrapup);
               }
             }
          } 
      }

         sts = om$send(msg=message Root.connect(to_loops,NULL,
                       nesting->loopid,OM_Gw_current_OS,to_outter,NULL),
                       targetid=my_id);
         EMerr_hndlr(!(1&sts),*EMmsg,EMS_E_OMerror,wrapup);

/* Set the 'EXTERNAL' and ACTIVE bit in the newly added child */
          sts = om$send(msg=message EMSloop.EMset_props
                       (EMmsg, EMLP_EXTERNAL, EMS_O_ON),
                       targetid=nesting->loopid);
          if(! (1 & *EMmsg & sts)) goto wrapup;

	  if(!(nesting->lp_props & EMLP_NATURAL))
	   {
	    sts = om$send(msg = message EMSsubbs.EMset_props
			(EMmsg, EMSIS_RANGE_MODIFIED, EMS_O_ON),
			p_chanselect = &to_surf);
            if(! (1 & *EMmsg & sts)) goto wrapup;
	   }


        /*
         * Make an FRT for the new loop.
         */
        {
          IGRushort     loop_props;
	  IGRboolean		open = FALSE, 
				ploop = FALSE;
	
          sts = om$send(msg = message EMSloop.EMget_props(EMmsg,
                        &loop_props), targetid = nesting->loopid);
          if(! (1 & *EMmsg & sts)) goto wrapup;

	  open = loop_props & EMLP_OPEN;
	  ploop = loop_props & EMLP_PLOOP;
	  
          if(( ploop && (!open)) || featurelp)
	   {
            sts = om$send(msg = message EMSsubbs.EMmake_frt(EMmsg,
                          nesting->loopid), p_chanselect = &to_surf);
            if(! (1 & *EMmsg & sts)) goto wrapup;
	   }

        }

/* If a non natural loop was added then the loopset is no longer
   natural. Feature loop is ignored for this natural property of the
   loopset.
*/
          if(!(nesting->lp_props & EMLP_NATURAL) && !featurelp)
             ME.EMSloopset->ls_props &= ~EMLS_NATURAL;

         break;


       default:
         *EMmsg = EMS_E_InvalidArg;
         break;
     }


wrapup:
          if(loopids) om$dealloc(ptr=loopids);
          if(props) om$dealloc(ptr=props);
          EMWRAPUP(*EMmsg,sts,"In EMSloopset.EMtreemod")
          return(sts);
}

end implementation EMSloopset;
