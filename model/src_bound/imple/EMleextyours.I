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
 parent is.

ASSUMPTION
        Input boundaries are in pairs representing positive parts of the 
 edge.


HISTORY
21-Sep-88   SM  If extracting the whole edge and 'delete' option is TRUE
		then return the same edgeid instead of actually
		extracting.
15_Aug_88   RC  Extract the whole edge if the input is one boundary
                which spans over the entire edge.
08-DEC-87   SM  Setting of correct curve_types.
31-Oct-87   SM  Modified to send curve type to EMleinit method.
23-Oct-1987 jBk EMED_NONMODIFIABLE removed.  Bit never used.
25-Sep-1987 SS  If this is a model-space edge, then the extracted
                pieces are connected to this edge's associations.
                Also these pieces are generated as part-edges so
                long as they do not span across common end-points
                (closed edges).
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

class implementation EMSlinedge;

#include "EMS.h"
#include "emssfint.h"
#include "OMmacros.h"
#include "emsdef.h"
#include "emsinter.h"
#include "emsedgedef.h"
#include "emsimpdef.h"

#if DEBUG
#define POINTS_BUF	2
#define BUF_NUM_POINTS	1
#else
#define POINTS_BUF	100
#define BUF_NUM_POINTS	50
#endif

extern OMuword  OPP_EMSlinedge_class_id, OPP_EMSpartedge_class_id;

from EMSpartedge import EMpeinit;

method EMextractyourself(IGRlong *EMmsg;
                         struct EMSsfintedpar *my_bdrys,*ele_bdrys;
                         IGRint num_bdrys;GRobjid **output_obj;
                         struct EMSsfintedpar ***out_bdrys,***against_bdrys;
                         IGRboolean output_pairs;
                         IGRushort options;struct EMSpartedinfo *bnd;
                         struct EMSpartolbasis *partolbasis)
{
        IGRlong                sts;
        struct IGRpolyline     poly,temp_poly;
        struct EMSpartedinfo   part;
        IGRint                  i;
        OMuint                 count;
        IGRushort       props,user_props;
        struct EMSedgebound     bound[2];
        OM_S_CHANSELECT         to_owner, to_edge;
	IGRuchar	user_curve_type = EMlinestring, 
				new_curve_type = EMlinestring;
	IGRlong			EFget_clipped_edge_type();
	IGRboolean		delete_me, whole_edge = FALSE, 
				same_edge_used = FALSE;
	IGRdouble		static_buf[POINTS_BUF];
	
   *EMmsg = EMS_S_Success;
   sts = OM_S_SUCCESS;
   poly.num_points = 0;
   poly.points = static_buf;

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


/* The maximum number of points in any extracted polyline will be the 
   number of points in the edge plus one. So malloc space once only.
   This space will be used over and over again for every boundary that is
   extracted. Malloc only if static buffer is not large enough.
*/
   if( (ME.EMSlinedge->num_points + 1) > BUF_NUM_POINTS)
     poly.points = (IGRdouble *) om$malloc(size=(ME.EMSlinedge->num_points+1) *
                                        2*sizeof(IGRdouble));
   EMerr_hndlr(!poly.points,*EMmsg,EMS_E_DynamicMemoryAllocated,wrapup);

   if(bnd)
    {
      OM_BLOCK_MOVE(bnd,&part,sizeof(struct EMSpartedinfo));
      OM_BLOCK_MOVE(bnd->edbdry,bound,2*sizeof(struct EMSedgebound));
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
                        bound,&bound[1],NULL),
                        targetid = my_id);
      EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_EdgeError,wrapup);
      OM_BLOCK_MOVE(bound,part.edbdry,2*sizeof(struct EMSedgebound));
    }

/* The following properties of the extracted edges are kept same as the
   parent edge, 
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

/* If this edge is a model-space edge the following channels will be used
*/
   if (user_props & EMED_XYZ)
    {
      sts = EMmake_chanselect (EMSedge_to_owner, &to_owner);
      EMerr_hndlr (!(1&sts), *EMmsg, EMS_E_OMerror, wrapup);

      sts = EMmake_chanselect (EMSbd_owner_to_comps, &to_edge);
      EMerr_hndlr (!(1&sts), *EMmsg, EMS_E_OMerror, wrapup);
    }


/* If there are no boundary pairs passed in or only one boundary is
   passed which spans over the whole edge, then extract the whole edge.
   The curve_type of the new edge is same as the parent edge.
*/
   if(whole_edge)
    {
      if (! (user_props & EMED_XYZ))
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
                        (EMmsg, props, user_curve_type, &poly, partolbasis,
			 NULL, NULL_OBJID));
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
                (EMmsg, props, bound, user_curve_type));
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
      struct EMSsfintedpar      *ed_from,*ed_to,*ele_from,*ele_to;
      IGRdouble                 check_from, check_to;

      /* Since part of the edge is being extracted, decide the clipped
	 edge type based on the parent edge type.
      */
      if(!whole_edge)
       {
        sts = EFget_clipped_edge_type(EMmsg, user_curve_type, &new_curve_type);
        EMerr_hndlr(!(1&*EMmsg&sts), *EMmsg, EMS_E_Fail, wrapup);
       }
      else new_curve_type = user_curve_type;

      ed_from = my_bdrys;
      ed_to = ed_from->next;
      if(output_pairs)
       {
        ele_from = ele_bdrys;
        ele_to = ele_from->next;
       }

      for(i=0;i<num_bdrys;i++)
       {

          poly.num_points = 0;

/* If the edge is closed and the boundary to be extracted extends across
   the coincedent endpoints, then the two peices are extracted seperately
   and appended to form the total geometry. This is true even for model-space
   edges.
*/
          check_from = ed_from->edgepar.span_inx + ed_from->edgepar.param;
          check_to = ed_to->edgepar.span_inx + ed_to->edgepar.param;
          
          if( ((!(user_props & EMED_OPEN)) && (!(user_props & EMED_REVERSED))
              && (check_from > check_to)) 
           ||
              ((!(user_props & EMED_OPEN)) && (user_props & EMED_REVERSED)
                   && (check_from < check_to))
            )
           {
             OM_BLOCK_MOVE(&ed_from->edgepar,&part.edbdry[0],
                                        sizeof(struct EMSedgebound));
             OM_BLOCK_MOVE(&bound[1],&part.edbdry[1],
                                        sizeof(struct EMSedgebound));
             sts = om$send(msg=message EMSedge.EMgetpygeom
                        (EMmsg,0,MAXINT,FALSE,&part,&poly, 
                         partolbasis, NULL),targetid = my_id);
             EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_EdgeError,wrapup);

/* The end point of the first piece and the begin point of the next peice
        will be same points. So use that point only once in the total
        appended geometry.
*/
             poly.num_points--;
             temp_poly.num_points = 0;
             temp_poly.points = &poly.points[2*poly.num_points];
             OM_BLOCK_MOVE(bound,&part.edbdry[0],sizeof(struct EMSedgebound));
             OM_BLOCK_MOVE(&ed_to->edgepar,&part.edbdry[1],
                                        sizeof(struct EMSedgebound));
             sts = om$send(msg=message EMSedge.EMgetpygeom
                        (EMmsg,0,MAXINT,FALSE,&part,&temp_poly,
                         partolbasis, NULL),
                                                targetid = my_id);
             EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_EdgeError,wrapup);
             poly.num_points += temp_poly.num_points;

             sts = om$construct(classid=OPP_EMSlinedge_class_id,
                             p_objid=&(*output_obj)[i],
                        msg=message EMSlinedge.EMleinit
                                (EMmsg, props, new_curve_type, &poly,
				 partolbasis,NULL, NULL_OBJID));
             EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_EdgeError,wrapup);
           }
          else
           {
             OM_BLOCK_MOVE(&ed_from->edgepar,&part.edbdry[0],
                                sizeof(struct EMSedgebound));
             OM_BLOCK_MOVE(&ed_to->edgepar,&part.edbdry[1],
                                sizeof(struct EMSedgebound));

             if (! (user_props & EMED_XYZ))
              {
                sts = om$send(msg=message EMSedge.EMgetpygeom
                        (EMmsg,0,MAXINT,FALSE,&part,&poly,partolbasis,
NULL),
                        targetid = my_id);
                EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_EdgeError,wrapup);
                sts = om$construct(classid=OPP_EMSlinedge_class_id,
                             p_objid=&(*output_obj)[i],
                        msg=message EMSlinedge.EMleinit
                                (EMmsg,props, new_curve_type, &poly,
				 partolbasis,NULL, NULL_OBJID));
                EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_EdgeError,wrapup);
              }
             else
              {
                /*
                 * This edge is a model-space edge. Construct a part-edge
                 * with the correct boundaries.
                 */

                if (check_from > check_to)
                  props |= EMED_REVERSED;
                sts = om$construct (classid = OPP_EMSpartedge_class_id, 
                       p_objid = &(*output_obj)[i], 
                       msg = message EMSpartedge.EMpeinit (EMmsg, props,
                       part.edbdry, new_curve_type));
                EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_EdgeError,wrapup);

                sts = om$get_channel_count (objid = part.edid, 
                       p_chanselect = &to_owner, count = &count);
                EMerr_hndlr (!(1&sts), *EMmsg, EMS_E_OMerror, wrapup);

                sts = om$send (msg = message Root.connect (to_edge, count,
                       part.edid, OM_Gw_current_OS, to_owner, NULL), 
                       senderid = part.edid, targetid = (*output_obj)[i]);
                EMerr_hndlr (!(1&sts), *EMmsg, EMS_E_OMerror, wrapup);
              }
           }

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

     if ( (user_props & EMED_XYZ) && !same_edge_used)
      {
        sts = om$send (msg = message EMSedge.EMconn_to_myassoc 
               (EMmsg, num_bdrys, *output_obj), targetid = my_id);
        EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_EdgeError,wrapup);
      }
    }

  if( (options & EMImpBnd_MaintainAssoc) && !same_edge_used)
   {
    sts = om$send (msg = message EMSedge.EMconn_to_myassoc 
               (EMmsg, num_bdrys, *output_obj), targetid = part.edid);
    EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_EdgeError,wrapup);
   }

  if(delete_me && !same_edge_used)
     sts = om$send(msg=message Root.delete(TRUE),targetid=part.edid);

wrapup:
   if( poly.points && (poly.points != static_buf)) om$dealloc(ptr=poly.points);

   EMWRAPUP(*EMmsg,sts,"In EMSlinedge.EMextractyourself");
   return(sts);
}

end implementation EMSlinedge;

