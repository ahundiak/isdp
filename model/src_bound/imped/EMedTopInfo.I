/* ###################   APOGEE COMPILED   ################## */
/*

ABSTRACT

  This method returns topology-related info at an edge, in a structure
  EMStopinfo (declared in EMSbnd.h).

HISTORY

  Aug-01-88	RV	Creation. Requested by S.T. 

*/

class implementation EMSedge;

#include "EMS.h"
# include "OMmacros.h"
# include "emseligible.h"
# include "emsdef.h"

#define INITIAL_SIZE	8
#define INCREMENT	4


method EMget_topology_info(IGRlong *EMmsg;struct IGRbsp_surface *surf;
                              IGRshort *mx_type; IGRmatrix mx;
                              GRobjid surf_id;
			      IGRushort eligible_edge_type;
			      struct EMStopinfo **topinfo;
			      IGRint *buf_size;
			      IGRint *num_in_buf)
{
  IGRlong               sts;
  OMuint                count;
  struct IGRbsp_curve   *curve = NULL;
  struct IGRpolyline    *poly = NULL;
  OM_S_CHANSELECT       to_common_edge;

  /*
   * Initialize
   */

  sts = OM_S_SUCCESS;
  *EMmsg = EMS_S_Success;


  if( (eligible_edge_type & EMSeligible_NonSubEdge) &&
      (ME.EMSedge->ed_props & EMED_SUBORDINATE)) goto wrapup;

  if( (eligible_edge_type & EMSeligible_NonNatEdge) &&
      (ME.EMSedge->ed_props & EMED_NATURAL)) goto wrapup;
  
  if( (eligible_edge_type & EMSeligible_NonSeamEdge) &&
      ( (ME.EMSedge->ed_props & EMED_SEAM) && 
        (ME.EMSedge->ed_props & EMED_SUBORDINATE))) goto wrapup;

  if( (eligible_edge_type & EMSeligible_NonDegenerateEdge) &&
      (ME.EMSedge->ed_props & EMED_DEGENERATE)) goto wrapup;

  if (! *buf_size)	
  {
      *topinfo = (struct EMStopinfo *) om$malloc (size = (unsigned) 
                         (INITIAL_SIZE * sizeof (struct EMStopinfo)));
      EMerr_hndlr (!(*topinfo),*EMmsg,EMS_E_NoDynamicMemory,wrapup);

      *buf_size = INITIAL_SIZE;
  }
  else if ((*num_in_buf + 1) > *buf_size)
  {
      (*buf_size) += INCREMENT;
      *topinfo = (struct EMStopinfo *) om$realloc (ptr = (IGRchar *)*topinfo,
      size = (unsigned) (*buf_size) * sizeof (struct EMStopinfo ));
      EMerr_hndlr (!(*topinfo),*EMmsg,EMS_E_NoDynamicMemory,wrapup);
  }
 
  (*topinfo)[*num_in_buf].edge_id = my_id;
  sts = om$get_classid(object = me, 
			p_classid = &(*topinfo)[*num_in_buf].class_id);
  if(! (1 & sts)) goto wrapup;

  if(eligible_edge_type & EMSeligible_ParametricGeom)
   {
     if(eligible_edge_type & EMSeligible_BSplineGeom)
      {
	curve = (struct IGRbsp_curve *) om$malloc (size = (unsigned) 
                         sizeof (struct IGRbsp_curve));
        EMerr_hndlr (!curve,*EMmsg,EMS_E_NoDynamicMemory,wrapup);

	curve->poles = NULL;
	curve->weights = NULL;
	curve->knots = NULL;
	curve->num_boundaries = 0;
	curve->bdrys = NULL;

	sts = om$send(msg = message EMSedge.EMgetbcgeom(EMmsg, 0, MAXINT, 
					FALSE, NULL, curve, NULL, NULL), 
					targetid = my_id);
	if(!(1&sts&*EMmsg)) goto wrapup;

	(*topinfo)[*num_in_buf].edge_geom.datatype = EMSdata_curve3d;
        (*topinfo)[*num_in_buf].edge_geom.data.curve = curve;
      }
     else
      {
	poly = (struct IGRpolyline *) om$malloc (size = (unsigned) 
                         sizeof (struct IGRpolyline));
        EMerr_hndlr (!curve,*EMmsg,EMS_E_NoDynamicMemory,wrapup);

	poly->points = NULL;
	poly->num_points = 0;

	sts = om$send(msg = message EMSedge.EMgetpygeom(EMmsg, 0, MAXINT, 
					FALSE, NULL, poly, NULL, NULL), 
					targetid = my_id);
	if(!(1&sts&*EMmsg)) goto wrapup;

	(*topinfo)[*num_in_buf].edge_geom.datatype = EMSdata_poly2d;
        (*topinfo)[*num_in_buf].edge_geom.data.poly = poly;
      }
   }
  else
   {
     curve = (struct IGRbsp_curve *) om$malloc (size = (unsigned) 
                         sizeof (struct IGRbsp_curve));
     EMerr_hndlr (!curve,*EMmsg,EMS_E_NoDynamicMemory,wrapup);

     curve->poles = NULL;
     curve->weights = NULL;
     curve->knots = NULL;
     curve->num_boundaries = 0;
     curve->bdrys = NULL;

     sts = om$send(msg = message EMSedge.EMget_bcxyz_geom(EMmsg, NULL,
                  NULL, surf, 0, MAXINT, FALSE, NULL, curve),
                  targetid = my_id);
     if(! (1 & *EMmsg & sts)) goto wrapup;

     (*topinfo)[*num_in_buf].edge_geom.datatype = EMSdata_curve3d;
     (*topinfo)[*num_in_buf].edge_geom.data.curve = curve;
   }
   sts = om$send(msg = message EMSedge.EMget_props_type(EMmsg,
				&(*topinfo)[*num_in_buf].props,
				&(*topinfo)[*num_in_buf].curve_type),
                 targetid = my_id);
   if(! (1 & *EMmsg & sts)) goto wrapup;

   sts = om$send(msg = message EMSedge.EMgetsurface_info(EMmsg,
				&(*topinfo)[*num_in_buf].surf_id, NULL),
                 targetid = my_id);
   if(! (1 & *EMmsg & sts)) goto wrapup;

   to_common_edge.type = OM_e_addr;
   to_common_edge.u_sel.addr = &ME.EMSedge->to_common_edge;

   sts = om$get_channel_count(object = me,
                             p_chanselect = &to_common_edge,
                             count = &count);
   if(! (1 & sts)) goto wrapup;

   if (! count)
   {
     (*topinfo)[*num_in_buf].partner_edge_id = NULL_OBJID;
     (*topinfo)[*num_in_buf].partner_surf_id = NULL_OBJID;
   }
   else
   {
      sts = om$send(msg = message EMSboundary.EMget_objid(EMmsg,
				&(*topinfo)[*num_in_buf].partner_edge_id),
			senderid = my_id,
			p_chanselect = &to_common_edge);
      if(! (1 & *EMmsg & sts)) goto wrapup;

      sts = om$send(msg = message EMSedge.EMgetsurface_info(EMmsg,
			&(*topinfo)[*num_in_buf].partner_surf_id, NULL),
			senderid = my_id,
			p_chanselect = &to_common_edge);
      if(! (1 & *EMmsg & sts)) goto wrapup;
   }
  
   (*num_in_buf)++;


wrapup:


  return(sts);
}

end implementation EMSedge;
