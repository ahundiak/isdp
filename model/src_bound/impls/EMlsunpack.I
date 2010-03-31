/* ###################   APOGEE COMPILED   ################## */
/*
Notes
	This method accepts a set of valid boundary points and creates a valid
	loopset out of them.

	If any of the boundaries is invalid then a model space
	linestring is constructed for it. If the objids of such linestrings
	is desired to be returned then the space for the same should be 
	allocated by the caller and a non-NULL pointer should be passed
	in. The maximum number will be num_bdrys.
	An invalid boundary is -
	1) Which is open.
	2) Which self intersects or has self overlaps.
	3) Which has a single point.
	4) Which has two points within tolerance.
History
	SM	08/28/87	Design and creation.
        rlw     05/03/89        Modified not to die on boundaries with no
                                points.
*/

class implementation EMSloopset;

#include "EMS.h"

#define DEBUG 0

#include "OMmacros.h"		/* IF_EQ_OBJID */
#include "emsmacros.h"		/* EM2dbxinc */
#include "msdef.h"		/* MSSUCC */
#include "bserr.h"		/* BSSUCC, BSINARG */
#include "bsparameters.h"	/* BSTOLLENVEC */
#include "emsinter.h"		/* enum EMScvinttype */
#include "emsdef.h"
#include "EMSopt.h"
#include "emsedgedef.h"		/* curve type definitions */
#include "emsimpdef.h"

#if DEBUG
#include <stdio.h>
#endif

from EMSloop import EMlpinit, EMgivenestinfo, EMtreemod, EMget_props;
from EMSloop import EMget_loops;
from EMSlinedge import EMleinit;
from EMSloop import EMtoggle_type;

extern OMuword OPP_EMSloop_class_id, OPP_EMSlinedge_class_id;
extern OMuword OPP_EMSloopset_class_id;


static IGRint EMis_bdry_good(EMmsg, bdry, good, const_list, partol, surface, 
			     linestr_id)
IGRlong			*EMmsg;
struct IGRbsp_bdry_pts	*bdry;
IGRboolean		*good;
struct GRvg_construct	*const_list;
IGRdouble		partol;
struct IGRbsp_surface	*surface;
GRobjid			*linestr_id;
{
  IGRlong		sts, rc;
  IGRint		num_pts, num_segs, i, j;
  IGRdouble		pars1[2], pars2[2], box[4], *xyz_points;
  IGRboolean		EF2dpyint(), int_found, 
			EFplace_line_string(), closed;
  enum EMScvinttype	type1, type2;
  void			EM2dbx();
  IGRdouble		points[2][2], lentol;
  IGRboolean		self_inter, degenerate;

  sts = OM_S_SUCCESS;
  *EMmsg = EMS_S_Success;
  sts = EFextract_par(BSTOLLENVEC,partol,&lentol,&rc);
  
  num_pts = bdry->num_points;
  num_segs = num_pts - 1;
  *good = TRUE;
  xyz_points = NULL;
  *linestr_id = NULL_OBJID;		/* rlw 05/03/89 */
  *good = num_pts > 1;
  
  degenerate = FALSE;
  self_inter = FALSE;
  
/* Is the boundary closed ? If not it is bad.
*/
  closed = FALSE;

  if(*good)
   {
     closed = EM2ddistptpt(bdry->points,&bdry->points[num_pts*2 - 2]) 
		< lentol;

     if(!closed) *good = FALSE;
   }

/* If the boundary is degenerate, it is bad.
*/
  if(*good && closed && (num_pts == 2)) {*good = FALSE; degenerate = TRUE;}
	
/* If the boundary has self intersections or self-overlaps, it is bad.
*/
  for(i=0; ((i<(num_segs -1)*2) && *good); i+=2)  
   {
     EM2dbx(2, &bdry->points[i], box);
     EM2dbxinc(box, lentol);
     for(j= i+2; ( (j < num_segs *2) && *good); j+=2)
      {
	if(EM2dsegbxint(&bdry->points[j], box))
	 {
	   int_found = EF2dpyint(&lentol,&bdry->points[i], &bdry->points[i+2], 
			 &bdry->points[j], &bdry->points[j+2], &type2, pars2, 
			   &type1, pars1, points, EMmsg);
	   EMerr_hndlr(*EMmsg!=MSSUCC, *EMmsg, EMS_E_Fail, wrapup);
	   if(int_found)
	    {
	      /* If the two segments intersect each other in the middle
	         (of both) or if they overlap each other, then we
	         scream.
	      */
	      if( ((type1 == EMScvint_middle) && (type2 == EMScvint_middle)) 
		  || (type1 == EMScvint_overlap) || (type2 == EMScvint_overlap)
		 )
	         { *good = FALSE; self_inter = TRUE;}
	
	    } /* if(int_found) */
	
	 } /* if(EM2dsegbxint(&bdry->points[j], box)) */
	
      } /* for(j= i+2; ( (j < num_segs) && *good); j+=2) */

   }  /* for(i=0;i < ( (num_segs -1) && *good); i+=2)  */


/* If this boundary was bad then output it as a linestring
*/

  if((!(*good)) && num_pts)         /* rlw 05/03/89 added "&& num_pnts" */
   {
     IGRuchar	old_weight;
  extern      void		BSsfptseval();
     IGRlong		rc;
     IGRchar		*save_geom;

     xyz_points = (IGRdouble *) om$malloc(size = sizeof(IGRpoint) * num_pts);
     EMerr_hndlr(!xyz_points, *EMmsg, EMS_E_NoDynamicMemory, wrapup);
     BSsfptseval(
		 surface, 
		 num_pts, 
		 bdry->points, 
		 xyz_points, 
		 &rc);
/* If some of the borderline points occured then move them and try
   again.
*/
     if(rc == BSINARG)
      {
	IGRdouble	u_low, u_hig, v_low, v_hig, *pts;
	IGRint		k;
	
	u_low = surface->u_knots[surface->u_order - 1];
 	u_hig = surface->u_knots[surface->u_num_poles];
 	v_low = surface->v_knots[surface->v_order - 1];
 	v_hig = surface->v_knots[surface->v_num_poles];
	pts = (IGRdouble *) bdry->points;
	for(k=0; k<2*num_pts;k+=2)
	 {
	   if(pts[k] < u_low) pts[k] = u_low;
	   else if(pts[k] > u_hig) pts[k] = u_hig;

	   if(pts[k+1] < v_low) pts[k+1] = v_low;
	   else if(pts[k+1] > v_hig) pts[k+1] = v_hig;
	 }
	
         BSsfptseval(
		 surface, 
		 num_pts, 
		 bdry->points, 
		 xyz_points, 
		 &rc);
       }
  
     EMerr_hndlr(rc != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);
     old_weight = const_list->display->weight;
     const_list->display->weight = 3;
     save_geom = (IGRchar *) const_list->geometry;
     sts = EFplace_line_string(NULL_OBJID, const_list, num_pts, xyz_points, 
				linestr_id, EMmsg);
     EMerr_hndlr(!(1&*EMmsg&sts), *EMmsg, EMS_E_Fail, wrapup);

     /* EFplace_line_string sets the geometry pointer to NULL. So reset it
        back to what it was
     */
     const_list->geometry = (IGRchar *) save_geom; 

#if DEBUG
     if(self_inter)
       fprintf(stderr, "Self Inter   ");
     else if(degenerate)
       fprintf(stderr, "Degenerate   ");
     else if(!closed)
       fprintf(stderr, "Open         ");
     else
       fprintf(stderr, "Unknown      ");
#endif

   } /* if(! (*good)) */


wrapup:

  if(xyz_points) om$dealloc(ptr = xyz_points);
  EMWRAPUP(*EMmsg, sts, "In EMis_bdry_good");
  return(sts);
}

method EMunpack(IGRlong *EMmsg;
		struct EMSpartolbasis *partolbasis;
		struct GRvg_construct *const_list;
		GRobjid *bad_bdry_lnstr;
		IGRint	*num_bad_bdrys)
{
   IGRint		sts, i, num_faces, depth, buf_size, num_new_loops,
        		num_cloops, result_buf_size, j, num_result_loops,
			temp_result_buf_size = 0;
   OM_S_CHANSELECT	to_loops, to_owner, to_edges, to_outter;
   GRobjid		loop, edge, *p_loops, dummy_ls, *c_loops;
   GRobjid		*result_loops, new_objid, 
			bad_objid, *temp_result_loops = NULL;
   IGRushort	lp_props, ed_props, options;
   struct IGRpolyline	poly;
   struct EMSnest_info	nesting;
   struct IGRbsp_surface *surface;
   IGRboolean		bdry_good, on_off;
   IGRint		num_bdrys, num_bdrys_in;
   struct IGRbsp_bdry_pts *bdrys;
   IGRushort	togtype_options = NULL;

   sts = OM_S_SUCCESS;
   *EMmsg = EMS_S_Success;

   p_loops = NULL;
   c_loops = NULL;
   result_loops = NULL;
   temp_result_loops = NULL;
   surface = (struct IGRbsp_surface *) const_list->geometry;
   num_bdrys_in = surface->num_boundaries;
   bdrys = (struct IGRbsp_bdry_pts *) surface->bdrys;
   on_off = surface->on_off;

   sts = EMmake_chanselect (EMSbd_owner_to_comps, &to_edges);
   EMerr_hndlr(!(1&sts), *EMmsg, EMS_E_OMerror, wrapup);

   sts = EMmake_chanselect (EMSedge_to_owner, &to_owner);
   EMerr_hndlr(!(1&sts), *EMmsg, EMS_E_OMerror, wrapup);
   
   sts = EMmake_chanselect (EMSloopset_to_loops, &to_loops);
   EMerr_hndlr(!(1&sts), *EMmsg, EMS_E_OMerror, wrapup);

   sts = EMmake_chanselect (EMSloop_to_outter, &to_outter);
   EMerr_hndlr(!(1&sts), *EMmsg, EMS_E_OMerror, wrapup);


   lp_props = NULL;
   lp_props = EMLP_ACTIVE;
   ed_props = NULL;
   num_bdrys = 0;
   if(num_bad_bdrys) *num_bad_bdrys = 0;

   for(i=0; i<num_bdrys_in; i++)
    {
      sts = EMis_bdry_good(EMmsg, &bdrys[i], &bdry_good, const_list, 
			   partolbasis->tol, surface, &bad_objid);
      EMerr_hndlr(!(1&*EMmsg&sts), *EMmsg, EMS_E_Fail, wrapup);

      if(!bdry_good) 
       {
	
#if DEBUG
	 fprintf(stderr, " Bad Bdry: %d   Surf: %d\n", 
				bad_objid, sender_id);
#endif
	 if(bad_bdry_lnstr) bad_bdry_lnstr[(*num_bad_bdrys)++] = bad_objid;
         continue;
       }

      num_bdrys++;

      sts = om$construct(classid = OPP_EMSloop_class_id, 
			 p_objid = &loop);
      EMerr_hndlr(!(1&sts), *EMmsg, EMS_E_OMerror, wrapup);
      poly.num_points = bdrys[i].num_points;
      poly.points = bdrys[i].points;
      sts = om$construct(classid = OPP_EMSlinedge_class_id, 
			 p_objid = &edge, 
			 msg = message EMSlinedge.EMleinit
	(EMmsg, NULL, EMlinestring, &poly, partolbasis,NULL, NULL_OBJID));
      EMerr_hndlr(!(1&sts), *EMmsg, EMS_E_OMerror, wrapup);
      sts = om$send(msg = message Root.connect(to_owner, NULL, loop, 
				OM_Gw_current_OS, to_edges, NULL), 
			senderid = loop, targetid = edge);
      EMerr_hndlr(!(1&sts), *EMmsg, EMS_E_OMerror, wrapup);
      sts = om$send(msg = message EMSloop.EMlpinit(EMmsg, lp_props, 
				partolbasis, NULL), targetid = loop);
      EMerr_hndlr(!(1&*EMmsg&sts), *EMmsg, EMS_E_LoopError, wrapup);

      sts = om$send(msg=message EMSloop.EMgivenestinfo(EMmsg,&nesting),
			targetid = loop);
      EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_NestError,wrapup);
      sts = om$send(msg=message EMSloopset.EMnesting
			(EMmsg,&nesting,partolbasis),targetid=my_id);
      EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_NestError,wrapup);

      if(IF_EQ_OBJID(nesting.parent,my_id))
          sts = om$send(msg=message EMSloopset.EMtreemod
			(EMmsg,&nesting,ADD_CHILD,partolbasis),
			targetid = my_id);
      else
	  sts = om$send(msg=message EMSloop.EMtreemod
			(EMmsg,&nesting,ADD_CHILD,partolbasis),
			targetid = nesting.parent);
      EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_NestError,wrapup);

    }

    EMerr_hndlr(!num_bdrys, *EMmsg, EMS_I_NoMoreLoops, wrapup);

/* Make all external loops as P loops and toggle through the entire loopset
*/
    togtype_options = EMTogType_SendInner;
    sts = om$send(msg = message EMSloop.EMtoggle_type
			(EMmsg, TRUE, FALSE, my_id, togtype_options,
			NULL, NULL, NULL, NULL, NULL, NULL), 
			p_chanselect = &to_loops);
    EMerr_hndlr(!(1&*EMmsg&sts), *EMmsg, EMS_E_LoopsetError, wrapup);


    depth = MAXINT;
    p_loops = (GRobjid *) om$malloc(size = num_bdrys * sizeof(GRobjid));
    EMerr_hndlr(!p_loops, *EMmsg, EMS_E_NoDynamicMemory, wrapup);
    buf_size = num_bdrys;
    num_faces = 0;
    sts = om$send(msg = message EMSloopset.EMget_loops
				(EMmsg, EMS_OPT_PLOOP, &depth, &p_loops, 
				 NULL, &buf_size, &num_faces), 
				targetid = my_id);
    EMerr_hndlr(!(1&*EMmsg&sts), *EMmsg, EMS_E_LoopsetError, wrapup);

/* Now we have the loopids of all the P loops in the loopset.
   For each P loop impose its C loop children on it.
*/
   sts = om$construct(classid = OPP_EMSloopset_class_id, 
			p_objid = &dummy_ls);
   EMerr_hndlr(!(1&sts), *EMmsg, EMS_E_OMerror, wrapup);

   c_loops = (GRobjid *) om$malloc(size = num_bdrys * sizeof(GRobjid));
   EMerr_hndlr(!c_loops, *EMmsg, EMS_E_NoDynamicMemory, wrapup);

   num_result_loops = 0;
   result_buf_size = num_bdrys;
   result_loops = (GRobjid *) om$malloc(size = num_bdrys * sizeof(GRobjid));
   EMerr_hndlr(!result_loops, *EMmsg, EMS_E_NoDynamicMemory, wrapup);
   
   for(i=0;i<num_faces;i++)
    {
       buf_size = num_bdrys;  /* num c loops can never be > num_bdrys */
       depth = 2;
       num_cloops = 0;       
       sts = om$send(msg = message EMSloop.EMget_loops
				(EMmsg, EMS_OPT_CLOOP, &depth, &c_loops, 
				 NULL, &buf_size, &num_cloops), 
				targetid = p_loops[i]);
       EMerr_hndlr(!(1&*EMmsg&sts), *EMmsg, EMS_E_LoopsetError, wrapup);
       for(j=0;j<num_cloops;j++)
        {
          sts = om$send(msg = message EMSloop.EMtreemod
				(EMmsg, NULL, EXTRACT, partolbasis), 
				targetid = c_loops[j]);
          EMerr_hndlr(!(1&*EMmsg&sts), *EMmsg, EMS_E_LoopError, wrapup);
        }

       sts = om$send(msg = message EMSloop.EMtreemod
				(EMmsg, NULL, EXTRACT, partolbasis), 
				targetid = p_loops[i]);
       EMerr_hndlr(!(1&*EMmsg&sts), *EMmsg, EMS_E_LoopError, wrapup);
       sts = om$send(msg = message Root.connect(to_outter, NULL, dummy_ls, 
				OM_Gw_current_OS, to_loops, NULL), 
				senderid = dummy_ls, targetid = p_loops[i]);
       EMerr_hndlr(!(1&sts), *EMmsg, EMS_E_OMerror, wrapup);
       options = EMImpBnd_CloseRegular;
       sts = om$send(msg = message EMSloopset.EMsplityourself
				(EMmsg, c_loops, num_cloops, NULL, NULL, NULL, 
				 NULL, NULL, options, NULL, NULL, partolbasis, 
				 NULL), targetid = dummy_ls);
       EMerr_hndlr(!(1&*EMmsg&sts), *EMmsg, EMS_E_LoopsetError, wrapup);

       sts = om$send(msg = message EMSboundary.EMcompress_top
				(EMmsg, partolbasis, &new_objid), 
				targetid = dummy_ls);
       EMerr_hndlr(!(1&*EMmsg&sts), *EMmsg, EMS_E_LoopsetError, wrapup);

       depth = MAXINT;
       num_new_loops = 0;
       temp_result_loops = NULL;
       temp_result_buf_size = 0;
       sts = om$send(msg = message EMSloopset.EMget_loops
			(EMmsg, EMS_OPT_ALL, &depth, &temp_result_loops, 
			 NULL, &temp_result_buf_size, &num_new_loops), 
			targetid = dummy_ls);
       EMerr_hndlr(!(1&*EMmsg&sts), *EMmsg, EMS_E_LoopsetError, wrapup);
       for(j=0;j<num_new_loops;j++)
        {
          sts = om$send(msg = message EMSloop.EMtreemod
				(EMmsg, NULL, EXTRACT, partolbasis), 
				targetid = temp_result_loops[j]);
          EMerr_hndlr(!(1&*EMmsg&sts), *EMmsg, EMS_E_LoopError, wrapup);
        }

       if(result_buf_size<num_new_loops)
        {
         result_loops = (GRobjid *) om$realloc(ptr = (char *)result_loops, size = sizeof(GRobjid) *
			(num_result_loops+num_new_loops+result_buf_size));
         EMerr_hndlr(!result_loops, *EMmsg, EMS_E_NoDynamicMemory, wrapup);
         result_buf_size += num_new_loops;
	}
       OM_BLOCK_MOVE(temp_result_loops, &result_loops[num_result_loops], 
		     num_new_loops * sizeof(GRobjid));
       num_result_loops += num_new_loops;
       result_buf_size -= num_new_loops;
       if(temp_result_loops) om$dealloc(ptr = temp_result_loops);
       temp_result_loops = NULL;
       temp_result_buf_size = 0;
    }

/* Now we have all the resultant loops.
   Nest them inside myself again.
*/
   for(i=0;i<num_result_loops;i++)
    {
      sts = om$send(msg=message EMSloop.EMgivenestinfo(EMmsg,&nesting),
			targetid = result_loops[i]);
      EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_NestError,wrapup);
      sts = om$send(msg=message EMSloopset.EMnesting
			(EMmsg,&nesting,partolbasis),targetid=my_id);
      EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_NestError,wrapup);

      if(IF_EQ_OBJID(nesting.parent,my_id))
          sts = om$send(msg=message EMSloopset.EMtreemod
			(EMmsg,&nesting,ADD_CHILD,partolbasis),
			targetid = my_id);
      else
	  sts = om$send(msg=message EMSloop.EMtreemod
			(EMmsg,&nesting,ADD_CHILD,partolbasis),
			targetid = nesting.parent);
      EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_NestError,wrapup);
    }


/* Delete the dummy loopset
*/
   sts = om$send(msg = message Root.delete(TRUE), targetid = dummy_ls);
   EMerr_hndlr(!(1&sts), *EMmsg, EMS_E_OMerror, wrapup);

/*
   If on_off is TRUE then we have
   external C loops. On the other hand if
   it is FALSE then we have external P loops. Set the properties of the
   loops in the loopset by toggling accordingly.
*/
   togtype_options = EMTogType_SendInner;
   sts = om$send(msg = message EMSloop.EMtoggle_type
		(EMmsg, on_off ? FALSE : TRUE, FALSE, my_id, togtype_options, 
		NULL, NULL, NULL, NULL, NULL, NULL), 
				p_chanselect = &to_loops);

wrapup:
        if(temp_result_loops) om$dealloc(ptr = temp_result_loops);
	if(p_loops) om$dealloc(ptr = p_loops);
	if(c_loops) om$dealloc(ptr = c_loops);
	if(result_loops) om$dealloc(ptr = result_loops);
	
	EMWRAPUP(*EMmsg, sts, "In EMSloopset.EMunpack");
	return(sts);
}




end implementation EMSloopset;
