/* ###################   APOGEE COMPILED   ################## */
/*
 * METHOD:
 *
 *  EMconstruct_associative
 *
 * DESCRIPTION:
 *
 *  This method does the recompute and associative construction for  
 *
 *      Fillet by surfaces and radii
 *      Surface by offsetting a surface
 *      Extracted partial surface
 *      Drafted surface
 *      
 *
 * HISTORY:
 *
 *  jhw     03/20/91    Creation date.
 *  jhw     04/21/91    Added surface by offsetting surface.
 *  jhw     04/25/91    Added extracted partial surface.
 *  jhw     04/30/91    Added drafted surface.
 *  DLB     09/15/91    Support txt-w-leader if fillet sf.
 *  Jack    13-Jan-93   Modified to call EFget_analytic_info() for analytic
 *                      surface creation.  Also, changed call to 
 *                      EMSsurface.EMoffset
 *                      to reflect argument change(did this for Sampath Kumar.)
 *  sam     03/16/93    Added code for associative functionality for multiple
 *                      thikness values for place offset surface. -- sampath.
 *  
 *  sam     06/01/93    fixed memory problem.
 *  Jack    10-Jun-93   Added WANT_POST220_BEHAVIOR condition for doing analytic 
 *                      surface creation.
 *  Sudhakar 26Jul'93   Modified for auto-dimensioning of offset surfaces.
 *  Sudhakar 12Aug'93   Modified to invoke the general 'offset' method if
 *                      specific algorithm fails.
 *  SY      08/25/93    If edge located for filleting, pass edge xyz geometry
 *			as intersection curve for constant and varying radius
 *			fillet routines.
 *  Sudhakar 08Sep'93   Deleted "the call to 'general' algorithm, if the special
 *                      algorithm fails". This has now been integrated with
 *                      the special algorithms.
 *  Sudhakar 24Sep'93   Modified to handle new 'recompute' info for 
 *                      'EMS_ASsurface_by_offsetting_surface'. Pulled out the
 *                      'edge' parents. Added an additional 'surface' parent for
 *                      dimensioning of the common offset distance.
 */
class implementation EMSgencompsf;

#include "OMmacros.h"
#include "EMSasnucdef.h"
#include "EMSasnuc.h"
#include "EMSasdef.h"
#include "EMSas.h"
#include "EMSfillet.h"
#include "REgenbs.h"
#include "REgencompsf.h"
#include "bsvalues.h"
#include "bserr.h"
#include "bsparameters.h"
#include "EMSanaltypes.h"
#include "bsdistptpt.h"
#include "bsdotp.h"
#include "bsmkvec.h"
#include "bsptonnsdsf.h"

/* align a value 'x' up to the next 'a'-sized boundary */
#define ALIGN(x,a) ((char *) (((unsigned int)(x) + (a) - 1) / (a) * (a)))

from EMSsubbs import EMgetfillet;
from EMSsubbs import EMpartsf, EMdrafted_surface;
from EMSgenbs import EMblend_3_or_more_curves;
from EMSdpr   import EMmake_primitive1;
from GRlinear import GRgetpolyline;
from EMSedge  import EMgetsurface_info, EMchkconvex;
from EMSedge  import EMget_bcxyz_geom, EMxyz_endpt;

extern OMuword OPP_EMSgenbs_class_id, OPP_GRcurve_class_id;

extern void     EFget_analytic_info();
extern IGRboolean WANT_POST220_BEHAVIOR;

method EMconstruct_associative ( IGRlong               * msg; 
                                 IGRushort       opts;
                                 GRobjid                 old_objid;
                                 IGRint                  num_parents;
                                 IGRchar               * parent_info;
                                 IGRint                  type;
                                 IGRchar               * recomp_info;
                                 struct GRvg_construct * constr_list)
{
    IGRchar                 * stackptr=NULL;
    IGRint                  * param_type=NULL;
    union EMSparent_info    * param=NULL;
    IGRlong                   msg_loc, om_msg, sts;
    struct GRid             * grid_info=NULL;
    IGRint                    ii;
    IGRuint                   info_size=0;
    IGRint                    i, j, num_objects = 0;
    struct GRobj_env        * objects = NULL;
    struct GRmdenv_info	    * mdenv_info=NULL;
    GRobjid                 * comp_objects = NULL;
    OM_S_CHANSELECT           to_comps;
    IGRboolean convert_into_plane = TRUE;
    OMuword                 new_classid=0;
    OM_S_OBJID              new_objid=NULL_OBJID;
    IGRint                  info_bits=0;
    IGRdouble               *val_spec_thick = NULL;
    struct GRobjid_set      *spec_surf_set = NULL;
    IGRint                  parent_count=0;

    IGRpoint                loc_start_point, loc_end_point;
    IGRdouble               tolr;
    struct GRid		    sf1_GRid, sf2_GRid, *int_cv_GRid = NULL;
    IGRboolean		    sf1_normal, sf2_normal, closed = FALSE;
    struct IGRbsp_curve     *int_cv_geom = NULL;

    extern IGRdouble fabs();
    extern IGRboolean BSrev_cv();


    *msg = EMS_S_Success;
    om_msg = OM_S_SUCCESS;

    stackptr = NULL;
    BSEXTRACTPAR(&msg_loc, BSTOLLENVEC, tolr);

    sf1_normal = TRUE;	/* shut up compiler warning */
    sf2_normal = TRUE;	/* shut up compiler warning */

    /*
     * Get space for the parameter information.
     */

    stackptr = (IGRchar *) stackalloc ((1 +num_parents) * sizeof(IGRint));

    param_type = (IGRint *)stackptr;

    param = (union EMSparent_info *)
            stackalloc((1 +num_parents) * sizeof (union EMSparent_info));

    /*
     * Fill in the appropriate parameter requests.
     */
    switch (type)
    {
    /*-----------------------------------------------------------*/
    /* added to support new fillet surface types. 03/23/93 : JSY */
    /*-----------------------------------------------------------*/
    case EMS_ASfillet_by_edge_radius:
    case EMS_ASfillet_by_edge_radius_w_track_pt:
      param_type[0] = EMSlcinfo;	       	/* edge             */
      param_type[1] = EMSdistance;		/* radius           */
      param_type[2] = EMSscalar;		/* extend distance  */
      param_type[3] = EMSscalar;		/* rho value        */
      if (num_parents == 5) param_type[4] = EMSgrid; /* track point */
      break;

    case EMS_ASfillet_by_surface_surface_radius:
    case EMS_ASfillet_by_surface_surface_radius_w_track_pt:
      param_type[0] = EMSlcinfo;		/* surface1         */
      param_type[1] = EMSlcinfo;		/* surface2         */
      param_type[2] = EMSdistance;		/* radius           */
      param_type[3] = EMSscalar;		/* extend distance  */
      param_type[4] = EMSscalar;		/* rho value        */
      if (num_parents == 6) param_type[5] = EMSgrid; /* track point */
      break;

    case EMS_ASfillet_by_edge_radii:
    case EMS_ASfillet_by_edge_radii_w_track_pt:
      /*
       * The parents of varying radii fillet by edge are organized
       * in the following way
       * open edge:
       * - linear varying
       *   num_parents == 5; edge, ext_distance, rho, start_radius, end_radius
       * - law curve varying
       *   a. start_radius == end_radius
       *      num_parents == 7; edge, ext_distance, rho, start_radius,
       *                        end_radius, mm_radius, law_curve
       *   b. start_radius <> end_radius
       *      num_parents == 6; edge, ext_distance, rho, start_radius,
       *                        end_radius, law_curve
       * closed edge (has to be law curve varying):
       * num_parents == 6; edge, ext_distance, rho, start_rad, mm_radius,
       *                   law_curve
       *
       * NOTE: for open edge, we maintain seperate start and end radius even
       *       though they may be of same value;
       *       for closed edge, we maintain start radius only.
       *       - per Mehash.
       */
      param_type[0] = EMSlcinfo;			/* edge            */
      param_type[1] = EMSscalar;			/* extend distance */
      param_type[2] = EMSscalar;			/* rho value       */
      param_type[3] = EMSdistance;			/* start radius    */
      param_type[4] = EMSdistance;			/* end radius or   */
      if (type == EMS_ASfillet_by_edge_radii)		/* maxmin radius   */
      {
	if (num_parents > 5)
	{
	  if (num_parents == 7)
	    param_type[5] = EMSdistance;		/* maxmin radius   */
	  param_type[num_parents - 1] = EMSlcinfo;	/* law curve       */
	}
      }
      else
      {
	if (num_parents > 6)
	{
	  if (num_parents == 8)
	    param_type[5] = EMSdistance;		/* maxmin radius   */
	  param_type[num_parents - 2] = EMSlcinfo;	/* law curve       */
	}
	param_type[num_parents - 1] = EMSgrid;		/* track pt */
      }
      break;

    case EMS_ASfillet_by_surface_surface_radii:
    case EMS_ASfillet_by_surface_surface_radii_w_track_pt:
      /*
       * The parents of varying radii fillet by surfaces are organized
       * in the following way
       * linear varying:
       * - open intersection
       *   num_parents == 8; surface1, surface2, ext_distance, rho,
       *                     start_radius, end_radius, start_pt, end_pt
       *                     (without direction)
       * - closed intersection
       *   num_parents == 8; surface1, surface2, ext_distance, rho,
       *                     start_radius, end_radius, start_pt, end_pt
       *                     (with direction in recomp_info)
       * law curve varying:
       * - start_radius == end_radius
       *   a. open intersection
       *      num_parents == 10; surface1, surface2, ext_distance, rho,
       *                         start_radius, end_radius, start_pt, end_pt,
       *                         law_curve, mm_radius (without direction)
       *   b. closed intersection
       *      num_parents == 10; surface1, surface2, ext_distance, rho,
       *                         start_radius, end_radius, start_pt, end_pt,
       *                         law_curve, mm_radius (with direction in
       *                         recomp_info)
       * - start_radius <> end_radius
       *   a. open intersection
       *      num_parents == 9; surface1, surface2, ext_distance, rho,
       *                        start_radius, end_radius, start_pt, end_pt,
       *                        law_curve (without direction)
       *   b. closed intersection
       *      num_parents == 9; surface1, surface2, ext_distance, rho,
       *                        start_radius, end_radius, start_pt, end_pt,
       *                        law_curve (with direction in recomp_info)
       */
      param_type[0] = EMSlcinfo;		/* surface1        */
      param_type[1] = EMSlcinfo;		/* surface2        */
      param_type[2] = EMSscalar;		/* extend distance */
      param_type[3] = EMSscalar;		/* rho value       */
      param_type[4] = EMSdistance;		/* start radius    */
      param_type[5] = EMSdistance;		/* end radius      */
      param_type[6] = EMSpoint;			/* start point     */
      param_type[7] = EMSpoint;			/* end point       */
      if (type == EMS_ASfillet_by_surface_surface_radii)
      {
	if (num_parents > 8)
	{
	  param_type[8] = EMSlcinfo;		/* law curve       */
	  if (num_parents == 10)
	    param_type[9] = EMSdistance;	/* maxmin radius   */
	}
      }
      else
      {
	if (num_parents > 9)
	{
	  param_type[8] = EMSlcinfo;		/* law curve       */
	  if (num_parents == 11)
	    param_type[9] = EMSdistance;	/* maxmin radius   */
	}
	param_type[num_parents - 1] = EMSgrid;	/* track pt        */
      }
      break;

    case EMS_ASfillet_by_curve_surface_surface:
    case EMS_ASfillet_by_curve_surface_surface_w_track_pt:
      param_type[0] = EMSlcinfo;		/* curve              */
      param_type[1] = EMSlcinfo;		/* surface (curve on) */
      param_type[2] = EMSlcinfo;		/* surface            */
      param_type[3] = EMSscalar;		/* rho value          */
      if (num_parents == 5) param_type[4] = EMSgrid; /* track point   */
      break;

    case EMS_ASfillet_by_curve_surface_radius:
    case EMS_ASfillet_by_curve_surface_radius_w_track_pt:
      param_type[0] = EMSlcinfo;		/* curve            */
      param_type[1] = EMSlcinfo;		/* surface          */
      param_type[2] = EMSdistance;		/* radius           */
      param_type[3] = EMSscalar;		/* rho value        */
      if (num_parents == 5) param_type[4] = EMSgrid; /* track point */
      break;

    case EMS_ASfillet_by_triple_surfaces:
    case EMS_ASfillet_by_triple_surfaces_w_track_pt:
      param_type[0] = EMSlcinfo;		/* surface1         */
      param_type[1] = EMSlcinfo;		/* surface2         */
      param_type[2] = EMSlcinfo;		/* surface3         */
      param_type[3] = EMSdistance;		/* extend distance  */
      param_type[4] = EMSscalar;		/* rho value        */
      if (num_parents == 6) param_type[5] = EMSgrid; /* track point */
      break;

    case EMS_ASfillet_by_surfaces_and_radii:
    case EMS_ASfillet_by_surfaces_and_radii_w_track_pt:
        if (num_parents == 4 || num_parents == 5)
        {
            param_type[0] = EMSlcinfo;
            param_type[1] = EMSlcinfo;
            param_type[2] = EMSpoint;
            param_type[3] = EMSangle;
            if (num_parents == 5) param_type[4] = EMSgrid; /*track pt*/
        }
        else if (num_parents == 6 || num_parents == 7)
        {
            param_type[0] = EMSlcinfo;
            param_type[1] = EMSlcinfo;
            param_type[2] = EMSpoint;
            param_type[3] = EMSangle;
            param_type[4] = EMSpoint;
            param_type[5] = EMSangle;
            if (num_parents == 7) param_type[6] = EMSgrid;  /*track pt*/
        }
        else goto ret_end;
        break;

    case EMS_ASsurface_by_offsetting_surface:
    case EMS_ASsurface_by_offsetting_surface1:
          {
            struct EMSoffset_surface   old_recomp,*as_offset = NULL;
            IGRint dum_type,size_of_struct=0;

            om_msg = om$send(msg = 
                message EMSassoc.EMget_info(&msg_loc, NULL,
                                   (IGRuint *)&dum_type, &info_size, NULL),
                     targetid = my_id);
            EMerr_hndlr(EMSerror(om_msg & msg_loc), *msg, EMS_E_Fail, ret_end);

            size_of_struct= sizeof(struct EMSoffset_surface);
            param_type[0]  = EMSlcinfo;
            param_type[1]  = EMSdistance;
            param_type[2]  = EMSgrid;
            if(info_size >= size_of_struct)
              {
              parent_count=3;
              as_offset = (struct EMSoffset_surface *)recomp_info;

              if(as_offset->num_spec_tks)
              {
             /* Parameter values for specific offset distances */
                for(i=0;i<as_offset->num_spec_tks;i++)
                    param_type[parent_count++]  = EMSdistance;
              }
  
              /* Common offset distance dimensioning surface */
              param_type[parent_count++]  = EMSgrid;
  
              if(as_offset->num_spec_tks)
              {
               /* Specific offset surface ids */
                for(i=0;i<as_offset->num_spec_tks;i++)
                    for(j=0;j<as_offset->off_surf_views[i+1].num_sfs_per_tks;j++)
                        param_type[parent_count++]  = EMSgrid;
              }
             }
           else
             {
             as_offset = &old_recomp;
             as_offset->props = *(unsigned long  *) recomp_info;
             as_offset->num_spec_tks = 0;
             as_offset->off_surf_views[0].num_sfs_per_tks=0;
             as_offset->off_surf_views[0].best_view_index=0;
             as_offset->off_surf_views[0].uv_point[0]=0;
             as_offset->off_surf_views[0].uv_point[1]=0;
             parent_count=3;
             param_type[parent_count++]  = EMSgrid;
  
             }
            }
            break;

    case EMS_ASextracted_partial_surface:
    case EMS_ASextracted_partial_surface1:
        param_type[0] = EMSlcinfo;
        param_type[1] = EMSpoint;
        param_type[2] = EMSpoint;
        if (num_parents > 3) param_type[3] = EMSpoint;
        break;

    case EMS_ASdrafted_surface:
    case EMS_ASdrafted_surface1:
        param_type[0] = EMSlcinfo;
        param_type[1] = EMSdistance;
        param_type[2] = EMSvector;
        for (i=3; i<num_parents; ++i) param_type[i] = EMSangle;
        break;

    case EMS_ASblend_curve_surface:
     param_type[0] = EMSdistance;
     for (i=1;i<num_parents;i++)
      param_type[i] = EMSlcinfo;
    break;
    default:
        goto ret_end;
    }

    /*
     * Get the parameter information.
     */
    om_msg = om$send ( msg = message EMSassoc.EMget_parent_info
                                            ( &msg_loc,
                                              NULL,
                                              num_parents,
                                              parent_info,
                                  (IGRuint *) param_type,
                                              param ),
                        targetid = my_id);
    EMerr_hndlr (EMSerror (om_msg & msg_loc), *msg, EMS_E_Fail, ret_end);

    /*
     * If we located an edge for filleting, we need extract the
     * two adjacent surfaces first.
     */
    if (type == EMS_ASfillet_by_edge_radius ||
	type == EMS_ASfillet_by_edge_radius_w_track_pt ||
	type == EMS_ASfillet_by_edge_radii ||
	type == EMS_ASfillet_by_edge_radii_w_track_pt)
    {
      struct GRid *edge_GRid;
      struct GRmdenv_info *md_env;
      struct GRmd_env *env;  
      struct IGRbsp_surface *surf_geom;
      IGRboolean convex, neutral, active_state = FALSE;
      OM_S_CHANSELECT edge_chan, to_father;
      OM_S_OBJECT_LINKAGE edge_link, parent_link, creator_link;
      OMuint edge_count, parent_count;
      IGRushort undo_option = EMS_UNDO_SAVE;
      struct GRid active_state_GRid;

      extern OMuword OPP_EMSpointer_class_id;
      
      edge_GRid = &param[0].lc_info.located_obj;
      md_env = &param[0].lc_info.module_info.md_env;
      env = &param[0].lc_info.module_info;
      
      sf1_GRid.objid = NULL_OBJID;
      sf2_GRid.objid = NULL_OBJID;
      active_state_GRid.objid = NULL_OBJID;

      om_msg = om$send(msg = message EMSedge.EMgetsurface_info(&msg_loc,
							       &sf1_GRid.objid,
							       NULL),
		       senderid = NULL_OBJID,
		       targetid = edge_GRid->objid,
		       targetos = edge_GRid->osnum);
      EMerr_hndlr(EMSerror(om_msg & msg_loc), *msg, EMS_E_Fail, ret_end);
      sf1_GRid.osnum = edge_GRid->osnum;
      
      /* 
        If the  surface of the edge cann't be reached because of a previous
	operation, get the same through the indirection object by reaching
	creator of this indirection object, and then activating him.  This
        act puts the edge back in circulation, and after getting all the 
	required recomp info, activate the topmost guy again.  The topmost
        active guy is caught before activing the creator of the indirection
        object. - TR#:119417761 - 24/08/94 - Vadi.
      */
	
      if(IF_NULL_OBJID(sf1_GRid.objid)) {
      EMmake_chanselect(NDfather_father, &to_father);

      om_msg = om$get_channel_objects(objid = old_objid,
                                      osnum = edge_GRid->osnum,
                                      p_chanselect = &to_father,
                                      size = 1,
                                      list = &parent_link,
                                      count = &parent_count);
               EMerr_hndlr(EMSerror(om_msg), om_msg, OM_E_ABORT, ret_end);

      if(EFisAncestryValid(&msg_loc, parent_link.S_objid, parent_link.osnum,
                           OPP_EMSpointer_class_id, FALSE))  
      {
      om_msg = om$get_channel_objects(objid = parent_link.S_objid,
                                      p_chanselect = &to_father,
                                      size = 1,
                                      list = &creator_link,
                                      count = &parent_count);
               EMerr_hndlr(EMSerror(om_msg), om_msg, OM_E_ABORT, ret_end);

      om_msg = om$send(msg = message EMSsurface.EMisactive(&msg_loc, 
                             &active_state, NULL),
                       targetid = creator_link.S_objid);   
      EMerr_hndlr(EMSerror(om_msg & msg_loc), *msg, EMS_E_Fail, ret_end);

      if(!active_state) {
      om_msg = om$send(msg = message EMSsurface.EMgetactiveid (&msg_loc,
                             &active_state_GRid, NULL),
                       targetid = creator_link.S_objid,
                       targetos = creator_link.osnum);
      EMerr_hndlr(EMSerror(om_msg & msg_loc), *msg, EMS_E_Fail, ret_end);

      om_msg = om$send(msg = message EMSsurface.EMmake_active_state(&msg_loc,
                            &undo_option, env, NULL,NULL,
                             NULL,NULL,NULL,NULL),
                      targetid = creator_link.S_objid,
                      targetos = creator_link.osnum);
      EMerr_hndlr(EMSerror(om_msg & msg_loc), *msg, EMS_E_Fail, ret_end);

      om_msg = om$send(msg = message EMSedge.EMgetsurface_info(&msg_loc,
                                                               &sf1_GRid.objid,
                                                               NULL),
                       senderid = NULL_OBJID,
                       targetid = edge_GRid->objid,
                       targetos = edge_GRid->osnum);
      EMerr_hndlr(EMSerror(om_msg & msg_loc), *msg, EMS_E_Fail, ret_end);
           }  
        }  
     }

      om_msg = om$make_chanselect(channame = "EMSedge.to_common_edge",
				  p_chanselect = &edge_chan);
      EMerr_hndlr(EMSerror(om_msg), om_msg, OM_E_ABORT, ret_end);
      
      om_msg = om$get_channel_objects(objid = edge_GRid->objid,
				      osnum = edge_GRid->osnum,
				      p_chanselect = &edge_chan,
				      size = 1,
				      list = &edge_link,
				      count = &edge_count);
      EMerr_hndlr(EMSerror(om_msg), om_msg, OM_E_ABORT, ret_end);

      om_msg = om$send(msg = message EMSedge.EMgetsurface_info(&msg_loc,
							       &sf2_GRid.objid,
							       NULL),
		       senderid = NULL_OBJID,
		       targetid = edge_link.S_objid,
		       targetos = edge_GRid->osnum);
      EMerr_hndlr(EMSerror(om_msg & msg_loc), *msg, EMS_E_Fail, ret_end);
      sf2_GRid.osnum = edge_GRid->osnum;

      /*
       * Having got two surfaces, we need to determine the normals
       * of the surface where fillet surface will be placed. This
       * is achieved by determining the convexity of the edge and
       * computing a dot product of the normals.
       */      
      om_msg = om$send(msg = message EMSedge.EMchkconvex(&msg_loc,
							 EMSchkconvex_nextgeomsf,
							 &md_env->matrix_type,
							 md_env->matrix,
							 EMS_ZEROANGLE_DEG,
							 &convex,
							 &neutral,
							 NULL),
		       senderid = NULL_OBJID,
		       targetid = edge_GRid->objid,
		       targetos = edge_GRid->osnum);
      EMerr_hndlr(EMSerror(om_msg & msg_loc), *msg, EMS_E_Fail, ret_end);

      /* we do not process neutral edge */
      if (neutral == TRUE)
      {
        *msg = EMS_Fil_NeutralEdge;
        om_msg = OM_E_ABORT;
        goto ret_end;
      }

      /*
       * determine the side of the first surface (normal1)
       * where fillet will be placed
       */
      surf_geom = NULL;
      om_msg = EMgetvggeom(&msg_loc,
			   &md_env->matrix_type,
			   md_env->matrix,
			   &sf1_GRid,
			   &surf_geom,
			   NULL);
      EMerr_hndlr(!(om_msg & msg_loc & 1), *msg, msg_loc, ret_end);
      sf1_normal = convex ? surf_geom->pos_orient : !surf_geom->pos_orient;
      om$dealloc(ptr = surf_geom);

      /*
       * determine the side of the second surface (normal2)
       * where fillet will be placed
       */
      surf_geom = NULL;
      om_msg = EMgetvggeom(&msg_loc,
                           &md_env->matrix_type,
                           md_env->matrix,
                           &sf2_GRid,
                           &surf_geom,
                           NULL);
      EMerr_hndlr(!(om_msg & msg_loc & 1), *msg, msg_loc, ret_end);
      sf2_normal = convex ? surf_geom->pos_orient : !surf_geom->pos_orient;
      om$dealloc(ptr = surf_geom);

      /*
       * Extrace the xyz geometry of the edge to be passed in as the
       * intersection curve.
       */
      int_cv_geom = (struct IGRbsp_curve *) alloca(sizeof(struct IGRbsp_curve));
      int_cv_geom->poles = NULL;
      int_cv_geom->knots = NULL;
      int_cv_geom->weights = NULL;
      om_msg = om$send(msg = message EMSedge.EMget_bcxyz_geom(&msg_loc,
							      md_env,
							      &sf1_GRid,
							      NULL,
							      0,
							      MAXINT,
							      FALSE,
							      NULL,
							      int_cv_geom),
		       senderid = NULL_OBJID,
		       targetid = edge_GRid->objid,
		       targetos = edge_GRid->osnum);
      EMerr_hndlr(EMSerror(om_msg & msg_loc), *msg, EMS_E_Fail, ret_end);
      int_cv_GRid = edge_GRid;

      /*
       * If this is varying radii filleting, then we need to further
       * extract the end points of the edge to be used as the starting
       * and ending points.
       */
      if (type == EMS_ASfillet_by_edge_radii ||
	  type == EMS_ASfillet_by_edge_radii_w_track_pt)
      {
	om_msg = om$send(msg = message EMSedge.EMxyz_endpt(&msg_loc,
							   NULL,
							   md_env,
							   NULL,
							   NULL,
							   loc_start_point,
							   loc_end_point,
							   NULL),
			 senderid = NULL_OBJID,
			 targetid = edge_GRid->objid,
			 targetos = edge_GRid->osnum);
	EMerr_hndlr(EMSerror(om_msg & msg_loc), *msg, EMS_E_Fail, ret_end);

	if (BSdistptpt(&msg_loc, loc_start_point, loc_end_point) < tolr)
	  closed = TRUE;
      }
 
     /*
        Here activate the top guy again(See the comments above for the
        same TR)  - TR#:119417761 - 24/08/94 - Vadi
     */
 
   if(!IF_NULL_OBJID(active_state_GRid.objid)) {
      om_msg = om$send(msg = message EMSsurface.EMmake_active_state(&msg_loc,
                            &undo_option, env, NULL,NULL,
                             NULL,NULL,NULL,NULL),
                      targetid = active_state_GRid.objid,
                      targetos = active_state_GRid.osnum);
      EMerr_hndlr(EMSerror(om_msg & msg_loc), *msg, EMS_E_Fail, ret_end);
      }  
    }
    
    /*
     * Fill in the appropriate fillet information.
     */
    switch (type)
    {    
    /*-----------------------------------------------------------*/
    /* added to support new fillet surface types. 03/23/93 : JSY */
    /*-----------------------------------------------------------*/
    case EMS_ASfillet_by_surface_surface_radius:
    case EMS_ASfillet_by_surface_surface_radius_w_track_pt:
      sf1_GRid = param[0].lc_info.located_obj;
      sf2_GRid = param[1].lc_info.located_obj;
      /*
       * no BREAK here
       */
    case EMS_ASfillet_by_edge_radius:
    case EMS_ASfillet_by_edge_radius_w_track_pt:
      {
        IGRdouble loc_radius, loc_ext_distance, loc_rho_value, cht_tol;
        struct EMSfillet_surface_new *as_fillet;
        GRobjid *loc_fillets = NULL;
	IGRushort fillet_opts;
	OMuword space_num;
        extern IGRlong EMcreate_fillet_surf1_to_surf2_const_rad();

        as_fillet = (struct EMSfillet_surface_new *) recomp_info;
	fillet_opts = as_fillet->props;
	
        /*
         * Save the current chord height tolerance. Use the chord
         * height tolerance when creation for recomputation.
         */
        BSEXTRACTPAR(&msg_loc, BSTOLCHRDHT, cht_tol);
        BSchangepar(&msg_loc, BSTOLCHRDHT, as_fillet->cht_tol);

        if (type == EMS_ASfillet_by_edge_radius_w_track_pt ||
	    type == EMS_ASfillet_by_surface_surface_radius_w_track_pt)
        {
          struct GRid *track;
          struct GRmd_env *track_env;
          struct IGRpolyline polyline;
          IGRpoint pt_coord;
          IGRint index, return_poly = 1;
	  struct GRmdenv_info *md_env;
          struct IGRbsp_surface *surf_geom;
          IGRboolean nat_side;
          BSrc bsrc;
          extern OMuword OPP_GRpoint_class_id;

	  index = num_parents - 1;
          track = &param[index].grobj.grid;
          track_env = &param[index].grobj.env;

          if (!EFisAncestryValid(&msg_loc, track->objid, track->osnum,
                                 OPP_GRpoint_class_id, FALSE))
          {
            *msg = EMS_E_InvalidCase;
            goto ret_end;
          }

          polyline.points = pt_coord;
          om_msg = om$send(msg = message GRlinear.GRgetpolyline
                           (&msg_loc,
                            &track_env->md_env.matrix_type,
                            track_env->md_env.matrix,
                            &return_poly,
                            &polyline),
                           targetid = track->objid,
                           targetos = track->osnum);
          EMerr_hndlr(EMSerror(om_msg & msg_loc), *msg, EMS_E_Fail, ret_end);

	  md_env = &param[0].lc_info.module_info.md_env;
	  for (i = 0; i < 2; i++)
          {
            surf_geom = NULL;
	    om_msg = EMgetvggeom(&msg_loc,
				 &md_env->matrix_type,
				 md_env->matrix,
				 i ? &sf2_GRid : &sf1_GRid,
				 &surf_geom,
				 NULL);
	    EMerr_hndlr(EMSerror(om_msg & msg_loc), *msg, EMS_E_Fail, ret_end);

            (void) BSptonnsdsf(surf_geom, pt_coord, &nat_side, &bsrc);
            if (bsrc != BSSUCC)
            {
              *msg = EMS_E_BSerror;
              goto ret_end;
            }

	    if (nat_side)
	      fillet_opts |= i ? EMS_FIL_NATURAL_NORMAL2 :
		                 EMS_FIL_NATURAL_NORMAL1;
	    else
	      fillet_opts &= i ? ~EMS_FIL_NATURAL_NORMAL2 :
		                 ~EMS_FIL_NATURAL_NORMAL1;

            om$dealloc(ptr = surf_geom);
          }
        }
	else if (type == EMS_ASfillet_by_edge_radius)
	{
	  if (sf1_normal)
	    fillet_opts |= EMS_FIL_NATURAL_NORMAL1;
	  else
	    fillet_opts &= ~EMS_FIL_NATURAL_NORMAL1;
	  if (sf2_normal)
	    fillet_opts |= EMS_FIL_NATURAL_NORMAL2;
	  else
	    fillet_opts &= ~EMS_FIL_NATURAL_NORMAL2;
	}

	if (type == EMS_ASfillet_by_edge_radius ||
	    type == EMS_ASfillet_by_edge_radius_w_track_pt)
	{
	  loc_radius = param[1].value;
	  loc_ext_distance = param[2].value * loc_radius;
	  loc_rho_value = param[3].value;
	}
	else
	{
	  loc_radius = param[2].value;
	  loc_ext_distance = param[3].value * loc_radius;
	  loc_rho_value = param[4].value;
	}

	sts = EMcreate_fillet_surf1_to_surf2_const_rad(&msg_loc,
						       fillet_opts,
						       constr_list,
						       &sf1_GRid,
						       NULL,
						       &sf2_GRid,
						       NULL,
						       loc_radius,
						       loc_ext_distance,
						       FALSE, /* fill_pt_ind */
						       int_cv_GRid,
						       int_cv_geom,
						       NULL, /*start_arc_GRid*/
						       NULL, /*start_arc_geom*/
						       NULL, /* end_arc_GRid */
						       NULL, /* end_arc_geom */
						       NULL, /* ref_pt */
						       FALSE, /* is_chamfer */
						       loc_rho_value,
						       &num_objects,
						       &loc_fillets,
						       NULL,
						       NULL,
						       NULL);
	if (msg_loc == EMS_E_InvalidArg || msg_loc == EMS_E_SurfaceError ||
	    msg_loc == EMS_E_BSerror || msg_loc == EMS_E_NoDynamicMemory ||
	    msg_loc == EMS_E_Fail)
	{
	  *msg = msg_loc;
	  goto ret_end;
	}

        if (num_objects)
        {
	  space_num = constr_list->env_info->md_id.osnum;

	  objects = (struct GRobj_env *) stackalloc(num_objects * sizeof(struct GRobj_env));
	  comp_objects = (GRobjid *) alloca(num_objects * sizeof(GRobjid));

	  for (i = 0; i < num_objects; i++)
	  {
	    objects[i].obj_id.objid = loc_fillets[i];
	    objects[i].obj_id.osnum = space_num;
	    objects[i].mod_env = *(constr_list->env_info);
	    comp_objects[i] = loc_fillets[i];
	  }

	  free(loc_fillets);
        }

	/*
	 * Restore the current chord height tolerance.
	 */
	BSchangepar(&msg_loc, BSTOLCHRDHT, cht_tol);
      }
      break;

    case EMS_ASfillet_by_surface_surface_radii:
    case EMS_ASfillet_by_surface_surface_radii_w_track_pt:
      sf1_GRid = param[0].lc_info.located_obj;
      sf2_GRid = param[1].lc_info.located_obj;
      /*
       * no BREAK here
       */
    case EMS_ASfillet_by_edge_radii:
    case EMS_ASfillet_by_edge_radii_w_track_pt:
      {
	IGRdouble loc_start_radius, loc_end_radius, loc_mm_radius;
        IGRdouble loc_ext_distance, loc_rho_value, cht_tol;
	IGRpoint tmp_point;
	struct GRid *law_cv_GRid = NULL;
        struct EMSfillet_surface_new *as_fillet;
	struct IGRbsp_curve *ctrline_cv = NULL;
        GRobjid *loc_fillets = NULL;
        IGRushort fillet_opts;
	IGRshort ctrline_type = 0;
	OMuword space_num;
        extern IGRlong EMcreate_fillet_surf1_to_surf2_var_rad();

        as_fillet = (struct EMSfillet_surface_new *) recomp_info;
	fillet_opts = as_fillet->props;
	loc_mm_radius = 0.0;	/* shut up compiler warning */

        /*
         * Save the current chord height tolerance. Use the chord
         * height tolerance when creation for recomputation.
         */
        BSEXTRACTPAR(&msg_loc, BSTOLCHRDHT, cht_tol);
        BSchangepar(&msg_loc, BSTOLCHRDHT, as_fillet->cht_tol);
	
        if (type == EMS_ASfillet_by_edge_radii_w_track_pt ||
	    type == EMS_ASfillet_by_surface_surface_radii_w_track_pt)
        {
          struct GRid *track;
          struct GRmd_env *track_env;
          struct IGRpolyline polyline;
          IGRpoint pt_coord;
          IGRint index, return_poly = 1;
	  struct GRmdenv_info *md_env;
          struct IGRbsp_surface *surf_geom;
          IGRboolean nat_side;
          BSrc bsrc;
	  extern OMuword OPP_GRpoint_class_id;
	  
	  index = num_parents - 1;
          track = &param[index].grobj.grid;
          track_env = &param[index].grobj.env;

          if (!EFisAncestryValid(&msg_loc, track->objid, track->osnum,
                                 OPP_GRpoint_class_id, FALSE))
          {
            *msg = EMS_E_InvalidCase;
            goto ret_end;
          }
	  
          polyline.points = pt_coord;
          om_msg = om$send(msg = message GRlinear.GRgetpolyline
                           (&msg_loc,
                            &track_env->md_env.matrix_type,
                            track_env->md_env.matrix,
                            &return_poly,
                            &polyline),
                           targetid = track->objid,
                           targetos = track->osnum);
          EMerr_hndlr(EMSerror(om_msg & msg_loc), *msg, EMS_E_Fail, ret_end);

	  md_env = &param[0].lc_info.module_info.md_env;
          for (i = 0; i < 2; i++)
          {
            surf_geom = NULL;
	    om_msg = EMgetvggeom(&msg_loc,
				 &md_env->matrix_type,
				 md_env->matrix,
				 i ? &sf2_GRid : &sf1_GRid,
				 &surf_geom,
				 NULL);
	    EMerr_hndlr(EMSerror(om_msg & msg_loc), *msg, EMS_E_Fail, ret_end);

            (void) BSptonnsdsf(surf_geom, pt_coord, &nat_side, &bsrc);
            if (bsrc != BSSUCC)
            {
              *msg = EMS_E_BSerror;
              goto ret_end;
            }

	    if (nat_side)
	      fillet_opts |= i ? EMS_FIL_NATURAL_NORMAL2 :
		                 EMS_FIL_NATURAL_NORMAL1;
	    else
	      fillet_opts &= i ? ~EMS_FIL_NATURAL_NORMAL2 :
		                 ~EMS_FIL_NATURAL_NORMAL1;

            om$dealloc(ptr = surf_geom);
          }
        }
	else if (type == EMS_ASfillet_by_edge_radii)
	{
	  if (sf1_normal)
	    fillet_opts |= EMS_FIL_NATURAL_NORMAL1;
	  else
	    fillet_opts &= ~EMS_FIL_NATURAL_NORMAL1;
	  if (sf2_normal)
	    fillet_opts |= EMS_FIL_NATURAL_NORMAL2;
	  else
	    fillet_opts &= ~EMS_FIL_NATURAL_NORMAL2;
	}

	if (type == EMS_ASfillet_by_edge_radii ||
	    type == EMS_ASfillet_by_edge_radii_w_track_pt)
	{
	  loc_ext_distance = param[1].value;
	  loc_rho_value = param[2].value;
	  loc_start_radius = param[3].value;
	  if (closed == TRUE)
	  {
	    loc_end_radius = loc_start_radius;
	    loc_mm_radius = param[4].value;
	  }
	  else
	    loc_end_radius = param[4].value;
	  if (type == EMS_ASfillet_by_edge_radii)
	  {
	    if (num_parents > 5)
	    {
	      if (num_parents == 7)
		loc_mm_radius = param[5].value;
	      law_cv_GRid = &param[num_parents - 1].lc_info.located_obj;
	    }
	  }
	  else
	  {
	    if (num_parents > 6)
	    {
	      if (num_parents == 8)
		loc_mm_radius = param[5].value;
	      law_cv_GRid = &param[num_parents - 2].lc_info.located_obj;
	    }
	  }
	  if (closed != TRUE && law_cv_GRid &&
	      (fillet_opts & EMS_FIL_FLIP_EDGE_ENDS))
	  {
	    memcpy(tmp_point, loc_start_point, sizeof(IGRpoint));
	    memcpy(loc_start_point, loc_end_point, sizeof(IGRpoint));
	    memcpy(loc_end_point, tmp_point, sizeof(IGRpoint));
	    BSrev_cv(&msg_loc, int_cv_geom);
	  }
	}
	else
	{
	  sf1_GRid = param[0].lc_info.located_obj;
	  sf2_GRid = param[1].lc_info.located_obj;
	  loc_ext_distance = param[2].value;
	  loc_rho_value = param[3].value;
	  loc_start_radius = param[4].value;
	  loc_end_radius = param[5].value;
	  loc_mm_radius = loc_start_radius + loc_end_radius;
	  memcpy(loc_start_point, param[6].point, sizeof(IGRpoint));
	  memcpy(loc_end_point, param[7].point, sizeof(IGRpoint));
	  if (type == EMS_ASfillet_by_surface_surface_radii)
	  {
	    if (num_parents > 8)
	    {
	      law_cv_GRid = &param[8].lc_info.located_obj;
	      if (num_parents == 10)
		loc_mm_radius = param[9].value;
	    }
	  }
	  else
	  {
	    if (num_parents > 9)
	    {
	      law_cv_GRid = &param[8].lc_info.located_obj;
	      if (num_parents == 11)
		loc_mm_radius = param[9].value;
	    }
	  }
	}

	/*
	 * stored extend distance is in fact a ratio
	 */
	if ((loc_start_radius < loc_end_radius && loc_start_radius != 0.0) ||
	    loc_end_radius == 0.0)
	  loc_ext_distance *= loc_start_radius;
	else
	  loc_ext_distance *= loc_end_radius;
			   
	sts = EMcreate_fillet_surf1_to_surf2_var_rad(&msg_loc,
						     fillet_opts,
						     constr_list,
						     &sf1_GRid,
						     NULL,
						     &sf2_GRid,
						     NULL,
						     loc_start_radius,
						     loc_end_radius,
						     loc_mm_radius,
						     loc_start_point,
						     loc_end_point,
						     as_fillet->reverse,
						     loc_ext_distance,
						     loc_ext_distance,
						     int_cv_GRid,
						     int_cv_geom,
						     law_cv_GRid,
						     NULL,
						     NULL, /*start_arc_GRid*/
						     NULL, /*start_arc_geom*/
						     NULL, /* end_arc_GRid */
						     NULL, /* end_arc_geom */
						     0.0,  /* fpar0 */
						     1.0,  /* fpar1 */
						     &ctrline_cv,
						     &ctrline_type,
						     NULL, /* ref_pt */
						     FALSE, /* is_chamfer */
						     loc_rho_value,
						     &num_objects,
						     &loc_fillets,
						     NULL,
						     NULL);
        if (msg_loc == EMS_E_InvalidArg || msg_loc == EMS_E_SurfaceError ||
            msg_loc == EMS_E_BSerror || msg_loc == EMS_E_NoDynamicMemory ||
            msg_loc == EMS_E_Fail)
        {
          *msg = msg_loc;
          goto ret_end;
        }

	if (num_objects)
        {
          space_num = constr_list->env_info->md_id.osnum;

          objects = (struct GRobj_env *) stackalloc(num_objects * sizeof(struct GRobj_env));
          comp_objects = (GRobjid *) alloca(num_objects * sizeof(GRobjid));

          for (i = 0; i < num_objects; i++)
          {
            objects[i].obj_id.objid = loc_fillets[i];
            objects[i].obj_id.osnum = space_num;
            objects[i].mod_env = *(constr_list->env_info);
            comp_objects[i] = loc_fillets[i];
          }

          free(loc_fillets);
        }

        /*
         * Restore the current chord height tolerance.
         */
        BSchangepar(&msg_loc, BSTOLCHRDHT, cht_tol);
      }
      break;

    case EMS_ASfillet_by_curve_surface_surface:
    case EMS_ASfillet_by_curve_surface_surface_w_track_pt:
      {
        IGRdouble cht_tol;
        struct EMSfillet_surface_new *as_fillet;
        GRobjid *loc_fillets = NULL;
        IGRushort fillet_opts;
	OMuword space_num;
        extern IGRlong EMcreate_fillet_cv_on_surf1_to_surf2();

        as_fillet = (struct EMSfillet_surface_new *) recomp_info;
	fillet_opts = as_fillet->props;

	/*
	 * Save the current chord height tolerance. Use the chord
	 * height tolerance when creation for recomputation.
	 */
	BSEXTRACTPAR(&msg_loc, BSTOLCHRDHT, cht_tol);
	BSchangepar(&msg_loc, BSTOLCHRDHT, as_fillet->cht_tol);
	
	if (type == EMS_ASfillet_by_curve_surface_surface_w_track_pt)
        {
          struct GRid *track;
          struct GRmd_env *track_env;
          struct IGRpolyline polyline;
          IGRpoint pt_coord;
          IGRint index, return_poly = 1;
          struct IGRbsp_surface *surf_geom;
          IGRboolean nat_side;
          BSrc bsrc;
          extern IGRlong EMget_the_geometry();
	  extern OMuword OPP_GRpoint_class_id;

	  index = num_parents - 1;
          track = &param[index].grobj.grid;
          track_env = &param[index].grobj.env;

          if (!EFisAncestryValid(&msg_loc, track->objid, track->osnum,
                                 OPP_GRpoint_class_id, FALSE))
          {
            *msg = EMS_E_InvalidCase;
            goto ret_end;
          }

          polyline.points = pt_coord;
          om_msg = om$send(msg = message GRlinear.GRgetpolyline
                           (&msg_loc,
                            &track_env->md_env.matrix_type,
                            track_env->md_env.matrix,
                            &return_poly,
                            &polyline),
                           targetid = track->objid,
                           targetos = track->osnum);
          EMerr_hndlr(EMSerror(om_msg & msg_loc), *msg, EMS_E_Fail, ret_end);

          for (i = 1; i < 3; i++)
          {
            surf_geom = NULL;
            sts = EMget_the_geometry(&param[i].lc_info, FALSE, FALSE, FALSE,
				     my_id, &surf_geom, &msg_loc);
            EMerr_hndlr(EMSerror(sts & msg_loc), *msg, EMS_E_Fail, ret_end);

            (void) BSptonnsdsf(surf_geom, pt_coord, &nat_side, &bsrc);
            if (bsrc != BSSUCC)
            {
              *msg = EMS_E_BSerror;
              goto ret_end;
            }

	    if (nat_side)
	      fillet_opts |= i == 1 ? EMS_FIL_NATURAL_NORMAL1 :
		                      EMS_FIL_NATURAL_NORMAL2;
	    else
	      fillet_opts &= i == 1 ? ~EMS_FIL_NATURAL_NORMAL1 :
		                      ~EMS_FIL_NATURAL_NORMAL2;

            om$dealloc(ptr = surf_geom);
          }
        }

	sts = EMcreate_fillet_cv_on_surf1_to_surf2(&msg_loc,
                                                   fillet_opts,
                                                   constr_list,
                                                   &param[0].lc_info.located_obj,
                                                   NULL,
                                                   &param[1].lc_info.located_obj,
                                                   NULL,
                                                   &param[2].lc_info.located_obj,
                                                   NULL,
                                                   FALSE,
                                                   param[3].value,
						   &num_objects,
						   &loc_fillets,
                                                   NULL,
						   NULL);
	if (msg_loc == EMS_E_InvalidArg || msg_loc == EMS_E_SurfaceError ||
	    msg_loc == EMS_E_BSerror || msg_loc == EMS_E_NoDynamicMemory ||
	    msg_loc == EMS_E_Fail)
	{
	  *msg = msg_loc;
	  goto ret_end;
	}

        if (num_objects)
        {
	  space_num = constr_list->env_info->md_id.osnum;

	  objects = (struct GRobj_env *) stackalloc(num_objects * sizeof(struct GRobj_env));
	  comp_objects = (GRobjid *) alloca(num_objects * sizeof(GRobjid));

	  for (i = 0; i < num_objects; i++)
	  {
	    objects[i].obj_id.objid = loc_fillets[i];
	    objects[i].obj_id.osnum = space_num;
	    objects[i].mod_env = *(constr_list->env_info);
	    comp_objects[i] = loc_fillets[i];
	  }

	  free(loc_fillets);
        }

	/*
	 * Restore the current chord height tolerance.
	 */
	BSchangepar(&msg_loc, BSTOLCHRDHT, cht_tol);
      }
      break;
      
    case EMS_ASfillet_by_curve_surface_radius:
    case EMS_ASfillet_by_curve_surface_radius_w_track_pt:
      {
        IGRdouble cht_tol;
        struct EMSfillet_surface_new *as_fillet;
        GRobjid *loc_fillets = NULL;
        IGRushort fillet_opts;
	OMuword space_num;
        extern IGRlong EMcreate_fillet_curve_to_surface();

        as_fillet = (struct EMSfillet_surface_new *) recomp_info;
	fillet_opts = as_fillet->props;

        /*
         * Save the current chord height tolerance. Use the chord
         * height tolerance when creation for recomputation.
         */
        BSEXTRACTPAR(&msg_loc, BSTOLCHRDHT, cht_tol);
        BSchangepar(&msg_loc, BSTOLCHRDHT, as_fillet->cht_tol);

	if (type == EMS_ASfillet_by_curve_surface_radius_w_track_pt)
        {
          struct GRid *track;
          struct GRmd_env *track_env;
          struct IGRpolyline polyline;
          IGRpoint pt_coord, curve_pt;
          IGRint index, return_poly = 1;
          IGRvector direct, test_dir;
          struct IGRbsp_surface *surf_geom;
          IGRboolean nat_side;
          BSrc bsrc;
          extern IGRlong EMget_the_geometry();
          extern IGRint EMcompute_curve_ind();
	  extern OMuword OPP_GRpoint_class_id;

	  index = num_parents - 1;
          track = &param[index].grobj.grid;
          track_env = &param[index].grobj.env;

	  if (!EFisAncestryValid(&msg_loc, track->objid, track->osnum,
                                 OPP_GRpoint_class_id, FALSE))
          {
            *msg = EMS_E_InvalidCase;
            goto ret_end;
          }

          polyline.points = pt_coord;
          om_msg = om$send(msg = message GRlinear.GRgetpolyline
                           (&msg_loc,
                            &track_env->md_env.matrix_type,
                            track_env->md_env.matrix,
                            &return_poly,
                            &polyline),
                           targetid = track->objid,
                           targetos = track->osnum);
          EMerr_hndlr(EMSerror(om_msg & msg_loc), *msg, EMS_E_Fail, ret_end);

          EMcompute_curve_ind(&msg_loc,
                              &param[1].lc_info, NULL,
                              &param[0].lc_info, NULL, NULL,
                              curve_pt, direct);

          BSmkvec(&msg_loc, test_dir, curve_pt, pt_coord);

	  if (BSdotp(&msg_loc, direct, test_dir) > 0.0)
	    fillet_opts |= EMS_FIL_NATURAL_NORMAL1;
	  else
	    fillet_opts &= ~EMS_FIL_NATURAL_NORMAL1;

          surf_geom = NULL;
          sts = EMget_the_geometry(&param[1].lc_info, FALSE, FALSE, FALSE,
                                   my_id, &surf_geom, &msg_loc);
          EMerr_hndlr(EMSerror(sts & msg_loc), *msg, EMS_E_Fail, ret_end);

	  (void) BSptonnsdsf(surf_geom, pt_coord, &nat_side, &bsrc);
          if (bsrc != BSSUCC)
          {
            *msg = EMS_E_BSerror;
            goto ret_end;
          }
	  if (nat_side)
	    fillet_opts |= EMS_FIL_NATURAL_NORMAL2;
	  else
	    fillet_opts &= ~EMS_FIL_NATURAL_NORMAL2;

          om$dealloc(ptr = surf_geom);
        }

	sts = EMcreate_fillet_curve_to_surface(&msg_loc,
					       fillet_opts,
					       constr_list,
					       &param[0].lc_info.located_obj,
					       NULL,
					       &param[1].lc_info.located_obj,
					       NULL,
					       param[2].value,
					       NULL,
					       NULL,
					       NULL,
					       NULL,
					       NULL,
					       FALSE,
					       param[3].value,
					       &num_objects,
					       &loc_fillets,
					       NULL,
					       NULL);
	if (msg_loc == EMS_E_InvalidArg || msg_loc == EMS_E_SurfaceError ||
	    msg_loc == EMS_E_BSerror || msg_loc == EMS_E_NoDynamicMemory ||
	    msg_loc == EMS_E_Fail)
	{
	  *msg = msg_loc;
	  goto ret_end;
	}

        if (num_objects)
        {
	  space_num = constr_list->env_info->md_id.osnum;

	  objects = (struct GRobj_env *) stackalloc(num_objects * sizeof(struct GRobj_env));
	  comp_objects = (GRobjid *) alloca(num_objects * sizeof(GRobjid));

	  for (i = 0; i < num_objects; i++)
	  {
	    objects[i].obj_id.objid = loc_fillets[i];
	    objects[i].obj_id.osnum = space_num;
	    objects[i].mod_env = *(constr_list->env_info);
	    comp_objects[i] = loc_fillets[i];
	  }

	  free(loc_fillets);
        }

	/*
	 * Restore the current chord height tolerance.
	 */
	BSchangepar(&msg_loc, BSTOLCHRDHT, cht_tol);
      }
      break;

    case EMS_ASfillet_by_triple_surfaces:
    case EMS_ASfillet_by_triple_surfaces_w_track_pt:
      {
        IGRdouble cht_tol;
        struct EMSfillet_surface_new *as_fillet;
        GRobjid loc_fillets;
        IGRushort fillet_opts;
        extern IGRlong EMcreate_fillet_triple_surfaces();

        as_fillet = (struct EMSfillet_surface_new *) recomp_info;
	fillet_opts = as_fillet->props;

        /*
         * Save the current chord height tolerance. Use the chord
         * height tolerance when creation for recomputation.
         */
        BSEXTRACTPAR(&msg_loc, BSTOLCHRDHT, cht_tol);
        BSchangepar(&msg_loc, BSTOLCHRDHT, as_fillet->cht_tol);

        if (type == EMS_ASfillet_by_triple_surfaces_w_track_pt)
        {
          struct GRid *track;
          struct GRmd_env *track_env;
          struct IGRpolyline polyline;
          IGRpoint pt_coord;
          IGRint index, return_poly = 1;
          struct IGRbsp_surface *surf_geom;
          IGRboolean nat_side;
          BSrc bsrc;
          extern IGRlong EMget_the_geometry();
	  extern OMuword OPP_GRpoint_class_id;

	  index = num_parents - 1;
          track = &param[index].grobj.grid;
          track_env = &param[index].grobj.env;

          if (!EFisAncestryValid(&msg_loc, track->objid, track->osnum,
                                 OPP_GRpoint_class_id, FALSE))
          {
            *msg = EMS_E_InvalidCase;
            goto ret_end;
          }

          polyline.points = pt_coord;
          om_msg = om$send(msg = message GRlinear.GRgetpolyline
                           (&msg_loc,
                            &track_env->md_env.matrix_type,
                            track_env->md_env.matrix,
                            &return_poly,
                            &polyline),
                           targetid = track->objid,
                           targetos = track->osnum);
          EMerr_hndlr(EMSerror(om_msg & msg_loc), *msg, EMS_E_Fail, ret_end);

	  for (i = 0; i < 3; i++)
          {
            surf_geom = NULL;
            sts = EMget_the_geometry(&param[i].lc_info, FALSE, FALSE, FALSE,
                                     my_id, &surf_geom, &msg_loc);
            EMerr_hndlr(EMSerror(sts & msg_loc), *msg, EMS_E_Fail, ret_end);

            (void) BSptonnsdsf(surf_geom, pt_coord, &nat_side, &bsrc);
            if (bsrc != BSSUCC)
            {
              *msg = EMS_E_BSerror;
              goto ret_end;
            }

	    if (nat_side)
	      fillet_opts |= i == 0 ? EMS_FIL_NATURAL_NORMAL1 :
		             i == 1 ? EMS_FIL_NATURAL_NORMAL2 :
			              EMS_FIL_NATURAL_NORMAL3;
	    else
	      fillet_opts &= i == 0 ? ~EMS_FIL_NATURAL_NORMAL1 :
		             i == 1 ? ~EMS_FIL_NATURAL_NORMAL2 :
			              ~EMS_FIL_NATURAL_NORMAL3;

            om$dealloc(ptr = surf_geom);
          }
        }

	num_objects = 1;

	sts = EMcreate_fillet_triple_surfaces(&msg_loc,
                                              fillet_opts,
                                              constr_list,
                                              &param[0].lc_info.located_obj,
                                              NULL,
                                              &param[1].lc_info.located_obj,
                                              NULL,
                                              &param[2].lc_info.located_obj,
                                              NULL,
					      param[3].value,
					      NULL,
					      NULL,
                                              FALSE,
                                              param[4].value,
                                              &loc_fillets,
                                              NULL,
                                              NULL);
	if (msg_loc == EMS_E_InvalidArg || msg_loc == EMS_E_SurfaceError ||
            msg_loc == EMS_E_BSerror || msg_loc == EMS_E_NoDynamicMemory ||
            msg_loc == EMS_E_Fail)
        {
          *msg = msg_loc;
          goto ret_end;
        }

	objects = (struct GRobj_env *) stackalloc(sizeof(struct GRobj_env));
	comp_objects = (GRobjid *) alloca(sizeof(GRobjid));

	objects->obj_id.objid = loc_fillets;
	objects->obj_id.osnum = constr_list->env_info->md_id.osnum;
	objects->mod_env = *(constr_list->env_info);
	*comp_objects = loc_fillets;

        /*
         * Restore the current chord height tolerance.
         */
        BSchangepar(&msg_loc, BSTOLCHRDHT, cht_tol);
      }
      break;

    case EMS_ASfillet_by_surfaces_and_radii:
    case EMS_ASfillet_by_surfaces_and_radii_w_track_pt: 
   {
        GRobjid               * loc_fillets = NULL;
        IGRpoint                loc_end_point;
        IGRdouble               loc_end_radius;
        struct IGRbsp_curve   * law_curve = NULL;
        IGRlong                 law_curve_index;
        struct EMSfillet_surface * as_fillet;
        IGRchar               * p_info;
        IGRdouble               rho;
        IGRboolean              natural_normal1, natural_normal2;
        extern void             EMget_lawcurve();
        IGRint                  cnc_ind=0, cnv_ind=2, ext_ind=2;

        p_info = recomp_info;
        as_fillet = (struct EMSfillet_surface *)p_info;

        /*
         * If a law curve is being used get it's definition.
         */
        if (as_fillet->props & EMS_LAW_CURVE)
        {
            p_info += sizeof(struct EMSfillet_surface);

            EMget_lawcurve ( &msg_loc,
                             p_info,
                             &law_curve_index,
                             &law_curve );

            EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
        }
        else law_curve = NULL;

        /*
         * If an end point and radius have been defined...
         */
        if ((num_parents == 6) && (as_fillet->props & EMS_VARIABLE_FILLET))
        {
            memcpy(loc_end_point, param[4].point, sizeof(IGRpoint));
            loc_end_radius = param[5].value;
        }
        else /* Use the start point and radius. */
        {
            memcpy(loc_end_point, param[2].point, sizeof(IGRpoint));
            loc_end_radius = param[3].value;
        }

        rho = (as_fillet->props & EMS_CHAMFER_FILLET) ? 
              0.0 : .41421356237309504880;
        rho = (as_fillet->props & EMS_CHAMFER_FILLET) ? 
              0.0 :as_fillet->rho_value;

        if (type == EMS_ASfillet_by_surfaces_and_radii_w_track_pt)
        {
          IGRpoint              track_pt;
          IGRlong               surf_bytes;
          IGRint                return_poly=1;
          BSrc                  bsrc;
          struct IGRbsp_surface *surf_geom=NULL;
          struct IGRpolyline    polyline;
          struct GRmd_env       track_env, *surf_env;
          struct GRid           track, *surf_grid;
          IGRboolean            nat_side; 
          extern OMuword        OPP_GRpoint_class_id;


          natural_normal1 = natural_normal2 = FALSE;

          if (num_parents == 5)
          {
            track = param[4].grobj.grid;
            track_env = param[4].grobj.env;
          }
          else /*num_parents == 7*/
          {
            track = param[6].grobj.grid;
            track_env = param[6].grobj.env;
          }

          if (!EFisAncestryValid(&msg_loc, track.objid, track.osnum,
                                 OPP_GRpoint_class_id, FALSE))
          {*msg = EMS_E_InvalidCase; goto ret_end;}

          polyline.points = track_pt;

          om_msg = om$send(msg = message GRlinear.GRgetpolyline(&msg_loc,
                                 &track_env.md_env.matrix_type,
                                 track_env.md_env.matrix,
                                 &return_poly, &polyline),
                    targetid = track.objid,
                    targetos = track.osnum);
          EMerr_hndlr(EMSerror(om_msg & msg_loc), *msg, EMS_E_Fail, ret_end);

          for(ii=0; ii<2; ii++)
          {
            surf_env = &param[ii].lc_info.module_info;
            surf_grid = &param[ii].lc_info.located_obj;

            om_msg = om$send(msg = message GRvg.GRgetsize(&msg_loc,
                                   &surf_env->md_env.matrix_type,
                                   surf_env->md_env.matrix,
                                   &surf_bytes),
                           targetid = surf_grid->objid,
                           targetos = surf_grid->osnum);
            EMerr_hndlr(EMSerror(om_msg & msg_loc), *msg, EMS_E_Fail, ret_end);

            surf_geom = (struct IGRbsp_surface *) alloca(surf_bytes);
          
            om_msg = om$send(msg = message GRvg.GRgetgeom (&msg_loc,
                                   &surf_env->md_env.matrix_type,
                                   surf_env->md_env.matrix,
                                   (IGRchar *) surf_geom),
                             targetid = surf_grid->objid,
                             targetos = surf_grid->osnum);
            EMerr_hndlr(EMSerror(om_msg & msg_loc), *msg, EMS_E_Fail, ret_end);

            surf_geom->num_boundaries = 0;
 
            (void) BSptonnsdsf(surf_geom, track_pt, &nat_side, &bsrc);
            if (bsrc != BSSUCC) {*msg = EMS_E_BSerror; goto ret_end;}

            /* nat_size is true if track point is lying on natural side of
             * the surface, false otherwise 
             */
            if (nat_side)
            {
              if (ii == 0) natural_normal1 = TRUE;
              else natural_normal2 = TRUE;
            }
          }
        }
        else
        {
          natural_normal1 = (as_fillet->props & EMS_NATURAL_NORMAL1) ? 1 : 0;
          natural_normal2 = (as_fillet->props & EMS_NATURAL_NORMAL2) ? 1 : 0;
        }

        if(as_fillet->props & EMS_NO_EXT_FILLET) 
           ext_ind = 0;
        else if(as_fillet->props & EMS_EXT_EXD_FILLET) 
           ext_ind = 2;
        else if (as_fillet->props & EMS_EXT_ROLL_BALL_FILLET) 
           ext_ind = 1;

        if(as_fillet->props & EMS_INT_EXD_FILLET) 
           cnv_ind = 2;
        else if (as_fillet->props & EMS_INT_ROLL_BALL_FILLET) 
           cnv_ind = 1;

        /*
         * Ask the first surface to generate the fillet(s).
         */
        om_msg = om$send ( msg = message EMSsubbs.EMgetfillet 
                            ( &msg_loc,
                              &param[0].lc_info.module_info.md_env.matrix_type,
                              param[0].lc_info.module_info.md_env.matrix,
                              natural_normal1,
                              &param[1].lc_info,
                              natural_normal2,
                              param[2].point, 
                              param[3].value,
                              loc_end_point, 
                              loc_end_radius,
                              NULL,       
                              law_curve,
                              rho,
                              constr_list,   
                              NULL,          
                              &num_objects,  
                              &loc_fillets,
                              ext_ind,
                              cnv_ind,
                              cnc_ind),
                           targetid = param[0].lc_info.located_obj.objid,
                           targetos = param[0].lc_info.located_obj.osnum);

        EMerr_hndlr (EMSerror (om_msg & msg_loc), *msg, EMS_E_Fail, ret_end);

        if (num_objects)
        {
            OMuword            space_num;

            space_num = constr_list->env_info->md_id.osnum;

            objects = (struct GRobj_env *)stackalloc(num_objects * sizeof(struct GRobj_env));

            comp_objects = ( GRobjid *)alloca(num_objects * sizeof( GRobjid));

            for (i=0; i<num_objects; ++i)
            {
                objects[i].obj_id.objid = loc_fillets[i];
                objects[i].obj_id.osnum = space_num;
                objects[i].mod_env = *(constr_list->env_info);
                comp_objects[i] = loc_fillets[i];
            }

            free(loc_fillets);
        }
    }
        break;

    case EMS_ASsurface_by_offsetting_surface:
    case EMS_ASsurface_by_offsetting_surface1:
    {
        GRobjid                     offset_id;
        struct GRid                 active_grid;
        struct EMSoffset_surface    old_recomp,*as_offset = NULL;
        IGRushort                   undo_option;
        IGRint dum_type,size_of_struct=0;

/**************** optional parents ****/

     active_grid.objid = NULL_OBJID;
     active_grid.objid = NULL_OBJID;

   /*** get active_grid**********/
     if (EFisAncestryValid(&msg_loc, param[0].grobj.grid.objid,
                               param[0].grobj.grid.osnum,
                                OPP_EMSsurface_class_id, FALSE))
     {
         om_msg = om$send (msg = message EMSsurface.EMgetactiveid(&msg_loc,
                           &active_grid,NULL),
                      senderid = NULL_OBJID,
                      targetid = param[0].grobj.grid.objid,
                      targetos = param[0].grobj.grid.osnum);
         if (!(1&om_msg&msg_loc)) goto ret_end;
     }

     /*active_grid.objid*/
   if(active_grid.objid != param[2].grobj.grid.objid)
   {
     undo_option = EMS_UNDO_SAVE;
     om_msg = om$send (msg = message EMSsurface.EMmake_active_state(&msg_loc,
                             &undo_option,
                             &param[0].lc_info.module_info, NULL,NULL,
                             NULL,NULL,NULL,NULL),
                       targetid = param[2].grobj.grid.objid,
                       targetos = param[2].grobj.grid.osnum);
     if (!(1&om_msg&msg_loc)) goto ret_end;
   }
 
/*********************/
 
        om_msg = om$send(msg = message EMSassoc.EMget_info(&msg_loc, NULL,
                                   (IGRuint *)&dum_type, &info_size, NULL),
                     targetid = my_id);
        EMerr_hndlr(EMSerror(om_msg & msg_loc), *msg, EMS_E_Fail, ret_end);
 
        size_of_struct= sizeof(struct EMSoffset_surface);
        if(info_size >= size_of_struct)
          {
        as_offset = (struct EMSoffset_surface *)recomp_info;

        parent_count=3;

        if(as_offset->num_spec_tks)
        {
          val_spec_thick= (IGRdouble *)
               om$malloc(size = as_offset->num_spec_tks * sizeof(IGRdouble));
          spec_surf_set = (struct GRobjid_set *) om$malloc(size = 
                     as_offset->num_spec_tks * sizeof(struct GRobjid_set));

         /* Setup the specific surface offset distances */
          for(i=0;i<as_offset->num_spec_tks;i++)
            val_spec_thick[i]  = param[parent_count++].value;
        }

        /* Skip the common offset distance dimension surface */
        parent_count++;

        if(as_offset->num_spec_tks)
        {
         /* Setup the specific surface objid sets */
          for(i=0;i<as_offset->num_spec_tks;i++)
          {
              spec_surf_set[i].num_ids =
                    as_offset->off_surf_views[i+1].num_sfs_per_tks;
              spec_surf_set[i].objids = (GRobjid *) om$malloc(size =
              as_offset->off_surf_views[i+1].num_sfs_per_tks * sizeof(GRobjid));
              for(j=0;j<as_offset->off_surf_views[i+1].num_sfs_per_tks;j++)
                  spec_surf_set[i].objids[j] =
                      param[parent_count++].grobj.grid.objid;
          }
        }
        }
        else
         {
         as_offset = &old_recomp;
         as_offset->props = *(unsigned long  *) recomp_info;
         as_offset->num_spec_tks = 0;
         as_offset->off_surf_views[0].num_sfs_per_tks=0;
         as_offset->off_surf_views[0].best_view_index=0;
         as_offset->off_surf_views[0].uv_point[0]=0;
         as_offset->off_surf_views[0].uv_point[1]=0;
         }

        mdenv_info = &param[0].lc_info.module_info.md_env;
        om_msg = om$send ( msg = message EMSsurface.EMoffset
                                 ( &msg_loc,
                                   (as_offset->props & EMS_TRIMMING) ?
                                   EMS_opt_offsetS_copy_topology : 0,
                                   &mdenv_info->matrix_type,mdenv_info->matrix,
                                   constr_list,
                                   (as_offset->props & EMS_NATURAL_NORMAL),
                                   param[1].value,
                                   as_offset->num_spec_tks,
                                   val_spec_thick,
                                   spec_surf_set,
                                   0, NULL, NULL,
                                   &offset_id, NULL),
                           targetid = param[0].lc_info.located_obj.objid,
                           targetos = param[0].lc_info.located_obj.osnum);

        if(as_offset->num_spec_tks)
        {
                om$dealloc(ptr=val_spec_thick);
                for(i=0;i<as_offset->num_spec_tks;i++)
                        om$dealloc(ptr=spec_surf_set[i].objids);
                om$dealloc(ptr=spec_surf_set);
        }

/********** restore dpr tree *********/
    if(active_grid.objid != param[2].grobj.grid.objid)
    {
     undo_option = EMS_UNDO_SAVE;
     om_msg = om$send (msg = message EMSsurface.EMmake_active_state(&msg_loc,
                             &undo_option,
                             &param[0].lc_info.module_info, NULL,NULL,
                             NULL,NULL,NULL,NULL),
                        targetid =  active_grid.objid,
                        targetos =  active_grid.osnum);
     if (!(1&om_msg&msg_loc)) goto ret_end;
    }
/*********** restore dpr tree *********/

        EMerr_hndlr (EMSerror (om_msg & msg_loc), *msg, EMS_E_Fail, ret_end);
        objects = (struct GRobj_env *)stackalloc(sizeof(struct GRobj_env));
        objects->obj_id.objid = offset_id;
        objects->obj_id.osnum = constr_list->env_info->md_id.osnum;
        objects->mod_env = *(constr_list->env_info);
        num_objects = 1;
    }
        break;

    case EMS_ASextracted_partial_surface:
    case EMS_ASextracted_partial_surface1:
    {
        IGRint                  i, trimming_required, num_points;
        GRobjid                 prtobj;
        struct GRprops          geomprops;
        struct GRparms              proj_parms[3];
        IGRpoint                proj_point;

        om_msg = om$send ( msg = message GRvg.GRgeomprops 
                                        ( &msg_loc,
                                          &constr_list->env_info->md_env.matrix_type,
                                          constr_list->env_info->md_env.matrix,
                                          &geomprops ),
                           targetid = param[0].lc_info.located_obj.objid,
                           targetos = param[0].lc_info.located_obj.osnum );

        EMerr_hndlr (EMSerror (msg_loc & om_msg), *msg, EMS_E_Fail, ret_end);

        if (geomprops.phy_closed && (num_parents == 3))
        {
            *msg = MSFAIL;
            om_msg = OM_E_ABORT;
            goto ret_end;
        }

        trimming_required = *((IGRint *)recomp_info);

        /* 
         * Project all points onto the surface.
         */
        num_points = num_parents - 1;

        for (i=0; i<num_points; ++i)
        {
        om_msg = om$send ( msg = message GRgraphics.GRptproject(&msg_loc,
                               &param[0].lc_info.module_info.md_env.matrix_type,
                                param[0].lc_info.module_info.md_env.matrix,
                               param[i+1].point,
                               proj_point,
                               &proj_parms[i]),
                           targetid = param[0].lc_info.located_obj.objid,
                           targetos = param[0].lc_info.located_obj.osnum );

        EMerr_hndlr (EMSerror (om_msg & msg_loc), *msg, EMS_E_Fail, ret_end);
        }
        om_msg = om$send ( msg = message EMSsubbs.EMpartsf 
                             ( &msg_loc,
                               constr_list,
                               &proj_parms[0].u,
                               &proj_parms[2].u,
                               &proj_parms[1].u,
                               2,
                               &prtobj,
                               NULL,
                               trimming_required,
                               TRUE ),
                           targetid = param[0].lc_info.located_obj.objid,
                           targetos = param[0].lc_info.located_obj.osnum );

        EMerr_hndlr (EMSerror (om_msg & msg_loc), *msg, EMS_E_Fail, ret_end);

        objects = (struct GRobj_env *)stackalloc(sizeof(struct GRobj_env ));
        objects->obj_id.objid = prtobj;
        objects->obj_id.osnum = constr_list->env_info->md_id.osnum;
        objects->mod_env = *(constr_list->env_info);
        num_objects = 1;
    }
        break;

    case EMS_ASdrafted_surface:
    case EMS_ASdrafted_surface1:
    {
        struct EMSdrafted_surface *as_draft;
        struct d_s_codes_views    *as_c_v;
        unsigned short            loc_props;
        unsigned short            loc_count;
        IGRint                    *loc_codes;
        IGRdouble                 *loc_angles;
        IGRvector                 loc_vector;
        OMuword                   classid;

        /*
         * Get all the stuff ...
         */
        as_draft = (struct EMSdrafted_surface *)recomp_info;
        loc_props = as_draft->props;
        loc_count = as_draft->num_sides; 

        loc_codes = (IGRint *) stackalloc(loc_count * sizeof(IGRint));
        loc_angles = (IGRdouble *)stackalloc(loc_count * sizeof(IGRdouble));

        as_c_v = as_draft->codes_views;

        for (i=0; i<loc_count; ++i)
        {
          loc_codes[i] = as_c_v[i].as_code;
          loc_angles[i] = param[i+3].value * M_PI/180; /*Radians*/
        }

        MAscalvc (&msg_loc, &param[1].value, param[2].vector, loc_vector);
        
        om$get_classid (objid = param[0].lc_info.located_obj.objid,
                        osnum = param[0].lc_info.located_obj.osnum,
                        p_classid = &classid );

        /*
         * If the defining curve is a composite ...
         */
        if ((om$is_ancestry_valid(superclassid = OPP_EMScomposite_class_id,
                                  subclassid = classid) == OM_S_SUCCESS))
        {
            om_msg = om$send ( msg = message EMSgencompsf.EMproject_with_draft
                                          ( &msg_loc, 
                                            param[0].lc_info.located_obj.objid,
                                            loc_props & EMS_IS_UNIFORM,
                                            loc_angles,
                                            loc_vector,
                                            loc_props & EMS_IS_FILLETED,
                                            loc_props & EMS_IS_RIGHT_SIDE,
                                            loc_codes,
                                            constr_list ),
                               targetid = my_id );

            EMerr_hndlr(EMSerror(om_msg & msg_loc), *msg, EMS_E_Fail, ret_end);
        }
        else /* Simple curve */
        {
            GRobjid drfobj;

            new_objid = NULL_OBJID;

           /*
            * We only want to come in here if we are creating or 
            * recomputing a post-220 object.  
            */
           if ( WANT_POST220_BEHAVIOR )
            {
              /*
               * Let's try and found out if any analytic surface will be 
               * created by creating a ruled surface from the input curve.
               */
              info_bits = 0;  /* no input bits set */
              
              EFget_analytic_info(&msg_loc,               /* EMmsg */
                                   loc_angles[0],         /* draft_angle */
                                  &param[0].lc_info.located_obj, /* curve_id */
                                  &param[0].lc_info.module_info, /* curve_env */ 
                                   NULL,                  /* curve_geom */
                                   NULL,                  /* curve_type */
                                   loc_vector,            /* axis */
                                   0.0,                   /* rev_angle */
                                   0,                     /* const_os */
                                  &new_classid,           /* new_classid */
                                  &new_objid,             /* new_obj */
                                  &info_bits);            /* info_bits */
            }          

            if(new_objid == NULL_OBJID)
              /*
               * Construct and define the general surface if there was
               * no analytic surface possible.
               */
              om_msg = om$construct(classid =  OPP_EMSgenbs_class_id,
                                    osnum   =  constr_list->env_info->md_id.osnum,
                                    p_objid = &drfobj);
            else
              drfobj = new_objid;


            om_msg = om$send ( msg = message EMSsubbs.EMdrafted_surface
                                               ( &msg_loc,
                                                 NULL,
                                                 &param[0].lc_info,
                                                 NULL,
                                                 loc_vector,
                                                 loc_angles[0],
                                                 loc_props & EMS_IS_RIGHT_SIDE,
                                                 loc_props & EMS_IS_FILLETED,
                                                 NULL,
                                                 TRUE,
                                                 &drfobj,
                                                 constr_list ),
                                targetid = drfobj,
                                targetos = constr_list->env_info->md_id.osnum);

            EMerr_hndlr(EMSerror(om_msg & msg_loc), *msg, EMS_E_Fail, ret_end);

            objects = (struct GRobj_env *)
                      stackalloc(sizeof(struct GRobj_env ));
            objects->obj_id.objid = drfobj;
            objects->obj_id.osnum = constr_list->env_info->md_id.osnum;
            objects->mod_env = *(constr_list->env_info);
            num_objects = 1;
        }
    }
        break;
    case EMS_ASblend_curve_surface:
    {
     IGRint number_of_curves;
     IGRboolean is_curve, make_natural_boundary = FALSE;
     IGRdouble distance;
     IGRpoint center_point;
     IGRvector normal_vector;
     struct GRid tmp_GRid;
     OMuword obj_classid;
     OM_S_OBJID tmp_objid;
     OM_S_OBJID new_surfid;
     struct GRid my_GRid;
     struct GRid *ptr_GRid;
     struct GRlc_info **curves_ptr, **surfaces_ptr;

     my_GRid.objid = my_id;
     my_GRid.osnum = OM_Gw_current_OS;
     
     curves_ptr = (struct GRlc_info **)stackalloc(num_parents*
                  sizeof (struct GRlc_info *));
     surfaces_ptr = (struct GRlc_info **)stackalloc(num_parents*
                   sizeof (struct GRlc_info *));
     EMerr_hndlr(!curves_ptr || !surfaces_ptr,*msg, 
                 EMS_E_DynamicMemoryAllocated, ret_end);

     number_of_curves = 0;
     for (i=0;i<num_parents;i++)
     {
      curves_ptr[i] = NULL;
      surfaces_ptr[i] = NULL;
     }
     for (i=1;i<num_parents;i++)
     {
       ptr_GRid = &param[i].lc_info.located_obj;

       om_msg = om$get_classid (objid = ptr_GRid->objid,
                                p_classid = &obj_classid);
       EMerr_hndlr(!(1&om_msg&*msg), *msg, EMS_E_OMerror, ret_end);

       om_msg = om$is_ancestry_valid(subclassid = obj_classid,
                                     superclassid = OPP_GRcurve_class_id);
       if (om_msg == OM_S_SUCCESS) is_curve = TRUE;
       else if (om_msg == OM_I_INVANCESTRY)
       {
        is_curve = FALSE;
        om_msg = OM_S_SUCCESS;
       }
       else
       {
        *msg = EMS_E_OMerror;
        goto ret_end;
       }

       if (is_curve) 
       {
        curves_ptr[number_of_curves] = &param[i].lc_info;
        ++number_of_curves;
       }
       else
        surfaces_ptr[number_of_curves-1] = &param[i].lc_info;
     }

     if (number_of_curves > 4)
       distance = param[0].value;
     else
       distance = 0;
/*
 * Intialise my properties 
 */

     om_msg = om$send (msg = message GRvg.GRconstruct(constr_list),
              targetid = my_id);
     EMerr_hndlr(!(1&om_msg), *msg, EMS_E_Fail, ret_end);

     om_msg = om$construct(
          classid =  OPP_EMSgenbs_class_id,
          msg = message EMSgenbs.EMblend_3_or_more_curves(
                number_of_curves,
                curves_ptr,
                surfaces_ptr,
                constr_list,
                distance,
                center_point,
                normal_vector,
                &new_surfid),
          p_objid = &tmp_objid);
     EMerr_hndlr(!(1&om_msg), *msg, EMS_E_Fail, ret_end);
/*
 * Use the geometry field in the construct list to return information
 * to the command object. The right way to do this is to add an argument
 * in EMconstruct_associative. Again return this only if it is an initial
 * construction.
 */

     if (!(opts & EMSasconst_recompute))
     {
      struct EMSblend_curve_surface_ret_info *ret_info;
      constr_list->geometry = (IGRchar *)
                        malloc(sizeof(struct EMSblend_curve_surface_ret_info));
      EMerr_hndlr(!constr_list->geometry, *msg,
                  EMS_E_DynamicMemoryAllocated,ret_end);
      ret_info = (struct EMSblend_curve_surface_ret_info *)
                   constr_list->geometry;
      OM_BLOCK_MOVE(center_point, ret_info->center_point, sizeof (IGRpoint));
      OM_BLOCK_MOVE(normal_vector,ret_info->normal_vector, sizeof (IGRvector));
     }

     tmp_objid = new_surfid;
     tmp_GRid.objid = NULL_OBJID;
     make_natural_boundary = FALSE;
     om_msg = om$send (msg = message EMSdpr.EMmake_primitive1(msg,
                            constr_list->env_info, &tmp_GRid),
              targetid = tmp_objid);
     if (om_msg == OM_W_UNKNOWN_MSG)
     {
      make_natural_boundary = TRUE;
      new_surfid = tmp_objid;
      om_msg = OM_S_SUCCESS;
     }
     else if (1&om_msg&*msg)
      new_surfid = tmp_GRid.objid;
     else goto ret_end;

     if (make_natural_boundary)
     {
      om_msg = om$send (msg = message EMSsurface.EMmk_nat_bdry(msg,
                              &constr_list->env_info->md_env, 
                              NULL),
                        targetid = new_surfid);
      EMerr_hndlr (!(1&om_msg&*msg), *msg, EMS_E_Fail, ret_end);
     }
    /*
     * Connect the surface to myself.
     */
     om_msg = om$send (msg = message GRconnector.GRrigidconn(msg,
                         &my_GRid, (IGRlong *) &i),
                   targetid = new_surfid);
     EMerr_hndlr (!(1&*msg), *msg, EMS_E_Fail, ret_end);
     break;
    }
   }
    /*
     * If there are objects add them ...
     */
    if (num_objects && objects)
    {

    if (type == EMS_ASfillet_by_surfaces_and_radii &&
        type == EMS_ASfillet_by_surfaces_and_radii_w_track_pt)
       {
       struct GRid my_GRid;
        my_GRid.objid = my_id;
        my_GRid.osnum = OM_Gw_current_OS;

          for(ii=0; ii<num_objects; ii++)
          {
            om_msg  = om$send(
                 msg = message EMSsubbs.EMmk_nat_bdry( &msg_loc, 
                       &constr_list->env_info->md_env, NULL), 
                 targetid = comp_objects[ii]);
          }
          if(num_objects > 1)
             om_msg = om$send ( msg = message EMSgencompsf.EMmake_comp
                                          ( &msg_loc,
                                            num_objects,
                                            comp_objects,
                                            constr_list->env_info),
                           targetid = my_id );


          /* if fails rigid connect the comps to the general composite surf */
          om_msg = EMmake_chanselect(GRcmpowner_to_components, &to_comps);
          if(! ( om_msg & 1 ) ) goto ret_end;
          for(ii=0; ii<num_objects; ii++)
          {

             if( ! (1 &om$is_objid_on_channel(object_c = me,
                       p_chanselect = &to_comps, objid =  comp_objects[ii]) )  )

                 om_msg = om$send (msg = message GRconnector.GRrigidconn(msg,
                         &my_GRid, (IGRlong *) &num_objects),
                   targetid = comp_objects[ii] );
          }


       }
       else
        om_msg = om$send ( msg = message GRowner.GRadd_components 
                                          ( &msg_loc,
                                            constr_list->env_info,
                                            &num_objects,
                                            objects,
                                            NULL,
                                            NULL ),
                           targetid = my_id );

        /*
         * If anything failed delete the objects.
         */
        if (EMSerror (om_msg & msg_loc))
        {
            for (i=0; i<num_objects; ++i)
            {
                om$send (msg = message GRgraphics.GRdelete 
                                            ( &msg_loc,
                                              constr_list->env_info),
                         targetid = objects[i].obj_id.objid,
                         targetos = objects[i].obj_id.osnum);
            }
        }
    }

    EMerr_hndlr (EMSerror (om_msg & msg_loc), *msg, EMS_E_Fail, ret_end);

    /*
     * Perform the appropriate auto-dimensioning if requested.
     */
    if (!(opts & EMSasconst_noautodimension) &&
        !(opts & EMSasconst_recompute))
    {
        grid_info = (struct GRid *)parent_info;

        switch (type)
        {
        case EMS_ASfillet_by_surfaces_and_radii:
        case EMS_ASfillet_by_surfaces_and_radii_w_track_pt:
            break;
        case EMS_ASsurface_by_offsetting_surface:
        case EMS_ASsurface_by_offsetting_surface1:
            break;
        }
    }

     if( (type == EMS_ASsurface_by_offsetting_surface1 ||
          type == EMS_ASdrafted_surface1 ||
          type == EMS_ASextracted_partial_surface1) && convert_into_plane)
      om_msg = EMconvert_into_plane(msg, NULL, NULL, NULL, NULL, NULL, NULL, 
               NULL, constr_list->env_info, my_id, OM_Gw_current_OS);

ret_end:
    if (stackptr) stackfree (stackptr);
    if (int_cv_geom)
    {
      if (int_cv_geom->poles)
        free(int_cv_geom->poles);
      if (int_cv_geom->knots)
        free(int_cv_geom->knots);
      if (int_cv_geom->weights)
        free(int_cv_geom->weights);
    }      

    EMWRAPUP (*msg, om_msg, "EMSgencompsf.EMconstruct_associative");
    return (om_msg);
}

end implementation EMSgencompsf;







