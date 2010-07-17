/* ###################   APOGEE COMPILED   ################## */
/*
 Description

 This method performs the construction logic
 for the following simple construction commands:

                 Command                      mytype
        ----------------------------------    -------
        Rho conic                               22
        Conic by 3 points and 2 tangents        23
        Conic by 4 points and 1 tangent         24
        Conic by 5 points                       25
        Place part of curve                     32
        Place parabola tangent to 2 curves      33
        Place blend between 2 curves            34
        Place helix                             36
        Project curve onto surface along norm   40
        Project point along vector onto surf    41
        Project curve along vector onto surf    42
        Extract iso curves                      52
        Intersect elements                      85
        Create wireframe model                  112
        Place parting lines as curves           113
        Place parting lines as features         201
        Display isophotes                       202
        Place conic by linestring               93

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
 02/24/88 : rlw : Fixed a bug in place parabola tangent to 2 curves.  I was
                  pulling the tangent parameters out of the wrong place.
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
 08/01/88 : rlw : Added Create wireframe model command, note that this
                  was originally witten by Sunit on 01/21/88.
                  Added Place parting lines command (waiting on Allen for
                  the method).
 08/05/88 : rlw : Moved data reduction to the modification method
 08/17/88 : AIC : Added EMprofile send for Place parting lines.
 08/29/88 : rlw : Added additional question for sweep direction of helix.
 10/10/88 : rlw : Modified to call Doree's form to allow user to control
                  the shape of blending curves.
 11/28/88 : rlw : Modified extract iso curve to support trimming to boundaries.
 02/28/89 : rlw : Modified to add conditional compilation statements
                  for the I/DRAW product.
 08/01/89 : pp  : Added a command to place angular parting lines.
 08/16/89 : pp  : Modified the project curve onto surface command to
                  let the user identify an infinite plane and to support
                  sets for curves.
 Sep 5,90:Inasu : Added/modified conditional compilation statements  to
                  include command 33.
 08/30/91: Jack : Moved the code to determine the view vector so that it
                  is calculated as well for the case of Create Wireframe
                  Model.  The view vector is needed farther down for
                  horizon edges.
 11/28/91: Jack : Reacted to parameter change for EMprofile.  Changed
                  window_id to num_vectors. 
 06/03/93:Sudha : Modified for adding BSprototype headers
 04/20/94: Vadi : 'breakup-composites' only if it isn't 'Create wireframe'.
 */

class implementation ECconstruct;

%safe
#include <math.h> 
%endsafe

#include "EMS.h"		/* Shared library stuff */
#include "ems_m_inc.h"          /* Includes everything */
#include "EMScnc5input.h"       /* Defines for conic placement method */
#include "OMmacros.h"           /* OM_BLOCK_MOVE macro */
#include "EMSdpb.h"             /* To get construction parameters */
#include "EMSopt.h"
#include "emseligible.h"	/* Make wireframe requires */
#include "emssfcvs.h"		/* Make wireframe requires */
#include "EC_P.h"		/* Prompt messages */
#include "EC_I.h"		/* Status messages */
#include "emssfintdef.h"
#include "emserr.h"
#include "EMSmsgdef.h"
#include "EMSasopts.h"           /* For EMSasconst_nonassociative */
#include "EMSifmacros.h"
#include "EMSascmacros.h"
#include "madetplan.h"
#include "bsparameters.h"
#include "bsnorvec.h"
#include "bsmkvec.h"

from GRgraphics import GRdelete;
from GRsubbc import EMgenConicBy5inputs;
from GRsubbc import EMconic_by_linestring;
from GRsubbc import EMprb2crvs;
#ifndef IDRAW
from GRsubbc import EMblnd2cvs;
from GRsubbc import EMplace_helix_curve;
from GRcurve import EMpartofcv;
from EMSslider import EMprocess_form;
from EMSsurface import EMmake_wire_frame;
from EMSsubbs import EMproject_curve_along_surface_normals;
from EMSsubbs import EMpjptsf;
from EMSsubbs import EMproject_curve_onto_surface;
from EMSsubbs import EMisoparcvs;
from EMSsubbs import EMprofile;
from EMSsubbs import EMcreate_isophotes;
#endif

extern OMuword OPP_GRbcsubbc_class_id;
extern short _Pathway, _pathway_trim, _pathway_orient;

extern IGRboolean  VS_STRUDL_process;
/*
  Added by Raju - 11/17/95
  External variable;  Set to TRUE during drawing extraction. Defaults to
FALSE. If it is TRUE, the downloaded EMS methods understand that they
are being called for drawing extraction and behave accordingly. When FALSE
their behavior is that of EMS' behavior.
*/

#ifndef IDRAW
extern OMuword OPP_EMSslider_class_id;
#endif

/*extern		IGRlong EMselective_fence();*/

method perform_wframe_construction()
{
 extern		void EFextract_points();
 /*extern		IGRlong EFbuild_graphic_group();*/
 OMuword        space_number;
 IGRboolean     trimming_required;
 IGRlong        sts, *my_msg;
 IGRdouble      radii[2];
 IGRpoint       points[20];             /* A conservative estimate */
 IGRvector      *height_vector, *width_vector, *depth_vector;
 GRobjid        *my_constructed_object;
 struct         IGResbs *surface_specific;
 struct         IGResbc curve_specific;
 struct         GRvg_construct *my_construct_list;
 struct         GRlc_info *me_event_0_located_object_0;
 struct         GRlc_info *me_event_1_located_object_0;
 struct         GRlc_info *me_event_2_located_object_0;
 struct         GRlc_info *me_event_3_located_object_0;

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
 curve_specific.is_polydis = surface_specific->is_polydis;
 curve_specific.is_curvedis = TRUE;
 my_construct_list->class_attr = (IGRchar *) &curve_specific;

/*
 * Get the active trim status, if this command requires it.
 * rlw - 05/30/88
 */

#ifndef IDRAW
 if ((me->mytype == 40) ||        /* Project along normals */
     (me->mytype == 42) ||        /* Project along vector */
     (me->mytype == 52) ||        /* Extract iso curve */
     (me->mytype == 85) ||        /* Intersect elements */
     (me->mytype == 113)||        /* Place parting lines as curves */
     (me->mytype == 201)||        /* Place parting lines as features */
     (me->mytype == 202))         /* Place angular parting lines */
  {
   IGRuchar buffer;
   IGRboolean   ignore_boundaries;
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
 * I am cheating here and accessing information 
 * placed in obscure places by the verify function.
 */

 width_vector  = (IGRvector *)&me_event_0_located_object_0->proj_pnt[0];
 height_vector = (IGRvector *)&me->events[0].located_object[1].proj_pnt[0];
 depth_vector  = (IGRvector *)&me_event_1_located_object_0->proj_pnt[0];

/*
 * Branch based on the type of construction desired
 */
 switch (me->mytype)
  {
   case 22:
   case 23:
   case 24:
   case 25:
    {
     IGRlong    option;

     switch (me->mytype)
      {
       case 22:
        option = EMSconic_by_22Rho;
        break;
       case 23:
        option = EMSconic_by_32;
        break;
       case 24:
        option = EMSconic_by_41;
        break;
       case 25:
        option = EMSconic_by_50;
        break;
      } /* switch (me->mytype) */
      sts = om$construct(
       classid =  OPP_GRbcsubbc_class_id,
       msg = message GRsubbc.EMgenConicBy5inputs(
        my_construct_list,
        option,
        points,
        me->events[4].event.value,
        my_constructed_object),
       p_objid = my_constructed_object,
       osnum = space_number);
     }
    break;

#ifndef IDRAW
   case 32:
    {
     struct             GRlc_info *lc_info;
     struct             GRid *id;
     struct             GRmdenv_info *mdenv_info;

     lc_info = me_event_0_located_object_0;
     id = &lc_info->located_obj;
     mdenv_info = &lc_info->module_info.md_env;
     sts = om$send(
       msg = message GRcurve.EMpartofcv(
        my_msg,
        &mdenv_info->matrix_type,
        mdenv_info->matrix,
        my_construct_list,
        &me_event_1_located_object_0->geom_parms,
        &me_event_3_located_object_0->geom_parms,
        &me_event_2_located_object_0->geom_parms,
        my_constructed_object),
       targetid = id->objid,
       targetos = id->osnum);
    }
    break;
#endif

/* The followings  case is included for MDS -Inasu, Sept 5,1990 */
   case 33:
    {
     IGRdouble          u1, u2;
     struct             GRlc_info *lc_info;
     struct             GRid *id1, *id2;
     struct             GRmd_env *md_env1, *md_env2;

     lc_info = me_event_0_located_object_0;
     id1 = &lc_info->located_obj;
     md_env1 = &lc_info->module_info;
     u1 = me_event_1_located_object_0->geom_parms.u;
     lc_info = me_event_2_located_object_0;
     id2 = &lc_info->located_obj;
     md_env2 = &lc_info->module_info;
     u2 = me_event_3_located_object_0->geom_parms.u;
     sts = om$construct(
       classid =  OPP_GRbcsubbc_class_id,
       msg = message GRsubbc.EMprb2crvs(
        my_msg,
        md_env1,
        md_env2,
        *id1,
        *id2,
        u1,
        u2,
        my_construct_list),
      p_objid = my_constructed_object,
      osnum = space_number);
    }
    break;

#ifndef IDRAW
   case 34:
    {
     IGRdouble          u1, u2;
     struct             GRlc_info *lc_info;
     struct             GRid *id1, *id2;
     struct             GRmd_env *md_env1, *md_env2;

     lc_info = me_event_0_located_object_0;
     id1 = &lc_info->located_obj;
     md_env1 = &lc_info->module_info;
     u1 = me_event_1_located_object_0->geom_parms.u;
     lc_info = me_event_3_located_object_0;
     id2 = &lc_info->located_obj;
     md_env2 = &lc_info->module_info;
     u2 = me->events[4].located_object[0].geom_parms.u;
     sts = om$construct(
       classid =  OPP_GRbcsubbc_class_id,
       msg = message GRsubbc.EMblnd2cvs(
        my_msg,
        md_env1,
        md_env2,
        *id1,
        *id2,
        u1,
        u2,
        points[2],
        points[5],
        my_construct_list),
      p_objid = my_constructed_object,
      osnum = space_number);
    }
    break;

   case 36:
    {
     IGRboolean		ccw;
     IGRlong    	number_of_pitches;

     number_of_pitches = me->events[6].event.value;
     ccw = me->events[7].located_object[0].geom_parms.polygon_inx;
     sts = om$construct(
       classid = OPP_GRbcsubbc_class_id,
       msg = message GRsubbc.EMplace_helix_curve(
        points[0],
        points[1],
        points[2],
        radii[1],
        me->events[4].event.value,
        me->events[5].event.value,
        number_of_pitches,
        ccw,
        my_construct_list),
       p_objid = my_constructed_object,
       osnum = space_number);
    }
    break;

   case 40:
    {
     GRobjid            *objects;
     IGRlong            number_of_objects;
     struct             GRlc_info *curve, *surface;
     struct             GRid *id;

     objects = NULL;
     number_of_objects = 0;
     curve = me_event_0_located_object_0;
     surface = me_event_1_located_object_0;
     id = &surface->located_obj;
     sts = om$send(
       msg = message EMSsubbs.EMproject_curve_along_surface_normals(
        curve,
        surface,
        my_construct_list,
        TRUE,                   /* want status messages */
        trimming_required,      /* trimming required */
        &number_of_objects,
        &objects,
        my_msg),
       targetid = id->objid,
       targetos = id->osnum);
      if (! (1 & sts)) goto wrapup;
     if (number_of_objects && objects)
      {
       if (number_of_objects == 1)
        *my_constructed_object = objects[0];
       else
        {
/************************************************************************
         sts = EFbuild_graphic_group(
          number_of_objects,
          objects,
          NULL,
          my_construct_list,
          my_constructed_object,
          my_msg);
************************************************************************/
         sts = ems$build_graphic_group(
                         number_of_objects = number_of_objects,
                                   objects = objects,
                                    construction_args = my_construct_list,
                                    constructed_object = my_constructed_object,
                                                msg = my_msg);
        }
       free(objects);
      }
    }
    break;

   case 41:
    {
     IGRlong            number_of_points;
     IGRpoint           *intersection_points;
     struct             GRlc_info *lc_info;
     struct             GRid *id;
     struct             GRmd_env *md_env;

     lc_info = me_event_0_located_object_0;
     id = &lc_info->located_obj;
     md_env = &lc_info->module_info;
     number_of_points = 0;
     intersection_points = NULL;
     sts = om$send(
       msg = message EMSsubbs.EMpjptsf(
        my_msg,
        md_env,
        points[1],
        points[2],
        points[3],
        &number_of_points,
/***** ANSI C fix ******/
        (IGRdouble **)&intersection_points,
        NULL,                   /* Don't want u parameters */
        NULL),                  /* Don't want v parameters */
       targetid = id->objid,
       targetos = id->osnum);
      if (! (1 & sts)) goto wrapup;
     if (number_of_points && intersection_points)
      {
       IGRlong  loc_msg;
       extern	IGRlong EMoutput_point();
       struct   GRid *objects;

       objects = (struct GRid *) malloc(sizeof(struct GRid) * number_of_points);
        if (!objects)
         {
          free(intersection_points);
          *my_msg = MANOMEMORY; 
          goto wrapup;
         }
       sts = EMoutput_point(
         &loc_msg,
         my_id,
         my_construct_list,
         number_of_points,
         intersection_points,
         objects);
       free(intersection_points);
        if (! sts) 
         {
          free(objects);
          goto wrapup;
         }
       if (number_of_points == 1)
        *my_constructed_object = objects[0].objid;
       else
        {
/***************************************************************************
         sts = EFbuild_graphic_group(
          number_of_points,
          NULL,
          objects,
          my_construct_list,
          my_constructed_object,
          my_msg);
***************************************************************************/
         sts = ems$build_graphic_group(
                         number_of_objects = number_of_points,
                                   objids = objects,
                                construction_args = my_construct_list,
                                constructed_object = my_constructed_object,
                                            msg = my_msg);
        }
       free(objects);
      } /* if (number_of_points) */
    }
    break;

   case 42:
    {

#define BUFF_SIZE 10

     OMuword		yes_list;
     OM_S_CLASSLIST	yes_classes, no_classes;
     GRobjid            *objects;
     IGRlong            number_of_objects,num_cv_obj;
     IGRint             i;
     struct             GRlc_info *lc_info, *surface,*cv_obj_info = NULL;
     struct             GRid *id,*cvid;
     GRobjid            obj_buff[BUFF_SIZE];

     objects = NULL;
     number_of_objects = 0;
     surface = me_event_3_located_object_0;

     id = &surface->located_obj;
     points[5][0] -= points[4][0];      /* Projection vector */
     points[5][1] -= points[4][1];
     points[5][2] -= points[4][2];
 
     yes_list = OPP_GRcurve_class_id;
     yes_classes.p_classes = &yes_list;
     yes_classes.w_count = 1;
     no_classes.w_count = 0;
     no_classes.p_classes = NULL;
     num_cv_obj = 0;
     cv_obj_info = NULL;
     lc_info = &me->events[6].located_object[0];
/***************************************************************************
     sts = EMselective_fence(
       &yes_classes,
       &no_classes, 
       lc_info,				 set_object 
       FALSE,
       TRUE,			 This is a readonly operation 
       my_id,
       &num_cv_obj,
       &cv_obj_info,
       my_msg);
***************************************************************************/
     sts = ems$selective_fence(
                       yes_classes = &yes_classes,
                       no_classes = &no_classes,
                         set_object = lc_info,
                         senderid = my_id,
                       number_of_objects = &num_cv_obj,
                                 objects = &cv_obj_info,
                                     msg = my_msg);  
      if (! (1 & sts))
       goto wrapup;

     for (i = 0; i < num_cv_obj; i++)
      {
       lc_info = &cv_obj_info[i];
       cvid = &lc_info->located_obj;

       if (id->objid != NULL_OBJID)
       {
        sts = om$send(
          msg = message EMSsubbs.EMproject_curve_onto_surface(
           lc_info,
           surface,
           my_construct_list,
           points[5],
           TRUE,                   /* want status messages */
           trimming_required,      /* trimming required */
           &number_of_objects,
           &objects,
           my_msg),
        targetid = id->objid,
        targetos = id->osnum);
       if (! (1 & sts))
       {
         if (objects) free (objects);
         goto wrapup;
       }
      }
      else /* Projecting onto infinite plane */
      {
       struct IGRplane pln;
       IGRpoint point_buff;
       IGRvector normal_buff;
       IGRdouble tol;
       IGRlong no_pts = 3;
       struct GRid output_obj;

       if (i == 0)
       {
         pln.point = point_buff;
         pln.normal = normal_buff;

         sts = BSEXTRACTPAR(my_msg, BSTOLLENVEC,tol);

         sts = MAdetplane(my_msg,(IGRdouble *)points,&no_pts,&tol,&pln);
         if (!(1&sts)) goto wrapup;

         if (num_cv_obj < BUFF_SIZE)
          objects = obj_buff;
         else
         {
          objects = (GRobjid *)om$malloc (size = sizeof (GRobjid) * num_cv_obj);
          if (!objects)
          {
           sts = OM_E_ABORT;
           goto wrapup; 
          }
         }
       }

       EFproject_any_curve_on_planen(my_msg,my_construct_list,
             &lc_info->located_obj, &lc_info->module_info,&pln,points[5],
             &output_obj,NULL);
       if (1&*my_msg)
       {
        objects[number_of_objects] = output_obj.objid;
        ++number_of_objects;
       }
       else if (*my_msg == MANOSOLUTION)
        *my_msg = MSSUCC;
       else
       {
        if (objects && (objects != obj_buff)) free (objects);
        goto wrapup;
       }
     }
    }

     if (number_of_objects && objects)
      {
       if (number_of_objects == 1)
        *my_constructed_object = objects[0];
       else
        {
/**************************************************************************
         sts = EFbuild_graphic_group(
          number_of_objects,
          objects,
          NULL,
          my_construct_list,
          my_constructed_object,
          my_msg);
**************************************************************************/
         sts = ems$build_graphic_group(
                         number_of_objects = number_of_objects,
                                   objects = objects,
                                   construction_args = my_construct_list,
                                   constructed_object = my_constructed_object,
                                       msg = my_msg);  
        }
       if (objects != (obj_buff))
       free(objects);
      }
/* fix for mlk */
    if(cv_obj_info)
      {
      om$dealloc(ptr = cv_obj_info);
      cv_obj_info = NULL;
      }

    }
    break;

   case 52:
    {
     IGRboolean             use_u_curve;
     IGRlong            number_of_parameters;
     struct             GRlc_info *lc_info;
     struct             GRparms rangeparms, extparms;

     lc_info = me_event_0_located_object_0;
     use_u_curve = lc_info->geom_parms.polygon_inx;
     number_of_parameters = radii[1];

     extparms   = me_event_1_located_object_0->geom_parms;
     rangeparms = me->events[4].located_object[0].geom_parms;
     number_of_parameters = radii[1];
/***************************************************************************
     sts = EFiso_parametric_curves(my_msg,
            me->associative ? NULL : EMSasconst_notassociative,
            trimming_required,
            use_u_curve,
            lc_info,  Surface 
            number_of_parameters, number of parameters             
            (use_u_curve ? extparms.u   : extparms.v),
            (use_u_curve ? rangeparms.u : rangeparms.v),
            my_construct_list, 
            my_constructed_object);
***************************************************************************/
     sts = ems$iso_parametric_curves(msg = my_msg,
                             surface = lc_info,
                           use_u_curve = use_u_curve,
                           num_param = number_of_parameters,
                start_param = (use_u_curve ? extparms.u   : extparms.v),
                end_param = (use_u_curve ? rangeparms.u : rangeparms.v),
                trimming_required = trimming_required,
                options = me->associative ? NULL : EMSasconst_notassociative,
                construction_list = my_construct_list,
                resultant_obj = my_constructed_object);           
      if (! (1 & sts)) goto wrapup;
    }
    break;
#endif

   case 85:
    {
/****************************************************************************
     sts = EFassociative_intersect_elements(
              my_msg,
              me->associative ? NULL : EMSasconst_notassociative,
              trimming_required,
              me_event_0_located_object_0,
              me_event_1_located_object_0,
              my_construct_list,
              my_constructed_object);
****************************************************************************/
     if (_Pathway)
     {
       _pathway_trim = 1;
       if (trimming_required)
       _pathway_orient = 1;
     }
     sts = ems$assoc_intersect_elements(msg = my_msg,
                       elem1_info = me_event_0_located_object_0,
                       elem2_info = me_event_1_located_object_0,
                       trimming_required = trimming_required,     
                  options = me->associative ? NULL : EMSasconst_notassociative,
                  construction_list = my_construct_list,
                  resultant_obj = my_constructed_object); 
     if (_Pathway)
     {
       _pathway_trim   = 0;
       _pathway_orient = 0;
     }
     if (! (1 & sts)) goto wrapup;
     if (*my_msg == EMS_I_Interrupt)
      {
       ex$message (msgnumb = EMS_I_ProcessingInterrupt);
       ems_sleep (2);
      }

     if (*my_msg == EMS_I_NoSolution)
     {
       *my_constructed_object = NULL_OBJID;
       *my_msg = MSSUCC;
     }
    }
    break;

   case 93:
    sts = om$construct(
      classid =  OPP_GRbcsubbc_class_id,
      msg = message GRsubbc.EMconic_by_linestring(
       0,                       /* No input points */
       NULL,                    /* No input points */
       me_event_0_located_object_0,
       my_construct_list,
       my_constructed_object),
     p_objid = my_constructed_object,
     osnum = space_number);
    break;

#ifndef IDRAW
   case 112:
   case 113:
   case 201:
   case 202:
    {
     OMuword		yes_list;
     OM_S_CLASSLIST	yes_classes, no_classes;
     IGRshort		option;
     IGRboolean		break_up_composites;
     IGRlong	  	number_of_objects, i, buffer_size;
     IGRlong		number_of_created_objects;
     IGRvector		view_vector;
     struct             GRlc_info *lc_info, *objects;
     struct             GRid *id, *created_objects;
     struct		EMScurveinfo curve_info;

     if (me->mytype == 112)
      {
       break_up_composites = FALSE;
       option = EMSeligible_NonSeamEdge |
                EMSeligible_NonDegenerateEdge | EMSeligible_UseMsc;
       buffer_size = 0;
       curve_info.messg_linestr = NULL;
       curve_info.messg_gencrv = NULL;
       curve_info.construct_list = my_construct_list;
       curve_info.linestr.objid = NULL_OBJID;
       curve_info.gencrv.objid = NULL_OBJID;
       curve_info.linestr_counter = 0;
       curve_info.gencrv_counter = 0;
       curve_info.curves = (struct GRid **) &created_objects;
       curve_info.buf_size = (IGRlong *) &buffer_size;
       curve_info.num_curves = (IGRlong *) &number_of_created_objects;
      } /* if (me->mytype == 112) */


      /* this used to be done for the else condition of the above if.
         now we want to do it all the time.
       */  
      {
extern IGRboolean EFboreline() ;
       IGRboolean	status;
       IGRlong		loc_msg;
       IGRpoint		point1, point2;
       struct		IGRline bore_line;

       break_up_composites = TRUE;
       bore_line.point1 = point1;
       bore_line.point2 = point2;
       status = EFboreline(
           my_msg,
           my_id,
           &me->events[0],
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
      } /* end block to calculate view vector */

     if (me->mytype == 112)
      {
       curve_info.view_vector = view_vector;
       break_up_composites = FALSE;
      } /* if (me->mytype == 112) */

     yes_list = OPP_EMSsurface_class_id;
     yes_classes.p_classes = &yes_list;
     yes_classes.w_count = 1;
     no_classes.w_count = 0;
     no_classes.p_classes = NULL;
     number_of_objects = 0;
     objects = NULL;
     lc_info = me_event_0_located_object_0;
/***************************************************************************
     sts = EMselective_fence(
       &yes_classes,
       &no_classes, 
       lc_info,				 set_object 
       break_up_composites,
       TRUE,				 This is a readonly operation 
       my_id,
       &number_of_objects,
       &objects,
       my_msg);
******************************************************************************/
     sts = ems$selective_fence(
                       yes_classes = &yes_classes,
                        no_classes = &no_classes,
                       set_object = lc_info,
                     break_down_composites = break_up_composites,
                             senderid = my_id,
                        number_of_objects = &number_of_objects,
                                  objects = &objects,
                                      msg = my_msg);                  
      if (! (1 & sts)) goto wrapup;
     number_of_created_objects = 0;
     created_objects = NULL;
     for (i = 0; i < number_of_objects; i++)
      {
       lc_info = &objects[i];
       id = &lc_info->located_obj;
       if (me->mytype == 112)
        {

	 if ( VS_STRUDL_process )
	 {
/* ALAIN FALASSE 13 April 94 : must do it since I removed it from
   method EMSsurface.EMmake_wire_frame ...
 */
		option |= EMSeligible_NonSubEdge;
/* END ALAIN FALASSE */
	 }

         sts = om$send(
           msg = message EMSsurface.EMmake_wire_frame(
            my_msg,
            &lc_info->module_info,
            &curve_info,
            option),
           targetid = id->objid,
           targetos = id->osnum);
        } /* if (me->mytype == 112) */

       else if (me->mytype == 202)
       {
        IGRdouble start_angle;
        IGRdouble stop_angle;
        IGRint incmnt;
        IGRushort options = FALSE;

        start_angle = me->events[2].event.value;

        if (!me->events[3].located_object[0].geom_parms.polygon_inx)
        {
          stop_angle = me->events[3].event.value;
          incmnt = me->events[4].event.value - 2;
          if (incmnt < 0)
          {
            incmnt = 0;
            stop_angle = start_angle;
          }
        }
        else
        {
          stop_angle = start_angle;
          incmnt = 0;
        }
        if (!trimming_required) options |= EMSignoreBoundaries;

        sts = om$send (msg = message EMSsubbs.EMcreate_isophotes(my_msg,
                             &lc_info->module_info,
	                     my_construct_list,
                             options,view_vector,
                             start_angle,stop_angle,incmnt,
                             (IGRint *)&number_of_created_objects, 
                             &created_objects),
                       targetid = id->objid,
                       targetos = id->osnum);
        if (*my_msg == EMS_I_Interrupt)
        {
          ex$message (msgnumb = EMS_I_ProcessingInterrupt);
          ems_sleep (2);
          break;
        }
        
       }
       else
        {
         IGRshort	options;

	 if(me->mytype == 113)
	   options = EMSplaceProfileCurves;
	 else
	   options = EMSplaceProfileFeatures;
         if (! trimming_required) options |= EMSignoreBoundaries;
	 sts = om$send(
	   msg = message EMSsubbs.EMprofile(
	     my_msg,
	     &lc_info->module_info,
	     my_construct_list,
             1,
/* 	     &me->window_id, */
	     &view_vector,
             options,
             (IGRint *)&number_of_created_objects, 
             &created_objects),
           targetid = id->objid,
           targetos = id->osnum);
        } /* ELSE FOR if (me->mytype == 112) */

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
/***************************************************************************
         sts = EFbuild_graphic_group(
          number_of_created_objects,
          NULL,
          created_objects,
          my_construct_list,
          my_constructed_object,
          my_msg);
*****************************************************************************/
         sts = ems$build_graphic_group(
                           number_of_objects = number_of_created_objects,
                                     objids = created_objects,
                                 construction_args = my_construct_list,
                                 constructed_object = my_constructed_object,
                                               msg = my_msg);   
        }
       free(created_objects);
      }
    }
    break;
#endif
   default:
    *my_msg = MSFAIL;
    goto wrapup;
  } /* switch (me->mytype) */
 if (! (1 & sts)) goto wrapup;          /* Just to save code space */

/*
 * Post processing on placment commands
 */
#ifndef IDRAW
 switch (me->mytype)
  {
   case 34:
    {
     IGRboolean	modify_u_direction, modify_v_direction;
     GRobjid	slider_id;
     IGRdouble	response_data[EX_RESPONSE_DATA_SIZE / 8 + 1]; /* Aligned */
     IGRint	response;
     struct	GRlc_info lc_info;

     modify_u_direction = TRUE;
     modify_v_direction = FALSE;

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
        1,	/* 1 for curve */
        (IGRint *)&response,
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
#endif

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
