/* ###################   APOGEE COMPILED   ################## */
/*
NOTES
   This method is intended to be a generic method for any modifications
   to be made to an existing loopset (looptree). It gets the loop id to
   be operated upon and the type of operation to be done.
        For all operations the nesting structure is input, except for the
   EXTRACT and DELETE operations. In EXTRACT case the nesting structure 
   is outputif space is provided by the caller. 
        Following operations can be done on the loop and its relation to
   the tree - 

        ADD_CHILD  - add a child under me. The child id is nesting->loopid.
                     If the new child encloses any existing children then
                     adjust accordingly. If the new child is coincident
                     with any existing children then treat the new child
                     as enclosing the existing child. The reasoning: This
                     choice is arbitrary to some extent anyway. But the
                     existing coincident child loop could have bee chosen
                     as the parent loop as well. Since it was not, there
                     probably is some good intent here. Therefore, enclose
                     this child loop.
        CHG_PARENT - change my current parent to nesting->parent.
        DELETE -     delete myself. Connect my children to my parent.
        EXTRACT -    remove myself from the looptree.Connect my children
                     to my parent.Return the nesting structure with the 
                     information about myself.

HISTORY
   SS   08-May-89	With the ADD_CHILD option, the algorithm treats
                        existing loops that are coincident with the loop
                        to be added as being enclosed. Reasoning is given
                        above.
   SM	03-Mar-89	With DELETE option, the method used to send delete
			to edges(wrt object) and then delete (wrt msg) the
			loop. Changed it to disconnect outer connection and
			send delete (wrt object) to the loop.
   SM	20-Feb-89	When removing a P loop turn the DUMMY_CLOOP property
			off on the owner. The owner may or may not be a dummy
			C loop. Turn off the property anyway.
   RC	15-Feb-89	Set EMSIS_RANGE_MODIFIED bit on the surface even
			when a natural loop is removed. 
   SM	02-Jan-89	Return EMS_I_NoMoreLoops if the last loop in the
			loopset is extracted/deleted and EMS_I_FeatureLoop
			if the only loops remianing are feature loops, after
			deleting/extracting a loop.
   SM	20-Jul-88	Set EMSIS_RANGE_MODIFIED bit on the surface
			wherever applicable.
   AIC  28 April 88     EMSgradata.EMreset argument list changed.
   AIC  24 February 88  Make the to_helpers chanselectors in the
                        initiazation phase.
   AIC  29 December 87  Fix channel error when attempting to send
                        across the to_helpers channel for a loopset.
   AIC  22 September 87 Use EMSsubbs.EMmake_frt to allow surface
                        control of graphics data objects.
   AIC  15-Jul-87       Update graphics data objects.
   SM   02/24/87        Creation date
*/

class implementation EMSloop;

#include "EMS.h"
# include "OMmacros.h"
# include "emsmacros.h"
# include "EMSfrtdef.h"
# include "EMSssprops.h"

extern OMuword OPP_EMSloopset_class_id;

from EMSloopset import EMset_props, EMget_loops;
from EMSgradata import EMinit, EMreset;
from EMSsubbs import EMmake_frt, EMset_props;

method EMtreemod(IGRlong *EMmsg;struct EMSnest_info *nesting; 
                 IGRint operation;struct EMSpartolbasis *partolbasis)
{
    IGRlong             sts;
    OMuint		count, parent_count = 0;
    IGRint              i,depth,buf_size;
    GRobjid             old,child,parent,*loopids;
    IGRboolean          delete,external;
    struct EMSnest_info temp_nesting;
    OM_S_CHANSELECT     to_inner,to_outter,to_loops,to_edges,to_helpers,
			to_surf;
    IGRushort   *props;
    GRclassid           parent_classid;

    *EMmsg = EMS_S_Success;
    sts = OM_S_SUCCESS;
    loopids = NULL;
    props = NULL;

     sts = EMmake_chanselect (EMSrequester_to_helpers, &to_helpers);
     EMerr_hndlr(!(1&*EMmsg&sts),sts,OM_E_ABORT,wrapup);
     sts = EMmake_chanselect (EMSloop_to_inner, &to_inner);
     EMerr_hndlr(!(1&sts),*EMmsg,EMS_E_OMerror,wrapup);
     sts = EMmake_chanselect (EMSloop_to_outter, &to_outter);
     EMerr_hndlr(!(1&sts),*EMmsg,EMS_E_OMerror,wrapup);
     sts = EMmake_chanselect (EMSloopset_to_loops, &to_loops);
     EMerr_hndlr(!(1&sts),*EMmsg,EMS_E_OMerror,wrapup);
     sts = EMmake_chanselect (EMSloopset_to_surface, &to_surf);
     EMerr_hndlr(!(1&sts),*EMmsg,EMS_E_OMerror,wrapup);
     delete = (operation==DELETE) ? TRUE : FALSE;
     external = ME.EMSloop->lp_props & EMLP_EXTERNAL;

    switch (operation)
     {
       case ADD_CHILD:
/*
 Get all the UNSPLIT loops one level under me. If the incoming loop
 encloses any of them, then send a CHG_PARANT message to it. 
        When getting the unsplit loops, the split loops will be
ignored for deciding the level. Since the message is to be sent to
myself set the depth to 2 so that the traversal takes place 1 level
under me. Then ignore my_id in the list that is obtained.
*/    
          depth = 2;
          buf_size = 0;
          count = 0;
          sts = om$send(msg=message EMSloop.EMget_loops
                        (EMmsg,EMS_OPT_UNSPLIT,&depth,&loopids,&props,
                         &buf_size,(IGRint *)&count),targetid = my_id);
          for(i=0;i<count;i++)
           {
            if(!IF_EQ_OBJID(loopids[i],my_id))
             {
               sts = om$send(msg = message EMSloop.EMgivenestinfo
                                (EMmsg,&temp_nesting),targetid=loopids[i]);
               EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_LoopError,wrapup);
               sts = om$send(msg = message EMSloop.EMnesting
                                (EMmsg,&temp_nesting,partolbasis),
                                 targetid = nesting->loopid);
               EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_LoopError,wrapup);
               if(IF_EQ_OBJID(temp_nesting.parent,nesting->loopid) ||
                  *EMmsg == EMS_I_Ambiguous)
                {
                  temp_nesting = *nesting;
                  temp_nesting.parent = nesting->loopid;
                  sts = om$send(msg = message EMSloop.EMtreemod
                                (EMmsg,&temp_nesting,CHG_PARENT,partolbasis),
                                targetid = loopids[i]);
                  EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_LoopError,wrapup);
                }
             }
          } 

          sts = om$send(msg=message Root.connect(to_inner,NULL,
                         nesting->loopid,OM_Gw_current_OS,to_outter,NULL),
                         senderid = nesting->loopid,targetid=my_id);
         EMerr_hndlr(!(1&sts),*EMmsg,EMS_E_OMerror,wrapup);

/* Set the EXTERNAL bit off in the new child and the ACTIVE bit
   on in the new child */
         if(nesting->lp_props & EMLP_EXTERNAL)
         sts = om$send(msg=message EMSloop.EMset_props
                          (EMmsg,EMLP_EXTERNAL,EMS_O_OFF),
                       targetid=nesting->loopid);
         EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_LoopError,wrapup);

/*
         if(!(nesting->lp_props & EMLP_ACTIVE))
         sts = om$send(msg=message EMSloop.EMset_props
                          (EMmsg,EMLP_ACTIVE,EMS_O_ON),
                       targetid=nesting->loopid);
         EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_LoopError,wrapup);
*/

/* Set the natural bit in the loopset OFF if this loop was natural.
*/
         if(ME.EMSloop->lp_props & EMLP_NATURAL)
           sts = om$send(msg=message EMSloopset.EMset_props
                        (EMmsg,EMLS_NATURAL,EMS_O_OFF),
                        p_chanselect=&to_outter);

          /*
           * If the Ploop has an graphics data flag it as out of date,
           * otherwise create an graphics data. (The Ploop is the inner
           * loop, unless the inner loop is a Cloop. Note that the inner
           * and outter loops can both be Ploops until the loopset is
           * cleaned up. This block of code assumes that adding a Ploop
           * child to a Ploop will always result in deleting the old
           * Ploop.)
           */
          {
            IGRushort   new_loop_props;
            GRobjid             Ploop_id;

            new_loop_props = 0;
            sts = om$send(msg = message EMSloop.EMget_props(EMmsg,
                          &new_loop_props), targetid = nesting->loopid);
            if(! (new_loop_props & EMLP_PLOOP))
            {
              if(me^^EMSloop.lp_props & EMLP_PLOOP)
              {
                /*
                 * The graphics data will be attached to me
                 */
                Ploop_id = my_id;
              }
              else Ploop_id = NULL_OBJID;
            }
            else
            {
              /*
               * The graphics data will be attached to the new child
               */
              Ploop_id = nesting->loopid;
            }

            if(Ploop_id ISNT NULL_OBJID)
            {
              *EMmsg = EMS_I_NoResponse;
              sts = om$send(msg = message EMSgradata.EMreset(EMmsg,
                            EMS_O_OUTOFDATE), senderid = Ploop_id,
                            p_chanselect = &to_helpers);
              if(sts IS OM_W_UNKNOWN_MSG) sts = OM_S_SUCCESS;
              EMerr_hndlr(!(1&*EMmsg&sts),sts,OM_E_ABORT,wrapup);
              if(*EMmsg IS EMS_I_NoResponse)
              {
                /*
                 * There is no graphics data -- make one
                 */
                GRobjid surf_id;

                surf_id = NULL_OBJID;
                sts = om$send(msg = message EMSloop.EMgetsurface_info
                              (EMmsg, &surf_id, NULL), targetid = my_id);
                EMerr_hndlr(!(1&*EMmsg&sts),sts,OM_E_ABORT,wrapup);
                if(surf_id != NULL_OBJID)
                {
                  sts = om$send(msg = message EMSsubbs.EMmake_frt(EMmsg,
                                Ploop_id), targetid = surf_id);
                  EMerr_hndlr(!(1&*EMmsg&sts),sts,OM_E_ABORT,wrapup);
                }
              } /* No Response */
            } /* if Ploop_id ISNT NULL_OBJID */
          } /* block */

         break;

       case CHG_PARENT:

         old = NULL_OBJID;         
/* who is my current parent ? */
         sts = om$send(msg=message EMSboundary.EMget_objid(EMmsg,&old),
                             p_chanselect = &to_outter);
         EMerr_hndlr(!(1& *EMmsg & sts),*EMmsg,EMS_E_LoopError,wrapup);

/* who is my new parent ?
*/
         sts = om$get_classid(objid=nesting->parent,
                                p_classid = &parent_classid);
         EMerr_hndlr(!(1&sts),*EMmsg,EMS_E_OMerror,wrapup);

/* disconnect myself from current parent if there is one
*/

         if(!IF_NULL_OBJID(old))
          {
            if(ME.EMSloop->lp_props & EMLP_EXTERNAL)
             {
               sts = om$send(msg=message Root.disconnect(to_loops,
                           my_id,OM_Gw_current_OS,to_outter),
                           targetid=old);
               EMerr_hndlr(!(1&sts),*EMmsg,EMS_E_OMerror,wrapup);
               ME.EMSloop->lp_props &= ~EMLP_EXTERNAL;
	       if(!(ME.EMSloop->lp_props & EMLP_NATURAL))
		{
	         sts = om$send(msg = message EMSsubbs.EMset_props
				(EMmsg, EMSIS_RANGE_MODIFIED, EMS_O_ON),
			senderid = old, p_chanselect = &to_surf);
                 EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_Fail,wrapup);
		}
             }
            else
             {
               sts = om$send(msg=message Root.disconnect(to_inner,
                           my_id,OM_Gw_current_OS,to_outter),
                           targetid=old);

               EMerr_hndlr(!(1&sts),*EMmsg,EMS_E_OMerror,wrapup);
             }
          }

         if(parent_classid == OPP_EMSloopset_class_id)
          {
            sts = om$send(msg=message Root.connect(to_loops,NULL,my_id,
                        OM_Gw_current_OS,to_outter,NULL),
                        targetid = nesting->parent);
            EMerr_hndlr(!(1&sts),*EMmsg,EMS_E_OMerror,wrapup);
            ME.EMSloop->lp_props |= EMLP_EXTERNAL;
	    if(!(ME.EMSloop->lp_props & EMLP_NATURAL))
	     {
              sts = om$send(msg = message EMSsubbs.EMset_props
				(EMmsg, EMSIS_RANGE_MODIFIED, EMS_O_ON),
		senderid = nesting->parent, p_chanselect = &to_surf);
              EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_Fail,wrapup);
	     }
          }
         else
          {
            sts = om$send(msg=message Root.connect(to_inner,NULL,my_id,
                        OM_Gw_current_OS,to_outter,NULL),
                        targetid = nesting->parent);
            EMerr_hndlr(!(1&sts),*EMmsg,EMS_E_OMerror,wrapup);
          }

          /*
           * Set ACTIVE property bit on
           */
/*
          ME.EMSloop->lp_props |= EMLP_ACTIVE;
*/
          /*
           * If the Ploop has an graphics data flag it as out of date,
           * otherwise create an graphics data.
           */
          {
            GRobjid             Ploop_id;

            if(me^^EMSloop.lp_props & EMLP_PLOOP)
            {
              /*
               * The graphics data will be attached to me
               */
              Ploop_id = my_id;
            }
            else
            {
              IGRushort   new_loop_props;

              new_loop_props = 0;
              sts = om$send(msg = message EMSloop.EMget_props(EMmsg,
                            &new_loop_props), targetid = nesting->parent);

              if(new_loop_props & EMLP_PLOOP)
              {
                /*
                 * The graphics data will be attached to the new parent
                 */
                Ploop_id = nesting->parent;
              }
              else Ploop_id = NULL_OBJID;

              /*
               * reset my old parent's graphics data
               */
              sts = om$send(msg = message EMSgradata.EMreset(EMmsg,
                            EMS_O_OUTOFDATE), senderid = old,
                            p_chanselect = &to_helpers);
              if((sts IS OM_E_INVCHAN) || (sts IS OM_W_UNKNOWN_MSG))
                sts = OM_S_SUCCESS;
              EMerr_hndlr(!(1&*EMmsg&sts),sts,OM_E_ABORT,wrapup);
            }

            if(Ploop_id ISNT NULL_OBJID)
            {
              /*
               * reset the Ploop graphics data
               */
              *EMmsg = EMS_I_NoResponse;
              sts = om$send(msg = message EMSgradata.EMreset(EMmsg,
                            EMS_O_OUTOFDATE), senderid = Ploop_id,
                            p_chanselect = &to_helpers);
              if(sts IS OM_E_INVCHAN)
                { *EMmsg = EMS_S_Success; sts = OM_S_SUCCESS; }
              if(sts IS OM_W_UNKNOWN_MSG) sts = OM_S_SUCCESS;
              EMerr_hndlr(!(1&*EMmsg&sts),sts,OM_E_ABORT,wrapup);
              if(*EMmsg IS EMS_I_NoResponse)
              {
                /*
                 * There is no graphics data -- make one
                 */
                GRobjid surf_id;

                surf_id = NULL_OBJID;
                sts = om$send(msg = message EMSloop.EMgetsurface_info
                              (EMmsg, &surf_id, NULL), targetid = Ploop_id);
                EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_OMerror,wrapup);
                if(surf_id != NULL_OBJID)
                {
                  sts = om$send(msg = message EMSsubbs.EMmake_frt(EMmsg,
                                Ploop_id), targetid = surf_id);
                  EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_OMerror,wrapup);
                }
              }
            }
         }

         break;
     
       case DELETE: case EXTRACT:

/* move my children to my current parent and delete/extract myself
*/
           parent = NULL_OBJID;
           sts = om$send(msg=message EMSboundary.EMget_objid
                                (EMmsg,&parent),p_chanselect=&to_outter);
           EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_LoopError,wrapup);

/* If the loop being extracted out has no parent, then do not bother
   about its children either.
*/
        if(!IF_NULL_OBJID(parent))
         {
           if(ME.EMSloop->lp_props & EMLP_EXTERNAL)
             sts = om$get_channel_count(objid = parent,count = &parent_count,
                                        p_chanselect=&to_loops);
           else
             sts = om$get_channel_count(objid=parent,count=&parent_count,
                                        p_chanselect=&to_inner);
           EMerr_hndlr(!(1&sts),*EMmsg,EMS_E_OMerror,wrapup);

           sts = om$get_channel_count(object=me,p_chanselect=&to_inner,
                                        count=&count);
           EMerr_hndlr(!(1&sts),*EMmsg,EMS_E_OMerror,wrapup);

           for(i=count-1;i>=0;i--)
            {
              sts = om$send(msg=message EMSboundary.EMget_objid
                                        (EMmsg,&child),p_chanselect=&to_inner,
                                        from=i,to=i);
              EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_LoopError,wrapup);

/* Disconnect the child from me
*/
              sts = om$send(msg=message Root.disconnect(to_outter,
                                        my_id,OM_Gw_current_OS,to_inner),
                                        targetid=child);
              EMerr_hndlr(!(1&sts),*EMmsg,EMS_E_OMerror,wrapup);

/* Connect my child loop to my current parent
*/
              if(ME.EMSloop->lp_props & EMLP_EXTERNAL)
               {
                 sts = om$send(msg=message Root.connect(to_loops,
                        NULL,child,OM_Gw_current_OS,to_outter,
                        NULL),senderid=child,targetid=parent);
                 EMerr_hndlr(!(1&sts),*EMmsg,EMS_E_OMerror,wrapup);

/* If I was an external loop then my child loop now becomes external.
*/
                 sts = om$send(msg=message EMSloop.EMset_props
                           (EMmsg,EMLP_EXTERNAL,EMS_O_ON),targetid=child);
               EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_LoopError,wrapup);
               }
              else
               {
                 sts = om$send(msg=message Root.connect(to_inner,
                              NULL,child,OM_Gw_current_OS,to_outter,NULL),
                                senderid=child,targetid=parent);
                 EMerr_hndlr(!(1&sts),*EMmsg,EMS_E_OMerror,wrapup);
               }

            } /* for(i=count-1;i>=0;i--) */

	   /* If an external loop is deleted/extracted the external
		area of the surface has changed. So set the bit on the
		surface. If the loop is external,the parent better be
		the loopset. 
	   */
	   if( ME.EMSloop->lp_props & EMLP_EXTERNAL)
	    {
	     sts = om$send(msg = message EMSsubbs.EMset_props
			(EMmsg, EMSIS_RANGE_MODIFIED, EMS_O_ON),
			senderid = parent, p_chanselect = &to_surf);
             EMerr_hndlr(!(1&sts),*EMmsg,EMS_E_OMerror,wrapup);
	    }
	
	   /* Turn off the DUMMY_CLOOP property on the C loop owner.
	   */
	   if( (ME.EMSloop->lp_props & EMLP_PLOOP) &&
	       !(ME.EMSloop->lp_props & EMLP_EXTERNAL))
	    {
	      sts = om$send(msg = message EMSloop.EMset_props
				(EMmsg, EMLP_DUMMY_CLOOP, EMS_O_OFF), 
				targetid = parent);
	      /* Purposely ignoring errors. Error in setting this property
		 does not warrant the method quitting halfway.
	      */
	      *EMmsg = EMS_S_Success;
	      sts = OM_S_SUCCESS;
	    }
          } /* if parent != NULL_OBJID */
         else
          {
            if(!delete) 
             {
               sts = om$send(msg=message Root.wild_disconnect(to_inner),
                                targetid = my_id);
               EMerr_hndlr(!(1&sts),*EMmsg,EMS_E_OMerror,wrapup);
             }
          }


/* If the option was to extract then fill the nesting structure,else delete
   myself
*/
         sts = om$send(msg=message Root.wild_disconnect(to_outter),
                                      targetid=my_id);
         EMerr_hndlr(!(1&sts),*EMmsg,EMS_E_OMerror,wrapup);

         if(delete)
          {
            to_edges.type = OM_e_addr;
            to_edges.u_sel.addr = &ME.EMSbd_owner->to_comps;

/*******************************************
            sts = om$send(mode=OM_e_wrt_object,msg=message Root.delete
			(TRUE), p_chanselect=&to_edges);
            EMerr_hndlr(!(1&sts),*EMmsg,EMS_E_OMerror,wrapup);
            sts = om$send(mode=OM_e_wrt_message,msg=message Root.delete
			(TRUE), targetid=my_id);
            EMerr_hndlr(!(1&sts),*EMmsg,EMS_E_OMerror,wrapup);
********************************************/
            sts = om$send(msg=message Root.delete (TRUE), targetid=my_id);
            EMerr_hndlr(!(1&sts),*EMmsg,EMS_E_OMerror,wrapup);
          }
         else
          {
                IGRint  size;
/*********************************
            sts = om$send(msg=message Root.wild_disconnect(to_outter),
                                        targetid=my_id);
            EMerr_hndlr(!(1&sts),*EMmsg,EMS_E_OMerror,wrapup);
********************************/

            if(nesting)
             {
               ME.EMSloop->lp_props &= ~(EMLP_EXTERNAL);
               nesting->loopid = my_id;
               nesting->lp_props = ME.EMSloop->lp_props;
               nesting->parent = NULL_OBJID;
               nesting->parent_props = NULL;
               size=4*sizeof(IGRdouble);
               OM_BLOCK_MOVE(ME.EMSloop->range,nesting->range,size);
             }
          }

        /*
         * If I am a Ploop, delete my graphics data, else reset my
         * parent's graphics data
         */
        {
          if(ME.EMSloop->lp_props & EMLP_PLOOP)
          {
            sts = om$send(msg = message Root.delete(1),
                          p_chanselect = &to_helpers);
            if(sts IS OM_W_UNKNOWN_MSG) sts = OM_S_SUCCESS;
            EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_OMerror,wrapup);
          }
          else /* CLOOP   */
          {
            if(parent != NULL_OBJID)
            {
              sts = om$send(msg = message EMSgradata.EMreset(EMmsg,
                            EMS_O_OUTOFDATE), senderid = parent,
                            p_chanselect = &to_helpers);
              if((sts IS OM_W_UNKNOWN_MSG) || (sts IS OM_E_INVCHAN))
                sts = OM_S_SUCCESS;
              EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_OMerror,wrapup);
            }
          }
        }

	 /* Convey the information about remaining loops, to the caller.
	 */
	 if(external && !count)
	  {
	   /* If this loop was the only loop under the loopset, then no more
	      loops are remaining in the loopset. If there were more
	      than one external loops, the remaining loops could possibly 
	      be just feature loops.
	   */
	   if(parent_count <= 1) *EMmsg = EMS_I_NoMoreLoops;
	   else 
	    {
	     IGRint		remaining = 0, depth = 1;
	
	     sts = om$send(msg = message EMSloopset.EMget_loops
			(EMmsg, EMS_OPT_FEATURES, &depth, NULL, NULL, NULL, 
			 &remaining), targetid = parent);
	     EMerr_hndlr(!(1&*EMmsg&sts), *EMmsg, EMS_E_LoopsetError, wrapup);
	     if(remaining == (parent_count - 1)) 
		*EMmsg = EMS_I_FeatureLoop;
	    }
	  }
         break;

       default:
         *EMmsg = EMS_E_InvalidArg;
         break;
     }


wrapup:
        if(loopids) om$dealloc(ptr=loopids);
        if(props) om$dealloc(ptr=props);

       EMWRAPUP(*EMmsg,sts,"In EMSloop.EMtreemod")
       return(sts);
}

end implementation EMSloop;
