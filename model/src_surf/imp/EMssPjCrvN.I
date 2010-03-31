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

extern OMuword OPP_EMSplane_class_id;

method EMproject_curve_along_surface_normals(
 struct		GRlc_info *located_curve;
 struct		GRlc_info *located_surface;
 struct		GRvg_construct *construct_list;
 IGRboolean	want_status_messages;
 IGRboolean	trimming_required;
 IGRlong	*number_of_objects;
 OM_S_OBJID	**objects;
 IGRlong	*msg)

{
 IGRint         sts;
 struct         IGRbsp_surface *surface;
 OMuword	my_classid;

/*
 * Initialize
 */

 *msg = EMS_S_Success;
 *objects = NULL;
 *number_of_objects = 0;
 surface = NULL;

/*
 * Get the geometry of the surface
 */

 if (want_status_messages) ex$message(msgnumb = EMS_I_GettingSurfaceData)

 EMS_GET_GEOMETRY(sts, msg, located_surface, FALSE, surface)
  if (!(1 & sts)) goto wrapup;
/*
 * Project this curve onto the surface along the surfaces normals
 */
 {
  extern IGRint			EMget_mapped_data();
  IGRuint			count = 0;
  struct GRid			clip_ls;
  OM_S_CHANSELECT		to_loopset;
  OM_S_OBJECT_LINKAGE		obj;
  IGRushort		options;
  struct EMSgetlp_output	junk;

  options = NULL | EMMapBnd_StrokeIfNeeded | EMMapBnd_WantBadCurves |
	    ( want_status_messages ? EMMapBnd_WantStatMsg : NULL) |
	    EMMapBnd_NoValidate;
	
  /* If this is a plane or its subclass, set the appropriate bit on so 
     that mapping to uv space is optimised.
  */
  sts = om$get_classid(objid=my_id, p_classid=&my_classid);
  if(!(1&sts)) goto wrapup;

  if(my_classid == OPP_EMSplane_class_id) options |= EMMapBnd_SurfIsPlane;
  else
   {
     sts = om$is_ancestry_valid(subclassid = my_classid, 
			    superclassid = OPP_EMSplane_class_id);
			
    if(sts == OM_S_SUCCESS) options |= EMMapBnd_SurfIsPlane;
   }

  clip_ls.objid = NULL_OBJID;	
  clip_ls.osnum = OM_Gw_current_OS;

  if(trimming_required)
   {
      to_loopset.type = OM_e_addr;
      to_loopset.u_sel.addr = &ME.EMSsubbs->to_loopset;

      sts = om$get_channel_objects(object = me, p_chanselect = &to_loopset, 
				list = &obj, size = 1, count = &count);
      if(!(1&sts)) goto wrapup;
      if(count)
        clip_ls.objid = obj.S_objid;
   }

   junk.num_objs = 0;
   junk.objs = NULL;
   sts = EMget_mapped_data(1, NULL, located_curve, construct_list, surface, 
		    NULL, &located_surface->module_info, NULL, NULL, 
 		    NULL, &junk, clip_ls, options, NULL, msg);
   *objects = junk.objs;
   *number_of_objects = junk.num_objs;
 }


/*
 * End of routine
 */
wrapup:
 if (surface) free(surface);
 if (! (1 & *msg))
  {
   if (*number_of_objects && *objects) free(*objects);
   *number_of_objects = 0;
   return(OM_E_ABORT);
  }
 else
  return(OM_S_SUCCESS);
}

end implementation EMSsubbs;
