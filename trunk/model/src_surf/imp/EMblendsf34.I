/* ###################   APOGEE COMPILED   ################## */
/*
 Description

 This method creates a blending surface between
 3 or more input curves.  Each curve can optionally
 have a supporting surface.  Please refer to the 
 specification file for a further description of this method.

 History

 rlw : 06/29/88 : Creation Date
 rlw : 09/27/88 : Modified not to free sf on math failure.  I saw it
                  core dump at Rubbermaid and I think the math is not
                  clearing internal pointer fields.
 rlw : 11/29/88 : Modified to support arbitrary number of curves/surfaces,
                  and since this dictated changes in arguments I renamed
                  the method.
 rlw : 12/02/88 : Forgot to make natural boundaries before stitching.
 */

class implementation EMSgenbs;

#include "EMS.h"
#define DEBUG 0

#if DEBUG
#include <stdio.h>
#endif
#include "bs.h"			/* BSSUCC, etc. */
#include "msdef.h"		/* MSSUCC, MSFAIL */
#include "gocmacros.h"		/* GRgetasbsg macro */

#define MAX_CURVES 200

extern OMuword OPP_EMSgenbs_class_id;
extern OMuword OPP_EMSsfstitch_class_id;

from EMSsfstitch import EMmake_comp;

method EMblend_3_or_more_curves(
 IGRlong		number_of_curves;
 struct GRlc_info	*input_curves[];
 struct GRlc_info	*input_surfaces[];
 struct GRvg_construct	*construct_list;
 IGRdouble		distance;
 IGRpoint		center_point;
 IGRvector		normal_vector;
 GRobjid		*constructed_surface)
{
 IGRlong	*msg, sts, i, number_of_blending_surfaces;
 GRobjid	surface_objects[MAX_CURVES];
 struct		IGRbsp_curve *curves[MAX_CURVES];
 struct		IGRbsp_surface *surfaces[MAX_CURVES];
 struct		IGRbsp_surface *blending_surfaces[MAX_CURVES];
/*
 * Initialize
 */
 msg = construct_list->msg;
 *msg = MSSUCC;
 *constructed_surface = NULL_OBJID;
 for (i = 0; i < MAX_CURVES; i++)
  {
   curves[i] = NULL;
   surfaces[i] = NULL;
   blending_surfaces[i] = NULL;
   surface_objects[i] = NULL_OBJID;
  } 
 number_of_blending_surfaces = 1;	/* Make sure I get deleted on error */
 surface_objects[0] = my_id;
 if ((number_of_curves < 3) ||
     (number_of_curves > MAX_CURVES))
  {
   number_of_curves = 0;		/* Will blow out wrapup if not valid */
   *msg = MSINARG;
   goto wrapup;
  }
/*
 * Get the geometry of the curves and surfaces
 */
 for (i = 0; i < number_of_curves; i++)
  {
   extern	IGRlong EMget_the_geometry();

   sts = EMget_the_geometry(
     input_curves[i],
     TRUE,		/* This is a curve */
     FALSE,		/* The curve is not directed */
     FALSE,		/* Don't perform separate mallocs */
     my_id,
     &curves[i],	/* Resultant curve */
     msg);
    if (! (1 & sts)) goto wrapup;
   if (input_surfaces[i])
    {
     sts = EMget_the_geometry(
       input_surfaces[i],
       FALSE,		/* This is not a curve */
       FALSE,		/* Used only for curves */
       FALSE,		/* Don't perform separate mallocs */
       my_id,
       &surfaces[i],	/* Resultant surface */
       msg);
      if (! (1 & sts)) goto wrapup;
    } /* if (input_surfaces[i]) */
  } /* for (i = 0; i < number_of_curves; i++) */
/*
 * Call the math
 */
 if (number_of_curves < 5)
  {
   extern	void BSsf3o4cvtn();
   IGRlong	loc_msg;

   BSsf3o4cvtn(
    number_of_curves,
    curves,
    surfaces,
    &blending_surfaces[0],
    &loc_msg);
   if (loc_msg != BSSUCC)
    {
#if DEBUG
    fprintf(stderr, "\nBSsf3o4cvtn failure, rc = %d", loc_msg);
#endif
     blending_surfaces[0] = NULL;	/* Don't remove this */
     *msg = MSFAIL;
     goto wrapup;
    }
  } /* if (number_of_curves < 5) */
 else
  {
   extern	void BSblendsfs();
   IGRlong	loc_msg, indices[MAX_CURVES];
   IGRpoint	mid_points[MAX_CURVES];

   BSblendsfs(
    number_of_curves,
    curves,
    surfaces,
    FALSE,		/* Don't care - option for 1 patch if num_cv = 3,4 */
    distance,
    indices,		/* indices[curve_index] points to corres. output sf */
    mid_points,		/* mid points at which the input curves were split */
    center_point,
    normal_vector,
    blending_surfaces,
    &loc_msg);
   if (loc_msg != BSSUCC)
    {
#if DEBUG
    fprintf(stderr, "\nBSblendsfs failure, rc = %d", loc_msg);
#endif
     *msg = MSFAIL;
     goto wrapup;
    }
   number_of_blending_surfaces = number_of_curves;
  } /* ELSE FOR if (number_of_curves < 5) */
/*
 * Construct and post the necessary surface objects
 */
 for (i = 0; i < number_of_blending_surfaces; i++)
  {
   if (i)
    {
     sts = om$construct(
       classid = OPP_EMSgenbs_class_id,
       p_objid = &surface_objects[i]);
      if (! (1 & sts)) 
       {
        *msg = MSFAIL;
        goto wrapup;
       }
    }
   construct_list->geometry = (IGRchar *) blending_surfaces[i];
   sts = om$send(
     msg = message GRvg.GRconstruct(construct_list),
     targetid = surface_objects[i]);
    if (! (1 & sts)) goto wrapup;
   if (number_of_blending_surfaces > 1)
    {
     struct	GRmd_env *md_env;

     md_env = construct_list->env_info;
     sts = om$send(
       msg = message EMSsubbs.EMmk_nat_bdry(
        msg, 
        &md_env->md_env,
        NULL), 			/* Don't want the edge id's */
       targetid = surface_objects[i]);
      if (! (1 & sts)) goto wrapup;
    } /* if (number_of_blending_surfaces > 1) */
  } /* for (i = 0; i < number_of_blending_surfaces; i++) */
/*
 * Construct a composite surface, if more than one surface
 * was output.
 */
 if (number_of_blending_surfaces > 1)
  {
   IGRlong	EMmsg;
   GRobjid	composite_surface;

   construct_list->geometry = NULL;
   sts = om$construct(
     classid = OPP_EMSsfstitch_class_id,
     msg = message GRgraphics.GRconstruct(
      construct_list),
     p_objid = &composite_surface);
    if (! (1 & sts))
     {
      *msg = MSFAIL;
      goto wrapup;
     }
   sts = om$send(
     msg = message EMSsfstitch.EMmake_comp(
      &EMmsg,
      number_of_blending_surfaces,
      surface_objects,
      construct_list->env_info,
      NULL,		/* struct EMSstitch_saveinfo *save_info */
      NULL, 		/* struct EMSstitch_info *in_pairs */
      0, 		/* IGRint in_num_pairs */
      NULL, 		/* struct EMSstitch_geominfo *geom */
      NULL), 		/* options */
     targetid = composite_surface);
   if ((! (1 & EMmsg)) ||
       (EMmsg == EMS_I_Fail))
    {
     extern	IGRlong EFbuild_graphic_group();

     sts = om$send(
      msg = message Root.delete(1),
      targetid = composite_surface);
     sts = EFbuild_graphic_group(
       number_of_blending_surfaces,
       surface_objects,
       NULL,		/* No GRid's */
       construct_list,
       &composite_surface,
       msg);
      if (! (1 & *msg)) goto wrapup;
    } /* stitch failed */
   *constructed_surface = composite_surface;
  } /* if (number_of_blending_surfaces > 1) */
 else
  *constructed_surface = my_id;
/*
 * eof
 */
wrapup:
 for (i = 0; i < number_of_blending_surfaces; i++)
  {
   if (blending_surfaces[i])
    {
     extern IGRboolean	BSfreesf();
     IGRboolean		status;
     IGRlong		loc_msg;

     status = BSfreesf(
      &loc_msg, 
      blending_surfaces[i]);
    }
   if ((! (1 & *msg)) &&
       (surface_objects[i] != NULL_OBJID))
    {
     sts = om$send(
      msg = message Root.delete(1),
      targetid = surface_objects[i]);
    }
  } /* for (i = 0; i < number_of_blending_surfaces; i++) */
 for (i = 0; i < number_of_curves; i++)
  {
   extern void		free();

   if (curves[i]) free(curves[i]);
   if (surfaces[i]) free(surfaces[i]);
  } /* for (i = 0; i < number_of_curves; i++) */
 if (! (1 & *msg))
  return(OM_E_ABORT);
 else
  return(OM_S_SUCCESS);
}

end implementation EMSgenbs;
