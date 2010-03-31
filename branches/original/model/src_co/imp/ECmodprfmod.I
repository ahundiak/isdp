/* ###################   APOGEE COMPILED   ################## */
/*
 Description

 This method performs the modification logic
 for the following simple commands:

                 Command                      mytype
        ----------------------------------    -------
	Change curve order			71
	Change surface order			72
	Increase curve order			73
	Increase surface order			74
	Change rule line display		75
	Place solid by capping surface		76
	Toggle polygon on/off			77
	Insert pole without changing shape	78
	Insert knot				79
	Extend surface - linear			80
	Extend surface - circular		81
	Extend surface - polynomial		82
	Delete surface boundaries		86
	Bezier curves from a bspline curve	89
	Bezier surfaces from a bspline surface	90
	Insert knotline				91
						--
	Modify curve shape			106
        Reduce curve data			107
	Modify surface shape			108
						---
	Change curve direction			110
						---
	Reduce surface data			114

 History

 12/29/87 : rlw : The beginning
 01/05/88 : rlw : Added some commands
 01/15/87 : rlw : Modified delete boundaries to accomodate changes
                  in the object id.
 02/06/88 : pp :  Setting me->constructed_object to id->objid when
                  there is error in capping.
 23-May-88: SM :  Pass environment and md_id to the message EMdelete_boundary.
		  Each surface, redisplays itself as it deletes the topology
		  on itself. This works well for composites by avoiding
		  the return of all the leaf surfaces and then the CO having
		  to redisplay them all.
 07/04/88 : rlw : Added modify curve shape command
 07/08/88 : rlw : Added modify surface shape command
 07/20/88 : rlw : Added Change curve direction command
 08/01/88 : rlw : Modified Change rule line display to support fences
                  and also ask for number of rule lines to use.
                  Modified Toggle polygon to support fences.
 08/05/88 : rlw : Changed curve data reduction from a placement command to
                  a modification command.
                  Added surface data reduction command.
 09/05/88 : rlw : Modified curve and surface data reduction to report
                  fitting errors to the user
 09/14/88 : rlw : Modified toggle polygon to send a specific message to
                  surfaces such that Moghe's range reduction can trap it.
 02/28/89 : rlw : Modified to add conditional compilation statements
                  for the I/DRAW product.
 04/12/89 : rlw : Modified change rule line display to send the GRputattr
                  even if the counts do not change.  This is needed to
                  reset the cross hatch graphics data, if present.
 05/08/89 : rlw : I was not passing the proper module enviroment for
                  toggle polygon.
 04/11/91 : jhw : Added associative construction for solid by capping surface.
 08/08/91 : scw : Converted to use gr$dpb associative flag
 11/24/92 : AMD : Modified for 'Place solid by capping' 
 11/03/93 : dhm : Added error check at wrapup for type == 78.

 */

class implementation ECmodify;

%safe
#include <math.h>
%endsafe

#include "EMS.h"
#include "ems_m_inc.h"		/* Includes everything */
#include "DIdef.h"
#include "EMSdpb.h"
#include "EMSasnucdef.h"
#include "EMSasnuc.h"
#include "EMSasopts.h"
#include "ECmsg.h"

from GRgraphics import GRdelete;
from GRsubbc import EMmodify_curve_shape;
#ifndef IDRAW
from GRvg import GRgetattr;
from GRvg import GRputattr;
from GRsubbc import EMmodify_order;
from GRsubbc import EMinsert_pole;
from GRsubbc import EMinsert_knot;
from GRsubbc import EMreduced_fit_curve;
from GRbspline import EMbctobz;
from EMSsurface import EMdelete_boundary, EMgetactiveid;
from EMSsubbs import EMbstobz;
from EMSsubbs import EMtoggle_polygon;
from EMSgenbs import EMmodify_order;
from EMSgenbs import EMextend_surface;
from EMSgenbs import EMinsktln;
from EMSgenbs import EMmodify_surface_shape;
from EMSgenbs import EMreduced_fit_surface;
from EMSsfsolid import EMcap_thyself;
#endif

extern OMuword OPP_GRbspline_class_id;
extern OMuword OPP_GRbcsubbc_class_id;
#ifndef IDRAW
extern OMuword OPP_EMSsubbs_class_id;
extern OMuword OPP_EMSgenbs_class_id;
extern OMuword OPP_EMSsfsolid_class_id;
#endif

method perform_modification()
{
 IGRboolean	is_a_surface;
 IGRlong	sts, *my_msg;
 struct		GRmd_env *md_env;
 struct		GRlc_info *loc_info;
 struct		GRid *id;
 struct		GRvg_construct *my_construct_list;
 IGRboolean     assoc_placement;

/*
 * Compiler code reductions
 */
 my_msg = &me->msg;
 my_construct_list = &me->construct_list;

/*
 * Initialize
 */
 *my_msg = MSSUCC;
 is_a_surface = FALSE;
 loc_info = &me->events[0].located_object[0];
 id = &loc_info->located_obj;
 md_env = &loc_info->module_info;
 me->constructed_object = id->objid;

/*
 * Get the associative placement flag.
 */
 gr$get_associative_flag( buffer = &assoc_placement );

/*
 * Promote the class, if required
 */
 switch (me->mytype)
  {
   case 71:
   case 73:
   case 78:
   case 79:
   case 106:
   case 107:
    sts = EMpromote_class(
      TRUE,
      md_env,
      id,
      my_msg);
     if (! (1 & sts)) goto wrapup;
    break;
#ifndef IDRAW
   case 72:
   case 74:
   case 80:
   case 81:
   case 82:
   case 91:
   case 108:
   case 114:
    is_a_surface = TRUE;
    sts = EMpromote_class(
      FALSE,
      md_env,
      id,
      my_msg);
     if (! (1 & sts)) goto wrapup;
    break;
#endif
   default:
    break;
  } /* switch (me->mytype) */
/*
 * Branch based on the type of modification desired
 */
 switch (me->mytype)
  {
#ifndef IDRAW
   case 71:
   case 73:
    sts = om$send(
      msg = message GRsubbc.EMmodify_order(
       (IGRboolean) (me->mytype == 73),
       loc_info,
       me->u_order,
       my_msg),
      targetid = id->objid,
      targetos = id->osnum);
    break;
   case 72:
   case 74:
    sts = om$send(
      msg = message EMSgenbs.EMmodify_order(
       (IGRboolean) (me->mytype == 74),
       loc_info,
       me->u_order,
       me->v_order,
       my_msg),
      targetid = id->objid,
      targetos = id->osnum);
    break;
   case 75:
   case 77:
    {
     OMuword		yes_list[2];
     OM_S_CLASSLIST	yes_classes, no_classes;
     IGRboolean		surface_toggle_poly;
     extern		IGRlong EMselective_fence();
     IGRlong	  	number_of_objects, u_rules, v_rules, i;
     struct	   	GRlc_info *objects;
     struct		IGResbs element_specific;

     yes_list[0] = OPP_EMSsubbs_class_id;
     yes_list[1] = OPP_GRbspline_class_id;
     yes_classes.p_classes = yes_list;
     if (me->mytype == 77)
      yes_classes.w_count = 2;
     else
      {
       yes_classes.w_count = 1;
       u_rules = me->events[1].event.value;
       v_rules = me->events[2].event.value;
      }
     no_classes.w_count = 0;
     no_classes.p_classes = NULL;
     number_of_objects = 0;
     objects = NULL;
     sts = EMselective_fence(
       &yes_classes,
       &no_classes, 
       loc_info,			/* set_object */
       TRUE,				/* break_down_composites */
       FALSE,				/* is_operation_readonly */
       my_id,
       &number_of_objects,
       &objects,
       my_msg);
      if (! (1 & sts)) goto wrapup;
     surface_toggle_poly = FALSE;
     for (i = 0; i < number_of_objects; i++)
      {
       loc_info = &objects[i];
       md_env = &loc_info->module_info;
       id = &loc_info->located_obj;
       sts = om$send(
         msg = message GRvg.GRgetattr(
          my_msg,
          (IGRchar *) &element_specific),
         targetid = id->objid,
         targetos = id->osnum);
        if (! (1 & sts)) goto wrapup;
       if (me->mytype == 75)
        {
         element_specific.u_rules = u_rules;
         element_specific.v_rules = v_rules;
        } /* if (me->mytype == 75) */
       else
        {
         OMuword	the_class_id;

         sts = om$get_classid(
           osnum = id->osnum,
           objid = id->objid,
           p_classid = &the_class_id);
          if (! (1 & sts))
           {
            *my_msg = MSFAIL;
            goto wrapup;
           }
         sts = om$is_ancestry_valid(
           subclassid = the_class_id,
           superclassid = OPP_GRbspline_class_id);
         if (sts == OM_S_SUCCESS)
          {
           struct	IGResbc *current;

           sts = EMpromote_class(
             TRUE,			/* It's a curve */
             md_env,
             id,
             my_msg);
            if (! (1 & sts)) goto wrapup;
       /* I assume sizeof(IGResbs) >= sizeof(IGResbc) */
           current = (struct IGResbc *) &element_specific;
           current->is_polydis = !current->is_polydis;
          }
         else
          {
           surface_toggle_poly = TRUE;
           element_specific.is_polydis = !element_specific.is_polydis;
          }
        } /* ELSE FOR if (me->mytype == 75) */
       if (surface_toggle_poly)
        {
         surface_toggle_poly = FALSE;
         sts = om$send(
          msg = message EMSsubbs.EMtoggle_polygon(
           my_msg,
           &md_env->md_id,
           (IGRchar *) &element_specific),
          targetid = id->objid,
          targetos = id->osnum);
        }
       else
        {
         sts = om$send(
          msg = message GRvg.GRputattr(
           my_msg,
           (IGRchar *) &element_specific),
          targetid = id->objid,
          targetos = id->osnum);
        }
       if (! (1 & sts)) goto wrapup;
      } /* for (i = 0; i < number_of_objects; i++) */
     if (number_of_objects &&
         objects) free(objects);
    }
    break;

   case 76:
    {
        struct EMSobject_info surface;
        struct GRid           result, active_GRid;
        IGRushort             assoc_options;
        IGRboolean            state;

        surface.grid = loc_info->located_obj;
        surface.env  = loc_info->module_info;

        sts = om$send(msg = message EMSsurface.EMgetactiveid(my_msg,
                              &active_GRid, NULL),
                        targetid = surface.grid.objid,
                        targetos = surface.grid.osnum);
        if (! (1 & sts)) goto wrapup;
 
        result.objid = NULL_OBJID;

        my_construct_list->env_info = md_env;

        gr$get_associative_flag( buffer = &state );

        if(state)
         assoc_options = NULL;
        else
         assoc_options = EFfunc_PLACE_NON_ASSOC;
      
        sts = EFplace_solid_by_capping_surface
                            ( my_msg,
                              *my_construct_list,
                              assoc_options,
                              active_GRid,
                              &surface,
                              &result );
        if (! (1 & sts)) goto wrapup;
    }
    break;

   case 78:
    sts = om$send(
      msg = message GRsubbc.EMinsert_pole(
       loc_info,
       &me->events[1].event.button.x,
       my_msg),
      targetid = id->objid,
      targetos = id->osnum);
    break;

   case 79:
    sts = om$send(
      msg = message GRsubbc.EMinsert_knot(
       loc_info,
       me->events[1].located_object[0].geom_parms.u,
       me->events[2].event.value,
       my_msg),
      targetid = id->objid,
      targetos = id->osnum);
    break;
   case 80:
   case 81:
   case 82:
    {
     IGRlong	option;

     option = me->mytype - 80;
     sts = om$send(
       msg = message EMSgenbs.EMextend_surface(
        loc_info,
        &me->events[1].event.button.x,
        &me->events[2].event.button.x,
        option,
        my_msg),
       targetid = id->objid,
       targetos = id->osnum);
    }
    break;
   case 86:
    sts = om$send(
      msg = message EMSsurface.EMdelete_boundary(
       my_msg,
       md_env,
       &me->display_env.md_id,  
       id),
      targetid = id->objid,
      targetos = id->osnum);
    me->constructed_object = id->objid;
    break;
   case 89:
   case 90:
    {
     GRobjid	*objects;
     IGRlong	number_of_objects;

     number_of_objects = 0;
     objects = NULL;
     if (me->mytype == 89)
      {
       sts = om$send(
         msg = message GRbspline.EMbctobz(
          my_construct_list,
          &objects,
          (IGRint *)&number_of_objects,
          my_msg),
         targetid = id->objid,
         targetos = id->osnum);
      }
     else
      {
       sts = om$send(
         msg = message EMSsubbs.EMbstobz(
          my_construct_list,
          &objects,
          (IGRint *)&number_of_objects,
          my_msg),
         targetid = id->objid,
         targetos = id->osnum);
      }
     if (! (1 & sts)) goto wrapup;
     if (number_of_objects && objects)
      {
       sts = om$send(
         msg = message GRgraphics.GRdelete(
          my_msg,
          md_env),
         targetid = id->objid,
         targetos = id->osnum);
        if (! (1 & sts)) goto wrapup;
       if (number_of_objects == 1)
        me->constructed_object = objects[0];
       else
        {
         my_construct_list->env_info = md_env;
         sts = EFbuild_graphic_group(
          number_of_objects,
          objects,
          NULL,
          my_construct_list,
          &me->constructed_object,
          my_msg);
        }
       free(objects);
      }
    }
    break;
   case 91:
    {
     IGRboolean	u_insertion;
     GRobjid	new_object_id;
     struct	GRparms *geom_parms;

     u_insertion = me->events[0].located_object[0].geom_parms.polygon_inx;
     geom_parms = &me->events[1].located_object[0].geom_parms;
     sts = om$send(
       msg = message EMSgenbs.EMinsktln(
        my_msg,
        md_env,
        1,
        &geom_parms->u,
        1,
        &geom_parms->v,
        me->events[3].event.value,	/* Multiplicity */
        0,				/* Use given multiplicity */
        u_insertion,
        ! u_insertion,
        &new_object_id),
      targetid = id->objid,
      targetos = id->osnum);
    }
    break;
#endif
   case 106:
    sts = om$send(
      msg = message GRsubbc.EMmodify_curve_shape(
       loc_info,
       me->events[1].located_object[0].geom_parms.u,
       &me->events[2].event.button.x,
       me->events[3].located_object[0].geom_parms.u,
       me->events[4].located_object[0].geom_parms.u,
       me->events[5].located_object[0].geom_parms.polygon_inx,
       me->events[6].located_object[0].geom_parms.polygon_inx,
       (me->events[3].response != EX_DATA),
       my_msg),
      targetid = id->objid,
      targetos = id->osnum);
    break;
#ifndef IDRAW
   case 107:
    {
     extern	IGRlong EFreport_fit_errors();
     IGRdouble	maximum_error, average_error;
     IGRpoint	error_line[2];

     sts = om$send(
       msg = message GRsubbc.EMreduced_fit_curve(
        loc_info,
        me->events[1].located_object[0].geom_parms.polygon_inx,
        me->events[2].located_object[0].geom_parms.polygon_inx,
        &maximum_error,
        &average_error,
        error_line,
        my_msg),
       targetid = id->objid,
       targetos = id->osnum);
      if (! (1 & sts)) goto wrapup;
     sts = EFreport_fit_errors(
       maximum_error,
       average_error,
       error_line,
       &me->display,
       &me->display_env,
       my_id,
       my_msg);
    }
    break;
   case 108:
    sts = om$send(
      msg = message EMSgenbs.EMmodify_surface_shape(
       loc_info,
       (me->events[3].response == EX_DATA),
       &me->events[1].located_object[0].geom_parms.u,
       &me->events[2].event.button.x,
       &me->events[3].located_object[0].geom_parms.u,
       &me->events[4].located_object[0].geom_parms.u,
       (me->events[5].response == EX_DATA),
       me->events[6].located_object[0].geom_parms.polygon_inx,
       me->events[7].located_object[0].geom_parms.polygon_inx,
       (me->events[8].response == EX_DATA),
       me->events[9].located_object[0].geom_parms.polygon_inx,
       me->events[10].located_object[0].geom_parms.polygon_inx,
       my_msg),
      targetid = id->objid,
      targetos = id->osnum);
    break;
   case 110:
    {
     extern	IGRlong EFset_curve_direction();
     struct	GRparms *parms;

     if (me->events[2].response == EX_DATA)
      parms = &me->events[2].located_object[0].geom_parms;
     else
      parms = NULL;
     sts = EFset_curve_direction(
       loc_info,
       &me->events[2].event.button.x,
       parms,
       (me->events[1].response != EX_DATA),
       my_id,
       &me->constructed_object,
       my_msg);
    }
    break;
   case 114:
    {
     extern	IGRlong EFreport_fit_errors();
     IGRdouble	maximum_error, average_error;
     IGRpoint	error_line[2];

     sts = om$send(
       msg = message EMSgenbs.EMreduced_fit_surface(
        loc_info,
        (me->events[1].response == EX_DATA),
        me->events[2].located_object[0].geom_parms.polygon_inx,
        me->events[3].located_object[0].geom_parms.polygon_inx,
        (me->events[4].response == EX_DATA),
        me->events[5].located_object[0].geom_parms.polygon_inx,
        me->events[6].located_object[0].geom_parms.polygon_inx,
        &maximum_error,
        &average_error,
        error_line,
        my_msg),
       targetid = id->objid,
       targetos = id->osnum);
      if (! (1 & sts)) goto wrapup;
     sts = EFreport_fit_errors(
       maximum_error,
       average_error,
       error_line,
       &me->display,
       &me->display_env,
       my_id,
       my_msg);
    }
    break;
#endif
   default:
    *my_msg = MSFAIL;
    goto wrapup;
  } /* switch (me->mytype) */
 if (! (1 & sts)) goto wrapup;		/* Just to save code space */
/*
 * eof
 */
wrapup:
 /* 
  * Return the sts on mytype == 78 so that ECmodify can output the correct
  * error message if needed.  dhm  11/3/93
  */
 if (me->mytype == 78)  /* Insert Pole w/o changing shape */
     return(sts);
 else if (1 & *my_msg)
  return(OM_S_SUCCESS);
 else
  return(OM_E_ABORT);
}

end implementation ECmodify;
