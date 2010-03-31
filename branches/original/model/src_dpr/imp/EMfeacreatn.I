/*
 * This metod does the actual construction of add/remove material feature.
 */


 /*
  * HISTORY:
  * Rustagi 08/02/93 Creation
  * NP      09/09/93 Changed variable "sortpt" & "bad_pts_info" from struct 
  *                  EMSsortpt_info to struct EMparms in line with selective 
  *                  boolean code. Also, "bad_pts_info" was not being freed.
  */

class implementation EMSslfeature;

%safe
#include <math.h>
%endsafe
#include "igrtypedef.h"
#include "igr.h"
#include "OMminimum.h"
#include "OMprimitives.h"
#include "igetypedef.h"
#include "igrdp.h"
#include "ex.h"
#include "dp.h"
#include "godef.h"
#include "gr.h"
#include "go.h"
#include "griodef.h"
#include "grio.h"
#include "emsdef.h"
#include "OMmacros.h"
#include "msdef.h"
#include "emserr.h"
#include "EMSconstruct.h"
#include "EMSmsgdef.h"
#include "EMSbnddef.h"
#include "EMSbnd.h"
#include "EMSlogic.h"
#include "emsdattyp.h"
#include "EMSopt.h"
#include "emsinterdef.h"
#include "EMSprop.h"
#include "emsinter.h"
#include "emssfintdef.h"
#include "emssfint.h"
#include "bserr.h"
#include "bsparameters.h"
#include "emsfeaopts.h"
#include "EMSsfintsort.h"
#include "EMSasfeatdef.h"

/* imports */

/* externs */
extern IGRdouble BSdistptpt();
extern void EFperform_special_boolean();
extern IGRlong EMcreate_secondary_solid();

#define LOCATE_PROFILE 0
#define LOCATE_FROM_SURFACE 1
#define LOCATE_TO_SURFACE 2
#define LOCATE_AXIS 3
#define LOCATE_TRACE_CURVE 4
#define LOCATE_SOLID 5

method EMcreate_add_rem_mat_feature(IGRlong *msg;
                                IGRushort feat_type;
                                IGRboolean projected;
                                IGRboolean revolved;
                                IGRboolean skinned;
                                IGRdouble proj_dist;
                                IGRboolean normal;
                                IGRboolean symmetric;
                                IGRboolean close;
                                IGRlong feaopts;
                                IGRlong matopts;
                                struct GRid *from_surf_id;
                                struct GRid *to_surf_id;
                                struct GRevent *event_info;
                                IGRpoint pivot_pnt;
                                IGRvector projection_vec;
                                IGRvector matadd_vector;
                                IGRdouble *ang_val;
                                IGRvector axis_vec;
                                struct GRid *trace;
                                struct GRvg_construct *const_args;
                                IGRushort assoc_opts)
{
IGRlong msg_loc, sts;
struct GRid secondary_solid, profid;
struct GRmd_env modenvcv, modenvsf;
IGRboolean world, success;
GRrange range;
IGRpoint point_of_importance;
IGRdouble value;
IGRmatrix xform_mat;
IGRshort xform_mattyp;
IGRvector xforms_vec;
struct GRid outcrv, sort_prof_id;
OM_S_OBJID save_md_id;
struct GRid solid_GRid, surface_ids[2], bool_fea_id;
IGRint array_size, numofsort, i;
IGRdouble array[3];
BSrc rc;
struct EMparms *sortpt=NULL, *bad_pts_info=NULL;
IGRint num_bad_pts;
enum EMSbooltype bool_type;

 sts = OM_S_SUCCESS;
 *msg = EMS_S_Success;
 world = TRUE;
 array_size = 3;
 array[0]=0.25; array[1] = 0.50; array[2] = 0.75;
 secondary_solid.objid = NULL_OBJID;
 sort_prof_id.objid = NULL_OBJID;
 outcrv.objid = NULL_OBJID;
 
 if(matopts & EMSadd_material)
  bool_type = EMSbool_union;
 else
 if(matopts & EMSremove_material)
  bool_type = EMSbool_difference;
 /*
  * Create the secondary solid.
  */ 
 sts = EMcreate_secondary_solid(
             &msg_loc,
             &event_info[LOCATE_PROFILE].located_object[0].located_obj,
             &event_info[LOCATE_PROFILE].located_object[0].module_info,
             projected,
             revolved,
             skinned,
             proj_dist,
             normal,
             symmetric,
             close,
             feaopts,
             matopts,
             from_surf_id,
             to_surf_id,
             &event_info[LOCATE_SOLID].located_object[0].module_info,
             pivot_pnt,
             projection_vec,
             matadd_vector,
             &event_info[LOCATE_SOLID].located_object[0].located_obj,
             ang_val,
             axis_vec,
             trace,
             const_args,
             point_of_importance, 
             &secondary_solid);
 if(!(1&sts)) goto ret_end;

 profid.objid = event_info[LOCATE_PROFILE].located_object[0].located_obj.objid;
 profid.osnum = event_info[LOCATE_PROFILE].located_object[0].located_obj.osnum;
 OM_BLOCK_MOVE(&event_info[LOCATE_PROFILE].located_object[0].module_info,
               &modenvcv, sizeof(struct GRmd_env));
 /*
  * HERE I CREATE THE PROPER INPUTS FOR THE SORT POINT GENERATION
  */

 /*
  * Get the range of the secondary solid.
  */
 OM_BLOCK_MOVE(&event_info[LOCATE_SOLID].located_object[0].module_info,
               &modenvsf, sizeof(struct GRmd_env));
 sts = om$send(msg = message GRvg.GRgetrang(&msg_loc,
                            &(modenvsf.md_env.matrix_type),
                            modenvsf.md_env.matrix, &world, range),
                       senderid = NULL_OBJID,
                       targetid = secondary_solid.objid,
                       targetos = secondary_solid.osnum);
 EMSmsgReport(msg_loc, "GRvg.GRgetrang", FALSE);
 value = BSdistptpt(&rc, &range[0], &range[3]);
 /*
  * the id of the profile which need to be  passed into the sort point
  * generation routine is the original profile being transformed to 
  * the point of importance.
  */
  for(i=0; i<3; i++)
   xforms_vec[i] = point_of_importance[i] - pivot_pnt[i];
  success = MAtrlmx(&msg_loc, xforms_vec, (IGRdouble *)xform_mat);
  EMerr_hndlr(!success || !(1&msg_loc), *msg, EMS_E_BSerror, ret_end);
  /*
   * find out the type of the matrix
   */
  success = MAtypemx(&msg_loc, (IGRdouble *)xform_mat, &xform_mattyp);
  EMerr_hndlr (!success || !(1&msg_loc), *msg, EMS_E_BSerror, ret_end);

  save_md_id = modenvcv.md_id.objid;
  /* modenvcv.md_id.objid = NULL_OBJID; */
  outcrv.osnum = profid.osnum;

  sts = om$send (msg= message GRgraphics.GRcopy(&msg_loc,
                                                &modenvcv,
                                                &modenvcv,
                                                &(outcrv.objid)),
                                  senderid=NULL_OBJID,
                                  targetid=profid.objid,
                                  targetos=profid.osnum);
  /* modenvcv.md_id.objid = save_md_id; */
  EMerr_hndlr (!(1&msg_loc&sts), *msg, EMS_E_Fail, ret_end);

  if((xform_mattyp != NULL)  && (xform_mat != NULL))
   {
    save_md_id = modenvcv.md_id.objid;
    /* modenvcv.md_id.objid = NULL_OBJID; */
    sort_prof_id.osnum = outcrv.osnum;
    sts = om$send (msg = message GRgraphics.GRxform(&msg_loc,
                                    &modenvcv, &xform_mattyp, xform_mat,
                                    &sort_prof_id.objid),
                  senderid = NULL_OBJID,
                  targetid = outcrv.objid,
                  targetos = outcrv.osnum);
   /* modenvcv.md_id.objid = save_md_id; */
   EMerr_hndlr (!(1&sts&msg_loc), *msg, EMS_E_Fail, ret_end);
   }
 solid_GRid.objid =
          event_info[LOCATE_SOLID].located_object[0].located_obj.objid;
 solid_GRid.osnum = 
          event_info[LOCATE_SOLID].located_object[0].located_obj.osnum;

 surface_ids[0].objid = from_surf_id->objid;
 surface_ids[0].osnum = from_surf_id->osnum;
 surface_ids[1].objid = to_surf_id->objid;
 surface_ids[1].osnum = to_surf_id->osnum;

 sts = EMgen_rightsortpts(&msg_loc,
                          &sort_prof_id,
                          &modenvcv,
                          point_of_importance,
                          projection_vec,
                          value,
                          trace,
                          &solid_GRid,
                          &secondary_solid,
                          surface_ids,
                          &modenvsf,
                          array_size,
                          array,
                          feaopts,
                          matopts,
                          const_args,
                          &numofsort,
                          &sortpt);
 if(!(1&sts)) goto ret_end;
 /*
  * since the purpose of creating the the copy of original profile
  * has been accomplished, delete it.
  */
 if(sort_prof_id.objid != NULL_OBJID)
  {
  sts = om$send(msg = message GRgraphics.GRdelete(&msg_loc,
                                       &modenvcv),
                         senderid = NULL_OBJID,
                         targetid = sort_prof_id.objid,
                         targetos = sort_prof_id.osnum);
  if(!(1&sts)) goto ret_end;
  }
 
 bool_fea_id.objid = my_id;
 bool_fea_id.osnum = solid_GRid.osnum;

 (void)EFperform_special_boolean(&msg_loc,
                                 &modenvsf,
                                 solid_GRid.objid,
                                 1,
                                 &secondary_solid.objid,
                                 FALSE,
                                 const_args,
                                 bool_type,
                                 numofsort,
                                 sortpt,
                                 NULL,
                                 &num_bad_pts,
                                 &bad_pts_info,
                                 bool_fea_id);
ret_end:
 if(sortpt) om$dealloc (ptr = sortpt); 
 if(bad_pts_info) om$dealloc (ptr = bad_pts_info); 
/*
 if(!(1&sts&msg_loc))
  {
  if(secondary_solid.objid != NULL_OBJID)
   {
   sts = om$send(msg = message GRgraphics.GRdelete(&msg_loc,
                                   &modenvsf),
                         senderid = NULL_OBJID,
                         targetid = secondary_solid.objid,
                         targetos = secondary_solid.osnum);
   if(!(1&sts)) goto ret_end;
   } 
  }
*/
 return(sts); 
}

end implementation EMSslfeature;

