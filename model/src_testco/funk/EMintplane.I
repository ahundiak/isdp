/*
 DESCRIPTION

 This function supports intersecting an object with an infinite plane.

 INPUT VARIABLES

 intersection_option
  0 - trim option
    Trim means that if a surface has boundaries then the intersection(s)
    are trimmed/shortened to honor the boundaries.
    Works for curves, composite curves, surfaces, composite surfaces,
    and solids (they are treated as composite surfaces).
  1 - no trim option
    No trim means that if a surface has boundaries then they are ignored.
    Works for curves, composite curves, surfaces, composite surfaces,
    and solids (they are treated as composite surfaces).
  2 - save side option
    Save side means that the surface is relimited such that it only
    exists on one side of the input plane.
    See BUGS section for limitations.
    Works for surfaces, composite surfaces, and solids.  
  3 - cross section option
    Cross section creates a planar surface that is suitable for cross hatching.
    Note that open surfaces/composites are supported so long as the
    intersections are closed.
    Works for surfaces, composite surfaces, and solids.  
 num_buffer_cuts
  The number of plane structures you are passing me.  Note that if zero
  I will assume that you are passing in a plane object/set.
 plane_buffers
  Array of plane structures.  Used iff num_buffer_cuts is not 0.
 plane_object
  Used iff no plane buffers are input.
  Locate information of a planar object.  Note that the this object
  may be a fence or graphic group of planar elements in which case
  multiple intersections are computed.  If any of the objects are
  not planar then they are skipped.
 save_side_point
  Used iff option is for save side.  This point must not lie in the input
  plane(s) and is used to determine which side of the surface to keep.
 redraw_save_side_objects_on_failure
  Used iff option is for save side.  If TRUE then input objects which
  have no intersection will be drawn on the screen in background, those
  which have a fatal, possibly corrupting, error are also drawn in
  the highlight plane.  This option is provided for the command object,
  since it would have erased all the objects before calling this routine.
 display_enviroment
  Used iff option is for save side and redraw_save_side_objects_on_failure
  is TRUE.  Module enviroment in which displays are to take place.
 intersection_object
  Locate information for the object to be intersected with the input plane(s).
  Note that this object may be a fence or graphic group of objects to
  intersect.  If any of the input objects are not supported then they
  are skipped.
 construct_list
  Standard construct list.
 want_status_messages
  If TRUE then I will output error, warning, and informational messages
  to the operator.
 my_stupid_id
  Caller's object id.  Used for message sends.
 natural_normal
  For save side option using an object, this indicates whether the side
  to be saved of the object being sliced is on the side of the natural
  normal of the slicing object.
    Valid values:       0   save side opposite natural normal
                        1   save side of natural normal
                        2   use save_side_point argument to determine side

 OUTPUT VARIABLES

 number_of_intersection_curves
  The number of intersection objects produced.
  Note that for the save side option 1 object is returned and this
  object represents the modified surface/solid.
 intersection_curves
  The intersection objects.  Note that the word "curves" is not
  totally correct.
 msg
  Error return code.  This will basically tell you if a fatal error
  occurred.  Since I process multiple options I do not treat intersection
  failures as fatal errors.

 BUGS

 Composite surfaces and surfaces with DPRs are not properly 
 supported by intersect plane save side.  Sunit is working this item.

 Save save works on surfaces within a composite so long as a boolean
 operation is not present on the state tree.

 HISTORY

Rustagi : 06/03/92 : Added argument 'bool_options' to the original function
                     EMintersect_with_plane with name now being changed to
                     'EMintersect_with_plane_mod'.

 rlw : 04/28/88 : Took this logic out of the command object and
                  rewrote it.
 rlw : 07/20/88 : Sunit pointed out that I was erroneously reporting
                  some save side errors as being corrupting.  I repaired
                  the damage.
 SM  : 29-Nov-88: Modified to set number_of_intersection curves to zero
		  just before exiting if the cut option is save side. This
		  is because the method will now provide selective display
		  so the command object does not have to handle display
		  upon return from this function.
 rlw : 12/01/88 : Modified such that when a corrupting error occurs, I tell
                  the user not to save the file.
 SM  : 10-Jan-89: Made minor changes to adapt to the evolution of 
		  EMintplane_saveside to EMintsurf_saveside. 
 SM  : 05-Jun-89: Add the cross section plane to the active owner. This was
		  the problem which prevented the plane from being owned
		  by the active drawing view.
 mrm : 07/29/91   Add natural_normal argument
 */

class implementation GRvg;

#include "EMS.h"
#if DEBUG
#include <stdio.h>                      /* Needed for print statements */
#endif
#define WATER_MARK 100
#define RLW_CURVE 20
#define RLW_SURFACE 21
#define RLW_UNKNOWN 22
#define RLW_TRIM 0
#define RLW_NO_TRIM 1
#define RLW_SAVE_SIDE 2
#define RLW_CROSS_SECTION 3

from EMSsurface import EMintsurf_saveside, EMintplane_notrim;
from EMSsurface import EMgetactiveid, EMcross_section, EMis_associative,
                       EMtransform_to_associative;
from EMSassoc import EMinit_associative;

#include "EC_F.h"
#include "EC_I.h"
#include "EC_M.h"
#include "EC_P.h"
#include "EMSmsgdef.h"	/* EMS_E_IntersectClosure */
#include "msdef.h"	/* Needed by ms.h */
#include "msmacros.h"	/* Has message subsystem macros */
#include "OMmacros.h"	/* Has OM_BLOCK_MOVE macro */
#include "emssfintdef.h" /* has bool option EMSsfbool_opt_display */
#include "emsimpdef.h"  /* has EMImpBnd_WantStatMsg for EMcross_section*/
#include "grownmacros.h"    /* For gr$add_to_active_owner */
#include "EMSasdef.h"   /* EMS_no_const_assoc */
#include "emsbool.h"
#include "emsdef.h"

#if DEBUG
#define ERROR(sts_stupid, error_number, error_message)\
 {\
  if(!(sts_stupid & 1))\
   {\
    fprintf(stderr, "\n*************************");\
    fprintf(stderr, "\nIn intplane function error condition encountered");\
    fprintf(stderr, "\n%s", error_message);\
    fprintf(stderr, "\nError number %d", error_number);\
    *msg = error_number;\
    om$report_error(sts = sts_stupid);\
    fprintf(stderr, "\n*************************");\
    goto wrapup;\
   }\
 }
#else
#define ERROR(sts_stupid, error_number, error_message)\
 {\
  if(!(sts_stupid & 1))\
   {\
    *msg = error_number;\
    goto wrapup;\
   }\
 }
#endif

extern OMuword OPP_GRcurve_class_id, OPP_EMSsurface_class_id,
               OPP_EMSsubbs_class_id, OPP_EMSsolid_class_id;

struct RLWplane
 {
  IGRpoint	point;
  IGRvector	normal;
 };

IGRlong EMintersect_with_plane_mod(
 intersection_option,
 num_buffer_cuts,
 plane_buffers,
 plane_object,
 save_side_point,
 redraw_save_side_objects_on_failure,
 display_enviroment,
 intersection_object,
 construct_list,
 want_status_messages,
 my_stupid_id,
 natural_normal,
 number_of_intersection_curves,
 intersection_curves,
 bool_options,
 msg)

IGRlong	       	     intersection_option;
IGRlong		     num_buffer_cuts;
struct		     RLWplane *plane_buffers;
struct		     GRlc_info *plane_object;
IGRpoint	     save_side_point;
IGRboolean	     redraw_save_side_objects_on_failure;
struct		     GRmd_env *display_enviroment;
struct		     GRlc_info *intersection_object;
struct		     GRvg_construct *construct_list;
IGRboolean	     want_status_messages;
OM_S_OBJID	     my_stupid_id;
IGRint               natural_normal;
IGRlong		     *number_of_intersection_curves;
struct		     GRid **intersection_curves;
IGRushort    	     bool_options;
IGRlong		     *msg;

{
 GRobjid		tmp_objid;
 IGRlong		i, j, sts, element_type;
 IGRlong		number_of_planes, number_of_intersection_elements;
 struct			GRlc_info *intersection_elements;
 struct			RLWplane *planes;
 struct 		EMSdataselect savesideplane;
 struct EMSobject_info *plobjs;


/*
 * Initialize
 */
 number_of_planes = 0;
 planes = NULL;
 number_of_intersection_elements = 0;
 intersection_elements = NULL;
 *number_of_intersection_curves  = 0;
 *intersection_curves = NULL;
 savesideplane.datatype = EMSdata_plane;

/*
 * Get the planes to intersect the elements with
 */
 if (num_buffer_cuts)
  {
   number_of_planes = num_buffer_cuts;
   planes = plane_buffers;
  } /* if (num_buffer_cuts) */
 else
  {
   IGRlong		number_of_planar_objects;
   struct		GRlc_info *planar_objects;
   struct		IGRplane resulting_plane;

   if (intersection_option != RLW_SAVE_SIDE)
   {
    sts = EMunwind_stupid_sets(
     plane_object,
     (intersection_option != RLW_SAVE_SIDE),
                                /* Do not break composites */
     TRUE,			/* This is a readonly operation */
     my_stupid_id,
     &number_of_planar_objects,
     &planar_objects,
     msg);
    ERROR(sts, *msg, "EMunwind_stupid_sets error")
   }
   else
   {
    number_of_planar_objects = 1;
    planar_objects = (struct GRlc_info *)om$malloc(size = 
                      sizeof (struct GRlc_info));
    *planar_objects = *plane_object;
   }
   if (number_of_planar_objects == 0)
    {
     if (want_status_messages)
      ex$message(msgnumb = EMS_I_00082)		/* No planar elements found */
     goto wrapup;
    }
   planes = (struct RLWplane *)
	    alloca(number_of_planar_objects * sizeof(struct RLWplane));
   plobjs = (struct EMSobject_info *)
            alloca(number_of_planar_objects * sizeof(struct EMSobject_info));
   number_of_planes = 0;
   for (i = 0; i < number_of_planar_objects; i++)
    {
     struct	GRid *planar_object;
     struct	GRmdenv_info *mdenv_info;
     double u, v;
     struct IGRbsp_surface *sf_geom = NULL;

     planar_object = &planar_objects[i].located_obj;
     mdenv_info = &planar_objects[i].module_info.md_env;
     resulting_plane.point = &planes[number_of_planes].point[0];
     resulting_plane.normal = &planes[number_of_planes].normal[0];

     sts = om$send(
       msg = message GRvg.GRdetplane(
        msg,
        &mdenv_info->matrix_type,
        mdenv_info->matrix,
        &resulting_plane),
       senderid = my_stupid_id,
       targetid = planar_object->objid,
       targetos = planar_object->osnum);
      ERROR(sts, *msg, "GRvg.GRdetplane error")
     if (*msg != MSSUCC)
      {
       IGRlong	index;

       *msg = MSSUCC;
       index = i + 1;				/* Element is not planar */
       if (want_status_messages)
        ex$message(
         msgnumb = EMS_I_00078,
         type = "%d",
         var = `index`)
      }
     else
     {
      plobjs[number_of_planes].grid = *planar_object;
      plobjs[number_of_planes].env = planar_objects[i].module_info;
      number_of_planes++;
     }
    } /* for (i = 0; (i < number_of_planes) && (! kill_loop); i++) */
   free(planar_objects);
  } /* ELSE FOR if (plane_input_by_structure) */
/*
 * Get the objects to section with the planes
 */
 sts = EMunwind_stupid_sets(
   intersection_object,
   FALSE,			/* Don't break up composites */
   (intersection_option != RLW_SAVE_SIDE),		/* is readonly? */
   my_stupid_id,
   &number_of_intersection_elements,
   &intersection_elements,
   msg);
  ERROR(sts, *msg, "EMunwind_stupid_sets error")
 if (number_of_intersection_elements == 0)
  {
   if (want_status_messages)
    ex$message(msgnumb = EMS_I_00013)		/* Element not found */
   goto wrapup;
  }
/*
 * Initialize counters before entering
 * intersection loops
 */
 *intersection_curves = (struct GRid *) malloc(WATER_MARK *
   sizeof(struct GRid));
  if (! *intersection_curves) ERROR(0, MANOMEMORY, "Allocation failure")
/*
 * Now we have a set of planes and a set of objects.  Let's
 * loop over each object and section it with each plane.
 */
 for (i = 0; i < number_of_intersection_elements; i++)
  {
   OMuword		class_id;
   IGRlong		cut_option, element_index;
   struct		GRlc_info *info;
   struct		GRid *intersection_objid;
   struct		GRmd_env *md_env;
   struct		GRmdenv_info *mdenv_info;

   element_index = i + 1;
   info = &intersection_elements[i];
   intersection_objid = &info->located_obj;
   md_env = &info->module_info;
   mdenv_info = &md_env->md_env;
   sts = om$get_classid(
     osnum = intersection_objid->osnum,
     objid = intersection_objid->objid,
     p_classid = &class_id);
    ERROR(sts, MSFAIL, "om$get_classid error")
   sts = om$is_ancestry_valid(
     subclassid = class_id, 
     superclassid = OPP_GRcurve_class_id);
    if (sts == OM_S_SUCCESS)
     element_type = RLW_CURVE;
    else
     {
      sts = om$is_ancestry_valid(
        subclassid = class_id, 
        superclassid = OPP_EMSsurface_class_id);
       if (sts == OM_S_SUCCESS)
        element_type = RLW_SURFACE;
       else
        element_type = RLW_UNKNOWN;
     }
/*
 * If we have a curve then we must use the trim option,
 * if we have an unknown then just skip it, otherwise,
 * we do what was requested.
 */
   if (element_type == RLW_CURVE)
    cut_option = RLW_TRIM;
   else
    cut_option = intersection_option;
   if (element_type == RLW_UNKNOWN)
    {
     if (want_status_messages)		/* Element is unsupported */
      ex$message(
       msgnumb = EMS_I_00079,
       type = "%d",
       var = `element_index`)
    }
/*
 * We have a valid object and a valid plane at this point.
 * Let's loop around the planes and branch based on the section option.
 */
   else
    {
     IGRboolean		already_in_list, kill_loop;
/*
 * We have a small problem in that intersect plane save side will only
 * produce one object per section cut.  In order to avoid adding
 * the result to the intersection list one than once I have defined
 * the variable already_in_list.  If it is TRUE then I try to
 * replace it in the list with the id of the topmost state on the tree.
 */
     already_in_list = FALSE;
     kill_loop = FALSE;		/* A way to exit on failure */
     for (j = 0; (j < number_of_planes) && (! kill_loop); j++)
      {
       IGRint	tmp_num_intersections;
       IGRlong	plane_index;
       struct	GRid *tmp_intersections;
       struct	IGRplane plane;

       plane_index = j + 1;
       if (want_status_messages)	/* Processing element x, plane y */
        ex$message(
         msgnumb = EMS_I_00081,
         type = "%d%d",
         var = `plane_index, element_index`)
       plane.point  = &planes[j].point[0];
       plane.normal = &planes[j].normal[0];
       tmp_num_intersections = 0;
       tmp_intersections = NULL;
       switch (cut_option)
        {
         case RLW_TRIM:        /* BUG - msg for curves is sometimes a BS msg */
          sts = om$send(
            msg = message GRvg.EMintplane(
             construct_list,
             &plane,
             info,
             &tmp_num_intersections,
             &tmp_intersections,
             (IGRint *)msg),
            senderid = my_stupid_id,
            targetid = intersection_objid->objid,
            targetos = intersection_objid->osnum);
          break;
         case RLW_NO_TRIM:
          sts = om$send(
            msg = message EMSsurface.EMintplane_notrim(
             construct_list,
             &plane,
             info,
             &tmp_num_intersections,
             &tmp_intersections,
             (IGRint *)msg),
            senderid = my_stupid_id,
            targetid = intersection_objid->objid,
            targetos = intersection_objid->osnum);
          break;
         case RLW_SAVE_SIDE:
          {
           IGRboolean is_associative=TRUE;
           OM_S_OBJID new_objid;

 
	   savesideplane.data.plane = (struct IGRplane *) &plane;

           sts = om$send (msg = message EMSsurface.EMis_associative(msg,
                                &is_associative),
            senderid = my_stupid_id,
            targetid = intersection_objid->objid,
            targetos = intersection_objid->osnum);
           ERROR(sts, *msg, "EMis_associative error")
           
           if (!is_associative)
           {
            sts = om$send (msg = message EMSsurface.EMtransform_to_associative(
                                 msg, &new_objid),
            senderid = my_stupid_id,
            targetid = intersection_objid->objid,
            targetos = intersection_objid->osnum);
            ERROR(sts, *msg, "EMtransform_to_associative error")
            intersection_objid->objid = new_objid;
           }

           sts = om$send(
            msg = message EMSsurface.EMintsurf_saveside(
             msg,
             construct_list,
             &savesideplane,
             md_env,
             save_side_point,
             natural_normal,
	     bool_options,
	     NULL, 		/* output int curves*/
	     NULL, 		/* output points to signal gaps */
             want_status_messages,
             (num_buffer_cuts) ? NULL : &plobjs[j]),    /* parent plane obj */
            senderid = my_stupid_id,
            targetid = intersection_objid->objid,
            targetos = intersection_objid->osnum);
           if ((1 & *msg) && 
               (1 & sts) &&
               (*msg != EMS_I_NoIntersection))
            {
             tmp_num_intersections = 1;
             tmp_intersections = (struct GRid *) malloc(
               sizeof(struct GRid));
              if (! tmp_intersections) 
               ERROR(0, MANOMEMORY, "Allocation failure")
             sts = om$send(
               msg = message EMSsurface.EMgetactiveid(
                msg, 
                tmp_intersections,
                NULL), 
               senderid = my_stupid_id,
               targetid = intersection_objid->objid,
               targetos = intersection_objid->osnum);
              ERROR(sts, *msg, "EMgetactiveid error")
/*
 * Change the information in the intersection object so that
 * we process the top state the next time through the loop.
 */
             *intersection_objid = *tmp_intersections;

            }
	   }
          break;
         case RLW_CROSS_SECTION:
          sts = om$send(
            msg = message EMSsurface.EMcross_section(
             msg,
             construct_list,
             &plane,
             md_env,
             &tmp_objid,
             want_status_messages ? EMImpBnd_WantStatMsg : NULL),
            senderid = my_stupid_id,
            targetid = intersection_objid->objid,
            targetos = intersection_objid->osnum);
           if ((1 & *msg) && 
               (1 & sts) &&
               (*msg != EMS_I_NoIntersection))
            {
             tmp_num_intersections = 1;
             tmp_intersections = (struct GRid *) malloc(
               sizeof(struct GRid));
              if (! tmp_intersections) 
               ERROR(0, MANOMEMORY, "Allocation failure")
             tmp_intersections->objid = tmp_objid;
             tmp_intersections->osnum = 
              construct_list->env_info->md_id.osnum;
	     sts = gr$add_to_active_owner(msg = msg, 
					  mod_env = construct_list->env_info, 
					  objid = tmp_intersections->objid, 
					  osnum = tmp_intersections->osnum);
            }
          break;
        } /* switch (cut_option) */
/*
 * Total up the intersections thus far
 */
       if (*msg == EMS_E_IntersectClosure)
        {
         if (want_status_messages)
          {
           ex$message(msgnumb = EMS_I_00077)		/* Closure */
           ems_sleep(2);			/* Make sure he sees this */
          }
        }
       else if (! (1 & sts))
        {
         if (cut_option == RLW_SAVE_SIDE)
          {
           kill_loop = TRUE;			/* Probably fatal */
           if (already_in_list)		/* Take it out as a failure */
            {
             already_in_list = FALSE;
             *number_of_intersection_curves -= 1;
            }
           if (want_status_messages)
            {
             if (*msg == EMS_F_Fail)
              {
               ex$message(msgnumb = EMS_I_00080) /* Failure, possibly bad */
               ex$message(msgnumb = EMS_F_0006)  /* Exit the file */
              }
             else
              {
               ex$message(msgnumb = EMS_I_00029)	/* Failure */
               ems_sleep(2);			/* Make sure he sees this */
              }
            }
          }
         else if (want_status_messages)
          {
           ex$message(msgnumb = EMS_I_00002)		/* Failure */
           ems_sleep(2);			/* Make sure he sees this */
          }
        }
       else if (tmp_num_intersections == 0)
        {
         if (want_status_messages)
          ex$message(msgnumb = EMS_I_00019)		/* No solution */
        }
       else
        {
         IGRlong	new_sum;

         if ((cut_option == RLW_SAVE_SIDE) &&
             already_in_list)			/* Overwrite existing entry */
          {
           new_sum = *number_of_intersection_curves;
           *number_of_intersection_curves -= 1;
          }
         else
          {
           already_in_list = TRUE;
           new_sum = *number_of_intersection_curves + tmp_num_intersections;
           if (new_sum > WATER_MARK)
            {
             *intersection_curves = (struct GRid *) realloc(
               *intersection_curves,
               sizeof(struct GRid) * new_sum);
              if (! *intersection_curves) 
               ERROR(0, MANOMEMORY, "Allocation failure")
            }
          }
         OM_BLOCK_MOVE(
          tmp_intersections,
          &(*intersection_curves)[*number_of_intersection_curves],
          tmp_num_intersections * sizeof(struct GRid));
         *number_of_intersection_curves = new_sum;
         free(tmp_intersections);
        }
/*
 * Don't abort except for memory or unrecoverable failures
 */
       *msg = MSSUCC;
      } /* for (j = 0; (j < number_of_planes) && (! kill_loop); j++) */
/*
 * Redraw those surfaces which had no intersection
 */
     if ((cut_option == RLW_SAVE_SIDE) &&
         (! already_in_list) &&
         redraw_save_side_objects_on_failure)
      {
       enum           GRdpmode DisplayMode;

       DisplayMode = (kill_loop ? GRbdhd : GRbd);
       sts = om$send(
         msg = message GRgraphics.GRdisplay(
          msg,
          &mdenv_info->matrix_type,
          mdenv_info->matrix,
          &DisplayMode,
          &display_enviroment->md_id),
         senderid = my_stupid_id,
         targetid = intersection_objid->objid,
         targetos = intersection_objid->osnum);
        ERROR(sts, *msg, "GRdisplay error")
      }
    } /* ELSE FOR if (element_type == RLW_UNKNOWN) */
  } /* for (i = 0; i < number_of_intersection_elements; i++) */
/*
 * Free it all up
 */
wrapup:
 if(intersection_option == RLW_SAVE_SIDE)
  *number_of_intersection_curves = 0;

 stackfree(stackfreeme);
 if (intersection_elements) free(intersection_elements);
 if ((*number_of_intersection_curves == 0) && *intersection_curves)
 {
   free(*intersection_curves);
   *intersection_curves = NULL;
 }
 if (1 & *msg)
  return(TRUE);
 else
  return(FALSE);
}

end implementation GRvg;
