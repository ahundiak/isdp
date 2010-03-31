/* ###################   APOGEE COMPILED   ################## */
/*
 Description

 This command supports the following intersect plane options:

 1) Trim - curves, composite curves, surfaces, composite surfaces, solids
 2) No trim - curves, composite curves, surfaces, composite surfaces, solids
 3) Save side - surfaces, solids
 4) Cross section - surfaces, composite surfaces, solids

 The plane may be input by 3 points or by using a multiple element
 event generator, e.g. all elements in file, fence, by objects.  
 I determine the plane of each of the objects and intersect the other 
 set with each of the planes.  If any of the elements are not planar
 then I just skip that element.

 If the plane is input by points and the option is not save side then
 I allow the user to specify that multiple parallel cuts are to
 take place.

 The objects may be input by identifying a single object or by using
 a multiple element event generator.  If one of the elements is not
 supported I merely skip it.

 History

08/14/94 scw       clarified sleep method
06/03/92 Rustagi : Changed the name of the function 'EMintersect_with_plane'
                   to 'EMintersect_with_plane_mod' as argument `bool_options'
                   being added to the original function. Defined variable
                   bool_options and initialised it to EMSsfbool_opt_display.
22 May 1989  jBk   Changed from use of GRgetevent to co$getevent,
                   including modification to use new value_type
                   argument.

                   Changed comment from referring to GRlclocate to
                   refer to lc$locate.

 rlw : ??/??/86  : The beginning
 sm  : 05/??/87  : Modified to do state tree stuff and to use sfsf int
 rlw : 06/03/87  : Modified prompts and added erase highlight plane logic
 rlw : 04/28/88  : Changed to use message subsystem, combined in cross section
                   command, made performance and code optimizations, repaired
                  such that reference files are supported, added fence
                  and graphic group support, and added support for parallel
                  multiple cuts.
 rlw : 08/02/88 : Modified to support locate by element name
 SM  : 29-Nov-88: Pass FALSE to EMintersect_with_plane() function for the
                  flag 'redraw_save_side_objects_on_failure' because the
                  method now provides selective display. Also commected out
                  the part where located surface/solid was erased for
                  save side, due to the same reason.
 rlw : 01/24/89 : Modified to allow rigid children for some cases
 DLB : 05/17/91 : Add LC_ASSOC and LC_EXTERN_CONSTRAINED if int pl - s s.
 pp  : 07/02/91 : Added support for associativity button
 mrm : 07/18/91 : Change user interface of ip-ss to use an arrow to indicate
                  which side of the plane to save
 Sudha 07/05/93 : Modified for BSprototypes ansification

 */

class implementation COintplane;

#include "EMS.h"
%safe
#include <math.h>       /* For fabs() */
%endsafe
#include "EC_F.h"
#include "EC_I.h"
#include "EC_M.h"
#include "EC_P.h"
#include "EMSdpb.h"     /* To get trim parameter */
#include "local_dsp.h"  /* Local display macro */
#include "exmacros.h"   /* Has ex$putque */
#include "dpmacros.h"   /* Has dp$erase_hilite */
#include "msmacros.h"   /* Has message subsystem macros */
#include "maerr.h"      /* MANOMEMORY */
#include "OMmacros.h"   /* Has OM_BLOCK_MOVE macro */
#include "lcdef.h"      /* For locate */
#include "lc.h"         /* For locate */
#include "lcmacros.h"   /* For locate */
#include "grgsdef.h"    /* Needed for the macros */
#include "grgsmacros.h" /* gr$gsput_locate_criteria() */
#include "emsdef.h"     /* GRgrset_to_owners */
#include "griomacros.h"    /* co$getevent */
#include "EMSdpb.h"
#include "bserr.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "emssfintdef.h" /* has bool option EMSsfbool_opt_display */
#include "OMmacros.h"

#define DEBUG 0
#if DEBUG
#include <stdio.h>                      /* Needed for print statements */
#endif

#include "madetplan.h"
#include "bsdistnct2.h"
#include "bssfarrevn.h"
#include "bsnorvec.h"

/* command types */

#define RLW_TRIM 0
#define RLW_NO_TRIM 1
#define RLW_SAVE_SIDE 2
#define RLW_CROSS_SECTION 3

/* command states - don't screw around with the numbers! */

#define STATE_0         0
#define STATE_1         1
#define STATE_2         2
#define STATE_3         3
#define STATE_4         4
#define STATE_5         5
#define STATE_6         6
#define STATE_7         7
#define LOCATE_PLANE    8
#define INDICATE_SIDE   9

struct RLWplane
{
  IGRpoint      point;
  IGRvector     normal;
};

from GRgraphics import GRdisplay, GRgetrang, GRptproject;
from EMSsubbs import EMsftanorm;
from NDnode import NDmove_to_root;
from EMSsurface import EMgetactiveid;

#if DEBUG
#define ERROR(sts_stupid, error_number, error_message)\
 {\
  if(!(sts_stupid & 1))\
   {\
    fprintf(stderr, "\n*************************");\
    fprintf(stderr, "\nIn COintplane error condition encountered");\
    *response = TERMINATE;\
    fprintf(stderr, "\n%s", error_message);\
    fprintf(stderr, "\nError number %d", error_number);\
    om$report_error(sts = sts_stupid);\
    fprintf(stderr, "\n*************************");\
    return(OM_E_ABORT);\
   }\
 }
#else
#define ERROR(sts_stupid, error_number, error_message)\
 {\
  if(!(sts_stupid & 1))\
   {\
    goto wrapup;\
   }\
 }
#endif

extern OMuword OPP_GRbspline_class_id,    OPP_GRcurve_class_id, 
               OPP_EMSsubbs_class_id,     OPP_EMSsurface_class_id,
               OPP_EMSsfboolean_class_id, OPP_EMSsolid_class_id,
               OPP_GRvg_class_id,         OPP_GRowner_class_id,
               OPP_EMSdatpln_class_id,
               OPP_GRgrset_class_id;

extern short _Pathway, _pathway_trim, _pathway_orient;

from GRvg import GRdetplane;

method execute(int *response; char *response_data; int pos)
{
  enum GRdpmode DisplayMode;
  IGRuchar buffer;
  IGRushort bool_options;
  OMuword r_classes[5], e_classes[5];
  IGRboolean ignore_boundaries, world, reverse;
  IGRboolean sign = 1, use_default;
  IGRlong i, j, sts, key = 0, msg, mask, size, object_was_located;
  IGRlong locate_mask, accept_mask, display_flag;
  IGRdouble normal[3], poly[6], range[6];
  IGRpoint projpt;
  OM_S_CLASSLIST rtree_classes, eligible_classes;
  struct GRparms projparms;
  struct GRevent event, accept_event;
  struct GRvg_construct construct_list;
  struct GRlc_locate attributes;
  struct GRid *grid;
  struct GRlc_info *obj;
  struct GRmd_env *mod;
/*  struct IGRbsp_surface *sf_geom = NULL; */
  struct IGRplane pln;
  IGRpoint pln_pt;
  IGRvector pln_nrml;
  char locate_prompt[GR_MAX_CHAR];

  bool_options=EMSsfbool_opt_display;
  pln.point = pln_pt;
  pln.normal = pln_nrml;

  /*
   * Initialize
   */
  size = sizeof(event);
  switch (me->mytype)
  {
   case RLW_TRIM:
   case RLW_NO_TRIM:
    sts = EMdpb_get(&msg, EMSdpb_props, &buffer);
    ERROR(sts, msg, "EMdpb_get error");
    ignore_boundaries = buffer & EMDPB_IGNORE_BOUNDARIES;
    if (ignore_boundaries)
      me->mytype = RLW_NO_TRIM;
    else
      me->mytype = RLW_TRIM;
    key = EM_M_0099;
    break;
   case RLW_SAVE_SIDE:
    key = EM_M_0100;
    break;
   case RLW_CROSS_SECTION:
    key = EM_M_0101;
    break;
  }                             /* switch (me->mytype) */
  ex$message(msgnumb = key);
  /*
   * Enter infinite loop
   */
  do
  {
    switch(me->state)
    {
      /*
       * Room for growth
       */
     case STATE_0:
      me->state = STATE_1;
      /*
       * Get the plane, either by points or by object(s)
       */
     case STATE_1:
     case STATE_2:
     case STATE_3:

      if (me->mytype == RLW_SAVE_SIDE)
      {
        /* Prasad wants this to always locate a single plane - mrm */
        me->state = LOCATE_PLANE; 
        break;
      }
      else
      {
        me->natural_normal = 2; /* use save_side_point arg */
      }

      mask = GRm_DATA | GRm_BACK_UP;
      /*
       * This is a little tricky.  I am call getevent() for a point but will
       * allow the operator to give me a fence.  The fence will use the
       * last locate criteria that was given to locate and it is highly
       * unlikely that this is what I want.  Therefore, I call the function
       * to load this criteria in order to ensure that I am given valid
       * elements.  Basically I want things or groups of things that can
       * response to the GRvg detplane message.
       */
      if (me->state == STATE_1)
      {
        ex$message(msgnumb = EMS_P_00133);
        mask |= GRm_SPECIFIED_OBJ;
        attributes.properties = 
                  LC_LC_ONLY     |      /* Locate locatable objects */
                  LC_DP_ONLY     |      /* Locate displayable objects */
                  IGN_MOD_BIT    |      /* Ignore modified and new props */
                  LC_PLANAR_ONLY |      /* Planar things only */
                  LC_RW;                /* I'm only going to read */
        attributes.owner_action = 
                  LC_RIGID_OWNER    |   /* Composites */
                  LC_RIGID_COMP     |   /* Members of composites */
                  LC_FLEX_OWNER     |   /* Graphic groups, etc. */
                  LC_FLEX_COMP      |   /* Members of graphic groups, etc. */
                  LC_REF_OBJECTS    |   /* Objects in ref. files are O.K. */
                  LC_NO_REF_HEADER;     /* No reference file headers */
        rtree_classes.w_count = 1;
        rtree_classes.w_flags = OM_CLST_subclass;
        rtree_classes.p_classes = &r_classes[0];
        eligible_classes.w_count = 1;
        eligible_classes.w_flags = OM_CLST_subclass;
        eligible_classes.p_classes = &e_classes[0];
        r_classes[0] = OPP_GRvg_class_id;
        e_classes[0] = OPP_GRvg_class_id;
        sts = gr$gsput_locate_criteria(msg = &msg,
                                       attributes = &attributes,
                                       rtree_classes = &rtree_classes,
                                       eligible_classes = &eligible_classes);
        ERROR(sts, msg, "gr$gsput_locate_criteria error");
      }
      else
      {
        i = me->state - 1;
        LOCAL_DISPLAY(sts, &msg, i, &me->points[0][0], TRUE);
        ERROR(sts, msg, "LOCAL_DISPLAY error");
        i = me->state;
        ex$message(msgnumb = EMS_P_00130, type = "%d", var = `i`);
        i = me->state - 2;
        EFrblineseg(&me->points[i][0], &ME.CObuild->ActiveDisplay);
      }

      sts = co$getevent (msg = &msg,
                         event_mask = mask,
                         response = response,
                         response_data = response_data,
                         event = &event);

      ERROR(sts, msg, "co$getevent error");
      ex$message(msgnumb = EMS_I_00000);
      if (me->state > 1)
      {
        i = me->state - 1;
        LOCAL_DISPLAY(sts, &msg, i, &me->points[0][0], FALSE);
        ERROR(sts, msg, "LOCAL_DISPLAY error");
      }
      if (event.response == GR_UNKNOWN_TYPE)
        return(OM_S_SUCCESS);
      else if (event.response == EX_BACK_UP)
        me->state--;
      else if (event.response == EX_OBJID)
      {
        struct                  GRid loc_obj;
        OM_S_CHANSELECT         my_stupid_thing, his_stupid_thing;

        me->have_plane_by_points = FALSE;
        me->number_of_buffer_cuts = 0;
        me->the_plane_object = event.located_object[0];
        me->state = (me->mytype == RLW_SAVE_SIDE) ? STATE_5 : STATE_6;
        /*
         * I must connect this stupid set onto a channel or else it
         * will get blown away if the user creates another set before
         * I make it to the processing section.
         */
        loc_obj = me->the_plane_object.located_obj;
        my_stupid_thing.type = OM_e_addr;
        my_stupid_thing.u_sel.addr = &me->to_graphics;
        sts = EMmake_chanselect(GRgrset_to_owners, &his_stupid_thing);
        ERROR(sts, MSFAIL, "EMmake_chanselect error");
        sts = om$send(msg = message Root.connect
                      (his_stupid_thing, /* to selector */
                       0,       /* to index */
                       my_id,   /* from objid */
                       OM_Gw_current_OS, /* from os */
                       my_stupid_thing, /* from selector */
                       0),      /* from index */
                      targetid = loc_obj.objid,
                      targetos = loc_obj.osnum);
        ERROR(sts, MSFAIL, "Root.connect error");
      }
      else
      {
        i = me->state - 1;
        me->points[i][0] = event.event.button.x;
        me->points[i][1] = event.event.button.y;
        me->points[i][2] = event.event.button.z;
        switch (me->state)
        {
         case STATE_1:
          me->have_plane_by_points = TRUE;
          me->state = STATE_2;
          break;
         case STATE_2:
          {
            IGRboolean  status;
            IGRlong     loc_msg;

            status = BSdistnct2(&loc_msg,
                                me->points[0],
                                me->points[1]);
            if (!status)
              ex$message(msgnumb = EMS_I_00001)
            else
              me->state = STATE_3;
          }
          break;
         case STATE_3:
          {
            IGRboolean  status;
            IGRlong     num_pnts = 3;
            struct      IGRplane plane;

            plane.point = &me->plane_point[0];
            plane.normal = &me->plane_normal[0];
            status = MAdetplane(
                                &msg,
                                (IGRdouble *)me->points,
                                &num_pnts,
                                &me->tolerance,
                                &plane);
            if (!status)
              ex$message(msgnumb = EMS_I_00001)
            else
            {
              if (me->mytype == RLW_SAVE_SIDE)
              {
                me->number_of_buffer_cuts = 1;
                me->state = STATE_5;
              }
              else
                me->state = STATE_4;
            }
          }
          break;
        }                       /* switch (me->state) */
      }
      break;
      /*
       * If the option is trim, no trim, or cross section and the
       * plane has been input by points then ask for the number of 
       * parallel cuts desired.  Note that this option is only in effect
       * if the user has input the plane by three points.
       */
     case STATE_4:
      LOCAL_DISPLAY(sts, &msg, 3, me->points, TRUE);
      ERROR(sts, msg, "LOCAL_DISPLAY error");
      /*
        ex$message(msgnumb = EMS_P_00136);
        mask = GRm_SCALAR | GRm_RJT_MOVEON | GRm_BACK_UP;
        sts = GRgetevent(&msg, &mask, &size, &event, response, response_data);
        */
      sts = co$getevent (msg = &msg,
                         event_mask = GRm_VALUE | GRm_RJT_MOVEON | GRm_BACK_UP,
                         value_type = GRIO_SCALAR,
                         msgnum = EMS_P_00136,
                         response = response,
                         response_data = response_data,
                         event = &event);

      ERROR(sts, msg, "co$getevent error");
      use_default = (msg == GRw_no_value); /* Save for later */
      ex$message(msgnumb = EMS_I_00000);
      LOCAL_DISPLAY(sts, &msg, 3, &me->points[0][0], FALSE);
      ERROR(sts, msg, "LOCAL_DISPLAY error");
      if (event.response == GR_UNKNOWN_TYPE)
        return(OM_S_SUCCESS);
      else if (event.response == EX_BACK_UP)
        me->state = STATE_3;
      else
      {
        if ((event.response == EX_RJT_MOVEON) || use_default)
          me->number_of_buffer_cuts = 1;
        else
          me->number_of_buffer_cuts = event.event.value;
        if (me->number_of_buffer_cuts < 1)
          ex$message(msgnumb = EMS_I_00009)
        else
          me->state = (me->number_of_buffer_cuts > 1) ? STATE_5 : STATE_6;
      }
      break;
      /*
       * If the option is save_side then get the point on the side to save.
       * If we are doing multiple parallel cuts then ask for a point
       * which will lie on the last cut plane.
       */
     case STATE_5:
      if (me->have_plane_by_points)
      {
        LOCAL_DISPLAY(sts, &msg, 3, me->points, TRUE);
        ERROR(sts, msg, "LOCAL_DISPLAY error");
      }
      if (me->mytype == RLW_SAVE_SIDE)
        ex$message(msgnumb = EMS_P_00131) /* Save side point */
      else
        ex$message(msgnumb = EMS_P_00137); /* Last cutting plane */
      mask = GRm_DATA | GRm_BACK_UP;
      /*
        sts = GRgetevent(&msg, &mask, &size, &event, response, response_data);
        */
      sts = co$getevent (msg = &msg,
                         event_mask = mask,
                         response = response,
                         response_data = response_data,
                         event = &event);

      ERROR(sts, msg, "co$getevent error");
      ex$message(msgnumb = EMS_I_00000);
      if (me->have_plane_by_points)
      {
        LOCAL_DISPLAY(sts, &msg, 3, &me->points[0][0], FALSE);
        ERROR(sts, msg, "LOCAL_DISPLAY error");
      }
      if (event.response == GR_UNKNOWN_TYPE)
        return(OM_S_SUCCESS);
      else if (event.response == EX_BACK_UP)
      {
        if (me->mytype == RLW_SAVE_SIDE)
          me->state = me->have_plane_by_points ? STATE_3 : STATE_1;
        else
          me->state = STATE_4;
      }
      else
      {
        me->points[3][0] = event.event.button.x;
        me->points[3][1] = event.event.button.y;
        me->points[3][2] = event.event.button.z;
        if (me->have_plane_by_points)
        {
          me->distance_to_plane = /* This must be signed */
            (me->points[3][0] - me->plane_point[0]) * me->plane_normal[0] + 
            (me->points[3][1] - me->plane_point[1]) * me->plane_normal[1] + 
            (me->points[3][2] - me->plane_point[2]) * me->plane_normal[2];
          if (fabs(me->distance_to_plane) < me->tolerance)
            ex$message(msgnumb = EMS_I_00001)
          else
            me->state = STATE_6;
        }                       /* if (me->have_plane_by_points) */
        else
          me->state = STATE_6;        /* Assume that it's good */
      }
      break;
      /*
       * Get the element to intersect
       */
     case STATE_6:
      if (me->have_plane_by_points)
      {
        LOCAL_DISPLAY(sts, &msg, 3, me->points, TRUE);
        ERROR(sts, msg, "LOCAL_DISPLAY error");
      }
      if (me->number_of_buffer_cuts > 1)
      {
        LOCAL_DISPLAY(sts, &msg, 1, me->points[3], TRUE);
        ERROR(sts, msg, "LOCAL_DISPLAY error");
      }
      locate_mask = GRm_DATA          | /* Normal locate */
                    GRm_TEXT_VALUE    | /* Element name */
                    GRm_SPECIFIED_OBJ | /* Fence */
                    GRm_BACK_UP;
      accept_mask = GRm_DATA;
      display_flag = 
                ELEM_HILIGHT            | /* Hilite the whole element */
                NO_PROJ_ACCEPT_POINT    | /* Don't project the accept point */
                ACC_REJ_CYCLE           | /* Run through accept reject cycle */
                RELOCATE                | /* Relocate if none found */
                LC_REGULAR_HIGHLIGHT    | /* Use regular hilite not 1/2 */
                LC_ERASE_ALL;             /* Erase hilite */
      attributes.properties = 
                LC_LC_ONLY              | /* Locate locatable objects */
                LC_DP_ONLY              | /* Locate displayable objects */
                IGN_MOD_BIT             | /* Ignore modified and new props */
                LC_PLANAR_NON_PLANAR;     /* Planarity doesn't matter */
      attributes.owner_action = 
                LC_RIGID_OWNER   | /* Composites */
                LC_FLEX_OWNER    | /* Graphic groups, etc. */
                LC_FLEX_COMP     | /* Members of graphic groups, etc. */
                LC_REF_OBJECTS   | /* Objects in ref. files are O.K. */
                LC_NO_REF_HEADER;  /* No reference file headers */
      rtree_classes.w_count = 1;
      rtree_classes.w_flags = OM_CLST_subclass;
      rtree_classes.p_classes = &r_classes[0];
      eligible_classes.w_count = 2;
      eligible_classes.w_flags = OM_CLST_subclass;
      eligible_classes.p_classes = &e_classes[0];
      r_classes[0] = OPP_EMSsubbs_class_id;
      r_classes[1] = OPP_GRbspline_class_id;
      e_classes[0] = OPP_EMSsurface_class_id;
      e_classes[1] = OPP_GRowner_class_id; /* Groups */
      e_classes[2] = OPP_GRcurve_class_id;
      switch (me->mytype)
      {
       case RLW_TRIM:
       case RLW_NO_TRIM:
        key = EMS_P_00135;    /* Identify element/set */
        attributes.owner_action |= LC_RIGID_COMP; /* Rigid children */
        attributes.properties |= LC_RW; /* I'm only going to read */
        rtree_classes.w_count = 2; /* Curves and surfaces */
        eligible_classes.w_count = 3;
        break;
       case RLW_CROSS_SECTION:
        key = EMS_P_00134;    /* Identify surface/solid/set */
        attributes.owner_action |= LC_RIGID_COMP; /* Rigid children */
        attributes.properties |= LC_RW; /* I'm only going to read */
        break;
        /*
         * Save side does not yet support composite surfaces
         * I have allowed location of composite surfaces in expectation of
         * Sunit allowing this by the July '88 release.
         */
       case RLW_SAVE_SIDE:
        key = EMS_P_00134;    /* Identify surface/solid/set */
        attributes.properties |= LC_WRITE_ONLY; /* I'm writing */
        attributes.owner_action |= (LC_ASSOCIATIVE | LC_EXTERN_CONSTRAINED) |
                                   LC_LOCALMOD;
        /*allow extern cnstr'd assoc eles*/
        break;
      }                       /* switch (me->mytype) */
      /*
       * I have to do this again due to lc$locate() being
       * rather brain dead.  One would think that it would be
       * smart enough to do this for you.
       */
      sts = gr$gsput_locate_criteria(msg = &msg,
                                     attributes = &attributes,
                                     rtree_classes = &rtree_classes,
                                     eligible_classes = &eligible_classes);
      ERROR(sts, msg, "gr$gsput_locate_criteria error");
      /*
       * Call the brain dead locate (It's been a bad day)
       */
      sts = lc$locate(rc =               &object_was_located,
                      event1 =           &me->locate_event,
                      event2 =           &accept_event,
                      mask1 =            locate_mask,
                      mask2 =            accept_mask,
                      display_flag =     display_flag,
                      unhilight_mode =   (enum GRdpmode)GRhd,
                      locate_key =       key,
                      acc_key =          EMS_P_00038,
                      relocate_key =     EMS_I_00013,
                      attributes =       &attributes,
                      stack =            &me->locate_stack,
                      rtree_classes =    &rtree_classes,
                      eligible_classes = &eligible_classes,
                      regex =            TRUE); /* Regular expression*/
      ERROR(sts, object_was_located, "lc$locate error");

      ex$message(msgnumb = EMS_I_00000);
      if (me->have_plane_by_points)
      {
        LOCAL_DISPLAY(sts, &msg, 3, me->points, FALSE);
        ERROR(sts, msg, "LOCAL_DISPLAY error");
      }
      if ((me->mytype == RLW_SAVE_SIDE) ||
          (me->number_of_buffer_cuts > 1))
      {
        LOCAL_DISPLAY(sts, &msg, 1, me->points[3], FALSE);
        ERROR(sts, msg, "LOCAL_DISPLAY error");
      }
      /*
       * Erase hilite and inform the operator we are in business
       */
      if (object_was_located)
      {
        ex$message(msgnumb = EMS_I_00004, type = "%s", var = " . ");
        me->the_intersect_object = accept_event.located_object[0];
        sts = dp$erase_hilite(msg = &msg);
        ERROR(sts, msg, "dp$erase_hilite error");
        me->state = STATE_7;          /* Assume success */
      }
      else if (me->locate_event.response == GR_UNKNOWN_TYPE)
        return(OM_S_SUCCESS);
      else                      /* Must be a EX_BACK_UP */
      {
        if (me->mytype == RLW_SAVE_SIDE)
          me->state = INDICATE_SIDE;
        else if (me->have_plane_by_points)
          me->state = (me->number_of_buffer_cuts > 1) ? STATE_5 : STATE_4;
        else
          me->state = STATE_1;
      }
      break;
      /*
       * Perform the necessary display cleanup.  If we are doing
       * a save side then erase the surface.
       */
     case STATE_7:
      ex$message(msgnumb = EMS_P_00000);
      ex$message(msgnumb = EMS_I_00004, type = "%s", var = " .. ");
      if(me->mytype == RLW_SAVE_SIDE) 
      {
        struct  GRlc_info *info;
        struct  GRid *id;
        struct  GRmdenv_info *mdenv_info;

        info = &me->the_intersect_object;
        mdenv_info = &info->module_info.md_env;
        id = &info->located_obj;
        DisplayMode = GRbe;
        /*********************
        sts = om$send(msg = message GRgraphics.GRdisplay
                      (&msg, &mdenv_info->matrix_type, mdenv_info->matrix,
                       &DisplayMode, &info->module_info.md_id),
                      targetid = id->objid,
                      targetos = id->osnum);
        ERROR(sts, msg, "GRdisplay error");
        **********************/
      }                         /* if (me->mytype == RLW_SAVE_SIDE)  */
      /*
       * Fill out the construction list
       */
      construct_list.msg = &msg;
      construct_list.env_info = &me->ModuleInfo;
      construct_list.newflag = FALSE;
      construct_list.geometry = NULL;
      construct_list.class_attr = NULL;
      construct_list.level = me->ActiveLevel;
      construct_list.properties = GRIS_LOCATABLE | GRIS_DISPLAYABLE;
      construct_list.display = &me->ActiveDisplay;
      construct_list.name = NULL;
      ex$message(msgnumb = EMS_I_00004, type = "%s", var = " ... ");
      /*
       * Get the planes to intersect the elements with
       */
      {
        IGRlong  num_cut;
        IGRlong  number_of_intersection_curves;
        struct   GRid *intersection_curves;
        struct   RLWplane *planes = NULL;

        num_cut = me->number_of_buffer_cuts;
        if (num_cut)
        {
          IGRdouble      delta_distance, distance;

          planes = (struct RLWplane *) alloca(num_cut * 
                                              sizeof(struct RLWplane));
          if (num_cut > 1)
            delta_distance = me->distance_to_plane / (num_cut - 1);
          else
            delta_distance = 0.0;
          for (i = 0; i < num_cut; i++)
          {
            distance = i * delta_distance;
            for (j = 0; j < 3; j++)
            {
              planes[i].normal[j] = me->plane_normal[j];
              planes[i].point[j] = me->plane_point[j] + 
                                   distance * me->plane_normal[j];
            }                   /* for (j = 0; j < 3; j++) */
          }                     /* for (i = 0; i < num_cut; i++) */
        }                       /* if (num_cut > 1) */

        if(me->mytype == RLW_SAVE_SIDE && _Pathway) 
        {
          _pathway_trim   = 1;
          _pathway_orient = 1;
        }

        sts = EMintersect_with_plane_mod(me->mytype,
                                     num_cut,
                                     planes,
                                     &me->the_plane_object,
                                     me->points[3],
                                     FALSE, /* Redraw save side on failure */
                                     &me->ModuleInfo,
                                     &me->the_intersect_object,
                                     &construct_list,
                                     TRUE, /* Want status messages */
                                     my_id,
                                     me->natural_normal,
                                     &number_of_intersection_curves,
                                     &intersection_curves,
                                     bool_options,
                                     &msg);

        if(me->mytype == RLW_SAVE_SIDE && _Pathway) 
        {
          _pathway_trim   = 0;
          _pathway_orient = 0;
        }

        ERROR(sts, msg, "EMintersect_with_plane_mod error");

        if(!me->is_associative &&  (me->mytype == RLW_SAVE_SIDE))
         {
	   struct GRid junkid;

	   junkid.objid = NULL_OBJID;
           sts = om$send(msg = message EMSsurface.EMgetactiveid(&msg, 
                 &junkid, NULL), 
                targetid = me->the_intersect_object.located_obj.objid, 
                targetos = me->the_intersect_object.located_obj.osnum);
           if(!IF_NULL_OBJID(junkid.objid))
            sts = om$send(msg = message NDnode.NDmove_to_root(&msg, 
                  &junkid, construct_list.env_info), 
                  targetid = junkid.objid, targetos = junkid.osnum);
         }       

        /*
         * Group all the intersections together
         */
        if (number_of_intersection_curves)
        {
          struct GRid total_group;
 
          if (number_of_intersection_curves > 1)
          {
            sts = EFbuild_graphic_group(number_of_intersection_curves,
                                        NULL,
                                        intersection_curves,
                                        &construct_list,
                                        &total_group.objid,
                                        &msg);
            ERROR(sts, MSFAIL, "EFbuild_graphic_group");
            total_group.osnum = construct_list.env_info->md_id.osnum;
          }
          else
            total_group = intersection_curves[0];
          /*
           * Display the resulting object
           */
          ex$message(msgnumb = EMS_I_00004, type = "%s", var = " .... ");
          DisplayMode = GRbd;
          sts = om$send(msg = message GRgraphics.GRdisplay
                        (&msg,
                         &me->ModuleInfo.md_env.matrix_type,
                         me->ModuleInfo.md_env.matrix,
                         &DisplayMode,
                         &me->ModuleInfo.md_id),
                        targetid = total_group.objid,
                        targetos = total_group.osnum);
          ERROR(sts, msg, "GRdisplay error");
          free(intersection_curves);
          ex$message(msgnumb = EMS_I_00000);
        }                       /* if (number_of_intersections_curves) */
        /*
         * Disconnect from the stupid set
         */
        if (! me->have_plane_by_points)
        {
          OM_S_CHANSELECT       my_stupid_thing;

          my_stupid_thing.type = OM_e_addr;
          my_stupid_thing.u_sel.addr = &me->to_graphics;
          sts = om$send(msg = message Root.wild_disconnect
                        (my_stupid_thing), /* to selector */
                        targetid = my_id);
          ERROR(sts, MSFAIL, "Root.wild_disconnect error");
        }
      }
      me->state = STATE_0;
      break;

     case LOCATE_PLANE:

      /* locate a plane */

      attributes.properties = 
                LC_LC_ONLY       | /* Locate locatable objects */
                LC_DP_ONLY       | /* Locate displayable objects */
                IGN_MOD_BIT      | /* Ignore modified and new props */
                LC_RW            | /* only going to read */
                LC_PLANAR_ONLY;    /* Planarity doesn't matter */
      attributes.owner_action = 
                LC_RIGID_OWNER   | /* Composites */
                LC_FLEX_COMP     | /* Members of graphic groups, etc. */
                LC_REF_OBJECTS   | /* Objects in ref. files are O.K. */
                LC_NO_REF_HEADER | /* No reference file headers */
                LC_ASSOCIATIVE   |
                LC_HANDLES       |
                LC_EXTERN_CONSTRAINED;    /* Locate associative objects */
      rtree_classes.w_count = 1;
      rtree_classes.w_flags = OM_CLST_subclass;
      rtree_classes.p_classes = &r_classes[0];
      eligible_classes.w_count = 2;
      eligible_classes.w_flags = OM_CLST_subclass;
      eligible_classes.p_classes = &e_classes[0];
      r_classes[0] = OPP_GRvg_class_id;
      e_classes[0] = OPP_EMSsubbs_class_id;
      e_classes[1] = OPP_EMSdatpln_class_id;

      ex$message ( buff = locate_prompt, msgnumb = EMS_P_IdentifyPlaneRefPlane);

      sts = lc$locate(rc = &object_was_located,
                      event1 = &event,
                      event2 = &event,
                      mask1 = GRm_DATA | GRm_TEXT_VALUE,
                      mask2 = GRm_DATA,
                      display_flag = ALL_WINDOWS | ELEM_HILIGHT |
                                     NO_PROJ_ACCEPT_POINT | ACC_REJ_CYCLE |
                                     RELOCATE | LC_REGULAR_HIGHLIGHT |
                                     LC_ERASE_ALL,
                      response = response,
                      response_data = response_data,
                      locate_prompt = locate_prompt,
                      acc_key = EMS_P_00038,            /* Accept/reject */
                      relocate_key = EMS_I_00013,       /* Element not found */
                      attributes = &attributes,
                      stack = &me->locate_stack,
                      rtree_classes = &rtree_classes,
                      eligible_classes = &eligible_classes,
                      regex = TRUE); /* Regular expression*/

      ERROR(sts, object_was_located, "lc$locate error");

      if ((sts & 1) && object_was_located)
      {
        me->state = INDICATE_SIDE;
        me->natural_normal = TRUE;
        me->have_plane_by_points = FALSE;
        me->number_of_buffer_cuts = 0;
        me->the_plane_object = event.located_object[0];
        OM_BLOCK_MOVE(&event.event.button.x,me->points[0],sizeof(IGRdouble)*3);
      }
      else if (event.response == GR_UNKNOWN_TYPE)
        return(OM_S_SUCCESS);
        
      break;

     case INDICATE_SIDE:

      /* get the id of the object from which to project the vector */
      
      obj = &me->the_plane_object;
      mod = &obj->module_info;
      grid = &obj->located_obj;
      
      /* get the normal for the surface near the accept point */
      
      sts = om$send(msg = message GRgraphics.GRptproject
                    (&msg, &mod->md_env.matrix_type, mod->md_env.matrix,
                     me->points[0], projpt, &projparms),
                    targetid = grid->objid,
                    targetos = grid->osnum);
      ERROR(sts,msg,"GRgraphics.GRptproject");
      
/*
      sts = om$send(msg = message EMSsubbs.EMsftanorm
                    (&msg, &mod->md_env.matrix_type,
                     mod->md_env.matrix,
                     (struct GRvg_construct *)NULL,
                     (IGRlong)1, &projparms.u,
                     (IGRlong)1, &projparms.v,
                     (IGRdouble)1.0, (IGRdouble *)NULL,
                     (IGRboolean)FALSE, (IGRboolean)TRUE, poly,
                     (OM_S_OBJID *)NULL),
                    targetid = grid->objid,
                    targetos = grid->osnum);
      
      ERROR(sts,msg,"EMSsubbs.EMsftanorm");
*/
      sts = om$send (msg = message GRvg.GRdetplane(&msg, 
                           &mod->md_env.matrix_type,
                            mod->md_env.matrix,
                           &pln),
                    targetid = grid->objid,
                    targetos = grid->osnum);
      ERROR(sts,msg,"GRvg.GRdetplane");
      
      /* get the range of the boundary (used in vector display) */

      world = TRUE;

      sts = om$send(msg = message GRgraphics.GRgetrang
                    (&msg, &mod->md_env.matrix_type,
                     mod->md_env.matrix, &world, range),
                    targetid = grid->objid,
                    targetos = grid->osnum);

      ERROR(sts,msg,"GRgraphics.GRgetrang");

      /* calculate and display the natural normal vector */

      normal[0] = poly[3] - poly[0];
      normal[1] = poly[4] - poly[1];
      normal[2] = poly[5] - poly[2];
      
      if (me->natural_normal)
       reverse = FALSE;
      else
       reverse = TRUE;

      EFdraw_vector_on_screen(my_id, &me->ActiveDisplay, &me->ModuleInfo,
                              GRbd, reverse, projpt, pln_nrml, range, &msg);


#if DOGS_EVER_FLY
      sts = EMget_the_geometry(obj, FALSE, FALSE, FALSE, my_id,
                               (IGRchar **)&sf_geom, &msg);

      BSsfarrevn(&msg, sf_geom, 1, &projparms.u, 1, &projparms.v, projpt,
                 normal);
      if (msg != BSSUCC) goto wrapup;

      BSnorvec(&msg, normal);
      if (msg != BSSUCC) goto wrapup;

      if (sf_geom->pos_orient)
      {
          normal[0] *= -1;
          normal[1] *= -1;
          normal[2] *= -1;
      }

      if (sf_geom) free(sf_geom);

      i = me->ActiveDisplay.color;
      me->ActiveDisplay.color++;

      EFdraw_vector_on_screen(my_id, &me->ActiveDisplay, &me->ModuleInfo,
                              GRbd, FALSE, poly, normal, range, &msg);

      me->ActiveDisplay.color = i;
#endif

      /* ask the user whether this is the direction to save */

      ex$message ( buff = locate_prompt, msgnumb = EMS_P_AcceptSideSaveMoveOnToReverse);

      sts = co$getevent(msg = &msg,
                        event_mask = GRm_DATA | GRm_BACK_UP | GRm_RJT_MOVEON,
                        prompt = locate_prompt,
                        response = response,
                        response_data = response_data,
                        event = &event);

      ex$message(msgnumb = EMS_I_00000);

      /* erase the vector */

      EFdraw_vector_on_screen(my_id, &me->ActiveDisplay, &me->ModuleInfo,
                              GRbe, reverse, projpt, pln_nrml, range, &msg);

      /* unhilite the plane */

      dp$erase_hilite (msg = &msg,
                       objid = me->ModuleInfo.md_id.objid,
                       osnum = me->ModuleInfo.md_id.osnum);

      if (event.response == EX_DATA)
      {
        if (!me->natural_normal) 
          sign = -1;
        me->points[3][0] = projpt[0] + sign*pln_nrml[0];
        me->points[3][1] = projpt[1] + sign*pln_nrml[1];
        me->points[3][2] = projpt[2] + sign*pln_nrml[2];
        me->state = STATE_6;    /* identify element to be intersected */
      }
      else if (event.response == EX_RJT_MOVEON)
      {
        if (me->natural_normal)
         me->natural_normal = FALSE;
        else
         me->natural_normal = TRUE;

        if (!me->natural_normal) 
          sign = -1;

        me->points[3][0] = projpt[0] + sign*pln_nrml[0];
        me->points[3][1] = projpt[1] + sign*pln_nrml[1];
        me->points[3][2] = projpt[2] + sign*pln_nrml[2];

        me->state = STATE_6;    /* identify element to be intersected */
      }
      else if (event.response == EX_BACK_UP)
      {
        me->state = LOCATE_PLANE;
      }
      else if (event.response == GR_UNKNOWN_TYPE)
      {
        return(OM_S_SUCCESS);
      }
      break;

      /*
       * Something has messed up our state table
       */
     default:
      ERROR(OM_E_ABORT, 0, "Default state reached");
    }
  }
  while(TRUE);
  /*
   * eof
   */
 wrapup:
  *response = TERMINATE;
  ex$message(msgnumb = EMS_F_0002);
  return(OM_E_ABORT);
}

method wakeup(int pos)
{
  IGRlong sts;

  sts = om$send (mode = OM_e_wrt_parent,
                 msg = message COintplane.wakeup (pos),
                 targetid = my_id);
  if (!(1 & sts)) return(OM_E_ABORT);

  /* Get the dpb variables */
 
  if (me->mytype == RLW_SAVE_SIDE)
  {
    IGRboolean props;

    gr$get_associative_flag( buffer = &props );
    if (props)
    {
      GRdisplay_associative_button(TRUE);
      me->is_associative = TRUE;
    }
  }
  return(OM_S_SUCCESS);
}

method super_cmd.sleep(int pos)
{
  IGRint sts=OM_S_SUCCESS;

  sts = om$send (mode = OM_e_wrt_parent,
                 msg = message COintplane.sleep(pos),
                 targetid = my_id);

  if ((me->mytype == RLW_SAVE_SIDE ) && (me->is_associative))
        GRdisplay_associative_button(FALSE);

  return(sts);
}

end implementation COintplane;
