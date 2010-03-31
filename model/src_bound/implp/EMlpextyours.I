/* ###################   APOGEE COMPILED   ################## */
/*
Notes
	This method extracts the positive parts out of a trimmed loop and
 constructs new loops/edges out of the extracted parts.A new loop is formed
 for each pair of positive boundaries on the loop. There can be any number
 of pairs of boundaries. They are passed in as a linked list of structures
 EMSsfintedpar. A pair of positive boundaries can extend over many edges.

Assumptions
	Every pair of input boundary represents a disjoint part of the
 loop. Hence every pair of input boundary results into a loop(which may be
 open or closed.)


History
	SM	03/24/87	Creation Date.
	SM	02-Mar-88	If the delete_me flag is TRUE and if an
				edge is completely in area then do not
				spend time extracting it. Use the existing
				edge and pretend it was extracted. 
        SM      27-Oct-88	Fixed a bug where the loop used to set the
				NoInputDelete off before sending the message
				to the edges. This resulted in the edge being
				reused (when extracting the whole edge) even
				if the caller does not want that to happen.
	SM	12-Mar-89	Supported extraction and creation of a single
				point (leading to a point loop). The
				information as to whether a point is to be 
				extracted is passed in via option 
				EMLpExtrct_SinglePoint in info field of the
				corresponding EMSsfintedpar structure. The
				info field if non NULL must point to a
				unsigned short containing options defined
				in emsextdef.h
	SM	14-Mar-89	made outputting of bdry pairs better. Now
				bdrys on loop and/or 'against' element can
				be requested independently. The input
				flag 'output_pairs' is meaningless.
	SM	30-Oct-89	Support option EMImpBnd_MaintainAssoc.
	SM	19-Mar-92	Removed the naive assumption that nobody
				would send this message with my_bdrys = NULL
				and num_bdrys = 0!
*/
	   
class implementation EMSloop;

#include "EMS.h"
#include "emssfint.h"
#include "emsinter.h"
#include "OMmacros.h"
#include "emsimpdef.h"
#include "bsparameters.h"
#include "emsmacros.h"
#include "emsextdef.h"

from EMSedge import EMextractyourself,EMendpts, EMget_props;
from EMSgraloop import EMglpinit;
from EMSptedge import EMpteinit;

extern OMuword	OPP_EMSloop_class_id, OPP_EMSptgralp_class_id, 
		OPP_EMSptedge_class_id;
		
extern IGRboolean WANT_POST220_BEHAVIOR;

method EMextractyourself(IGRlong *EMmsg;
			 struct EMSsfintedpar *my_bdrys,*ele_bdrys;
			 IGRint num_bdrys;GRobjid **output_obj;
			 struct EMSsfintedpar ***out_bdrys,***against_bdrys;
			 IGRboolean output_pairs;
			 IGRushort options;
			 struct EMSpartolbasis *partolbasis)
{
  IGRlong		sts,i, rc;
  OM_S_CHANSELECT	to_edges,to_owners;
  struct EMSsfintedpar	*from_lp_bdry = NULL, *to_lp_bdry = NULL;
  struct EMSsfintedpar	*from_el_bdry = NULL, *to_el_bdry = NULL;
  GRobjid		ext_edge, *ext_edge_ptr = NULL;
  IGRushort	props;
  OMuint		count;
  IGRboolean		same_edge, delete_me;
  IGRdouble		lentol;
  extern IGRboolean	EFextract_par();
  IGRushort	*extoptions = NULL;

  *EMmsg = EMS_S_Success;
  sts = OM_S_SUCCESS;
  EMerr_hndlr(!num_bdrys || !my_bdrys, *EMmsg, EMS_E_InvalidArg, wrapup);

  if(!partolbasis->is_valid)
   {
    sts = om$send(msg=message EMSboundary.EMgetsurface_info(EMmsg,NULL,
                        partolbasis), targetid=my_id);
    EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_LoopError,wrapup);
   }

  /* Got to have valid tolerance 
  */
  EMerr_hndlr(!partolbasis->is_valid, *EMmsg, EMS_E_InvalidArg, wrapup);

  delete_me = options & EMImpBnd_NoInputDelete ? FALSE : TRUE;

  ext_edge_ptr = &ext_edge;
  sts = EFextract_par(BSTOLLENVEC, partolbasis->tol, &lentol, &rc);

  if(!(*output_obj))
      *output_obj = (GRobjid *) om$malloc(size=num_bdrys*sizeof(GRobjid));
  EMerr_hndlr(!*output_obj,*EMmsg,EMS_E_DynamicMemoryAllocated,wrapup);
  if(out_bdrys && !(*out_bdrys))
   {
    *out_bdrys = (struct EMSsfintedpar **) om$malloc(size=num_bdrys*
				sizeof(struct EMSsfintedpar *));
    EMerr_hndlr(!*out_bdrys,*EMmsg,EMS_E_DynamicMemoryAllocated,wrapup);
   }

  if(against_bdrys && !(*against_bdrys))
   {
    *against_bdrys = (struct EMSsfintedpar **) om$malloc(size=num_bdrys*
				sizeof(struct EMSsfintedpar *));
    EMerr_hndlr(!*against_bdrys,*EMmsg,EMS_E_DynamicMemoryAllocated,wrapup);
   }

  sts = EMmake_chanselect (EMSbd_owner_to_comps, &to_edges);
  EMerr_hndlr(!(1&sts),*EMmsg,EMS_E_OMerror,wrapup);
  sts = EMmake_chanselect (EMSedge_to_owner, &to_owners);
  EMerr_hndlr(!(1&sts),*EMmsg,EMS_E_OMerror,wrapup);

/* Process each boundary pair on me.
*/
  from_lp_bdry = my_bdrys;
  to_lp_bdry = from_lp_bdry->next;
  if(against_bdrys)
   {
    from_el_bdry = ele_bdrys;
    to_el_bdry = from_el_bdry->next;
   }

  sts = om$get_channel_count(object=me,p_chanselect=&to_edges,
				   count = &count);
  EMerr_hndlr(!(1&sts),*EMmsg,EMS_E_OMerror,wrapup);

  for(i=0;i<num_bdrys;i++)
   {
     IGRboolean		pointloop = FALSE;
     extoptions = (IGRushort *) from_lp_bdry->info;

     if(extoptions && (*extoptions & EMLpExtrct_SinglePoint))
      pointloop = TRUE;
	
     same_edge = FALSE;

     sts = om$construct(classid = pointloop ? OPP_EMSptgralp_class_id :
					      OPP_EMSloop_class_id,
		  p_objid = &(*output_obj)[i]);
     EMerr_hndlr(!(1&sts),*EMmsg,EMS_E_OMerror,wrapup);
     if(pointloop)
      {
       sts = om$construct(classid = OPP_EMSptedge_class_id, 
			  p_objid = &ext_edge, 
			  msg = message EMSptedge.EMpteinit
			  (EMmsg, NULL, from_lp_bdry->point));
       EMerr_hndlr(!(1&sts),*EMmsg,EMS_E_OMerror,wrapup);

       sts = om$send(msg = message Root.connect(to_owners, NULL,
			(*output_obj)[i], OM_Gw_current_OS, to_edges,NULL),
			targetid = ext_edge);
       EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_OMerror,wrapup);

      }
     else
      {
       /* Before extracting the loop,  a determination needs to be made as to
       whether the part of the loop to be extracted lies on the same edge or
       spans across different edges. If the loop has only one edge or if
       the boundaries themselves span across edges, then it is a trivial 
       determination. But if the boundaries are on the same edge and if the 
       loop is closed then an ambiguous case arises. This is detected by 
       looking
       at the parameters on the edge. In cases such as these the part to be
       extracted is dictated by the direction of the loop. 
      */
       if(count == 1 && !(ME.EMSloop->lp_props & EMLP_XYZ)) same_edge = TRUE;
       else if(IF_EQ_OBJID(from_lp_bdry->edgeid,to_lp_bdry->edgeid))
        {
	 IGRdouble		p1, p2, fabs();
         IGRushort		edprops;
         IGRboolean		edrev;

	 sts = om$send(msg=message EMSedge.EMget_props(EMmsg, &edprops), 
				targetid = from_lp_bdry->edgeid);
	 EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg, EMS_E_EdgeError, wrapup);
	 p1 = from_lp_bdry->edgepar.param + from_lp_bdry->edgepar.span_inx;
	 p2 = to_lp_bdry->edgepar.param + to_lp_bdry->edgepar.span_inx;

	 edrev = (edprops & EMED_REVERSED) ? TRUE : FALSE;
	
	 if( (num_bdrys == 1) /*&& WANT_POST220_BEHAVIOR*/ && 
	     (fabs(p1-p2) < lentol) && !(ME.EMSloop->lp_props & EMLP_OPEN))
	  same_edge = FALSE;
	 else
	  {
	   if(edrev && (p1 < p2)) same_edge = FALSE;
	   else if(!edrev && (p1 > p2)) same_edge = FALSE;
	   else same_edge = TRUE;
	  }
        }
       else same_edge = FALSE;

       if( same_edge )
        {
         /* If the whole edge is to be extracted then we can use the
	   same edge and pretend it was extracted. This will be safe
	   to do if the delete_me flag is TRUE because by setting this
	   flag to TRUE, the caller has indicated that he does not care
	   what happens to this edge/loop.
	 */

	 if( (from_lp_bdry->intloc == EMScvint_lfend) &&
	    (to_lp_bdry->intloc == EMScvint_rtend) && delete_me) 
	   *ext_edge_ptr = from_lp_bdry->edgeid;
	 else
	  {
	   sts = om$send(msg=message EMSedge.EMextractyourself
			(EMmsg,from_lp_bdry,NULL,1,&ext_edge_ptr,NULL,NULL,
			FALSE, options,NULL,partolbasis),
		targetid = from_lp_bdry->edgeid);
	   EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_EdgeError,wrapup);
	  }
         sts = om$send(msg=message Root.connect(to_owners, NULL,
		(*output_obj)[i], OM_Gw_current_OS, to_edges, NULL),
			targetid = ext_edge);
	 EMerr_hndlr(!(1&sts),*EMmsg,EMS_E_OMerror,wrapup);
        }
       else
        {
         OMuint                         i1,i2;
         IGRint 			to_idx,edidx,edcount;
	 struct EMSedgebound		to_par,from_par;
	 struct EMSsfintedpar		edge_bdry[2];
	 IGRushort		props;

         edcount = 0;

	 sts = om$get_index(objid_c=my_id,p_chanselect=&to_edges,
			   objid=from_lp_bdry->edgeid,indexaddr=&i1);
	 EMerr_hndlr(!(1&sts),*EMmsg,EMS_E_OMerror,wrapup);
	
	 sts = om$get_index(object_c=me,p_chanselect=&to_edges,
			   objid=to_lp_bdry->edgeid,indexaddr=&i2);
	 EMerr_hndlr(!(1&sts),*EMmsg,EMS_E_OMerror,wrapup);
	
	 sts = om$send(msg=message EMSedge.EMendpts
				(EMmsg,NULL,NULL,NULL,&to_par,NULL),
			targetid = from_lp_bdry->edgeid);
	 EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_EdgeError,wrapup);
	
	 OM_BLOCK_MOVE(from_lp_bdry,edge_bdry,sizeof(struct EMSsfintedpar));
	 OM_BLOCK_MOVE(from_lp_bdry, &edge_bdry[1], 
			sizeof(struct EMSsfintedpar));
	 OM_BLOCK_MOVE(&to_par,&edge_bdry[1].edgepar,
			sizeof(struct EMSedgebound));
	 edge_bdry[0].next = &edge_bdry[1];
	
	 sts = om$send(msg=message EMSedge.EMextractyourself
			(EMmsg,edge_bdry,NULL,1,&ext_edge_ptr,NULL,NULL,
			FALSE, options,NULL,partolbasis),
			targetid = from_lp_bdry->edgeid);
	 EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_EdgeError,wrapup);
	
	 sts = om$send(msg=message Root.connect(to_owners,edcount,
			(*output_obj)[i],OM_Gw_current_OS,to_edges,NULL),
			targetid = ext_edge);
	 EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_OMerror,wrapup);
	 edcount++;

	 /* Decide the index of the edge upto which the extraction is to take
  	 place. If the loop is closed and the extraction is to take place 
	 across the end points then the indices need to be computed as a 
	 special case. But for the general case the index traversal from i1 
	 to i2 is by decrementing i1 (if i1 > i2) or by incrementing i1 (if 
	 i1 < i2). The fact that extraction is across the endpoints of the 
	 loop(which can happen only for closed loops) is detected as follows - 
         1) If the loop is not reversed and i1>i2
         2) If the loop is reversed and i1 < i2.
         A similar situation exists for extraction of closed edges also.
         */
	 to_idx = i2;
	 props = ME.EMSloop->lp_props;
	 if((!(props & EMLP_OPEN))&&(!(props & EMLP_REVERSED))&&(i1 >= i2)) 
	  edidx = (i1 + 1) % count;
	 else if((!(props & EMLP_OPEN))&&(props & EMLP_REVERSED)&&(i1 <= i2))
	  edidx = (i1 - 1 + count) % count ;
	 else edidx = (i1 > i2)? i1 - 1 : i1+1;

	/* Extract all the edges which are between i1 and i2.If a NULL bdry is
        passed to the edge then it will extract itself from begin to end.
	*/
	while(TRUE)
	 {
	  if(edidx==to_idx) break;
	  /* If the whole edge is to be extracted then we can use the
	  same edge and pretend it was extracted. This will be safe
	  to do if the delete_me flag is TRUE because by setting this
	  flag to TRUE, the caller has indicated that he does not care
	  what happens to this edge/loop.
          */
	  if(delete_me)
	   {
	    OMuword	dum_osnum;
	    sts = om$get_objid_at_index(object = me, 
					   p_chanselect = &to_edges, 
					   index = edidx, 
					   objidaddr = ext_edge_ptr, 
					   osnumaddr = &dum_osnum);
	    EMerr_hndlr(!(1&sts), *EMmsg, EMS_E_OMerror, wrapup);
	   }
	  else
	   {
	    sts = om$send(msg=message EMSedge.EMextractyourself
				(EMmsg,NULL,NULL,1,&ext_edge_ptr,NULL,NULL,
				 FALSE, options,NULL,partolbasis),
			p_chanselect=&to_edges,from=edidx,to=edidx);
	    EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_EdgeError,wrapup);
	   }
	  sts = om$send(msg=message Root.connect(to_owners,edcount,
			(*output_obj)[i],OM_Gw_current_OS,to_edges,NULL),
			targetid = ext_edge);
	  EMerr_hndlr(!(1&sts),*EMmsg,EMS_E_OMerror,wrapup);
	  edcount++;

          if((!(props & EMLP_OPEN))&&(!(props & EMLP_REVERSED))&&(i1 >= i2)) 
	       edidx = (edidx + 1) % count;
	  else if((!(props & EMLP_OPEN))&&(props & EMLP_REVERSED)&&(i1<=i2))
	       edidx = (edidx - 1 + count) % count;
	  else edidx = (i1 > i2) ? edidx - 1 : edidx + 1;
	
	 } /* while(TRUE) */

	/* Extract the last edge
	*/
	sts = om$send(msg=message EMSedge.EMendpts
				(EMmsg,NULL,NULL,&from_par,NULL,NULL),
			targetid = to_lp_bdry->edgeid);
	EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_EdgeError,wrapup);
	OM_BLOCK_MOVE(to_lp_bdry,edge_bdry,sizeof(struct EMSsfintedpar));
	OM_BLOCK_MOVE(to_lp_bdry,&edge_bdry[1],sizeof(struct EMSsfintedpar));
	OM_BLOCK_MOVE(&from_par,&edge_bdry[0].edgepar,
			sizeof(struct EMSedgebound));
	edge_bdry[0].next = &edge_bdry[1];
	sts = om$send(msg=message EMSedge.EMextractyourself
			(EMmsg,edge_bdry,NULL,1,&ext_edge_ptr,NULL,NULL,
			 FALSE, options,NULL,partolbasis),
			targetid = to_lp_bdry->edgeid);
	EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_EdgeError,wrapup);
	sts = om$send(msg=message Root.connect(to_owners,edcount,
			(*output_obj)[i],OM_Gw_current_OS,to_edges,NULL),
			targetid = ext_edge);
	EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_OMerror,wrapup);
	edcount++;
	
      } /* else for if(same_edge) */

    } /* else for if(pointloop) */


   /* Send a initialize message to the newly extracted loop.
   * The following properties of the new loop are set same as parent loop-
   * EMLP_NEW, EMLP_ACTIVE. 
   * 
   */
   props = (ME.EMSloop->lp_props & EMLP_ACTIVE)
	     | (ME.EMSloop->lp_props & EMLP_NEW);

   if(pointloop)
     sts = om$send(msg = message EMSgraloop.EMglpinit(EMmsg, props, 
				partolbasis, NULL_OBJID), 
				targetid = (*output_obj)[i]);
   else
     sts = om$send(msg=message EMSloop.EMlpinit
			(EMmsg, props, partolbasis, NULL),
			targetid = (*output_obj)[i]);
   EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_LoopError,wrapup);

   if(out_bdrys) (*out_bdrys)[i] = from_lp_bdry;
   if(against_bdrys) (*against_bdrys)[i] = from_el_bdry;
   if(to_el_bdry) from_el_bdry = to_el_bdry->next;
   if(from_el_bdry) to_el_bdry = from_el_bdry->next;

   if(to_lp_bdry) from_lp_bdry = to_lp_bdry->next;
   if(from_lp_bdry) to_lp_bdry = from_lp_bdry->next;

  } /* for(i=0;i<num_bdrys;i++) */

 if(options & EMImpBnd_MaintainAssoc)
  {
   sts = om$send (msg = message EMSboundary.EMconn_to_myassoc 
               (EMmsg, num_bdrys, *output_obj), targetid = my_id);
   EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_LoopError,wrapup);
  }

 if(delete_me)
  sts = om$send(msg=message Root.delete(TRUE),targetid=my_id);

wrapup:

/****************
   options = sav_options;
****************/

   EMWRAPUP(*EMmsg,sts,"In EMSloop.EMextractyourself");
   return(sts);
}

end implementation EMSloop;
