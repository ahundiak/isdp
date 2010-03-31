/* ###################   APOGEE COMPILED   ################## */
/*
 Description

 This method performs the construction logic
 for the following simple construction commands:

                 Command                      mytype
        ----------------------------------    -------
        Place surface by 3 boundaries           43
        Place surface by 4 boundaries           44
        Blend 2 surfaces - interior             46
        Blend 2 surfaces - exterior             47
        Place Angular parting surface           203
        Place partial surface                   37

        Place offset surface                    45
        code for Place offset surface is moved to
        src_testco/imp ECcsoffseti.I

        Place solid by offsetting surface       109
	
 Notes

 This function accesses obscure information placed by the 
 verify function in the events array.
 
 History

 10/28/87 : rlw : The beginning
 12/23/87 : rlw : Made additional ehancements to reduce object size.
                  Modified error handler for capping logic to just delete
                  the surface in case of error in capping.  Asked Prasad to
                  make sure solid takes care of itself.
                  Removed debug statements.
                  Modified to take care of element specific data.
 01/05/88 : rlw : Added some commands
 01/13/88 : jBk : Changed some OM_BLOCK_MOVE's of size IGRpoint to
                  simple assignment statements in order to fix some
                  memory problems around the stack pointer before
                  people complain.
 01/19/88 : pp  : Removed EMbs3cvs from the system as the function can be
                  served by EMbs4cvs.Made appropriate modification
 02/11/88 : rlw : Fixed a bug where I was pulling the parameter values for
                  blend curve out of the wrong place.
 02/18/88 : rlw : Fixed a bug on blend surface interior.  I was pulling the
                  blend option out of the wrong place.
 05/30/88 : rlw : Modified to read active trim option from the DPB.
                  Also modified project curve onto surface, intersect
                  elements, project curve onto surface along normals,
                  and extract partial surface to use this information.
                  Also turned on status messages for some of these cmds.
                  Modified fillet surface to support variable radius.
 10/Je/88 : jBk : Modified to reflect addition of option argument
                  to EMSsurface.EMoffset_surface and the renaming
                  of said message to EMgenerate_offset_surface.
 06/29/88 : rlw : Added place blending surface command
 07/12/88 : rlw : Added Place reduced fit command
                  Modified offset surface to optionally offset with boundaries
                  Added Place solid by offsetting surface command
 08/05/88 : rlw : Moved data reduction to the modification method
 10/04/88 : rlw : Modified to call Doree's form to allow user to control
                  the shape of blending surfaces.
 12/01/88 : rlw : Moved the place blending surface (105) command to a
                  separate class due to changes in the command.
 09/19/89 : rlw : Removed place fillet surface logic (48) as it has moved 
                  to ECfilletsf in order to support laws.
 21-Sep-89: SM  : Added 'Place angular parting surface'.
 04/20/91 : jhw : Added associative offset and partial surface.
 05/03/91 : DLB : Support current_creator.
 08/08/91 : scw : Converted to use gr$dpb associative flag
 03/19/93 : sam : code for place offset surface (case 45)is moved to
                  src_testco/imp/ECcsoffseti.I. --sampath
 05/09/93 : sam : added arguments to EMplace_offset function call.
 10/05/93 : Skar: Modified to call 'EMplace_shell' instead of 'EMplace_offset'.
                  This takes care of problems with associative construction.
*/

class implementation ECconstruct;

%safe
#include <math.h> 
%endsafe

#include "EMS.h"		/* Shared library stuff */
#include "ems_m_inc.h"          /* Includes everything */
#include "OMmacros.h"           /* OM_BLOCK_MOVE macro */
#include "EMSdpb.h"             /* To get construction parameters */
#include "EMSopt.h"		/* Options for offset with boundary */
#include "EC_P.h"		/* Prompt messages */
#include "EC_I.h"		/* Status messages */
#include "emssfintdef.h"
#include "emserr.h"
#include "EMSmsgdef.h"

/* ********* PADDED ******** */


#include "DIdef.h"
#include "EMSasnucdef.h"
#include "EMSasnuc.h"
#include "EMSasdef.h"
#include "EMSas.h"
#include "EMSdpb.h"
#include "EMSasopts.h"
#include "EMSascmacros.h"

from EMSassoc import EMinit_associative;
from NDnode import NDmove_to_root;

/* End EMS 2.0 */

from GRgraphics import GRdelete;
from EMSslider import EMprocess_form;
from EMSsubbs import EMpartsf;
from EMSsubbs import EMpjptsf;
from EMSsubbs import EMprofile;
from EMSgenbs import EMbs4cvs;
from EMSgenbs import EMblend_surface_interior;
from EMSgenbs import EMblend_surface;
from EMSsubbs import EMcreateAngularPartingSurface;

struct dimension_info
{
  GRobjid    surf;
  IGRpoint   uv_point;
  OMuword    view_index;
};

extern OMuword OPP_EMSslider_class_id;
extern OMuword OPP_EMSsubbs_class_id;
extern OMuword OPP_EMSgenbs_class_id;

extern IGRlong EMselective_fence();

extern OM_S_OBJID current_creator;

method perform_free_construction()
{
 extern		void EFextract_points();
 IGRboolean     trimming_required;
 OMuword        space_number;
 IGRlong        sts, *my_msg;
 IGRdouble      radii[2];
 IGRpoint       points[20];
 GRobjid        *my_constructed_object;
 struct         IGResbs *surface_specific;
 struct         GRvg_construct *my_construct_list;
 struct         GRlc_info *me_event_0_located_object_0;
 struct         GRlc_info *me_event_1_located_object_0;
 struct         GRlc_info *me_event_2_located_object_0;
 struct         GRlc_info *me_event_3_located_object_0;
 IGRboolean	assoc_placement;

/*
 * Compiler code reductions
 */

 my_msg = &me->msg;
 my_construct_list = &me->construct_list;
 my_constructed_object = &me->constructed_object;
 me_event_0_located_object_0 = &me->events[0].located_object[0];
 me_event_1_located_object_0 = &me->events[1].located_object[0];
 me_event_2_located_object_0 = &me->events[2].located_object[0];
 me_event_3_located_object_0 = &me->events[3].located_object[0];

/*
 * Initialize
 */

 *my_msg = MSSUCC;
 trimming_required = FALSE;
 *my_constructed_object = NULL_OBJID;
 EFextract_points(
  me->number_of_events_input,
  me->events,
  points);
 radii[0] = me->events[2].event.value;  /* Used by cones and cylinders */
 radii[1] = me->events[3].event.value;  /* Ditto */
 space_number = me->construct_env.md_id.osnum;
 surface_specific = (struct IGResbs *) my_construct_list->class_attr;

 gr$get_associative_flag( buffer = &assoc_placement );

/*
 * Get the active trim status, if this command requires it.
 * rlw - 05/30/88
 */
#ifndef IDRAW
 if ((me->mytype == 37) ||        /* Partial surface */
     (me->mytype == 45))          /* Offset surface */
  {
   IGRuchar buffer;
   extern	IGRlong EMdpb_get();

   sts = EMdpb_get(
     my_msg,
     EMSdpb_props,
     &buffer);
    if (! (1 & *my_msg)) goto wrapup;
   trimming_required = (buffer & EMDPB_IGNORE_BOUNDARIES) ? FALSE : TRUE;
  }
#endif

/*
 * Branch based on the type of construction desired
 */

 switch (me->mytype)
  {
   case 37:
    {
        IGRint                  i, j;
        struct EMSobject_info   loc_surface;
        struct EMSpoint_info    loc_points[3];

        loc_surface.env  = me_event_0_located_object_0->module_info;
        loc_surface.grid = me_event_0_located_object_0->located_obj;

        for (i=0,j=1; i<3; ++i, ++j)
        {
            loc_points[i].type = EMSdatainfo_event;
            loc_points[i].ptevent = &me->events[j];
        }
/******************************************************************************
        sts = EMplace_partial_surface ( my_msg,
                                        assoc_placement ? NULL : EMSasconst_notassociative,
                                        my_construct_list->env_info,
                                        my_construct_list->level,
                                        my_construct_list->display,
                                        my_construct_list->class_attr,
                                        my_construct_list->name,
                                        &loc_surface,
                                        &loc_points[0],  Start Point 
                                        &loc_points[1],  End Point 
                                        &loc_points[2],  Mid Point 
                                        trimming_required,
                                        my_constructed_object );
******************************************************************************/
        sts = ems$place_partial_surface(msg = my_msg,
                options = assoc_placement ? NULL : EMSasconst_notassociative,
                construction_list = my_construct_list,
                surface = &loc_surface,
                start_point = &loc_points[0],
                end_point = &loc_points[1],
                mid_point = &loc_points[2],
                trimming_required = trimming_required,
                partsf_obj = my_constructed_object );                
            
 
    }
    break;

   case 43:
   case 44:
   {
     struct EMSobject_info list[4];
     IGRint num_roots;
     extern OMuword OPP_EMAgenbs_class_id;

      list[0].grid = me_event_0_located_object_0->located_obj;
      list[0].env = me_event_0_located_object_0->module_info;
      list[1].grid = me_event_1_located_object_0->located_obj;
      list[1].env = me_event_1_located_object_0->module_info;
      list[2].grid = me_event_2_located_object_0->located_obj;
      list[2].env = me_event_2_located_object_0->module_info;
      if (me->mytype == 44)
      {
       list[3].grid = me_event_3_located_object_0->located_obj;
       list[3].env = me_event_3_located_object_0->module_info;
       num_roots = 4;
      }
      else
       num_roots = 3;

      sts = om$construct(classid = OPP_EMAgenbs_class_id,
                         p_objid = my_constructed_object,
                         osnum = space_number);
      if (1 & sts)
      {
        current_creator = *my_constructed_object;
        sts = om$send(msg = message EMSassoc.EMinit_associative(my_msg,NULL,
                            num_roots, list, EMS_ASsurface_by_bound,
                            0,NULL,my_construct_list),
                      targetid = *my_constructed_object,
                      targetos = space_number);
        current_creator = NULL_OBJID;

        if (!assoc_placement)
        {
         struct GRid src_GRid;
         om$send (msg = message NDnode.NDmove_to_root(my_msg,
                        &src_GRid, my_construct_list->env_info),
                  targetid = *my_constructed_object,
                  targetos = space_number);
         if (1&*my_msg)
          *my_constructed_object = src_GRid.objid;
        }
      }
   }
    break;

   case 109:
   case 45:        /* code is moved to src_testco/imp/ECcsoffseti.I 
			    for case 45.*/
    {
        IGRboolean             use_natural;
        struct EMSvalue_info   loc_distance;
        struct dimension_info  dim_info;

        loc_distance.type = EMSdatainfo_event;
        loc_distance.valevent  = &me->events[2];

        use_natural = (me_event_0_located_object_0->geom_parms.polygon_inx) ? 1 : 0;

       /* Set up the dimensioning info. for the surface */
        dim_info.surf = me_event_0_located_object_0->located_obj.objid;
        dim_info.uv_point[0] = 0.0; 
        dim_info.uv_point[1] = 0.0; 
        dim_info.view_index = 1;

       /* Call the construction function */
        sts = EMplace_shell  ( my_msg,
                               assoc_placement ? NULL : EMSasconst_notassociative,
                               my_construct_list->env_info,
                               my_construct_list->name,
			       me_event_0_located_object_0->located_obj.objid,
                               FALSE, use_natural, FALSE,
                               &loc_distance,
			       0, NULL, NULL, NULL, &dim_info,
                               0, NULL,
                               my_constructed_object );
    }
    break;

   case 46:
    {
     IGRboolean curve1_reversed, curve2_reversed;
     IGRshort   alignment_1, alignment_2;
     IGRdouble  *curve1_endpoint, *curve2_endpoint;
     IGRvector  vector_1, vector_2;
     struct     GRlc_info *events_1, *events_6;

     events_1 = me_event_1_located_object_0;
     events_6 = &me->events[6].located_object[0];
     curve1_reversed = events_1->geom_parms.polygon_inx;
     if (curve1_reversed)
      curve1_endpoint = &me->events[1].located_object[1].proj_pnt[0];
     else
      curve1_endpoint = &events_1->proj_pnt[0];
     vector_1[0] = points[3][0] - curve1_endpoint[0];
     vector_1[1] = points[3][1] - curve1_endpoint[1];
     vector_1[2] = points[3][2] - curve1_endpoint[2];
     alignment_1 = me->events[4].event.value;
     curve2_reversed = events_6->geom_parms.polygon_inx;
     if (curve2_reversed)
      curve2_endpoint = &me->events[6].located_object[1].proj_pnt[0];
     else
      curve2_endpoint = &events_6->proj_pnt[0];
     vector_2[0] = points[8][0] - curve2_endpoint[0];
     vector_2[1] = points[8][1] - curve2_endpoint[1];
     vector_2[2] = points[8][2] - curve2_endpoint[2];
     alignment_2 = me->events[9].event.value;
     sts = om$construct(classid =  OPP_EMSgenbs_class_id,
                        p_objid = my_constructed_object,
                        osnum = space_number,
                        msg = message EMSgenbs.EMblend_surface_interior
                             (me_event_0_located_object_0,
                              events_1,
                              vector_1,
                              alignment_1,
                              &me->events[5].located_object[0],
                              events_6,
                              vector_2,
                              alignment_2,
                              my_construct_list));
   }
    break;

   case 47:
    {
     IGRboolean surf1_reversed, surf2_reversed;
     struct     GRlc_info *surf1, *surf2;

     surf1 = me_event_0_located_object_0;
     surf1_reversed = (surf1->geom_parms.polygon_inx ? FALSE : TRUE);
     surf2 = &me->events[4].located_object[0];
     surf2_reversed = (surf2->geom_parms.polygon_inx ? FALSE : TRUE);
/*****************************************************************************
     sts = EFplace_blend_surface_exterior(
              my_msg,
              assoc_placement ? NULL : EMSasconst_notassociative,
              surf1,
              me_event_1_located_object_0->geom_parms.polygon_inx,  Side  
              surf1_reversed,
              points[3],       Blend direction off surface 1 
              surf2,
              me->events[5].located_object[0].geom_parms.polygon_inx,Side  
              surf2_reversed,
              points[7],       Blend direction off surface 1 
              my_construct_list,
              my_constructed_object);
*****************************************************************************/
    sts = ems$pl_blnd_sf_ext(msg = my_msg,
                             surface1 = surf1,
                 side1 = me_event_1_located_object_0->geom_parms.polygon_inx,
                 is_side1_reversed = surf1_reversed,
                 blend_direction_1 = points[3],
                 surface2 = surf2,
                side2 = me->events[5].located_object[0].geom_parms.polygon_inx,
                is_side2_reversed = surf2_reversed,
                blend_direction_2 = points[7],
                options = assoc_placement ? NULL : EMSasconst_notassociative, 
                construction_list = my_construct_list,
                constructed_object = my_constructed_object);                              
    }
    break;

   case 203:
    {
     OMuword		yes_list;
     OM_S_CLASSLIST	yes_classes, no_classes;
     IGRboolean		break_up_composites;
     IGRlong	  	number_of_objects, i;
     IGRlong		number_of_created_objects;
     IGRvector		view_vector;
     struct             GRlc_info *lc_info, *objects;
     struct             GRid *id, *created_objects;
     extern		IGRboolean EFboreline(), BSmkvec(), BSnorvec();
     IGRboolean		status;
     IGRlong		loc_msg;
     IGRpoint		point1, point2;
     struct		IGRline bore_line;

     break_up_composites = TRUE;
     bore_line.point1 = point1;
     bore_line.point2 = point2;
     status = EFboreline(
         my_msg,
         my_id,
         &me->events[1],
         &bore_line);
     if (! status) goto wrapup;
     status = BSmkvec(
       &loc_msg,
       view_vector,
       point1,
       point2);
      if (! status)
       {
       *my_msg = MSFAIL;
       goto wrapup;
       }
     status = BSnorvec(
       &loc_msg,
       view_vector);
      if (! status)
       {
        *my_msg = MSFAIL;
        goto wrapup;
       }

     yes_list = OPP_EMSsurface_class_id;
     yes_classes.p_classes = &yes_list;
     yes_classes.w_count = 1;
     no_classes.w_count = 0;
     no_classes.p_classes = NULL;
     number_of_objects = 0;
     objects = NULL;
     lc_info = me_event_0_located_object_0;
     sts = EMselective_fence(
       &yes_classes,
       &no_classes, 
       lc_info,				/* set_object */
       break_up_composites,
       TRUE,				/* This is a readonly operation */
       my_id,
       &number_of_objects,
       &objects,
       my_msg);
      if (! (1 & sts)) goto wrapup;
     number_of_created_objects = 0;
     created_objects = NULL;
     for (i = 0; i < number_of_objects; i++)
      {
      struct GRlc_info	*nprtl = NULL, *angprtl = NULL;
      IGRint j, i, num_pairs = 0;

       lc_info = &objects[i];
       id = &lc_info->located_obj;

        created_objects = (struct GRid *)om$malloc(size = sizeof(struct GRid));
        created_objects->objid = NULL_OBJID;
	 num_pairs = (me->number_of_events_input - 2)/2;
	 if(num_pairs)
           {
	   nprtl = (struct GRlc_info *)
                   om$malloc(size = num_pairs * sizeof(struct GRlc_info));
	   angprtl = (struct GRlc_info *)
                   om$malloc(size = num_pairs * sizeof(struct GRlc_info));
	   if(!nprtl || !angprtl) 
	     {*my_msg = EMS_E_NoDynamicMemory; goto wrapup;}
	   for(j=0, i=0; i<2*num_pairs; i+=2, j++)
	    {
	     nprtl[j] = me->events[i+2].located_object[0];
	     angprtl[j] = me->events[i+3].located_object[0];	
	    }
	   
           sts = om$send(
             msg = message EMSsubbs.EMcreateAngularPartingSurface(
            		my_msg,
            		&lc_info->module_info,
            		NULL,
	    		my_construct_list, 
            		NULL, 
	    		num_pairs, 
	    		NULL, 
	    		NULL, 
	    		nprtl, 
	    		angprtl, 
	    		NULL, 
	    		NULL,
	    		points[1], 
	    		created_objects, 
	    		NULL), 
            targetid = id->objid,
            targetos = id->osnum);
            if(nprtl) free(nprtl);
	    if(angprtl) free(angprtl);
           }
          if(1&*my_msg&sts) number_of_created_objects = 1;
       if (! (1 & sts)) goto wrapup;
      } /* for (i = 0; i < number_of_objects; i++) */
     if (number_of_objects &&
         objects) free(objects);
     if (number_of_created_objects && created_objects)
      {
       if (number_of_created_objects == 1)
        *my_constructed_object = created_objects[0].objid;
       else
        {
         sts = EFbuild_graphic_group(
          number_of_created_objects,
          NULL,
          created_objects,
          my_construct_list,
          my_constructed_object,
          my_msg);
        }
       free(created_objects);
      }
    }
    break;

   default:
    *my_msg = MSFAIL;
    goto wrapup;
  } /* switch (me->mytype) */
 if (! (1 & sts)) goto wrapup;          /* Just to save code space */

/*
 * Post processing on placment commands
 */

 switch (me->mytype)
  {
   case 46:
   case 47:
    {
     IGRboolean	modify_u_direction, modify_v_direction;
     GRobjid	slider_id;
     IGRdouble	response_data[EX_RESPONSE_DATA_SIZE / 8 + 1]; /* Aligned */
     IGRint	response;
     struct	GRlc_info lc_info;

     modify_u_direction = FALSE;
     modify_v_direction = FALSE;
     if (me->mytype == 46)
      modify_v_direction = TRUE;
     else
      modify_u_direction = TRUE;
     lc_info.located_obj.objid = *my_constructed_object,
     lc_info.located_obj.osnum = space_number;
     lc_info.module_info = *my_construct_list->env_info;
     sts = om$construct(
       classid = OPP_EMSslider_class_id,
       p_objid = &slider_id);
      if (! (1 & sts))
       {
        *my_msg = MSFAIL;
        goto wrapup;
       }
     sts = om$send(
       msg = message EMSslider.init(
        0,
        NULL),
       targetid = slider_id);
      if (! (1 & sts))
       {
        *my_msg = MSFAIL;
        goto wrapup;
       }
     ex$message(msgnumb = EMS_I_00000)	/* Clear field */
     ex$message(msgnumb = EMS_P_00154)	/* Use blend control form */
     sts = om$send(
       msg = message EMSslider.EMprocess_form(
        my_msg,
        &lc_info,
        modify_u_direction,
        modify_v_direction,
        (me->mytype == 34) ? 1 : 0,	/* 1 for curve, 0 for surface */
        &response,
        (IGRchar *)response_data),
       targetid = slider_id);
      if (! (1 & sts))
       {
        *my_msg = MSFAIL;
        goto wrapup;
       }
     sts = om$send(
       msg = message Root.delete(1),
       targetid = slider_id);
      if (! (1 & sts))
       {
        *my_msg = MSFAIL;
        goto wrapup;
       }
     ex$message(msgnumb = EMS_P_00000)	/* Clear field */
    }
   default:
    break;
  } /* switch (me->mytype) */

/*
 * eof
 */
wrapup:
 my_construct_list->class_attr = (IGRchar *) surface_specific;
 if (1 & *my_msg)
  return(OM_S_SUCCESS);
 else
  {
   *my_constructed_object = NULL_OBJID;
   return(OM_E_ABORT);
  }
}

end implementation ECconstruct;
