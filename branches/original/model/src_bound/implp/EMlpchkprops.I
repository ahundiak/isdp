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
	WHOEVER NEEDS DIFFERENT CHECKS SHOULD ADD ON TO THIS METHOD 
	APPROPRIATELY (THEMSELVES)!
	
  Following checks will be handled as of now -
  1) ls_props - EMLS_NATURAL.
  2) lp_props - EMLP_NATURAL, EMLP_EXTERNAL.


History
	SM	06/01/87	Creation date.
	SM  	16-Nov-88	For loop to be natural,in addition to all edges
				being EMSnatedges, the edges indices should 
				also be correct.
        RC      03/01/89        If the loop is marked as natural, turn off its
                    		EMLP_REVERSED property.
        Inasu   02/28/91        If the loop is reversed the 'edges' array will
				be reversed so that the edges will be reshuff-
				led to be ordered in the natural order.
*/

class implementation EMSloop;

#include "EMS.h"
#include "EMSopt.h"
#include "OMmacros.h"

from EMSloopset import EMset_props;
from EMSnatedge import EMget_location;

static IGRint EMreshuffle_edges(EMmsg, edges, locations, loopid, to_edges)
 IGRlong		*EMmsg;
 struct GRid	*edges;
 IGRshort		*locations;
 GRobjid		loopid;
 OM_p_CHANSELECT to_edges;
 {
  IGRlong               sts = 0;
  OM_S_CHANSELECT	to_loop;
  IGRint	        i, num_connected = 0, j;
  OMuint                edgeindices[4];
  IGRboolean		atleast_one_connected = FALSE;

    
  sts = EMmake_chanselect (EMSedge_to_owner, &to_loop);

  /* Store the loop indices on the 'to_loop' channel for each edge. We will
     use the same indices for reconnection. Only the edge indices on the
     'to_edges' channel will get reshuffled.
  */
  for(i=0; i<4; i++)
   {
    sts = om$get_index(objid_c = edges[i].objid, p_chanselect = &to_loop,
			   objid = loopid, indexaddr = & edgeindices[i]);
    if(!(1&sts)) goto wrapup;
   }

  sts = om$send(msg = message Root.wild_disconnect(*to_edges),
					targetid = loopid, senderid = loopid);
  if(!(1&sts)) goto wrapup;

  for(i=0; i<4; i++)
   {
    atleast_one_connected = FALSE;
    for(j=0; j<4; j++)
     {
     if(locations[j] == i) {atleast_one_connected = TRUE; break;}
     }

    if(!atleast_one_connected)
     {
       *EMmsg = EMS_E_Fail; 
       goto wrapup;
     }

    sts = om$send(msg = message Root.connect(*to_edges, edgeindices[j],
				edges[j].objid, OM_Gw_current_OS, to_loop, i),
				targetid = loopid, senderid = edges[j].objid);
    if(!(1&sts)) goto wrapup;
    num_connected++;
   }


wrapup:
 if(num_connected != 4) *EMmsg = EMS_E_Fail;
 return(sts);

 }


method EMcheck_props(IGRlong *EMmsg; IGRushort *ls_props, *lp_props, 
			*ed_props)
{
  IGRlong sts= 0;
  OM_S_CHANSELECT	to_inner, to_outter, to_edges;
  OMuint		count;
  struct GRid	*edges = NULL;
  IGRint		num_edges = 0, array_size = 0;

  to_inner.type = OM_e_addr;
  to_inner.u_sel.addr = &ME.EMSloop->to_inner;

  to_outter.type = OM_e_addr;
  to_outter.u_sel.addr = &ME.EMSloop->to_outter;

  to_edges.type = OM_e_addr;
  to_edges.u_sel.addr = &ME.EMSbd_owner->to_comps;

  if((*lp_props) & EMLP_EXTERNAL)
   {
    GRobjid outerid = NULL_OBJID;

    sts = om$send(msg = message EMSboundary.EMget_objid(EMmsg, &outerid), 
			p_chanselect = &to_outter);
    EMerr_hndlr(!(1&*EMmsg&sts), *EMmsg, EMS_E_LoopError, wrapup);
    if(IF_NULL_OBJID(outerid))
     ME.EMSloop->lp_props &= ~EMLP_EXTERNAL;
    else
     {
      OMuword outer_classid;
      sts = om$get_classid(objid = outerid, p_classid = &outer_classid);
      EMerr_hndlr(!(1&sts), *EMmsg, EMS_E_OMerror, wrapup);
      if (outer_classid == OPP_EMSloopset_class_id || 
          om$is_ancestry_valid (subclassid = outer_classid,
           superclassid = OPP_EMSloopset_class_id) == OM_S_SUCCESS)
       ME.EMSloop->lp_props |= EMLP_EXTERNAL;
      else ME.EMSloop->lp_props &= ~EMLP_EXTERNAL;
     }
    (*lp_props) &= ~EMLP_EXTERNAL;
   }

  if((*lp_props) & EMLP_NATURAL)
   {
/* If the natural property of the loop is to be checked, send down the message
   to all the edges.The first non natural edge will turn the property bit
   off and return OM_I_STOPSENDING to the loop. After this check
   set the corresponding option bit off so that this check will not be made
   again(there can be only one natural loop in a loopset) and it will be
   external. 
*/
     ME.EMSloop->lp_props |= EMLP_NATURAL;
     sts = om$send(msg = message EMSboundary.EMcheck_props
				(EMmsg, ls_props, lp_props, ed_props), 
				p_chanselect = &to_edges);
     if(sts == OM_I_STOP_SENDING) sts = OM_S_SUCCESS;
     EMerr_hndlr(!(1&*EMmsg&sts), *EMmsg, EMS_E_EdgeError, wrapup);
  
  /* In addition to all the edges being of class EMSnatedge, the natuarl
     property of the loop requires that they be on the proper indices
     on the 'to_comps' channel. If possible reshuffle them or else declare
     the loop to be non natural. If the natural property of the loop has
     remained intact at this point, it automatically means that all its
     edges are of class EMSnatedge.
  */
     if(ME.EMSloop->lp_props & EMLP_NATURAL)
      {
       sts = om$send(msg = message EMSloop.EMget_edges
		(EMmsg, 1, EMS_OPT_ALL, &edges, &array_size,
		 &num_edges), targetid = my_id);           
       EMerr_hndlr(!(1&*EMmsg&sts), *EMmsg, EMS_E_EdgeError, wrapup);
       if(num_edges == 4)
        {
         IGRint i,j;
         IGRshort	locations[4];
         IGRboolean  	good[4],bad = FALSE;
	 GRobjid 	edgeid;

	/*if loop order is reversed, reverse the array since EMget_edges always
	   returns in the natural order */

         if ( ME.EMSloop->lp_props & EMLP_REVERSED )
		for(i=0,j= (num_edges - 1); i < (num_edges/2); i++,j--)
		{ 
		  edgeid = edges[i].objid;
		  edges[i].objid = edges[j].objid;
		  edges[j].objid = edgeid;
                }

         for(i=0; i<num_edges; i++)
          {
           good[i] = FALSE;
           sts = om$send(msg = message EMSnatedge.EMget_location
			(EMmsg, &locations[i]), targetid = edges[i].objid);
           EMerr_hndlr(!(1&*EMmsg&sts), *EMmsg, EMS_E_EdgeError, wrapup);

	   /* The natural edges must be in the order 0, 1, 2, 3. If not we
	      got a problem.
	   */
           if(locations[i] != i) bad = TRUE;
          } 

         if(bad)
          {
           for(i=0; i<num_edges; i++)
            {
    	     IGRboolean *junk;

             if(locations[i] == 0) junk = &good[0];
	     else if(locations[i] == 1) junk = &good[1];
	     else if(locations[i] == 2) junk = &good[2];
	     else if(locations[i] == 3) junk = &good[3];
             else {good[0] = FALSE; break;}

  	     /* If we have two edges of same location, then loop is non 
	        natural 
	     */

   	     if(*junk) {*junk = FALSE; break;}
	     else *junk = TRUE;
	    }

  	   if(good[0] && good[1] && good[2] && good[3])
	    {
	     sts = EMreshuffle_edges(EMmsg, edges, locations, my_id,&to_edges);
	     if(!(1&*EMmsg&sts))
	      {
	       ME.EMSloop->lp_props &= ~EMLP_NATURAL;
	       *EMmsg = EMS_E_LoopError;
	       goto wrapup;
              }
               
	    }
	   else ME.EMSloop->lp_props &= ~EMLP_NATURAL;

          } /* if(bad) */

        } /* if(num_edges ==4) */

       else ME.EMSloop->lp_props &= ~EMLP_NATURAL;

       if (ME.EMSloop->lp_props & EMLP_NATURAL)
         ME.EMSloop->lp_props &= ~EMLP_REVERSED;

      } /* if(ME.EMSloop->lp_props & EMLP_NATURAL) */

     (*lp_props) &= ~EMLP_NATURAL;
   }

/* If this loop is requested to check whether the loopset is natural or not, 
   it will check it's own natural bit. If it is natural and if it has no
   children then it will conclude that the loopset is
   natural. It will also set the option bit off so that the check is not
   made again by any other loop.
       If the caller is not sure of the loop being natural, then that check
   should be specified by the caller. If specified it will be done before
   the loop checks the loopset to be natural.
*/
  if((*ls_props) & EMLS_NATURAL)
   {
     IGRboolean	ls_natural = TRUE;

     if(ME.EMSloop->lp_props & EMLP_NATURAL)
      {
	sts = om$get_channel_count(object=me, p_chanselect = &to_inner, 
				count = &count);
	EMerr_hndlr(!(1&sts), *EMmsg, EMS_E_OMerror, wrapup);
	if(count) ls_natural = FALSE;
      }
     else ls_natural = FALSE;
     
     if(ME.EMSloop->lp_props & EMLP_EXTERNAL)
      {
       sts = om$send(msg = message EMSloopset.EMset_props
		(EMmsg, EMLS_NATURAL, ls_natural ? EMS_O_ON : EMS_O_OFF), 
			p_chanselect = &to_outter);
       EMerr_hndlr(!(1&*EMmsg&sts), *EMmsg, EMS_E_LoopsetError, wrapup);
      }
     else
       sts = om$send(msg = message EMSboundary.EMcheck_props
				(EMmsg, ls_props, lp_props, ed_props), 
				p_chanselect = &to_outter);
     (*ls_props) &= ~EMLS_NATURAL;
   }

wrapup:
  if(edges) om$dealloc(ptr = edges);
  EMWRAPUP(*EMmsg, sts, "In EMSloop.EMcheck_props");
  return(sts);
}




end implementation EMSloop;
