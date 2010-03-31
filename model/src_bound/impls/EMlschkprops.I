/* ###################   APOGEE COMPILED   ################## */
/*
Notes
	This method checks the caller specified properties of the loopset, 
 loops and edges and makes them valid at the time this message is sent to
 the loopset. The properties of the loopset/loops/edges which need to be
 checked and set should be specified as combinations of bit masks in the
 3 input arguments. If for en element no property is to be checked then the
 corresponding address should still be valid and should point to value
 NULL.
	If a property is not specified in the check list it may be assumed
 to be valid and used in the checking of one of the properties specified
 on input list. If the caller is not sure of any related property then it
 would safer to specify it on the check list. For e.g in determining if
 the loopset is natural or not, the natural property of the loop is made
 use of. If the caller is not certain of validity of this property in
 the loops then it should be specified on the check list for loops.
	The input check list has bit combinations on input. These bit
 combinations WILL get ALTERED upon exit.

Bugs
	Only the properties needed at this time are taken care of.The method
	can be expanded in future to care of various other properties.
  Following checks will be handled as of now -
  1) ls_props - EMLS_NATURAL, EMLS_NONMODIFIABLE.
  2) lp_props - EMLP_NATURAL, EMLP_EXTERNAL.


History
	SM	06/01/87	Creation date.
	SM	09/18/87	Added code to check/set EMLS_NONMODIFIABLE.
*/

class implementation EMSloopset;

#include "EMS.h"
#include "EMSopt.h"

from EMSloop import EMset_props, EMget_props;
from EMSedge import EMget_props;

method EMcheck_props(IGRlong *EMmsg; IGRushort *ls_props, *lp_props, 
		     *ed_props)
{
  IGRlong		sts;
  OM_S_CHANSELECT	to_loops;
  IGRint		count, i, depth = 1, buf_size = 0;

  *EMmsg = EMS_S_Success;
  sts = OM_S_SUCCESS;

  to_loops.type = OM_e_addr;
  to_loops.u_sel.addr = &ME.EMSloopset->to_loops;

  if( ((*ls_props) & EMLS_NATURAL) ||
      ((*ls_props) & EMLS_NONMODIFIABLE) ||
      ((*lp_props) & EMLP_NATURAL))
   {
     sts = om$send(msg = message EMSloopset.EMget_loops(EMmsg, EMS_OPT_ALL, 
				&depth, NULL, NULL, &buf_size, &count), 
			targetid = my_id);
     EMerr_hndlr(!(1&*EMmsg&sts), *EMmsg, EMS_E_LoopsetError, wrapup);
   }

  if((*ls_props) & EMLS_NATURAL)
   {
/* Check and see if I am natural. A loopset is natural if it has only a
   natural loop. If the number of loops under the loopset is not 1 then
   it is definately not natural. If the number of loops is 1 then send
   the option down to that loop. If that loop is natural it will set the
   property of the loopset (after checking its children).
*/
     if(count == 1)
      {
	GRobjid	loopid, *junkptr;
	IGRint	buf_size = 1, count = 0, depth = 1;
	
	junkptr = &loopid;
        sts = om$send(msg = message EMSloopset.EMget_loops
			(EMmsg, EMS_OPT_ALL, &depth, &junkptr, NULL, &buf_size,
			 &count), targetid = my_id);
        EMerr_hndlr(!(1&*EMmsg&sts), *EMmsg, EMS_E_LoopError, wrapup);

	sts = om$send(msg = message EMSloop.EMcheck_props
			(EMmsg, ls_props, lp_props, ed_props), 
			targetid = loopid);
	if(sts == OM_I_STOP_SENDING) sts = OM_S_SUCCESS;
	EMerr_hndlr(!(1&*EMmsg&sts), *EMmsg, EMS_E_LoopError, wrapup);
      }
     else ME.EMSloopset->ls_props &= ~EMLS_NATURAL;
     (*ls_props) &= ~EMLS_NATURAL;
   }

/* If the caller needs to check the natural property of the loop then
   send that check down to each loop. Every loop under the loopset will make
   that check and set the option bit off. So set it on again before sending
   it to the next loop. This scheme assumes that a natural loop if any will
   always be connected directly to the loopset. However it does not assume
   that if there is a natural loop it will be the only loop under the
   loopset.
*/
  if((*lp_props) & EMLP_NATURAL)
   {
	IGRushort	loc_props;

     loc_props = *lp_props;
     for(i=0;i<count;i++)     
      {
         sts = om$send(msg = message EMSloop.EMcheck_props
			(EMmsg, ls_props, &loc_props, ed_props), 
			p_chanselect = &to_loops);
         EMerr_hndlr(!(1&*EMmsg&sts), *EMmsg, EMS_E_LoopError, wrapup);
	 loc_props |= EMLP_NATURAL;
      }
     (*lp_props) &= ~EMLP_NATURAL;
   }
/* If the caller needs the external property for the loop to be set then
   set the property of the loops directly under the loopset. Turn that option
   bit OFF so that if the message goes down, same check will not be made
   again.
*/

  if((*lp_props) & EMLP_EXTERNAL)
   {
     sts = om$send(msg = message EMSloop.EMset_props
			(EMmsg, EMLP_EXTERNAL, EMS_O_ON), 
			p_chanselect = &to_loops);
     EMerr_hndlr(!(1&*EMmsg&sts), *EMmsg, EMS_E_LoopError, wrapup);
     (*lp_props) &= ~EMLP_EXTERNAL;
   }

/* A loopset is non modifiable when it has atleast one intersection
   edge. Thus if the loopset is natural then it is definetely
   modifiable. If the loopset is non-natural then obtain a count of its
   loops. If it has more then 1 loop then it is definately
   non-modifiable. If the loopset is non-natural and it has only one loop
   then if all the edges are natural (or their partedges) then the loopset
   is modifiable else it is non-modifiable.
*/   
  if( (*ls_props) & EMLS_NONMODIFIABLE)
   {
     if(ME.EMSloopset->ls_props & EMLS_NATURAL)
       ME.EMSloopset->ls_props &= ~EMLS_NONMODIFIABLE;
     else
      {
	if( (count > 1) || (count ==0) )
	  ME.EMSloopset->ls_props |= EMLS_NONMODIFIABLE;
	else
	 {
	   GRobjid		loopid, *junkptr;
	   OMuint		sec_level_loops;
	   OM_S_CHANSELECT	to_inner;

	   junkptr = &loopid;
	   depth = buf_size = 1;
	   sts = om$send(msg = message EMSloopset.EMget_loops
			(EMmsg, EMS_OPT_ALL, &depth, &junkptr, NULL, &buf_size,
			 &count), targetid = my_id);
           EMerr_hndlr(!(1&*EMmsg&sts), *EMmsg, EMS_E_LoopError, wrapup);

	   sts = EMmake_chanselect (EMSloop_to_inner, &to_inner);
	   EMerr_hndlr(!(1&sts), *EMmsg, EMS_E_OMerror, wrapup);
	   sts = om$get_channel_count(objid = loopid,p_chanselect = &to_inner,
					count = &sec_level_loops);
	   EMerr_hndlr(!(1&sts), *EMmsg, EMS_E_OMerror, wrapup);
	   if(sec_level_loops)
	     ME.EMSloopset->ls_props |= EMLS_NONMODIFIABLE;
	   else
	    {
	      OM_S_CHANSELECT 		to_edges;
	      OMuint			num_edges;
	      IGRushort		ed_props;
	
	      sts = EMmake_chanselect (EMSbd_owner_to_comps, &to_edges);
	      EMerr_hndlr(!(1&sts), *EMmsg, EMS_E_OMerror, wrapup);
	      sts = om$get_channel_count(objid = loopid,
				p_chanselect = &to_edges,count = &num_edges);
	      EMerr_hndlr(!(1&sts), *EMmsg, EMS_E_OMerror, wrapup);
	      ME.EMSloopset->ls_props &= ~EMLS_NONMODIFIABLE;
	      for(i=0; i<num_edges; i++)
	       {
		 sts = om$send(msg = message EMSedge.EMget_props
				(EMmsg, &ed_props),
                 senderid = loopid,
                 p_chanselect = &to_edges, 
				 from = i, to = i);
		 EMerr_hndlr(!(1&*EMmsg&sts), *EMmsg, EMS_E_EdgeError, wrapup);
		 if( !(ed_props & EMED_NATURAL))
		  {
		    ME.EMSloopset->ls_props |= EMLS_NONMODIFIABLE;
		    break;
		  }
	       }
	    }
	 }
      }
    (*ls_props) &= ~EMLS_NONMODIFIABLE;
   }
 
   if( (*lp_props) || (*ed_props) || (*ls_props) )
   sts = om$send(msg = message EMSloop.EMcheck_props
			(EMmsg, ls_props, lp_props, ed_props), 
			p_chanselect = &to_loops);

wrapup:
 EMWRAPUP(*EMmsg, sts, "In EMSloopset.EMcheck_props");
 return(sts);

}
end implementation EMSloopset;
