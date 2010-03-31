/* ###################   APOGEE COMPILED   ################## */
/*
NOTES
        This method extracts the positive parts of an edge and constructs
 new edges out of them. The positive parts are represented by pairs of
 boundary parameters and are passed in as a linked list. If a NULL is
 passed then the entire edge is extracted into the new object(i.e a copy
 is made). The new edges formed are always full edges(even if the
 extraction took place on the part edge).Also none of the new edges are
 reversed because the extraction of the geometry for their creation takes
 place in the direction of the original edge. So all the extracted edges
 have same direction as the parent but none are reversed even if the 
 parant is.

ASSUMPTION
        Input boundaries are in pairs representing positive parts of the 
 edge.


HISTORY
22-Dec-93 ashok Modified so that EMED_ISO property bit is set for
		the extracted edge of class EMSlinedge.
01-Sep-93 ashok Modified so that EMED_NATURAL property bit is not set for
		the extracted edge of class EMSlinedge.
		Also took care of some "uninitialized variable" compilation
		warnings.
21-Sep-88   SM  If extracting the whole edge and 'delete' option is TRUE
		then return the same edgeid instead of actually
		extracting.
15_Aug_88   RC  Extract the whole edge if the input is one boundary
                which spans over the entire edge.
31-Oct-87   SM  Modified to send curve type to EMleinit method.
23-Oct-1987 jBk EMED_NONMODIFIABLE removed.  Bit never used.
25-Sep-1987 SS  If this is a model-space edge, then the extracted
                pieces are connected to this edge's associations.
24-Mar-1987 SM  Creation date.

ALGORITHM
        If NULL boundary is passed in extract the whole edge and return.
        Else for each pair -
         {
           If a partedgeinfo structure is passed in (meaning a partedge
             is actually being extracted), copy it into a local structure
             else put my info in the local structure.
           Put the two parameters in the boundary pair into the local
             structure.
           Extract the entire geometry between the two parameters of the 
            boundary pair.
           Create a linedge with this geometry and put it in the output 
            list.
         }
*/

class implementation EMSnatedge;

#include "EMS.h"
#include "emssfint.h"
#include "emsinter.h"
#include "OMmacros.h"
#include "emsdef.h"
#include "emsedgedef.h"
#include "emsimpdef.h"

extern OMuword  OPP_EMSlinedge_class_id;

from EMSlinedge import EMleinit;

method EMextractyourself(IGRlong *EMmsg;
                         struct EMSsfintedpar *my_bdrys,*ele_bdrys;
                         IGRint num_bdrys;GRobjid **output_obj;
                         struct EMSsfintedpar ***out_bdrys,***against_bdrys;
                         IGRboolean output_pairs;
                         IGRushort options;struct EMSpartedinfo *bnd;
                         struct EMSpartolbasis *partolbasis)
{
         IGRlong                sts;
         struct IGRpolyline     poly;
         struct EMSpartedinfo   part;
         void                   EMnatpoints();
         IGRdouble              points[4];
         IGRint                 i;
         IGRushort      props, user_props;
	 IGRboolean		delete_me, whole_edge = FALSE, 
				same_edge_used = FALSE;
	 IGRuchar	user_curve_type = EMlinestring, 
				new_curve_type = EMlinestring;
	 IGRlong		EFget_clipped_edge_type();
	
   *EMmsg = EMS_S_Success;
   sts = OM_S_SUCCESS;

   delete_me = options & EMImpBnd_NoInputDelete ? FALSE : TRUE;

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

/* The maximum number of points in the polyline will be the number of my
   points. So allocate it once only.
*/
   poly.num_points = 2;
   poly.points = &points[0];

   if(bnd)
    {
     OM_BLOCK_MOVE(bnd,&part,sizeof(struct EMSpartedinfo));
     user_props = bnd->edprops;
     user_curve_type = bnd->edtype;
    }
   else
    {
      part.edid = my_id;
      part.edprops = ME.EMSedge->ed_props;
      user_props = ME.EMSedge->ed_props;
      user_curve_type = ME.EMSedge->curve_type;
      sts = om$send(msg=message EMSedge.EMendpts(EMmsg,NULL,NULL,
                        &part.edbdry[0],&part.edbdry[1],NULL),
                        targetid = my_id);
      EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_EdgeError,wrapup);
    }

/* The following properties of the extracted edges are kept same as the
   parent edge.
   If the parent edge was open , then the extracted edges are also definately
   open.
   The extracted edges are NOT reversed even if the parent is.
*/
/*   props = EMED_NATURAL | (user_props & EMED_OPEN) |  - Ashok 1/sep/93 */
     props = EMED_ISO | (user_props & EMED_OPEN) |
           (user_props & EMED_DEGENERATE) |
	   (user_props & EMED_ISO) |
	   (user_props & EMED_XYZ);
	
   if(!my_bdrys) whole_edge = TRUE;
   else if(my_bdrys && (num_bdrys == 1) && (my_bdrys->intloc== EMScvint_lfend) 
      && (my_bdrys->next->intloc == EMScvint_rtend))
	whole_edge = TRUE;
	
   if(whole_edge)
    props |= user_props & EMED_XYZ_CLOSED;

/* If there are no boundary pairs passed or one pair is passed in which
   spans over the whole edge(RC), then extract the whole edge
*/
   if(whole_edge)
    {
     if(delete_me)
      {
       (*output_obj)[0] = part.edid;
       same_edge_used = TRUE;
      }
     else
      {
       sts = om$send(msg=message EMSedge.EMgetpygeom
                     (EMmsg,0,MAXINT,FALSE,&part,&poly, partolbasis, NULL),
                targetid = my_id);
       EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_EdgeError,wrapup);
       sts = om$construct(classid=OPP_EMSlinedge_class_id,
                         p_objid=*output_obj,msg=message EMSlinedge.EMleinit
               (EMmsg, props, user_curve_type, &poly, partolbasis,NULL, 
		NULL_OBJID));
       EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_EdgeError,wrapup);
      }

      /*
       * If this edge is a model-space edge, connect it's extracted piece
       * to the associations of this edge.
       */

      if ( (user_props & EMED_XYZ) && (!same_edge_used))
        {
        sts = om$send (msg = message EMSedge.EMconn_to_myassoc (EMmsg,
               1, *output_obj), targetid = my_id);
        EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_EdgeError,wrapup);
        }
    }
   else
    {
      struct EMSsfintedpar      *ed_from,*ed_to,*ele_from=NULL,*ele_to=NULL;

      /* Since part of the edge is being extracted, decide the clipped
	 edge type based on the parent edge type.
      */
      
      sts = EFget_clipped_edge_type(EMmsg, user_curve_type, &new_curve_type);
      EMerr_hndlr(!(1&*EMmsg&sts), *EMmsg, EMS_E_Fail, wrapup);

      ed_from = my_bdrys;
      ed_to = ed_from->next;
      if(output_pairs)
       {
         ele_from = ele_bdrys;
         ele_to = ele_from->next;
       }

      for(i=0;i<num_bdrys;i++)
       {
          OM_BLOCK_MOVE(&ed_from->edgepar,&part.edbdry[0],
                                sizeof(struct EMSedgebound));
          OM_BLOCK_MOVE(&ed_to->edgepar,&part.edbdry[1],
                                sizeof(struct EMSedgebound));

          poly.num_points = 0;
          sts = om$send(msg=message EMSedge.EMgetpygeom
                        (EMmsg,0,MAXINT,FALSE,&part,&poly, partolbasis, NULL),
                        targetid = my_id);
          EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_EdgeError,wrapup);
          sts = om$construct(classid=OPP_EMSlinedge_class_id,
                             p_objid=&(*output_obj)[i],
                        msg=message EMSlinedge.EMleinit
                      (EMmsg, props, new_curve_type, &poly, partolbasis,NULL, 
			NULL_OBJID));
          EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_EdgeError,wrapup);
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

    if ( (user_props & EMED_XYZ) && (!same_edge_used))
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
   EMWRAPUP(*EMmsg,sts,"In EMSnatedge.EMextractyourself");
   return(sts);
}

end implementation EMSnatedge;

