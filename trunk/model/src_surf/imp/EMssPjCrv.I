
/* ###################   APOGEE COMPILED   ################## */
/* 
DESCRIPTION

   This routine projects the input curve onto the surface
   along a caller specified vector.  One or more linestrings are created
   to represent this projection. Trimming with respect to the boundaries
   on the surface is done based on the option specified by the caller.

RETURN VALUES     

   number_of_objects    number of linestring objects created
   objects              object id's of the linestring objects
			Both these arguments should be initialized properly
			BEFORE sending this message. This method DOES NOT
			initialize them because a surface can be sent this
			message by the composite, which needs the total
			number of objects as the grand total from all leaf
			nodes.
   msg                  EMS_S_Success if sucess
                        EMS_E_NoDynamicMemory if no memory
                        EMS_E_Fail if severe problems (best to
                        abort), note that this most likely
                        implies coding, algorithm, or math
                        problems

HISTORY

    10/25/86 : pp  : Design date
    05/20/87 : rlw : Change the method name from GRbspline.EMpjcvsf
                     to EMSsubbs.EMproject_curve_onto_surface.  Also
                     basically rewrote this method to use the new, more
                     practical math routine.  This routine is now much
                     less complicated.
    19-Feb-88: SM  : Rewrote to do surface surface intersection with
		     trimming option if so desired by the caller.
		     If the input curve is a composite then each curve
		     in the composite is handled seperatly.
    07-Mar-89: PP  : Added EMSINT_TRIM_BDRYISAREA option when trimming
                     was desired to properly handle cases when the
                     projected curve lay along the seam.
    03/14/89 : rlw : Memory in wraup: was being freed because the pointer
                     was not being initialized early enough in the code.
    08/25/92 : NP  : Modified for ANSI compliance. GRowner.GRget_components was 
		     being passed struct "GRmdenv_info" instead of "GRmd_env". Added
		     other typecasts.
    02/10/93: sam :  Create long enough surface of projection and call 
                     EMintersect_two_elements to pick up the bspline fit for curves
 */

class implementation EMSsubbs;

#include "EMS.h"
#define DEBUG 0

#if DEBUG
#include <stdio.h>
#endif

#include "bs.h"
#include "bserr.h"
#include "bsparameters.h"
#include "emserr.h"
#include "EMSmsgdef.h"
#include "emssfintdef.h"
#include "emsdef.h"
#include "msdef.h"
#include "msmacros.h"
#include "ECmsg.h"
#include "go.h" 
#include "EMSasnuc.h"
#include "OMmacros.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "gr.h"
#include "EMSasopts.h"

from GRcurve import GRendpts;

method EMproject_curve_onto_surface(
 struct         GRlc_info *located_curve;
 struct         GRlc_info *located_surface;
 struct         GRvg_construct *construct_list;
 IGRvector      projection_vector;
 IGRboolean     want_status_messages;
 IGRboolean     trimming_required;
 IGRlong        *number_of_objects;
 OM_S_OBJID     **objects;
 IGRlong        *msg) 
{
 IGRint         	sts, i;
 IGRlong        	loc_msg;
 struct GRid		*in_id;
 struct GRmdenv_info 	*md_env_info_ptr;
 struct GRmd_env 	*my_env;
 IGRshort               trim_options;

/* New Stuff added */
 
 extern IGRboolean MAidmx(), MAmulmx();
 extern IGRboolean MAidmx(), MAmulmx(), MAtypemx(); 
 extern IGRboolean BSproj0();
 extern IGRdouble BSdistptpt();
 extern IGRboolean BSnorvec(); 
 extern IGRlong EMplace_surf_of_projection();  
 extern IGRlong EMintersect_two_element();

 IGRboolean world_is_false;
 GRrange my_range, curve_range;
 IGRpoint line[2], pds1, pds2, ln1,ln2;
 IGRvector dirvec2;
 IGRdouble d, dc, ds, dot = 0;
 IGRpoint curve_end_pts[2];
 struct GRmdenv_info cv_trans_md_env_info;
 IGRmatrix translation_matrix;
 IGRshort four = 4; 
 GRobjid pj_id = NULL_OBJID;
 struct EMSpoint_info pj_from, pj_to;
 struct EMSobject_info curve_object_info;
 struct IGRbsp_curve *c_list_geom; 
 unsigned short c_list_props; 
 GRobjid curve_md_id = construct_list->env_info->md_id.objid;
 IGRboolean surf_created = FALSE;
 GRobjid loc_cv_md_id = NULL_OBJID;
 struct GRid *int_objs = NULL;
 IGRlong num_int_objs = 0;

/* New Stuff added */

 /*
 * Initialize
 */
 *msg = EMS_S_Success;
 in_id = (struct GRid *) &(located_curve->located_obj);
 my_env = (struct GRmd_env *) &located_surface->module_info;
 md_env_info_ptr = &located_curve->module_info.md_env;
  
/* Options for surface-surface intersection.
 * We need model space intersections in the form of objects.
 * We do not need parametric space intersections.
 * We need to do trimming only if specified by the caller.
 * Now this is taken by call to EMintersect_two_elements
 * outparam_options = NULL;
 * outworld_options = EMSINT_OUTPUT_WORLD | EMSINT_WORLD_OBJECT;    
 */

/*
 * Added option to consider boundary as area when trimming is desired
 * to properly handle cases when the projected curve lay along the seam.
 * pp (03/07/89)
 */

 if (trimming_required)
  trim_options = EMSINT_TRIM_OUTPUT | EMSINT_TRIM_BDRYISAREA;
 else
  trim_options = NULL;
/* 
 * Get my EMSsubbs.GRgetrang
 */

 world_is_false = FALSE;
 sts = om$send(msg = message EMSsubbs.GRgetrang(msg,
               &my_env->md_env.matrix_type, my_env->md_env.matrix,
               &world_is_false, my_range), targetid = my_id); 
 EMerr_hndlr(!(1&sts&*msg), *msg, EMS_E_Fail, wrapup);


/* 
 * Get the curve range GRvg.GRgetrang
 */

 sts = om$send(msg = message GRvg.GRgetrang(msg,
               &md_env_info_ptr->matrix_type, md_env_info_ptr->matrix,
               &world_is_false, curve_range), 
               targetid = in_id->objid, targetos = in_id->osnum);
 EMerr_hndlr(!(1&*msg&sts), *msg, EMS_E_Fail, wrapup);
    
/*
 * Adjust the projection vector
 * Get curve end points GRvg.GRendpts
 * Make the projection
 * Vector start at One of the curve end points
 */ 

 (void)BSnorvec(&loc_msg, projection_vector);
 EMerr_hndlr(BSERROR(loc_msg), *msg, EMS_E_Fail, wrapup);
 
 /*   find the min max box for the curve   */

 dc = BSdistptpt(&loc_msg, curve_range, &curve_range[3]);
 EMerr_hndlr(BSERROR(loc_msg), *msg, EMS_E_Fail, wrapup);

 /*   find the min max box for the surface   */

 ds = BSdistptpt(&loc_msg, my_range, &my_range[3]);
 EMerr_hndlr(BSERROR(loc_msg), *msg, EMS_E_Fail, wrapup);

 /*   set d to the distance of the box with maximum distance between it's
      min and max points    */

 d = MAX(ds, dc);

 /* Get curve end points */

 sts = om$send(msg = message GRcurve.GRendpts(msg,
               &md_env_info_ptr->matrix_type, md_env_info_ptr->matrix,
               curve_end_pts[0], curve_end_pts[1]), 
               targetid = in_id->objid, targetos = in_id->osnum);
 EMerr_hndlr(!(1&*msg&sts), *msg, EMS_E_Fail, wrapup);
 
 /*   find the infinite line defined by the first curve pole and the 
      input projection_vector   */
  
 for(i=0; i<3; i++) {
   	line[0][i] = curve_end_pts[0][i];
 	line[1][i] = line[0][i] + projection_vector[i];
 }

 /*  project the surface min/max points onto the infinite line   */

 (void)BSproj0(&loc_msg, my_range, line, pds1);
  EMerr_hndlr(BSERROR(loc_msg), *msg, EMS_E_Fail, wrapup);

 (void)BSproj0(&loc_msg, &my_range[3], line, pds2);
  EMerr_hndlr(BSERROR(loc_msg), *msg, EMS_E_Fail, wrapup);

 for(i=0; i<3; i++) {
	dot += (pds1[i] - pds2[i]) * projection_vector[i];
 }

/* Adjust the actual projection vector to have the same direction 
 * vector as the input projection vector
 */

 if( dot  < 0 ) {
    for(i=0; i<3; i++) {
	dirvec2[i] = -projection_vector[i];
    }
 }
 else {
    for(i=0; i<3; i++) {
        dirvec2[i] = projection_vector[i];
    }
 }

 /*  now, find a point that is above the surface and below the surface  */

 for(i=0; i<3; i++) {
	ln1[i] = pds1[i] - d * dirvec2[i];
	ln2[i] = pds2[i] + d * dirvec2[i];
 }

 /* translation_matrix.matrix_type = TRANSLATION; 
  * This will be overwritten NOW! */

 (void) MAidmx (&loc_msg, translation_matrix);
         
 translation_matrix[3]  = ln1[0] - line[0][0];
 translation_matrix[7]  = ln1[1] - line[0][1];
 translation_matrix[11] = ln1[2] - line[0][2];
      
 (void) MAmulmx(&loc_msg, &four, &four, &four, translation_matrix, 
                md_env_info_ptr->matrix, cv_trans_md_env_info.matrix);
 (void) MAtypemx(&loc_msg, cv_trans_md_env_info.matrix, 
                 &(cv_trans_md_env_info.matrix_type));

 pj_from.type = EMSdatainfo_numeric; 
 pj_to.type = EMSdatainfo_numeric;
 OM_BLOCK_MOVE(ln1, pj_from.pt, sizeof(IGRpoint));
 OM_BLOCK_MOVE(ln2, pj_to.pt, sizeof(IGRpoint));

 /* Pass new env matrix so that when getgeom is done, the curve
  * is positioned at ln1.
  */
 
 OM_BLOCK_MOVE(in_id, &(curve_object_info.grid), sizeof(struct GRid));
 OM_BLOCK_MOVE(&cv_trans_md_env_info, &(curve_object_info.env.md_env), 
               sizeof(struct GRmdenv_info));
 OM_BLOCK_MOVE(&(located_curve->module_info.md_id), &(curve_object_info.env.md_id), 
 	       sizeof(struct GRid));

 /* store construct list writeable stuff away */
 
 c_list_geom = (struct IGRbsp_curve *) construct_list->geometry;
 c_list_props = construct_list->properties;

 /*
  * Adjust the module id to be NULL_OBJID, so that the surface does not get in
  * the rtree
  */ 

 /* Commented because it cannot be declared in the middle
  * It has been initialized at the top. ANSI screams cause
  * curve_md_id is restored in the end,  inside an "if"
  */
 /* curve_md_id = construct_list->env_info->md_id.objid; */
 construct_list->env_info->md_id.objid = NULL_OBJID;

 if (want_status_messages) ex$message(msgnumb = EMS_I_ProjAndConstResults)

/* Get the surface of projection */

 sts = EMplace_surf_of_projection(msg, EMSasconst_notassociative,
         construct_list->env_info, DEFAULT_GR_LEVEL, construct_list->display, 
         NULL, NULL, &curve_object_info, &pj_from, &pj_to, FALSE, &pj_id);
 EMerr_hndlr(!(1&*msg&sts), *msg, EMS_E_Fail, wrapup);

 surf_created = TRUE;
 
/* now restore module id for located curve and
 * construct_list writeable stuff
 */

 construct_list->env_info->md_id.objid = curve_md_id;
 construct_list->geometry = (char *) c_list_geom;
 construct_list->properties = c_list_props;

 /* adjust located curve to point to this pj_id, NULL the md_id */

 located_curve->located_obj.objid = pj_id;
 located_curve->located_obj.osnum = construct_list->env_info->md_id.osnum;
 loc_cv_md_id = located_curve->module_info.md_id.objid;

 /* Intersect myself with the projected surface and get the 
  * (depending on the option trimmed/untrimmed) intersections on myself.
  */

 sts = EMintersect_two_element(located_surface, located_curve, 
        trim_options, construct_list, &num_int_objs, &int_objs, msg);
 
 /* Restore located curves md_id and objid */
 
 located_curve->located_obj.objid = curve_object_info.grid.objid;
 located_curve->located_obj.osnum = curve_object_info.grid.osnum;
 located_curve->module_info.md_id.objid = loc_cv_md_id;

 EMerr_hndlr(!(1&*msg&sts), *msg, EMS_E_Intersect, wrapup);

/* Allocate for out going objectids */

 if(*objects) *objects = (OM_S_OBJID *) om$realloc(ptr = (IGRchar *)*objects, 
                           size = (num_int_objs + *number_of_objects)
			     * sizeof(OM_S_OBJID));
 else *objects = (OM_S_OBJID *)
                   om$malloc(size = num_int_objs * sizeof(OM_S_OBJID));
 EMerr_hndlr(!(*objects), *msg, EMS_E_NoDynamicMemory, wrapup);

/* stuff output ids */ 
 for( i = 0; i < num_int_objs; i++) {
   (*objects)[(*number_of_objects)++] = int_objs[i].objid;
 }
 
 wrapup:

 if(want_status_messages) {
    if(1&*msg&sts) ex$message(msgnumb = EMS_S_Done)
    else ex$message(msgnumb = EMS_I_ClearStatusField)
 }

 if(int_objs) free(int_objs);

/* delete this temporary projected surface */

 if(surf_created) { 
   IGRlong l_msg;
   construct_list->env_info->md_id.objid = NULL_OBJID;
   om$send(msg = message GRvg.GRdelete(
   		  &l_msg, construct_list->env_info),
		targetid = pj_id);
   construct_list->env_info->md_id.objid = curve_md_id;
 }
 
 if (! (1 & *msg)) {
   if (num_int_objs && *objects) free(*objects);
   *number_of_objects = 0;
   *objects = NULL;
 }

 EMWRAPUP(*msg, sts, "In EMSsubbs.EMproject_curve_onto_surface");
 return(sts);
}

end implementation EMSsubbs;
