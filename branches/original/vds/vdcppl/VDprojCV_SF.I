/* $Id: VDprojCV_SF.I,v 1.2 2001/04/06 15:13:50 ylong Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdcppl / VDprojCV_SF.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDprojCV_SF.I,v $
 *	Revision 1.2  2001/04/06 15:13:50  ylong
 *	TR4484
 *	
 *	Revision 1.1  2001/01/18 19:05:47  hans
 *	Merged SP16 modifications
 *	
 *
 * History:
 *	MM/DD/YYYY	AUTHOR		DESCRIPTION
 *	10/24/2000	HF		Creation date
 *					Overwrite of method EMproject_curve_along_surface_normals,
 *                                      because of missing options, causing incorrect results.
 *	03/27/01	ylong		TR4484
 * -------------------------------------------------------------------*/

/* ###################   APOGEE COMPILED   ################## */
/*
DESCRIPTION

   This routine projects the input curve onto the surface
   along the surface's normals.  One or more linestrings are created
   to represent this projection.

RETURN VALUES

   number_of_objects    number of linestring objects created
   objects		object id's of the linestring objects

NOTES
   If trimming is required then the existing loopset is given to
   'EMget_loops_for...'. The curves will then be clipped against this
   loopset.

HISTORY

   04/10/87 : rlw : creation date
   05/20/87 : rlw : Made this a method and placed it at EMSsubbs class
   10-Oct-87: SM  : Changed to call 'EMget_loops_for_imposition' instead of
		    'EFget_boundaries_for_imposition'. The new function
		    directly return model space curves projected normally
		    onto the surface.
   01-Jun-88:SM	  : fixed a bug which was causing junk id to be passed for
		    clip_ls to EMget_loop.. if trimming was required and
		    the suraface had no boundaries.
   28-Mar-89:SM	  : Argument change in EMget_loops_for_imposition.
		    Function renamed as EMget_mapped_data().
   25-Aug-92:NP   : Modified for ANSI compliance. Changed declaration of "count"
		    to "IGRuint".
 */

class implementation EMSsubbs;

#include "EMS.h"
#include "msdef.h"
#include "emsgetgeom.h"
#include "emsmapdef.h"		/* EMMapBnd_ options */
#include "msdef.h"
#include "msmacros.h"
#include "ECmsg.h"

#define	VD_DEBUG
#include	<VDdebug.h>

extern OMuword OPP_EMSplane_class_id;

IGRint VDproject_curve_along_surface_normals
(
  IGRushort              extra_options,
  struct GRlc_info      *located_curve,
  struct GRlc_info      *located_surface,
  struct GRvg_construct *construct_list,
  IGRboolean             want_status_messages,
  IGRboolean             trimming_required,
  IGRlong               *number_of_objects,
  OM_S_OBJID           **objects,
  IGRlong               *msg
)
{
  struct IGRbsp_surface *surface;
  IGRint                 sts        = OM_S_SUCCESS;
  IGRushort              options    = 0;
  OMuword                my_classid = 0;
  OMuword                my_os      = located_surface->located_obj.osnum;
  GRobjid                my_id      = located_surface->located_obj.objid;

  __enterFunction ( name = "VDproject_curve_along_surface_normals",
                    argfmt = "surface = [%d,%d], curve = [%d,%d], extra_options = %#x, want_status_messages = %d, trimming_required = %d",
                    args = `located_surface->located_obj.osnum, located_surface->located_obj.objid,
                            located_curve->located_obj.osnum, located_curve->located_obj.objid,
                            extra_options, want_status_messages, trimming_required` );

  *msg               = EMS_S_Success;
  *objects           = NULL;
  *number_of_objects = 0;
  surface            = NULL;

  /*
   * Get the geometry of the surface
   */

  if (want_status_messages)
  {
    ex$message(msgnumb = EMS_I_GettingSurfaceData);
  }
  EMS_GET_GEOMETRY(sts, msg, located_surface, FALSE, surface);
  __printf("<<<<< EMS_GET_GEOMETRY() sts = %d, msg = %#x", `sts, *msg`);
  if (!(1 & sts)) goto wrapup;
  /*
   * Project this curve onto the surface along the surfaces normals
   */
  {
    extern IGRint          EMget_mapped_data();
    IGRuint                count = 0;
    struct GRid            clip_ls;
    OM_S_CHANSELECT        to_loopset;
    OM_S_OBJECT_LINKAGE    objct;
    struct EMSgetlp_output junk;

    options = NULL | EMMapBnd_StrokeIfNeeded | EMMapBnd_WantBadCurves | EMMapBnd_NoValidate |
      ( want_status_messages ? EMMapBnd_WantStatMsg : NULL);

    /*
     * If this is a plane or its subclass, set the appropriate bit on so
     * that mapping to uv space is optimised.
     */
    sts = om$get_classid(objid = my_id, osnum = my_os, p_classid = &my_classid);

    if(!(1&sts)) goto wrapup;

    if(my_classid == OPP_EMSplane_class_id)
      options |= EMMapBnd_SurfIsPlane;
    else
    {
      sts =
        om$is_ancestry_valid(subclassid   = my_classid,
                             superclassid = OPP_EMSplane_class_id);

      if(sts == OM_S_SUCCESS) options |= EMMapBnd_SurfIsPlane;
    }

    clip_ls.objid = NULL_OBJID;
    clip_ls.osnum = construct_list->env_info->md_id.osnum;

    options |= extra_options;     // EMMapBnd_NoClip | EMMapBnd_NoFixing | EMMapBnd_NoRmvColEds;

    if(trimming_required)
    {
      to_loopset.type       = OM_e_name;
      to_loopset.u_sel.name = "to_loopset";
      //to_loopset.type       = OM_e_addr;
      //to_loopset.u_sel.addr = &ME.EMSsubbs->to_loopset;

      sts =
        om$get_channel_objects(objid        = located_surface->located_obj.objid,
                               osnum        = located_surface->located_obj.osnum,
                               p_chanselect = &to_loopset,
                               list         = &objct,
                               size         = (OMuint)1,
                               count        = &count);

      __printf("<<<<< om$get_channel_objects() sts = %d, count = %d", `sts, count`);

      if(!(1&sts)) goto wrapup;
      if(count)
        clip_ls.objid = objct.S_objid;

      /*
       * We do need clipping if trimming_required, added by ylong for TR4484
       */
      options = (options&(~EMMapBnd_NoClip));
    }


    junk.num_objs = 0;
    junk.objs     = NULL;
    sts = EMget_mapped_data(1, NULL, located_curve, construct_list, surface,
                            NULL, &located_surface->module_info, NULL, NULL,
                            NULL, &junk, clip_ls, options, NULL, msg);
    *objects           = junk.objs;
    *number_of_objects = junk.num_objs;
  }

wrapup:

  if (surface) free(surface);
  if (! (1 & *msg))
  {
    if (*number_of_objects && *objects) free(*objects);
    *number_of_objects = 0;
    sts = (OM_E_ABORT);
  }
  else
  {
    sts = (OM_S_SUCCESS);
  }
  __exitFunction ( name = "VDproject_curve_along_surface_normals",
                   argfmt = "sts = %d, msg = %#x, options = %#x, number_of_objects = %d",
                   args = `sts, *msg, options, *number_of_objects` );
  return(sts);
}

end implementation EMSsubbs;
