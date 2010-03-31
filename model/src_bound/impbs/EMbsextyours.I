/* ###################   APOGEE COMPILED   ################## */
/*
HISTORY

21-Sep-88   SM  If extracting the whole edge and 'delete' option is TRUE
		then return the same edgeid instead of actually
		extracting.
15_Aug_88   RC  Extract the whole edge if the input is one boundary
                which spans over the entire edge.
08-Dec-87   SM  Setting edge type when partedge is constructed.
12/02/87    PP  Made changes to handle setting of edge types correctly
23-Oct-1987 jBk EMED_NONMODIFIABLE removed.  Bit never used.
25-Sep-1987 SS  If this is a model-space edge, then the extracted
                pieces are connected to this edge's associations.
                Also these pieces are generated as part-edges so
                long as they do not span across common end-points
                (closed edges).
circa Jan 1987  Unbeknownst to us, creation.
Sudha 06/04/93  modified to include BSprototype header files
*/

class implementation EMSbsedge;

#include "EMS.h"
#include "OMmacros.h"
#include "emsdef.h"
#include "bserr.h"
#include "bsparameters.h"
#include "emssfint.h"
#include "emsinter.h"
#include "emsedgedef.h"
#include "emsimpdef.h"
#include "bschgdeppar.h"

extern OMuword	OPP_EMSbsedge_class_id, OPP_EMSpartedge_class_id;

from EMSpartedge import EMpeinit;

method EMextractyourself(IGRlong *EMmsg;
			 struct EMSsfintedpar *my_bdrys, *ele_bdrys;
			 IGRint num_bdrys;GRobjid **output_obj;
			 struct EMSsfintedpar ***out_bdrys,***against_bdrys;
			 IGRboolean output_pairs;
			 IGRushort options;struct EMSpartedinfo *bnd;
			 struct EMSpartolbasis *partolbasis)


{
	 IGRlong		sts;
         IGRdouble		basis_tol;
         GRobjid		dumid;
         OMuint 		count;
         IGRlong		rc;
         struct IGRbsp_curve    bcgeom;
	 struct EMSpartedinfo	part;
	IGRint			i;
	IGRushort	props = NULL, user_props = NULL;
        IGRuchar        user_type;
	struct EMSedgebound	bound[2];
        OM_S_CHANSELECT		to_owner, to_edge;
        IGRlong			EFget_clipped_edge_type();
	IGRboolean		delete_me, whole_edge = FALSE, 
				same_edge_used = FALSE;
   *EMmsg = EMS_S_Success;
   sts = OM_S_SUCCESS;
   bcgeom.poles = NULL;
   bcgeom.weights = NULL;
   bcgeom.bdrys = NULL;
   bcgeom.knots = NULL;
   delete_me = options & EMImpBnd_NoInputDelete ? FALSE : TRUE;

   sts = BSEXTRACTPAR (&rc, BSTOLBASIS, basis_tol);

   if (!partolbasis->is_valid)
   {
     sts = om$send (msg = message EMSboundary.EMgetsurface_info (EMmsg,
                             &dumid, partolbasis),
                       targetid = my_id);
     EMerr_hndlr (!(1&sts&*EMmsg), *EMmsg,EMS_E_EdgeError, wrapup);
   }
     
   BSchgdeppar (partolbasis->tol, &rc);

   if(!(*output_obj))
	*output_obj = (GRobjid *) om$malloc(size=num_bdrys*sizeof(GRobjid));
   EMerr_hndlr(!*output_obj,*EMmsg,EMS_E_DynamicMemoryAllocated,wrapup);
  if(output_pairs)
   {
    if(!(*out_bdrys))
      *out_bdrys = (struct EMSsfintedpar **) om$malloc(size=num_bdrys*
				sizeof(struct EMSsfintedpar *));
    EMerr_hndlr(!*out_bdrys,*EMmsg,EMS_E_DynamicMemoryAllocated,wrapup);
    if(!(*against_bdrys))
      *against_bdrys = (struct EMSsfintedpar **) om$malloc(size=num_bdrys*
				sizeof(struct EMSsfintedpar *));
    EMerr_hndlr(!*against_bdrys,*EMmsg,EMS_E_DynamicMemoryAllocated,wrapup);
  }


   if(bnd)
    {
      OM_BLOCK_MOVE(bnd,&part,sizeof(struct EMSpartedinfo));
      OM_BLOCK_MOVE(bnd->edbdry,bound,2*sizeof(struct EMSedgebound));
      user_props = bnd->edprops;
      user_type = bnd->edtype;
    }
   else
    {
      part.edid = my_id;
      part.edprops = ME.EMSedge->ed_props;
      user_props = ME.EMSedge->ed_props;
      user_type = ME.EMSedge->curve_type;
      sts = om$send(msg=message EMSedge.EMendpts(EMmsg,NULL,NULL,
			bound,&bound[1],NULL),
			targetid = my_id);
      EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_EdgeError,wrapup);
      OM_BLOCK_MOVE(bound,part.edbdry,2*sizeof(struct EMSedgebound));
    }

/* The following properties of the extracted edges are kept same as the
   parent edge.
   If the parent edge was open , then the extracted edges are also definately
   open.
   The extracted edges are NOT reversed even if the parent is.
*/
   props = (user_props & EMED_OPEN) |
           (user_props & EMED_DEGENERATE) |
           (user_props & EMED_XYZ) |
	   (user_props & EMED_ISO);
   
   if(!my_bdrys) whole_edge = TRUE;
   else if(my_bdrys && (num_bdrys == 1) && (my_bdrys->intloc== EMScvint_lfend) 
      && (my_bdrys->next->intloc == EMScvint_rtend))
	whole_edge = TRUE;
	
   if(whole_edge)
    props |= user_props & EMED_XYZ_CLOSED;

/* If this edge is a model-space edge the followin channels will be used
*/
   if (ME.EMSedge->ed_props & EMED_XYZ)
    {
      sts = EMmake_chanselect (EMSedge_to_owner, &to_owner);
      EMerr_hndlr (!(1&sts), *EMmsg, EMS_E_OMerror, wrapup);

      sts = EMmake_chanselect (EMSbd_owner_to_comps, &to_edge);
      EMerr_hndlr (!(1&sts), *EMmsg, EMS_E_OMerror, wrapup);
    }

/* If there are no boundary pairs passed in or there is only one 
 * boundary passed in and it spans over the whole edge, then extract 
 * the whole edge.
*/
   if(whole_edge)
    {
      if (! (ME.EMSedge->ed_props & EMED_XYZ))
       {
	if(delete_me)
	 {
	   (*output_obj)[0] = part.edid;
	   same_edge_used = TRUE;
	 }
	else
	 {
          sts = om$send(msg=message EMSedge.EMgetbcgeom
			(EMmsg,0,1,FALSE,&part,&bcgeom, partolbasis, NULL),
		targetid = my_id);
          EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_EdgeError,wrapup);
          sts = om$construct(classid=OPP_EMSbsedge_class_id,
 			 p_objid=*output_obj,msg=message EMSbsedge.EMbsinit
		(EMmsg, props, user_type, &bcgeom, partolbasis));
          EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_EdgeError,wrapup);
	 }
	
       }
      else
       {
         /*
          * If this edge is a model-space edge, construct a part-edge with
          * boundaries spanning the entire edge. Also connect this new
          * part edge to my associatations.
          */

         if (part.edprops & EMED_REVERSED)
           props |= EMED_REVERSED;
         sts = om$construct (classid = OPP_EMSpartedge_class_id, 
                p_objid = *output_obj, msg = message EMSpartedge.EMpeinit
                (EMmsg, props, bound, user_type));
         EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_EdgeError,wrapup);

         sts = om$get_channel_count (objid = part.edid, 
                p_chanselect = &to_owner, count = &count);
         EMerr_hndlr (!(1&sts), *EMmsg, EMS_E_OMerror, wrapup);

         sts = om$send (msg = message Root.connect (to_edge, count, part.edid,
                OM_Gw_current_OS, to_owner, NULL), senderid = part.edid,
                targetid = (*output_obj)[0]);
         EMerr_hndlr (!(1&sts), *EMmsg, EMS_E_OMerror, wrapup);

         sts = om$send (msg = message EMSedge.EMconn_to_myassoc (EMmsg,
                1, *output_obj), targetid = part.edid);
         EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_EdgeError,wrapup);
       }
    }
   else
    {
      struct EMSsfintedpar	*ed_from, *ed_to, *ele_from, *ele_to;
      IGRuchar child_edgetype; /* edge type of the 
                                          extracted edge */

      ed_from = my_bdrys;
      ed_to = ed_from->next;
      if(output_pairs)
       {
        ele_from = ele_bdrys;
        ele_to = ele_from->next;
       }

      sts = EFget_clipped_edge_type(EMmsg, user_type, &child_edgetype);
      EMerr_hndlr (!(1&sts&*EMmsg), *EMmsg, *EMmsg, wrapup);

      for(i=0;i<num_bdrys;i++)
       {
	  if( ((!(user_props & EMED_OPEN)) && (!(user_props & EMED_REVERSED))
	      && (ed_from->edgepar.param > ed_to->edgepar.param)) 
	   ||
	      ((!(user_props & EMED_OPEN)) && (user_props & EMED_REVERSED)
		   && (ed_from->edgepar.param < ed_to->edgepar.param))
	    )
	   {
	     OM_BLOCK_MOVE(&ed_from->edgepar,&part.edbdry[0],
					sizeof(struct EMSedgebound));
	     OM_BLOCK_MOVE(&ed_to->edgepar,&part.edbdry[1],
					sizeof(struct EMSedgebound));
             }
           else
            {
	     OM_BLOCK_MOVE(&ed_from->edgepar,&part.edbdry[0],
				sizeof(struct EMSedgebound));
	     OM_BLOCK_MOVE(&ed_to->edgepar,&part.edbdry[1],
				sizeof(struct EMSedgebound));
             }

           if (! (ME.EMSedge->ed_props & EMED_XYZ))
             {
	     sts = om$send(msg=message EMSedge.EMgetbcgeom
			(EMmsg,0,1,FALSE,&part,&bcgeom, partolbasis, NULL),
			targetid = my_id);
	     EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_EdgeError,wrapup);

	     sts = om$construct(classid=OPP_EMSbsedge_class_id,
			     p_objid=&(*output_obj)[i],
			msg=message EMSbsedge.EMbsinit
				(EMmsg,props,child_edgetype,
                                 &bcgeom,partolbasis));
	     EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_EdgeError,wrapup);
             }
           else
             {
             /*
              * This edge is a model-space edge. Construct a part-edge
              * with the correct boundaries.
              */

             if (ed_from->edgepar.span_inx + ed_from->edgepar.param >
                 ed_to->edgepar.span_inx + ed_to->edgepar.param)
               props |= EMED_REVERSED;
             sts = om$construct (classid = OPP_EMSpartedge_class_id, 
                    p_objid = &(*output_obj)[i], 
                    msg = message EMSpartedge.EMpeinit (EMmsg, props,
                    part.edbdry, child_edgetype));
             EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_EdgeError,wrapup);

             sts = om$get_channel_count (objid = part.edid, 
                    p_chanselect = &to_owner, count = &count);
             EMerr_hndlr (!(1&sts), *EMmsg, EMS_E_OMerror, wrapup);

             sts = om$send (msg = message Root.connect (to_edge, count,
                    part.edid, OM_Gw_current_OS, to_owner, NULL), 
                    senderid = part.edid, targetid = (*output_obj)[i]);
             EMerr_hndlr (!(1&sts), *EMmsg, EMS_E_OMerror, wrapup);
             }


             /* 
                We can use the same memory region allocated by getbcgeom
                again and again for all the boundaries. 
              */
	  if(output_pairs)
	   {
	    (*out_bdrys)[i] = ed_from;
	    (*against_bdrys)[i] = ele_from;
	    if(ele_to) ele_from = ele_to->next;
	    if(ele_from) ele_to = ele_from->next;
	   }
	  if(ed_to) ed_from = ed_to->next;
	  if(ed_from) ed_to = ed_from->next;
       }

       /*
        * If this edge is a model-space edge, connect the extracted pieces
        * to the associations of this edge.
        */

       if ( (ME.EMSedge->ed_props & EMED_XYZ) && (!same_edge_used))
         {
         sts = om$send (msg = message EMSedge.EMconn_to_myassoc 
                (EMmsg, num_bdrys, *output_obj), targetid = my_id);
         EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_EdgeError,wrapup);
         }
      }

  if( (options & EMImpBnd_MaintainAssoc) && (!same_edge_used))
   {
    sts = om$send (msg = message EMSedge.EMconn_to_myassoc 
               (EMmsg, num_bdrys, *output_obj), targetid = part.edid);
    EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_EdgeError,wrapup);
   }

  if(delete_me && (!same_edge_used))
     sts = om$send(msg=message Root.delete(TRUE),targetid=part.edid);

wrapup:
   BSchgdeppar (basis_tol, &rc);

   if (bcgeom.poles) om$dealloc (ptr = bcgeom.poles);
   if (bcgeom.knots) om$dealloc (ptr = bcgeom.knots);
   if (bcgeom.weights) om$dealloc (ptr = bcgeom.weights);
   if (bcgeom.bdrys) om$dealloc (ptr = bcgeom.bdrys);

   EMWRAPUP(*EMmsg,sts,"In EMSbsedge.EMextractyourself");
   return(sts);
}

end implementation EMSbsedge;

