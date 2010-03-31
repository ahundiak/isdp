/* ###################   APOGEE COMPILED   ################## */
/*
 Description

 This method performs the construction logic
 for the following simple construction commands:

                 Command                      mytype
        ----------------------------------    -------
        Place solid box by two points           1 
        Place box by four points                2 
        Place solid box by four points          3 
        Place cone by axis and diameters        4 
        Place solid right trunc. cone           5 
        Place cylinder by axis and radius       6 
        Place solid right circ. cylinder        7 
        Place torus                             8 
        Place solid torus                       9 
        Place solid right elliptical cylinder   10
        Place solid trunc. elliptical cone      11
        Place ellipsoid - foci axis len.        12
        Place ellipsoid - ctr. axis rad.        13
        Place solid 4 face 4 vert. polyhedron   14
        Place solid 5 face 5 vert. polyhedron   15
        Place solid 5 face 6 vert. polyhedron   16
        Place solid 6 face 7 vert. polyhedron   17
        Place solid 6 face 8 vert. polyhedron   18
        Place rectangular plane by 3 points     19
        Place parallelogram plane by 3 points   20
        Place solid right angle wedge           21
        Place sphere by center and radius       26
        Place solid globe                       27
        Place solid ellipsoid - foci axis len.  28
        Place solid ellipsoid - ctr. axis rad.  29
        Place right elliptical cylinder         30
        Place trunc. elliptical cone            31
        Place surface of revolution             38
        Place solid of revolution               39
        Place plane tangent to surface          49
        Place plane tangent to curve            50
        Place surface of projection             83
        Place solid of projection               84
        Place plane normal to curve             94
	
 Notes

 This function accesses obscure information placed by the 
 verify function in the events array.
 
 History

 10/28/87 : rlw : The beginning
 12/10/87 : pp  : Changed the arguments to EMplane_of_curve
                  Changed the method calls to place ellipsoids and
                  elliptical cylinder, elliptical cone.
                  Also changed the manner of invoking EMcap_thyself
 12/23/87 : rlw : Made additional ehancements to reduce object size.
                  Modified error handler for capping logic to just delete
                  the surface in case of error in capping.  Asked Prasad to
                  make sure solid takes care of itself.
                  Removed debug statements.
                  Modified to take care of element specific data.
 01/05/88 : rlw : Added some commands
 01/08/88 : sam : Added argument construction# 38 (my_constructed_object)
 01/13/88 : jBk : Changed some OM_BLOCK_MOVE's of size IGRpoint to
                  simple assignment statements in order to fix some
                  memory problems around the stack pointer before
                  people complain.
 01/15/88 : rlw : Put the code back which deletes the surface if capping fails.
                  Modified due to changes in surface/solid of projection
 01/17/88 : rlw : Modified solid of projection to allow for sweeping of
                  planar surfaces.  Changed the delete on the caps to a
                  GRdelete message.
 01/26/88 : rlw : I was trying to cap surface elliptical cylinders and cones.
 01/26/88 : pp  : Changed arguments to EMplane_of_curve from expecting
                  curve_id and module info to GRlc_info.
 01/26/88 : rlw : I was messing up the scale factor for elliptical cones.
 03/22/88 : rlw : Added place conic by linestring command.
                  Modified place plane tangent to curve and surface
                  constructions to use a new method, and added place
                  plane normal to curve.
 05/30/88 : rlw : Modified to read active trim option from the DPB.
                  Also modified project curve onto surface, intersect
                  elements, project curve onto surface along normals,
                  and extract partial surface to use this information.
                  Also turned on status messages for some of these cmds.
                  Modified fillet surface to support variable radius.
 07/28/88 : rlw : Removed Place plane encompassing planar element logic as
                  it's in ECautoplanei.I
 08/05/88 : rlw : Moved data reduction to the modification method
 10/25/88 : DLB : Modified case 19 input parameters (see inline code).
 02/28/89 : rlw : Modified to add conditional compilation statements
                  for the I/DRAW product.
 Sep 5,90:Inasu : Added/modified conditional compilation statements  to
                  include command 33.
 04/10/91 : jhw : Added calls to associative functions for constructions.
 06/03/91 : DLB : Support current_creator.
 08/08/91 : scw : Converted to use gr$dpb associative flag
 01/02/92 : np  : Modified case 84 (place solid of projection)  so that function
                  "EMsweep_surface_with_lift_face" does not notify batch list,
                  which it should not do anyway. It was causing the created 
                  solid to vanish. The global variable "ASbroadcast_in_progress"
                  is temporarily stored to a local variable, then set to "TRUE"
		  and after the solid is created, set to its original saved
		  value. This change may be undone ONLY if the "EMsweep_...."
		  function above is modified so that it does not notify the
		  batch list anymore. After the "EMsweep..." function can handle
                  associative solids of projections from surfaces, then the
		  warning message that the solid of projection is non-assoc. 
                  MUST be removed. Currently, this message comes up if the user
		  selects an assoc. plane for projection in the non-assoc. mode
		  and does the proj. in assoc. mode. Also see comments below.
 5/25/92 Tapadia  Modified EMsweep_surface_via_Lift_face() to 
		  EMsweep_surface_via_lift_face_mod() as I added an argument.
 */

class implementation ECconstruct;

%safe
#include <math.h> 
%endsafe

#include "EMS.h"
#include "ems_m_inc.h"
#include "OMmacros.h"  
#include "EMSdpb.h"     
#include "EMSopt.h"
#include "EC_P.h"		
#include "EC_I.h"		
#include "emssfintdef.h"
#include "emserr.h"
#include "EMSmsgdef.h"
#include "DItypedef.h"
#include "DIdef.h"
#include "EMSasnucdef.h"
#include "EMSasnuc.h"
#include "EMSasopts.h"
#include "REplane.h"
#include "msmacros.h"
#include "msdef.h"
#include "ECmsg.h"
#include "EMSascmacros.h"

from GRgraphics import GRdelete;
from EMSelpcone import EMconstruct_elliptical_cone;
from EMSblock import EMboxby2pt;
from EMSblock import EMboxbyhwd;
from EMSplane import EMplane;
from EMSplane import EMplane_normal_and_tangent_to;
from EMSwedge import EMrtwedge;
from EMScone import EMcone;
from EMScylindr import EMcylinder_by_axis_n_radius;
from EMSsphere import EMsphere_by_center_radius;
from EMSelpsoid import EMelpsd;
from EMStorus import EMtorus_by_axis_center_rad;
from EMSrevol import EMrevolve_curve;
from EMSproject import EMplace_surface_of_projection;
from EMSgenbs import EMboxby4;
from EMSpolyhdrn import EMcvx4f4v;
from EMSpolyhdrn import EMcvx5f5v;
from EMSpolyhdrn import EMcvx5f6v;
from EMSpolyhdrn import EMcvx6f7v;
from EMSpolyhdrn import EMcvx6f8v;

extern OMuword OPP_EMSsubbs_class_id;
extern OMuword OPP_EMSblock_class_id;
extern OMuword OPP_EMSelpcone_class_id;
extern OMuword OPP_EMSproject_class_id;
extern OMuword OPP_EMSrevol_class_id;
extern OMuword OPP_EMSplane_class_id;
extern OMuword OPP_EMSwedge_class_id;
extern OMuword OPP_EMSelpcyl_class_id;
extern OMuword OPP_EMScone_class_id;
extern OMuword OPP_EMScylindr_class_id;
extern OMuword OPP_EMSelpsoid_class_id;
extern OMuword OPP_EMSsphere_class_id;
extern OMuword OPP_EMStorus_class_id;
extern OMuword OPP_EMSgenbs_class_id;
extern OMuword OPP_EMSpolyhdrn_class_id;
extern OMuword OPP_EMSsfsolid_class_id;

extern OM_S_OBJID current_creator;
extern IGRboolean ASbroadcast_in_progress;

method perform_prim_construction()
{
 IGRboolean	assoc_placement;
 extern		void EFextract_points();
 OMuword        space_number;
 IGRlong        sts, msg_loc, *my_msg;
 IGRdouble      radii[2];
 IGRpoint       points[20];
 IGRdouble      *height_vector, *width_vector, *depth_vector;
 GRobjid        *my_constructed_object;
 struct         IGResbs *surface_specific;
 struct         GRvg_construct *cnstrlist;
 struct         GRlc_info *me_event_0_located_object_0;
 struct         GRlc_info *me_event_1_located_object_0;
 struct         GRlc_info *me_event_2_located_object_0;
 struct         GRlc_info *me_event_3_located_object_0;

/*
 * Compiler code reductions
 */

 my_msg = &me->msg;
 cnstrlist = &me->construct_list;
 my_constructed_object = &me->constructed_object;
 me_event_0_located_object_0 = &me->events[0].located_object[0];
 me_event_1_located_object_0 = &me->events[1].located_object[0];
 me_event_2_located_object_0 = &me->events[2].located_object[0];
 me_event_3_located_object_0 = &me->events[3].located_object[0];

/*
 * Initialize
 */

 *my_msg = MSSUCC;
 *my_constructed_object = NULL_OBJID;
 EFextract_points(
  me->number_of_events_input,
  me->events,
  points);
 radii[0] = me->events[2].event.value;  /* Used by cones and cylinders */
 radii[1] = me->events[3].event.value;  /* Ditto */
 space_number = me->construct_env.md_id.osnum;
 surface_specific = (struct IGResbs *) cnstrlist->class_attr;

/*
 gr$get_associative_flag( buffer = &assoc_placement );
*/

 assoc_placement = me->associative;
 
/*
 * I am cheating here and accessing information 
 * placed in obscure places by the verify function.
 */

 width_vector  = &me_event_0_located_object_0->proj_pnt[0];
 height_vector = &me->events[0].located_object[1].proj_pnt[0];
 depth_vector  = &me_event_1_located_object_0->proj_pnt[0];

/*
 * Branch based on the type of construction desired
 */

 switch (me->mytype)
  {
   case  1:
   {
        IGRint                  i;
        struct EMSpoint_info    pts[2];

        for (i=0; i<2; ++i)
        {
            pts[i].type = EMSdatainfo_event;
            pts[i].ptevent = &me->events[i];
        }

        EMplace_box_by_2pts ( &msg_loc,
                              assoc_placement ? NULL : EMSasconst_notassociative,
                              cnstrlist->env_info, 
                              cnstrlist->level,
                              cnstrlist->display,
                              cnstrlist->class_attr,
                              cnstrlist->name,
                              pts,
                              my_constructed_object );
    }
    break;

   case  2:
   case  3:
    {
        IGRint                  i;
        struct EMSpoint_info    pts[4];

        for (i=0; i<4; ++i)
        {
            pts[i].type = EMSdatainfo_event;
            pts[i].ptevent = &me->events[i];
        }

        EMplace_box_by_4pts ( &msg_loc,
                              assoc_placement ? NULL : EMSasconst_notassociative,
                              cnstrlist->env_info, 
                              cnstrlist->level,
                              cnstrlist->display,
                              cnstrlist->class_attr,
                              cnstrlist->name,
                              pts,
                              (me->mytype == 3),
                              my_constructed_object );
    }
    break;

   case  4:
   case  5:
    {
        IGRint                  i;
        IGRdouble               temp;
        struct EMSpoint_info    loc_axis[2];
        struct EMSvalue_info    loc_diams[2];

        /* 
         * For cylinders and cones these are diameters. Ugly huh.
         */
        temp = radii[1];
        radii[1] = radii[0];
        radii[0] = temp;

        for (i=0; i<2; ++i)
        {
            loc_axis[i].type = loc_diams[i].type = EMSdatainfo_event;
            loc_axis[i].ptevent = &me->events[i];
        }

        loc_diams[0].valevent = &me->events[3];
        loc_diams[1].valevent = &me->events[2];

        EMplace_cone_by_axis_and_diams
                            ( &msg_loc,
                              assoc_placement ? NULL : EMSasconst_notassociative,
                              cnstrlist->env_info, 
                              cnstrlist->level,
                              cnstrlist->display,
                              cnstrlist->class_attr,
                              cnstrlist->name,
                              loc_axis,
                              loc_diams,
                              (me->mytype == 5),
                              my_constructed_object );
    }
    break;

   case  6:
   case  7:
    {
    struct EMSpoint_info basept, heightpt;
    struct EMSvalue_info diameter;

    basept.type = EMSdatainfo_event;
    basept.ptevent = &me->events[0];
    heightpt.type = EMSdatainfo_event;
    heightpt.ptevent = &me->events[1];
    diameter.type = EMSdatainfo_event;
    diameter.valevent = &me->events[2];

    sts = EMplace_cylinder ( &msg_loc,
                             assoc_placement ? NULL : EMSasconst_notassociative,
                             cnstrlist->env_info, 
                             cnstrlist->level,
                             cnstrlist->display, 
                             cnstrlist->class_attr, 
                             cnstrlist->name,
                             &basept, 
                             &heightpt, 
                             &diameter, 
                             me->mytype == 6 ? FALSE : TRUE,
                             my_constructed_object);
    }
    break;

   case  8:
   case  9:
    {
        IGRint                  i;
        struct EMSpoint_info    loc_points[3];
        struct EMSvalue_info    loc_radius;

        for (i=0; i<3; ++i)
        {
            loc_points[i].type = EMSdatainfo_event;
            loc_points[i].ptevent = &me->events[i];
        }

        loc_radius.type = EMSdatainfo_event;
        loc_radius.valevent = &me->events[3];

        EMplace_torus_by_axis_center_and_radius
                            ( &msg_loc,
                              assoc_placement ? NULL : EMSasconst_notassociative,
                              cnstrlist->env_info, 
                              cnstrlist->level,
                              cnstrlist->display,
                              cnstrlist->class_attr,
                              cnstrlist->name,
                              loc_points,
                              &loc_points[2],
                              &loc_radius,
                              (me->mytype == 9),
                              my_constructed_object );
    }
    break;

   case 10:
   case 11:
   case 30:
   case 31:
   {
        IGRint                  i;
        IGRint                  is_cone, is_solid;
        struct EMSpoint_info    loc_points[5];

        is_cone  = (me->mytype == 11) || (me->mytype == 31);
        is_solid = (me->mytype == 10) || (me->mytype == 11);
        
        for (i=0; i<5; ++i)
        {
            loc_points[i].type = EMSdatainfo_event;
            loc_points[i].ptevent = &me->events[i];
        }

        EMplace_elliptical_cone ( &msg_loc,
                                  assoc_placement ? NULL : EMSasconst_notassociative,
                                  cnstrlist->env_info, 
                                  cnstrlist->level,
                                  cnstrlist->display,
                                  cnstrlist->class_attr,
                                  cnstrlist->name,
                                  &loc_points[0],
                                  &loc_points[1],
                                  &loc_points[2],
                                  &loc_points[3],
                                  is_cone ? &loc_points[4] : NULL,
                                  is_solid,
                                  my_constructed_object );
    }
    break;

   case 12:
   case 13:
   case 28:
   case 29:
    {
        struct EMSpoint_info    loc_center_focus1, loc_major_focus2;
        struct EMSvalue_info    loc_radius_axis_length;

        loc_center_focus1.type = EMSdatainfo_event;
        loc_center_focus1.ptevent = &me->events[0];

        loc_major_focus2.type = EMSdatainfo_event;
        loc_major_focus2.ptevent = &me->events[1];

        loc_radius_axis_length.type = EMSdatainfo_event;
        loc_radius_axis_length.valevent = &me->events[2];

        EMplace_ellipsoid ( &msg_loc,
                            assoc_placement ? NULL : EMSasconst_notassociative,
                            cnstrlist->env_info, 
                            cnstrlist->level,
                            cnstrlist->display,
                            cnstrlist->class_attr,
                            cnstrlist->name,
                            ((me->mytype == 12) || (me->mytype == 28)) ?
                            EMS_ASellipsoid_by_foci_axis_len :
                            EMS_ASellipsoid_by_center_axis_radius,
                            &loc_center_focus1,
                            &loc_major_focus2,
                            &loc_radius_axis_length,
                            (me->mytype == 28) || (me->mytype == 29),
                            my_constructed_object );
   }
   break;

   case 14:
    sts = om$construct(classid = OPP_EMSpolyhdrn_class_id,
                       p_objid = my_constructed_object,      
                       osnum = space_number);
    if (1 & sts)
    {
      current_creator = *my_constructed_object;
      sts = om$send(msg = message EMSpolyhdrn.EMcvx4f4v(my_msg, cnstrlist,
                          points),
                    targetid = *my_constructed_object,
                    targetos = space_number);
      current_creator = NULL_OBJID;
    }                    
    break;

   case 15:
    sts = om$construct(classid = OPP_EMSpolyhdrn_class_id,
                       p_objid = my_constructed_object,
                       osnum = space_number);
    if (1 & sts)
    {
      current_creator = *my_constructed_object;
      sts = om$send(msg = message EMSpolyhdrn.EMcvx5f5v(my_msg, cnstrlist,
                          points),
                    targetid = *my_constructed_object,
                    targetos = space_number);
      current_creator = NULL_OBJID;
    }                    
    break;

   case 16:
    sts = om$construct(classid = OPP_EMSpolyhdrn_class_id,
                       p_objid = my_constructed_object,
                       osnum = space_number);
    if (1 & sts)
    {
      current_creator = *my_constructed_object;
      sts = om$send(msg = message EMSpolyhdrn.EMcvx5f6v(my_msg, cnstrlist,
                          points),
                    targetid = *my_constructed_object,
                    targetos = space_number);
      current_creator = NULL_OBJID;
    }                    
    break;

   case 17:
    sts = om$construct(classid = OPP_EMSpolyhdrn_class_id,
                       p_objid = my_constructed_object,
                       osnum = space_number);
    if (1 & sts)
    {
      current_creator = *my_constructed_object;
      sts = om$send(msg = message EMSpolyhdrn.EMcvx6f7v(my_msg, cnstrlist,
                          points),
                    targetid = *my_constructed_object,
                    targetos = space_number);
      current_creator = NULL_OBJID;
    }                    
    break;

   case 18:
    sts = om$construct(classid = OPP_EMSpolyhdrn_class_id,
                       p_objid = my_constructed_object,
                       osnum = space_number);
    if (1 & sts)
    {
      current_creator = *my_constructed_object;
      sts = om$send(msg = message EMSpolyhdrn.EMcvx6f8v(my_msg, cnstrlist,
                          points),
                    targetid = *my_constructed_object,
                    targetos = space_number);
      current_creator = NULL_OBJID;
    }                    
    break;

   case 19:
    {
    /*
     * Added by DLB 10/25/88.  Math plane gen. code modifies closest base
     * point to be under height point.  So I move height point to be over
     * base point 0.
     */

    IGRvector unused_vec1, unused_vec2;
    sts = EFmkperp2vec(&me->events[0].event.button.x,
                       &me->events[1].event.button.x,
                       &me->events[2].event.button.x,
                       unused_vec1,
                       unused_vec2);
    if (!(1 & sts)) goto wrapup;
    /*No Break.*/
    }

   case 20:
   {
        IGRint                  i;
        struct EMSpoint_info    pts[3];

        for (i=0; i<3; ++i)
        {
            pts[i].type = EMSdatainfo_event;
            pts[i].ptevent = &me->events[i];
        }

        sts = EMplace_plane_by_3pts ( &msg_loc, 
                                      assoc_placement ? NULL : EMSasconst_notassociative,
                                      cnstrlist->env_info, 
                                      cnstrlist->level,
                                      cnstrlist->display,
                                      cnstrlist->class_attr,
                                      cnstrlist->name,
                                      pts,
                                      (me->mytype == 20),
                                      my_constructed_object );        
    }
    break;

   case 21:
    {
        IGRint                  i;
        struct EMSpoint_info    pts[4];

        for (i=0; i<4; ++i)
        {
            pts[i].type = EMSdatainfo_event;
            pts[i].ptevent = &me->events[i];
        }

        EMplace_right_angle_wedge
                            ( &msg_loc,
                              assoc_placement ? NULL : EMSasconst_notassociative,
                              cnstrlist->env_info, 
                              cnstrlist->level,
                              cnstrlist->display,
                              cnstrlist->class_attr,
                              cnstrlist->name,
                              pts,
                              my_constructed_object );
    }
    break;

   case 26:
   case 27:
    {
        struct EMSpoint_info    center;
        struct EMSvalue_info    radius;

        center.type = EMSdatainfo_event;
        center.ptevent = &me->events[0];

        radius.type = EMSdatainfo_event;
        radius.valevent = &me->events[1];

        sts = EMplace_sphere_by_center_and_radius
                                    ( &msg_loc, 
                                      assoc_placement ? NULL : EMSasconst_notassociative,
                                      cnstrlist->env_info, 
                                      cnstrlist->level,
                                      cnstrlist->display,
                                      cnstrlist->class_attr,
                                      cnstrlist->name,
                                      &center,
                                      &radius,
                                      (me->mytype == 27),
                                      my_constructed_object );
    }
    break;

   case 38:
   case 39:
    {
        struct EMSobject_info   loc_curve;
        struct EMSpoint_info    loc_axis[2];
        struct EMSvalue_info    loc_start, loc_sweep;

        loc_curve.grid = me_event_0_located_object_0->located_obj;
        loc_curve.env  = me_event_0_located_object_0->module_info;
        
        loc_axis[0].type = EMSdatainfo_event;
        loc_axis[0].ptevent = &me->events[1];

        loc_axis[1].type = EMSdatainfo_event;
        loc_axis[1].ptevent = &me->events[2];

        loc_sweep.type = EMSdatainfo_event;
        loc_sweep.valevent  = &me->events[3];

        loc_start.type = EMSdatainfo_event;
        loc_start.valevent  = &me->events[4];
/****************************************************************************
        EMplace_surf_of_revolution
                            ( &msg_loc,
                              assoc_placement ? NULL : EMSasconst_notassociative,
                              cnstrlist->env_info, 
                              cnstrlist->level,
                              cnstrlist->display,
                              cnstrlist->class_attr,
                              cnstrlist->name,
                              &loc_curve,
                               loc_axis,
                              &loc_start,
                              &loc_sweep,
                              (me->mytype == 39),
                              my_constructed_object );
****************************************************************************/
       ems$pl_surf_of_revolution(msg = &msg_loc,
             options = assoc_placement ? NULL : EMSasconst_notassociative,
             construction_list = cnstrlist,
             curve = &loc_curve,
             axis = loc_axis,
             start_angle = &loc_start,
             sweep_angle = &loc_sweep,
             is_solid = (me->mytype == 39),
             rev_obj = my_constructed_object );                       
    }
    break;

   case 49:
   case 50:
   case 94:
    {
        IGRint                  loc_type;
        struct EMSvalue_info    loc_width;
        struct EMSvalue_info    loc_length;
        struct EMSobject_info   loc_curve;
        struct EMSpoint_info    loc_point;

        loc_type = (me->mytype == 49) ? EMS_ASplane_tangent_to_surface :
                   (me->mytype == 50) ? EMS_ASplane_tangent_to_curve :
                                        EMS_ASplane_normal_to_curve;

        loc_length.type = EMSdatainfo_event;
        loc_length.valevent = &me->events[0];

        loc_width.type = EMSdatainfo_event;
        loc_width.valevent = &me->events[1];

        loc_curve.grid = me_event_2_located_object_0->located_obj;
        loc_curve.env  = me_event_2_located_object_0->module_info;

        loc_point.type = EMSdatainfo_event;
        loc_point.ptevent = &me->events[3];

        EMplace_plane_tangent_normal
                            ( &msg_loc,
                              assoc_placement ? NULL : EMSasconst_notassociative,
                              cnstrlist->env_info, 
                              cnstrlist->level,
                              cnstrlist->display,
                              cnstrlist->class_attr,
                              cnstrlist->name,
                              loc_type,
                              &loc_length,
                              &loc_width,
                              &loc_curve,
                              &loc_point,
                              my_constructed_object );
    }
    break;

   case 83:
   case 84:
    {
     IGRboolean         is_surface;
     struct             GRlc_info *lc_info;
     struct             GRid *id;
     struct             GRmd_env *md_env;
     IGRboolean 	save_old_ASbroadcast;

     lc_info = me_event_0_located_object_0;
     id = &lc_info->located_obj;
     md_env = &lc_info->module_info;
     is_surface = me->events[0].located_object[1].geom_parms.polygon_inx;

       /* The lift face operation is somehow putting itself into the 
        * batch list (which it should not) resulting in an update being
        * generated for the solid. The code for ASSOCIATIVELY creating a
        * solid of projection from a surface is not yet implemented, therefore, 
        * during the update, after the solid of projection is removed from the
        * range tree, the newly created associative solid (without any surfaces)
        * is added to the range tree and hence the solid seems to vanish on
        * screen. Solution to this is to:
        * 1. Prevent the user from picking a surface to project in the 
        *    associative mode and
        * 2. Making sure that the functions below are prevented from notifying
        *    the batch list (set ASbroadcast_in_progress = TRUE).
        * 
        * Both have been done. Eventually, somebody has to investigate why
        * the notify is being called within the 
 	* "EMsweep_surface_via_lift_face_mod" code. 
	* Actually, setting ASbroadcast_in_progress need be done only if
        * "is_surface" is true, since surfaces are picked only for placing 
        * solids of proj. and not for placing surfaces of proj.
        */
     save_old_ASbroadcast = ASbroadcast_in_progress; 
     ASbroadcast_in_progress = TRUE;

     if (is_surface)
      {
       extern	IGRlong EMsweep_surface_via_lift_face_mod();

       IGRboolean sym_flag = FALSE;

       sts = EMsweep_surface_via_lift_face_mod(
         lc_info,
         points[1],
         points[3],
         cnstrlist,
         my_id,
         my_constructed_object,
 	 sym_flag, 
         my_msg);

       /* This may need to be removed eventually, when we let the user select
        * surfaces to project as solids. Right now the user cannot pick surfaces
        * in associative mode, but if he decides to pick in non-associative mode
        * and THEN turns off associativity before projection, this message will
        * be displayed. Navin (1/2/92)
        */

       if (me->associative)
       {
         ex$message ( msgnumb = EMS_S_WarnSolPjIsNonAs);
         sleep (2);
       }
      }
     else
      {
        struct EMSobject_info curve;
        struct EMSpoint_info  base, height;

        curve.grid = *id;
        curve.env = *md_env;

        base.type = height.type = EMSdatainfo_event;
        base.ptevent = &me->events[1];
        height.ptevent = &me->events[3];
/*****************************************************************************
        sts = EMplace_surf_of_projection
                                   ( &msg_loc, 
                                     assoc_placement ? NULL : EMSasconst_notassociative,
                                     cnstrlist->env_info, 
                                     cnstrlist->level,
                                     cnstrlist->display,
                                     cnstrlist->class_attr,
                                     cnstrlist->name,
                                     &curve,
                                     &base, 
                                     &height,
                                     (me->mytype == 84),
                                     my_constructed_object );
*****************************************************************************/
        sts = ems$pl_surf_of_prjn(msg = &msg_loc,
                  options = assoc_placement ? NULL : EMSasconst_notassociative,
                  construction_list = cnstrlist,
                  curve = &curve,
                  base_point = &base,
                  height_point = &height,
                  is_solid = (me->mytype == 84),
                  prjn_obj = my_constructed_object ); 
 
      }

      ASbroadcast_in_progress = save_old_ASbroadcast; 
    }
    break;

   default:
    *my_msg = MSFAIL;
    goto wrapup;
  }
 if (! (1 & sts)) goto wrapup;

/*
 * eof
 */

wrapup:
 cnstrlist->class_attr = (IGRchar *) surface_specific;
 if (1 & *my_msg)
  return(OM_S_SUCCESS);
 else
  {
   *my_constructed_object = NULL_OBJID;
   return(OM_E_ABORT);
  }
}

end implementation ECconstruct;
