/* ###################   ANSI COMPILED     ################## */
/*

  ABSTRACT

    This function EMextend_intdata accepts two edge objects (each either
    a linear-edge or a bsedge) or two curve buffers (each either a poly
    or a b-spline curve) and extends/dis-extends one/both to their
    (real/extended) intersection. In special cases where the extended
    intersection is too far (more than twice the distance between the
    end-points in question), one of the data that is linear, is extended
    to the other's end-point. If in such a case, neither data is linear,
    there is no solution. In other special cases, where the real 
    intersection is too far, the two data are chopped off at that point.
    
     The 'partolbasis' passed to this function MUST BE VALID. THE FUNCTION
     DOES NOT OBTAIN IT.

  HISTORY

    Jul-xx-88	RV	Creation.
    24-Aug-88	SM	Call EM3dto2d() when converting 3d poles to 2d
			points. Also put the check for EMS_I_Useless after
			calling EMextend_intbuffers() and just for safety
			put the statement 'if(!new_buf[i]) continue;' in
			the 'for loop' which updates input data. All this was
			done to avoid a bus error.
   09/02/88     PP      Modified the arguments to EMcnvtpybs to incorporate
                        a dimension and changed the name of EMcnvtpybs to
                        EMcnvtpybsn to assist in transition.
   17-Sep-88	SM	Fixed a memory problem where a pointer was not
			being initialized to the address returned by
			realloc().
   19-Sep-88	SM	Use BSchgdeppar() to set all tolerances based on
			parametric basis tolerance. This is because
			EMextend_to_int extracts BSTOLLENVEC. So it should
			get that tolerance in parametric space.
   04-Oct-88	SM	Call static function EMsnap_to_uv_limits(), for
			polyline geometries to avoid points spilling out
			of uv range.
   05-Oct-88	SM	Fixed a bug in EMextend_int_buffers() where is_linear
			flags for both buffers were being initialized to
			TRUE instead of FALSE.
   25-Oct-88	SM	Treat any edge other than linear/bs edge as non
			extendable. This includes point edge, partedge, dummy
			edge etc. If one of the edges is non extendable extend
			the other to the end point of the non extendable
			edge. If both non extendable that's too bad. It ain't
			handled by this function as of now.
   08-Nov-88	SM	Fixed a bug, due to which wrong extend point was
			being sent to EMextend_geom method.
   08-jul-93    Sudha   Modified for BSprototypes ansification
*/

class implementation EMSedge;

%safe
#include <math.h>
%endsafe

#include "bserr.h"
#include "EMSopt.h"
#include "OMerrordef.h"
#include "OMmacros.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "igr.h"
#include "igrtypedef.h"
#include "gr.h"
#include "emsdef.h"
#include "emserr.h"
#include "emsdattyp.h"
#include "emsinter.h"
#include "EMSbnddef.h"
#include "EMSbnd.h"
#include "EMSmsgdef.h"
#include "emsedgedef.h"
#include "EMSprop.h"
#include "emsmacros.h"
#include "EMS.h"
#include "bserr.h"
#include "bsparameters.h"
#include "maidmx.h"
#include "bsfreecv.h"
#include "bsdotp.h"
#include "bsdistptpts.h"
#include "bscveval.h"
#include "bscv_copy.h"
#include "bschgdeppar.h"
#include "bsalloccv.h"

%safe
static void	EMsnap_to_uv_limits();
%endsafe

extern OMuword OPP_EMSlinedge_class_id;
extern OMuword OPP_EMSbsdge_class_id;
extern OMuword OPP_EMSptedge_class_id;
extern OMuword OPP_GRbcsubbc_class_id;

from GRvg import GRpostabsg, GRgetsize, GRgetgeom;
from EMSbsedge import EMbsinit;
from EMSlinedge import EMleinit;

static void  EMadd_point_to_linestring(EMmsg, buf, at_stop, add_point,
				       new_buf)
IGRlong *EMmsg;
struct IGRbsp_curve *buf;
IGRboolean at_stop;
IGRpoint add_point;
struct IGRbsp_curve **new_buf;
{
  IGRlong msg_loc, j;
  IGRdouble knot_inc;

  *EMmsg = EMS_S_Success;

  if (!(*new_buf))
  {
     BSalloccv(2, buf->num_poles + 1, FALSE, 0, new_buf, &msg_loc);
     EMerr_hndlr(msg_loc != BSSUCC,*EMmsg,EMS_E_BSerror,wrapup);
  }
  BScv_copy(&msg_loc, buf, *new_buf);
  EMerr_hndlr(msg_loc != BSSUCC,*EMmsg,EMS_E_BSerror,wrapup);

  ((*new_buf)->num_poles) ++;  
  if (at_stop)
  {
    j = ((*new_buf)->num_poles - 1)*3;
    OM_BLOCK_MOVE(add_point, &((*new_buf)->poles[j]), sizeof(IGRpoint));
  }
  else
  {
    OM_BLOCK_MOVE((*new_buf)->poles, &((*new_buf)->poles[3]), 
		((*new_buf)->num_poles - 1) * sizeof(IGRpoint));
    OM_BLOCK_MOVE(add_point, (*new_buf)->poles, sizeof(IGRpoint));
  }
  (*new_buf)->knots[0] = (*new_buf)->knots[1] = 0.;
  (*new_buf)->knots[(*new_buf)->num_poles] = 
	(*new_buf)->knots[(*new_buf)->num_poles+1] = 1.0;
  knot_inc = 1.0 / ((*new_buf)->num_poles - 1);
  for ( j = 2; j < (*new_buf)->num_poles; j++)
         (*new_buf)->knots[j] = (*new_buf)->knots[j-1] + knot_inc;

wrapup:
 
return;

}



IGRint EMextend_intdata (EMmsg, intdata1, intdata2, at_stop1, at_stop2,
	 	         partolbasis, option, surf_data, mat, mattyp)

IGRlong *EMmsg;
struct EMSdataselect *intdata1, *intdata2;
IGRboolean at_stop1, at_stop2;
struct EMSpartolbasis *partolbasis;
IGRushort option;
struct EMSdataselect *surf_data;
IGRmatrix mat;
IGRshort *mattyp;

{
  IGRlong OM_stat, msg_loc, rc;
  IGRint location;
  IGRushort i, j;
  IGRboolean is_nonext_edge[2], are_edges[2], bssts;
  struct IGRbsp_curve edge_geom[2], buf_geom[2], *buf[2], *new_buf[2];
  struct IGRpolyline poly;
  OMuword classid[2];
  struct EMSdataselect *intdata[2];
  IGRushort props[2];
  IGRuchar curve_type[2];
  IGRdouble save_bastol;

  OM_stat = OM_S_SUCCESS;
  *EMmsg = EMS_S_Success;
  bssts = BSEXTRACTPAR (&rc, BSTOLBASIS, save_bastol);
  BSchgdeppar (partolbasis->tol, &rc);
  EMerr_hndlr (BSERROR (rc), *EMmsg, EMS_E_Fail, wrapup);

  intdata[0] = intdata1; intdata[1] = intdata2;
  buf[0] = buf[1] = new_buf[0] = new_buf[1] = NULL;

  is_nonext_edge[0] = is_nonext_edge[1] = FALSE;
  are_edges[0] = are_edges[1] = FALSE;
  for (i=0; i<2; i++)
  {
      edge_geom[i].poles = NULL;
      edge_geom[i].knots = NULL;
      edge_geom[i].weights = NULL;
      edge_geom[i].num_boundaries = 0;
      edge_geom[i].bdrys = NULL;
      buf_geom[i].knots = NULL;
      buf_geom[i].poles = NULL;
      buf_geom[i].weights = NULL;
      buf_geom[i].num_boundaries = 0;
      buf_geom[i].bdrys = NULL;

   if (intdata[i]->datatype == EMSdata_object)
   {
    are_edges[i] = TRUE;
     OM_stat = om$get_classid(objid = intdata[i]->data.object->objid, 
			       osnum = intdata[i]->data.object->osnum,
			       p_classid = &classid[i]);
     EMerr_hndlr (!(1&OM_stat), *EMmsg, EMS_E_OMerror, wrapup);

     OM_stat = om$is_ancestry_valid(superclassid = OPP_EMSedge_class_id, 
					subclassid = classid[i]);

     if (classid[i] != OPP_EMSlinedge_class_id && 
               classid[i] != OPP_EMSbsedge_class_id)
     is_nonext_edge[i] = TRUE;

      OM_stat = om$send(msg = message EMSedge.EMget_props_type (EMmsg, 
					&props[i], &curve_type[i]),
		    senderid = NULL_OBJID,
		    targetid = intdata[i]->data.object->objid,
		    targetos = intdata[i]->data.object->osnum);
      EMerr_hndlr (!(1&OM_stat), *EMmsg, EMS_E_EdgeError, wrapup);

      /* stroke instance data if ISO-edge  */
      if (classid[i] == OPP_EMSlinedge_class_id && (props[i] & EMED_ISO))
      {
        OM_stat = om$send(msg = message EMSlinedge.EMstroke_iso_edge(EMmsg,
				mat, mattyp,
				surf_data->datatype == EMSdata_object ? 
						      surf_data->data.object :
						      NULL,
				surf_data->datatype == EMSdata_surface ? 
						      surf_data->data.surface :
						      NULL,
				FALSE, partolbasis, NULL_OBJID, NULL, TRUE),
		    senderid = NULL_OBJID,
		    targetid = intdata[i]->data.object->objid,
		    targetos = intdata[i]->data.object->osnum);
        EMerr_hndlr (!(1&OM_stat), *EMmsg, EMS_E_EdgeError, wrapup);

        props[i] &= ~EMED_ISO;
     }
     OM_stat = om$send(msg = message EMSedge.EMgetbcgeom(EMmsg, 0, MAXINT,
				FALSE, NULL, &edge_geom[i], partolbasis,
                                        NULL),
		    senderid = NULL_OBJID,
		    targetid = intdata[i]->data.object->objid,
		    targetos = intdata[i]->data.object->osnum);
     EMerr_hndlr (!(1&OM_stat), *EMmsg, EMS_E_EdgeError, wrapup);

     buf[i] = &edge_geom[i];
    }
  else
    {
    are_edges[i] = FALSE;
    if (intdata[i]->datatype == EMSdata_poly2d)
      {
       buf[i] = &buf_geom[i];
       EMcnvtpybsn (EMmsg, 2, intdata[i]->data.poly, &buf_geom[i]);
       EMerr_hndlr (!(*EMmsg), *EMmsg, EMS_E_Fail, wrapup);
      }
     else if (intdata[i]->datatype == EMSdata_curve3d)
       buf[i] = intdata[i]->data.curve;
     else {*EMmsg = EMS_E_InvalidArg; goto wrapup;}
    }
  }

    if ((is_nonext_edge[0] || is_nonext_edge[1])
                      &&
        (are_edges[0] && are_edges[1]))
    {
/********* From here to EMextend_geom message, code added by Sunit 08-Nov-88.*/
	
      IGRdouble		*ext_ptr = NULL, *wt = NULL, ext_pt[3];
      IGRboolean	junk_stop;
      IGRint		k;

      i = is_nonext_edge[0] ? 0 : 1;
      j = i == 0 ? 1 : 0;
      if (is_nonext_edge[j]) {*EMmsg = EMS_E_InvalidArg; goto wrapup;}
      location = j == 0 ? (at_stop1 ? END : BEGIN) :
			  (at_stop2 ? END : BEGIN);
      junk_stop = i == 0 ? at_stop1 : at_stop2;

      if(junk_stop)
       {
        ext_ptr = &edge_geom[i].poles[edge_geom[i].num_poles * 3 - 3];
	if(edge_geom[i].rational) 
	 wt = &edge_geom[i].weights[edge_geom[i].num_poles - 1];
       }
      else
       {
	ext_ptr = edge_geom[i].poles;
	if(edge_geom[i].rational) wt = edge_geom[i].weights;
       }
      OM_BLOCK_MOVE(ext_ptr, ext_pt, 3 * sizeof(IGRdouble));
      if(wt)
       for(k = 0; k< 3; k++)
         ext_pt[k] = ext_pt[k]/(*wt);
      OM_stat = om$send(msg = message EMSedge.EMextend_geom(EMmsg,
	                  ext_pt, &location, FALSE, 
			  NULL, NULL, NULL, partolbasis, NULL, 
			  surf_data->datatype == EMSdata_object ? 
					surf_data->data.object : NULL,
			  surf_data->datatype == EMSdata_surface ? 
					surf_data->data.surface : NULL,
			  mat, mattyp),
		    senderid = NULL_OBJID,
		    targetid = intdata[j]->data.object->objid,
		    targetos = intdata[j]->data.object->osnum);
      EMerr_hndlr (!(1&OM_stat), *EMmsg, EMS_E_EdgeError, wrapup);
      goto wrapup;
    }

  /* Now we have two buffers, so call the lower-level function. */

  OM_stat = EMextend_intbuffers (EMmsg, buf[0], buf[1], at_stop1, at_stop2,
				 &new_buf[0], &new_buf[1]);
  EMerr_hndlr (!(1&OM_stat), *EMmsg, EMS_E_Fail, wrapup);
  if ( (*EMmsg == EMS_I_NoSolution) || (*EMmsg == EMS_I_Useless)) goto wrapup;
 for (i=0; i<2; i++)
 {
  if (are_edges[i] && !is_nonext_edge[i])
   {
   /* update the edges' instance data */
      if(!new_buf[i]) continue;

      props[i] &= ~EMED_REVERSED;

      if (classid[i] == OPP_EMSbsedge_class_id)
      {
         OM_stat = om$send(msg = message EMSbsedge.EMbsinit (EMmsg, props[i],
					curve_type[i], new_buf[i], 
					partolbasis),
			    senderid = NULL_OBJID,
		    	    targetid = intdata[i]->data.object->objid,
			    targetos = intdata[i]->data.object->osnum);
         EMerr_hndlr (!(1&OM_stat), *EMmsg, EMS_E_EdgeError, wrapup);
      }
      else
      {
         poly.num_points = new_buf[i]->num_poles;
         poly.points = new_buf[i]->poles;

         (void) EM3dto2d(poly.points, poly.num_points);
	 (void) EMsnap_to_uv_limits(&poly, partolbasis);
         OM_stat = om$send(msg = message EMSlinedge.EMleinit (EMmsg, props[i],
		  curve_type[i], &poly, partolbasis, NULL, NULL_OBJID),
			    senderid = NULL_OBJID,
		    	    targetid = intdata[i]->data.object->objid,
			    targetos = intdata[i]->data.object->osnum);
         EMerr_hndlr (!(1&OM_stat), *EMmsg, EMS_E_EdgeError, wrapup);
      }
      BSfreecv(&msg_loc, new_buf[i]);
  }
  else 	/* update the input buffers with new geometry */
  {
      if(!new_buf[i]) continue;

      if (intdata[i]->datatype == EMSdata_poly2d)
      {
	if (new_buf[i]->num_poles > intdata[i]->data.poly->num_points)
        {
	  intdata[i]->data.poly->points = (IGRdouble *)om$realloc(
		     ptr = (IGRchar *) intdata[i]->data.poly->points, 
		     size = new_buf[i]->num_poles * 2 * sizeof(IGRdouble));
        }
	intdata[i]->data.poly->num_points = new_buf[i]->num_poles;
	
	(void) EM3dto2d(new_buf[i]->poles, new_buf[i]->num_poles);
	 {
	  struct IGRpolyline junk;
	  junk.num_points = new_buf[i]->num_poles;
	  junk.points = new_buf[i]->poles;
	  (void) EMsnap_to_uv_limits(&junk, partolbasis);
	 }

	OM_BLOCK_MOVE(new_buf[i]->poles, intdata[i]->data.poly->points, 
			2 * new_buf[i]->num_poles * sizeof(IGRdouble));
        BSfreecv(&msg_loc, new_buf[i]);   
      }
      else
      {
        BSfreecv(&msg_loc, intdata[i]->data.curve);	
	intdata[i]->data.curve = new_buf[i];
      }
   }
  }

wrapup:

  BSchgdeppar (save_bastol, &rc);
  for (i=0; i<2; i++)
  {
    if (edge_geom[i].poles) om$dealloc(ptr = edge_geom[i].poles);
    if (edge_geom[i].knots) om$dealloc(ptr = edge_geom[i].knots);
    if (edge_geom[i].weights) om$dealloc(ptr = edge_geom[i].weights);
    if (buf_geom[i].knots) om$dealloc(ptr = buf_geom[i].knots);
    if (buf_geom[i].poles) om$dealloc(ptr = buf_geom[i].poles);
  }

  EMWRAPUP (*EMmsg, OM_stat, "EMextend_intdata");
  return (OM_stat);
}


IGRint EMextend_intbuffers (EMmsg, buf1, buf2, at_stop1, at_stop2,
			    new_buf1, new_buf2)

IGRlong *EMmsg;
struct IGRbsp_curve *buf1, *buf2;
IGRboolean at_stop1, at_stop2;
struct IGRbsp_curve **new_buf1, **new_buf2;
{
  IGRlong OM_stat, msg_loc, objsize, i, j, k;
  IGRboolean fill_gap = FALSE, adjust = FALSE, is_linear[2];
  struct IGRbsp_curve *buf[2], **new_buf[2], *crv_ptr;
  GRclassid trash_classid;
  struct GRid trash_objects[2];
  GRobjid newid;
  struct GRpost_info p_info;
  IGRpoint ext_point, end_point[2], internal_point[2];
  IGRvector vec1, vec2;
  struct GRmd_env mod_info;
  struct GRparms parm[2];
  IGRchar *char_ptr = NULL;
  IGRdouble dotp[2], exttolsq;


  p_info.construct_flag = FALSE;
  MAidmx (&msg_loc, mod_info.md_env.matrix);
  mod_info.md_env.matrix_type = 2;
  mod_info.md_id.objid = NULL_OBJID;

  is_linear[0] = is_linear[1] = FALSE;  
  *new_buf1 = *new_buf2 = crv_ptr = NULL;
  buf[0] = buf1;
  buf[1] = buf2;
  new_buf[0] = new_buf1; 
  new_buf[1] = new_buf2; 
  
  parm[0].u = at_stop1 ? 1.0 : 0.0;
  parm[1].u = at_stop2 ? 1.0 : 0.0;
  parm[0].polygon_inx =  parm[1].polygon_inx = 0;

  for (i=0; i<2; i++)
  {
    if (buf[i]->order == 2 && !buf[i]->rational) is_linear[i] = TRUE;
    trash_classid = OPP_GRbcsubbc_class_id;

    OM_stat = EMgettrshobj_byinx(EMmsg, trash_classid, i, &trash_objects[i]);
    EMerr_hndlr (!(1&OM_stat), *EMmsg, EMS_E_Fail, wrapup);  

    OM_stat = om$send(msg = message GRvg.GRpostabsg(&msg_loc, &mod_info,
				&p_info, (IGRchar *) buf[i], &newid),
		    senderid = NULL_OBJID,
		    targetid = trash_objects[i].objid,
		    targetos = trash_objects[i].osnum);
    EMerr_hndlr (!(1&OM_stat), *EMmsg, EMS_E_CurveError, wrapup);

    BScveval(buf[i], parm[i].u, 0, (IGRpoint *)end_point[i], &msg_loc);
    EMerr_hndlr(msg_loc != BSSUCC,*EMmsg,EMS_E_BSerror,wrapup);   
  }
  exttolsq = 2 * BSdistptpts(&msg_loc, end_point[0], end_point[1]);
  EMerr_hndlr(msg_loc != BSSUCC,*EMmsg,EMS_E_BSerror,wrapup);

  OM_stat = EMextend_to_int(EMmsg, &mod_info, &trash_objects[0], 
			    &trash_objects[1], &parm[0], &parm[1], exttolsq,
                            TRUE, TRUE, end_point[0], end_point[1],
			    ext_point);
  EMerr_hndlr (!(1&OM_stat), *EMmsg, EMS_E_Fail, wrapup);

  if (*EMmsg == EMS_I_Useless) goto wrapup;
  else if (*EMmsg == EMS_E_Modified) adjust = TRUE;
  else if (*EMmsg == EMS_E_NoIntersection) fill_gap = TRUE;
  else if (! (1&*EMmsg)) {*EMmsg = EMS_I_NoSolution; goto wrapup;}
  else if (*EMmsg == EMS_I_OutOfBounds)
  {
    *EMmsg = EMS_S_Success;
    for (i=0; i<2; i++)    
    {
     BScveval(buf[i], 0.5, 0, (IGRpoint *)internal_point[i], &msg_loc);
     EMerr_hndlr(msg_loc != BSSUCC,*EMmsg,EMS_E_BSerror,wrapup);   

     for (j=0; j<3; j++)  
     {
	vec1[j] = end_point[i][j] - ext_point[j];
	vec2[j] = internal_point[i][j] - ext_point[j];
     }
     dotp[i] = BSdotp(&msg_loc, vec1, vec2);
    }
    if (dotp[0] < 0 && dotp[1] < 0)	/* ext_point is inside */
    {
      OM_stat = EMextend_to_int(EMmsg, &mod_info, &trash_objects[0], 
			    &trash_objects[1], &parm[0], &parm[1], exttolsq,
                            FALSE, TRUE, end_point[0], end_point[1],
			    ext_point);
      EMerr_hndlr (!(1&OM_stat), *EMmsg, EMS_E_Fail, wrapup);

      fill_gap = FALSE;
    }        
    else fill_gap = TRUE;
  }
  if (fill_gap)
  {
    if (is_linear[0] || is_linear[1])
    {
     *EMmsg = EMS_S_Success;
     i = is_linear[0] ? 0 : 1;
     j = i == 0 ? 1 : 0;
     EMadd_point_to_linestring(EMmsg, buf[i],
				i == 0 ? at_stop1 : at_stop2,
				end_point[j], new_buf[i]);
     EMerr_hndlr (!(1&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);

     BSalloccv(buf[j]->order, buf[j]->num_poles, buf[j]->rational, 0, 
		new_buf[j], &msg_loc);
     EMerr_hndlr(msg_loc != BSSUCC,*EMmsg,EMS_E_BSerror,wrapup);

     BScv_copy(&msg_loc, buf[j], *(new_buf[j]));
     EMerr_hndlr(msg_loc != BSSUCC,*EMmsg,EMS_E_BSerror,wrapup);
    }
    else {*EMmsg = EMS_I_NoSolution; goto wrapup;}
  }
  else
  {
      for (i=0; i<2; i++)
      {
        OM_stat = om$send(msg = message GRvg.GRgetsize(&msg_loc,
					&mod_info.md_env.matrix_type,
					mod_info.md_env.matrix, &objsize),
		      senderid = NULL_OBJID,
  		      targetid = trash_objects[i].objid,
		      targetos = trash_objects[i].osnum);
        EMerr_hndlr (!(1&OM_stat), *EMmsg, EMS_E_CurveError, wrapup);

        char_ptr = (IGRchar*)om$malloc(size = objsize);
        EMerr_hndlr (!(char_ptr), *EMmsg, EMS_E_NoDynamicMemory, wrapup);

        OM_stat = om$send(msg = message GRvg.GRgetgeom(&msg_loc,
					&mod_info.md_env.matrix_type,
					mod_info.md_env.matrix, char_ptr),
		      senderid = NULL_OBJID,
  		      targetid = trash_objects[i].objid,
		      targetos = trash_objects[i].osnum);
        EMerr_hndlr (!(1&OM_stat), *EMmsg, EMS_E_CurveError, wrapup);

        crv_ptr = (struct IGRbsp_curve *)char_ptr;

        BSalloccv(crv_ptr->order, crv_ptr->num_poles, crv_ptr->rational, 0, 
		  new_buf[i], &msg_loc);
        EMerr_hndlr(msg_loc != BSSUCC,*EMmsg,EMS_E_BSerror,wrapup);

        BScv_copy(&msg_loc, crv_ptr, *(new_buf[i]));
        EMerr_hndlr(msg_loc != BSSUCC,*EMmsg,EMS_E_BSerror,wrapup);

        om$dealloc (ptr = char_ptr);	
      }
      if (adjust)
      {
        *EMmsg = EMS_S_Success;
        if (is_linear[0] || is_linear[1])
        {
          i = is_linear[0] ? 0 : 1;
          j = i == 0 ? 1 : 0;

          BScveval(*(new_buf[j]), parm[j].u, 0, (IGRpoint *)end_point[j], &msg_loc);
          EMerr_hndlr(msg_loc != BSSUCC,*EMmsg,EMS_E_BSerror,wrapup);   

	  k = i == 0 ? (at_stop1 ? ((*(new_buf[i]))->num_poles - 1) * 3 : 0) :
		       (at_stop2 ? ((*(new_buf[i]))->num_poles - 1) * 3 : 0);
          (*(new_buf[i]))->poles[k] = end_point[j][0];
          (*(new_buf[i]))->poles[k+1] = end_point[j][1];
          (*(new_buf[i]))->poles[k+2] = end_point[j][2];
        }
      }
  }


wrapup:

  EMWRAPUP (*EMmsg, OM_stat, "EMextend_intbuffers");
  return (OM_stat);

}

static void EMsnap_to_uv_limits(poly, tol)
struct IGRpolyline *poly;
struct EMSpartolbasis *tol;
{
 IGRint		i, num_doubles;
 IGRdouble	tollen;
 IGRlong	sts, rc;


 sts = EFextract_par(BSTOLLENVEC, tol->tol, &tollen, &rc);

 num_doubles = 2 * poly->num_points;
 for(i=0; i<num_doubles; i++)
   if (poly->points[i] < tollen)
     poly->points[i] = 0.0;
   else if (poly->points[i] > (1.0 - tollen))
     poly->points[i] = 1.0;
}

end implementation EMSedge;
