/* ###################   APOGEE COMPILED   ################## */
/*
 Description

 This file contains the verify event, perform construction, 
 and perform dynamics methods for the place plane encompassing
 planar element command and part of the cross hatch command.

 History

 07/13/88 : rlw : The beginning - Actually it was written long ago
                  but I have reworked it to support autonesting.
 07/28/88 : rlw : Added Cross hatch command and added tree compression
 08/08/88 : rlw : Put plane construction logic into a function so that
                  Brooke could use it for supporting orphan cell translation
                  from the VAX to EMS.
 01/13/88 : rlw : Changed error return code check from Doree's function. I
                  think that it is not valid.
 04/14/89 : rlw : Modified to allow a set of curves to be input.
 08/08/91 : scw : Converted to use gr$dpb associative flag
 05/01/92 : pp  : Modified to not locate reference planes for place
                  plane encompassing planar element.
 09/18/96 : scw : Removed math.h
 */

class implementation ECautoplane;

#include "DIdef.h"
#include "EMS.h"
#include "ems_m_inc.h"		/* Includes everything */
#include "OMmacros.h"		/* OM_BLOCK_MOVE stuff */
#include "EC_P.h"		/* Message keys for prompt strings */
#include "EC_I.h"		/* Message keys for status strings */
#include "EMSasnucdef.h"
#include "EMSasnuc.h"
#include "EMSasopts.h"
#include "EMSdpb.h"
#include "emsdef.h"

from GRgraphics import GRdisplay, GRdelete, GRgetprops;

extern OMuword OPP_GRcurve_class_id;
extern OMuword OPP_EMSsurface_class_id;
extern OMuword OPP_GR3dpoint_class_id;
extern OMuword OPP_GRpoint_class_id;
extern OMuword OPP_SKpoint_class_id;
extern OMuword OPP_GA3dpoint_class_id;
extern OMuword OPP_EMSdatpln_class_id;

extern		IGRlong EMselective_fence(), EFgetprops();

method verify_event(
 IGRboolean	use_default;
 IGRboolean	*was_valid_event;
 IGRboolean	*done)

{
 IGRlong	key, sts, *my_msg;
 struct		GRevent *event;
/*
 * Compiler optimizations
 */
 my_msg = &me->msg;
/*
 * Initialize
 */
 *my_msg = MSSUCC;
 *done = FALSE;
 *was_valid_event = TRUE;
 event = &me->events[me->number_of_events_input - 1];

/*
 * Branch based on the command state
 */
 switch (me->number_of_events_input)
  {
/*
 * Event 1 verification
 *
 * If a set of curves was input then we are done.  If only
 * one curve was input then we wish to move forward to check
 * if auto nesting is desired.
 */
   case 1:
    {
     OMuword 	class_id;
     struct	GRid *id;
     extern OMuword OPP_SKmgr_class_id;

     id = &event->located_object[0].located_obj;

     /******
      10/7/92 Following is a kludge untill locate is fixed for profiles.
      By trying to accept sets, the command may end up locating SKmgr object
      instead of profile comp curve. In such a case, SKmgr is considered
      a set and no prompt for auto search is issued. The kludge is to replace
      the located object id by the comp curve id if a SKmgr was located.
      -- SM 

      Startdate 1.19.93 - The profile locate and ppepe still do not seem
      to mesh together. Presence of the #@!$# profiles seems to have a 
      warping affect on this command.
       --- SM
     ******/

     if (EFisAncestryValid(my_msg, id->objid,  id->osnum,  
				OPP_SKmgr_class_id,  FALSE))
     {
	OM_S_CHANSELECT to_comps;
        OMuint numcomps = 0, numcompcv = 0;
        OM_S_OBJECT_LINKAGE *junk = NULL, junkbuf[50], *ccv = NULL, ccvbuf[50];
        IGRint i;

	EMmake_chanselect(GRcmpowner_to_components,  &to_comps);
        sts = om$get_channel_count(objid = id->objid, osnum = id->osnum, 
              p_chanselect = &to_comps, count = &numcomps);
        if ( (!(1&sts)) || !numcomps) {*my_msg = MSFAIL; goto wrapup;}
	
        if(numcomps > 50)
         {
          junk = (OM_S_OBJECT_LINKAGE *) om$malloc(size = numcomps *
                sizeof(OM_S_OBJECT_LINKAGE));
          ccv = (OM_S_OBJECT_LINKAGE *) om$malloc(size = numcomps *
                sizeof(OM_S_OBJECT_LINKAGE));

         }
        else
         {
          junk = junkbuf;
          ccv = ccvbuf;
         }
        if ( !junk || !ccv) {*my_msg = MSFAIL; goto wrapup;}
	
        sts = om$get_channel_objects(objid = id->objid, osnum = id->osnum, 
              p_chanselect = &to_comps, list = junk, 
              size = numcomps, count = &numcomps);
        if (! (1 & sts)) {*my_msg = MSFAIL; goto wrapup;}
 
        numcompcv = 0;
        for(i=0; i<numcomps; i++)
         {
          if(EFisAncestryValid(my_msg, junk[i].S_objid,  junk[i].osnum,  
	     OPP_GRpoint_class_id,  FALSE))
	   continue;
	  else
	   ccv[numcompcv++] = junk[i];
	 }
        if (!numcompcv) {*my_msg = MSFAIL; goto wrapup;}	
	
	/* If the @#!% profile has only one non-degenerate element, treat
	   it as the located element. If multiple non-degenerate elements
	   exist, treat it as a set.
	*/
	if(numcompcv == 1)
	 {
	  id->objid = ccv[0].S_objid;
	  id->osnum = ccv[0].osnum;
	 }
	if(junk && (junk != junkbuf)) om$dealloc(ptr = junk);
	if(ccv && (ccv != ccvbuf)) om$dealloc(ptr = ccvbuf);
    }				

     sts = om$get_classid(
       osnum = id->osnum,
       objid = id->objid,
       p_classid = &class_id);
      if (! (1 & sts))
       {
        *my_msg = MSFAIL;
        goto wrapup;
       }
     sts = om$is_ancestry_valid(
       subclassid = class_id, 
       superclassid = OPP_GRcurve_class_id);
     if (sts == OM_S_SUCCESS)
      {
       struct	GRprops properties;

       sts = EFgetprops(
         event,
         my_id,
         &properties,
         my_msg);
        if (! (1 & sts)) goto wrapup;
       if (!properties.phy_closed)
        {
         *was_valid_event = FALSE;
         key = EMS_I_00014;
        }
       else
       {
        IGRshort graphics_props;
        struct	GRid temp_GRid;
        OM_S_CHANSELECT to_owners;
        event->located_object[0].geom_parms.polygon_inx = GRCURVE;

        graphics_props = 0;
        sts = om$send (msg = message GRgraphics.GRgetprops(my_msg,
                          &graphics_props),
                    senderid = NULL_OBJID,
                    targetid = id->objid,
                    targetos = id->osnum);
        if (!(1&sts&*my_msg)) goto wrapup;

        if (graphics_props & GR_RIGID_RELATIONSHIP)
        {
          EMmake_chanselect(GRconnector_to_owners, &to_owners);

          sts = om$get_objid_at_index(osnum = id->osnum,
                                      objid = id->objid,
                                      p_chanselect = &to_owners,
                                      index = 0,      
                                      objidaddr = &temp_GRid.objid,
                                      osnumaddr = &temp_GRid.osnum);
          if (!(1&sts)) goto wrapup;

          if (EFisAncestryValid(my_msg, temp_GRid.objid, temp_GRid.osnum, 
                          OPP_EMSdatpln_class_id, FALSE))
          {
           *was_valid_event = FALSE;
           key = EMS_S_InvInp;
          }
        }
       }
      } /* if (sts == OM_S_SUCCESS) */
     else
      {
       sts = om$is_ancestry_valid(
         subclassid = class_id, 
         superclassid = OPP_EMSsurface_class_id);
        if (sts == OM_S_SUCCESS)
         {
          event->located_object[0].geom_parms.polygon_inx = GRSURFACE;
          if (me->mytype == 35)
           {
            *was_valid_event = FALSE;
            key = EMS_I_00010;
           }
         }
        else
         {
          event->located_object[0].geom_parms.polygon_inx = GRCURVEPRISM;
          if ((me->mytype == 35) &&
              (event->response == EX_OBJID))  /* Not an event on the queue */
           *done = TRUE;
         }
      } /* ELSE FOR if (sts == OM_S_SUCCESS) */
    }
    break;
/*
 * Event 2 verification
 */
   case 2:
    {
     if (me->events[0].located_object[0].geom_parms.polygon_inx != GRCURVE)
      *done = TRUE;
    }
    break;
/*
 * Event 3 verification
 */
   case 3:
    {
     IGRlong	number_of_curves;
     struct	GRlc_info *curves;

     number_of_curves = 0;
     curves = NULL;
     if (use_default ||
         (event->event.keyin[0] == 'N') ||
         (event->event.keyin[0] == 'n'))
      {
       *done = TRUE;
      }
     else if ((event->event.keyin[0] == 'Y') ||
              (event->event.keyin[0] == 'y'))
      {
       extern	IGRlong EMauto_nester();
       struct	GRid window_id;
       struct	EX_button *button;

       ex$message(msgnumb = EMS_I_00003)
       button = &me->events[1].event.button;
       window_id.objid = button->objid;
       window_id.osnum = button->osnum;
       sts = EMauto_nester(
         my_msg,
         &me->events[0].located_object[0],
         window_id,
         &curves,
         &number_of_curves);
        if (! (1 & *my_msg)) goto wrapup;
       ex$message(msgnumb = EMS_I_00000)
       if (! number_of_curves)
        {
         *was_valid_event = FALSE;
         key = EMS_I_00010;
        }
      }
     else
      {
       *was_valid_event = FALSE;
       key = EMS_I_00005;
      }
     if (*was_valid_event)
      {
       me->number_of_curves = number_of_curves + 1;
       sts = om$vla_set_dimension(
         varray = me->curves,
         size = me->number_of_curves);
        if (! (1 & sts))
         {
          *my_msg = MSFAIL;
          goto wrapup;
         }
       me->curves[0] = me->events[0].located_object[0];
       if (number_of_curves)
        {
            IGRint              i, j, real_num = 1;
            struct GRlc_info *  loc_curves;
            OMuword             classid;

            loc_curves = &me->curves[0];

            for (i=0; i<number_of_curves; ++i)
            {
                /* Don't allow points on the list */
                om$get_classid (objid = curves[i].located_obj.objid,
                                osnum = curves[i].located_obj.osnum,
                                p_classid = &classid);
                if ((classid != OPP_GR3dpoint_class_id) &&
                    (classid != OPP_SKpoint_class_id)   &&
                    (classid != OPP_GA3dpoint_class_id))
                {
                    /* If the curve is not already on the list ... */
                    for (j=0; j<real_num; ++j) 
                        if ((curves[i].located_obj.objid == loc_curves[j].located_obj.objid) &&
                            (curves[i].located_obj.osnum == loc_curves[j].located_obj.osnum))
                            break;

                    if (j == real_num)
                    {
                        /* Add the curve to the list. */
                        loc_curves[real_num++] = curves[i];
                    }
                }
            }

            me->number_of_curves = real_num;
/*
         OM_BLOCK_MOVE(
          curves,
          &me->curves[1],
          number_of_curves * sizeof(struct GRlc_info));
*/
         free(curves);
        }
      }
    }
    break;
/*
 * Event 4 verification
 */
   case 4:
    if (event->response == EX_DATA)
     *done = TRUE;
    else
     {
      IGRshort	prevstate, donot_care;

      ms$onoff(
       msg = my_msg,
       prevstate = &prevstate,
       setstate = MS_OFF,
       type = MS_SET);
      sts = om$send(
        msg = message ECconstruct.restart(),
        targetid = my_id);
      ms$onoff(
       msg = my_msg,
       prevstate = &donot_care,
       setstate = prevstate,
       type = MS_SET);
     }
    break;
/*
 * Default:
 */
   default:
    *my_msg = MSFAIL;
    goto wrapup;
  } /* switch (me->number_of_events_input) */
/*
 * Output the error message, if any
 */
 if (! *was_valid_event)
  ex$message(msgnumb = key)
/*
 * eof
 */
wrapup:
 if (1 & *my_msg)
  return(OM_S_SUCCESS);
 else
  return(OM_E_ABORT);
}

method perform_dynamics()
{
 IGRlong	sts, *my_msg;
/*
 * Compiler optimizations
 */
 my_msg = &me->msg;
/*
 * Initialize
 */
 *my_msg = MSSUCC;
/*
 * Branch based on the command state
 */
 switch (me->number_of_events_input)
  {
/*
 * Event 1 dynamics
 */
   case 1:		/* Have curve */
/*  noop; */
    break;
/*
 * Event 2 dynamics
 */
   case 2:		/* Have view */
/*  noop; */
    break;
/*
 * Event 3 dynamics
 */
   case 3:		/* Have autonest option */
    {
     IGRlong	i;
     enum	GRdpmode DisplayMode;
     struct	GRlc_info *loc_info;
     struct	GRid *id;
     struct	GRmdenv_info *mdenv_info;

     DisplayMode = GRhhd;
     for (i = 1; i < me->number_of_curves; i++)
      {
       loc_info = &me->curves[i];
       id = &loc_info->located_obj;
       mdenv_info = &loc_info->module_info.md_env;
       sts = om$send(
         msg = message GRgraphics.GRdisplay(
          my_msg,
          &mdenv_info->matrix_type,
          mdenv_info->matrix,
          &DisplayMode, 
          &me->display_env.md_id),
         targetid = id->objid,
         targetos = id->osnum);
        if (! (1 & sts)) goto wrapup;
      } /* for (i = 1; i < me->number_of_curves; i++) */
    }
    break;
/*
 * Default
 */
   default:
    *my_msg = MSFAIL;
    goto wrapup;
  } /* switch (me->number_of_events_input) */
/*
 * eof
 */
wrapup:
 if (1 & *my_msg)
  return(OM_S_SUCCESS);
 else
  return(OM_E_ABORT);
}

method perform_construction()
{
 OMuword	space_number;
 extern		IGRlong EFplace_nested_plane();
 IGRlong	*my_msg, sts;
 GRobjid	*my_constructed_object;
 struct		GRvg_construct *my_construct_list;
 IGRboolean	assoc_placement;

/*
 * Compiler code reductions
 */
 my_msg = &me->msg;
 my_construct_list = &me->construct_list;
 my_constructed_object = &me->constructed_object;
 space_number = me->construct_env.md_id.osnum;

/*
 * Determine whether the placement is associative.
 */
 gr$get_associative_flag( buffer = &assoc_placement );

/*
 * Initialize
 */
 *my_msg = MSSUCC;
 *my_constructed_object = NULL_OBJID;

/*
 * Construct the surface
 */
 if (me->events[0].located_object[0].geom_parms.polygon_inx == GRCURVE)
  {
    IGRint                  i;
    struct EMSobject_info * objects;

    objects = (struct EMSobject_info *)stackalloc (me->number_of_curves * sizeof(struct EMSobject_info));

    for (i=0; i<me->number_of_curves; ++i)
    {
        objects[i].env = me->curves[i].module_info;
        objects[i].grid = me->curves[i].located_obj;
    }
    
    sts = EMplace_nested_plane ( my_msg,
                                 assoc_placement ? NULL : EMSasconst_notassociative,
                                 my_construct_list->env_info, 
                                 my_construct_list->level,
                                 my_construct_list->display,
                                 my_construct_list->class_attr,
                                 my_construct_list->name,
                                 me->number_of_curves,
                                 objects,
                                 my_constructed_object );
    stackfree (objects);

    if (! (1 & sts)) goto wrapup;
  } /* if (me->events[0].located_object[0].geom_parms... */
 else
  {
   OMuword		yes_list, no_list;
   OM_S_CLASSLIST	yes_classes, no_classes;
   IGRlong	  	number_of_objects, i;
   IGRlong		number_of_created_objects;
   GRobjid		*created_objects;
   struct		GRlc_info *objects;
   struct		GRprops properties;
   struct		GRevent event;

   me->number_of_events_input = 1;  /* Toss point in view as uneeded */
   yes_list = OPP_GRcurve_class_id;
   yes_classes.p_classes = &yes_list;
   yes_classes.w_count = 1;
   no_list = OPP_GRpoint_class_id;
   no_classes.w_count = 1;
   no_classes.p_classes = &no_list;
   number_of_objects = 0;
   objects = NULL;
   sts = EMselective_fence(
     &yes_classes,
     &no_classes, 
     &me->events[0].located_object[0],	/* set_object */
     FALSE,				/* break_up_composites */
     TRUE,				/* This is a readonly operation */
     my_id,
     &number_of_objects,
     &objects,
     my_msg);
    if (! (1 & sts)) goto wrapup;
   number_of_created_objects = 0;
   created_objects = (GRobjid *) malloc(
     number_of_objects * sizeof(GRobjid));
    if (! created_objects)
     {
      *my_msg = MANOMEMORY;
      goto wrapup;
     }
   for (i = 0; i < number_of_objects; i++)
    {
     event.located_object[0] = objects[i];
     sts = EFgetprops(
       &event,
       my_id,
       &properties,
       my_msg);
      if (! (1 & sts)) goto wrapup;
    if (properties.phy_closed)
     {
        struct EMSobject_info object;

        object.grid = objects[i].located_obj;
        object.env  = objects[i].module_info;

        sts = EMplace_nested_plane ( my_msg,
                                     assoc_placement ? NULL : EMSasconst_notassociative,
                                     my_construct_list->env_info, 
                                     my_construct_list->level,
                                     my_construct_list->display,
                                     my_construct_list->class_attr,
                                     my_construct_list->name,
                                     1,
                                     &object,
                                     my_constructed_object );
       if (! (1 & sts)) goto wrapup;
      created_objects[number_of_created_objects] = *my_constructed_object;
      number_of_created_objects++;
     } /* if (properties.phy_closed) */
    } /* for (i = 0; i < number_of_objects; i++) */
   if (number_of_objects &&
       objects) free(objects);
   if (number_of_created_objects && created_objects)
    {
     if (number_of_created_objects > 1)
      {
       sts = EFbuild_graphic_group(
        number_of_created_objects,
        created_objects,
        NULL,
        my_construct_list,
        my_constructed_object,
        my_msg);
      }
     free(created_objects);
    }
  } /* ELSE FOR if (me->events[0].located_object[0]....) */
/*
 * eof
 */
wrapup:
 if (1 & *my_msg)
  return(OM_S_SUCCESS);
 else
  {
   IGRlong	loc_msg;

   sts = om$send(
     msg = message GRgraphics.GRdelete(
      &loc_msg,
      my_construct_list->env_info),
     targetid = *my_constructed_object,
     targetos = space_number);
   *my_constructed_object = NULL_OBJID;
   return(OM_E_ABORT);
  }
}

end implementation ECautoplane;
