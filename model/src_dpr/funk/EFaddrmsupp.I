/* -----------------
 * FOR EMS 4.0
 * Creation : Sanjay
 * -----------------
 */
/*_______________________________________________________________________
 |                                                                       |  
 | OVERVIEW                                                              |
 |                                                                       |
 |    Any feature needs a base solid and a secondary solid (might have   |
 |    created from a profile). But the size of the secondary solid  is   |
 |    not the one which it is supposed to be, as in general it  is big   |
 |    enough for the desired result. And also there is no  way one can   |
 |    generate the  right sized secondary solid which will produce the   |
 |    desired result. So, the only way of accomplishing this  task  is   |
 |    to intersect the base and secondary solids and weed out the unw-   |
 |    anted trace groups which will produce  the desired  result. This   |   
 |    weeding out will ensure the right size of the secondary solid.     |
 |                                                                       |
 |    The functions available in this file attempt at weeding  out the   |
 |    unwanted intersections/trace groups depending up  on the type of   |
 |    feature  and  the  profile (open/close) from which the secondary   |
 |    solid is generated.                                                |
 |                                                                       |
 | NOTES                                                                 |
 |                                                                       |
 |    The functions available in this file are specially  written  for   |
 |    Add/Remove Material functionality.So, it may not be possible for   |
 |    others to use these functions directly, but one  can  derive the   |
 |    ideas from these. The support functions available  in  this file   |
 |    will do away with te sort point generation as  it  picks  up the   |
 |    required trace groups by having a close look  at the inters list   |
 |    of  the  secondary solid. These functions works very fast making   |
 |    the functionality less time consuming.                             |
 |                                                                       |
 |    THIS IS SUPPOSED TO BE THE HEART OF ADD/REMOVE MATERIAL FUNCTIO-   |
 |    NALITY. SO, I STRONGLY RECOMMEND TO UNDERSTAND  THE ALGORITHM(S)   |
 |    BEFORE MODIFYING ANYTHING, AS IT MAY SCREW UP EVERYTHING ELSE.     |
 |                                                                       |
 | HISTORY                                                               |
 |                                                                       |
 |   Sanjay    :  05/02/94  :   Creation                                 |
 |_______________________________________________________________________|
*/

class implementation EMSsfboolean;

#include "math.h"
#include "OMmacros.h"
#include "OMprimitives.h"
#include "igr.h"
#include "EMSdef.h"
#include "EMSmsgnumdef.h"
#include "EMSmsgdef.h"
#include "emssfintdef.h"
#include "emssfint.h"
#include "emsinter.h"
#include "emsimpdef.h"
#include "bserr.h"
#include "bsparameters.h"
#include "EMStpmacros.h"
#include "EMSutlmacros.h"
#include "emsfeaopts.h"
#include "addrmopts.h"
#include "addprot.h"

#include "bsxlnpl.h"
#include "bsdistptpt.h"
#include "bstagsort.h"
#include "bsptinbx.h"

from EMSsubbs    import EMpratmpt;
from EMSedge     import EMendpts, EMgetrange;
from GRcurve     import GRendpts;
extern IGRboolean EFisAncestryValid();
extern OMuword    OPP_EMSplane_class_id;
extern OMuword     OM_Gw_current_OS;
extern IGRboolean  ASbroadcast_in_progress;

extern void EMdelintobj_selective();

/* ------------------------------------------------------------------------- */
/*                      External API Definition                              */
/* ------------------------------------------------------------------------- */

/*__________________________________________________________________________
 |                                                                          |
 | ABSTRACT                                                                 |
 |                                                                          |
 |    This is the driver function for selective boolean operation in  Add/  |
 |    Remove Material functionality. This function takes in the Add/Remove  |
 |    Material options and keeps the trace groups which need  to  be there  |
 |    for the specified option and deletes the rest of them.                |
 |                                                                          |
 | DESCRIPTION                                                              |
 |                                                                          |
 |    Given the intersection data between the base solid and the secondary  |
 |    solid and the feature type (add/remove material), solid type (proje-  |
 |    cted/revolved/skinned) and the extent of the feature (tonext/fromto/  |
 |    finite/thruall), it keeps the trace groups which will ensure the ri-  |
 |    ght size of the secondary solid and deletes the rest  of  the  trace  |
 |    groups.                                                               |
 |                                                                          |
 | NOTES                                                                    |
 |                                                                          |
 |    None                                                                  |
 |                                                                          |
 | ARGUMENTS                                                                |
 |                                                                          |
 |    EFmsg           O    Return code.                                     |
 |    options         I    Not supported presently. For future use.         | 
 |    cons_list       I    Construction list.                               |
 |    md_env          I    Module environment.                              |
 |    feature_type    I    Feature type (Add/Remove Material).              |
 |    solid_type      I    Secondary solid type (projecte/revolved/skinned) |
 |    solid_extent    I    Solid extent (tonext/fromto/finite/thruall).     |
 |    base_slgrid     I    Base solid GRID.                                 |
 |    sec_slinfo      I    Secondary solid info.                            |
 |    base_inters    I/O   Intersection list on base solid.                 |
 |    sec_inters     I/O   Intersection list on secondary solid.            |
 |    base_trace     I/O   Tracedata of base solid.                         |
 |    sec_trace      I/O   Tracedata of secondary solid.                    |
 |                                                                          |
 | RETURN CODE                                                              |
 |                                                                          |
 |     OM_S_SUCCESS  - Success                                              |
 |     OM_E_ABORT    - Failure                                              |
 |                                                                          |
 | KEYWORDS                                                                 |
 |                                                                          |
 |     External API, intersections, tracedata, base and secondary solids    |
 |                                                                          |
 | CAVEATS                                                                  | 
 |                                                                          |
 |                                                                          |
 | ALGORITHM                                                                | 
 |                                                                          |
 |                                                                          |
 | HISTORY                                                                  |
 |                                                                          |
 |     Sanjay      XX/XX/XX      Creation                                   |
 |                                                                          |
 |__________________________________________________________________________|*/

IGRlong  EFkeep_right_trace_groups(
IGRlong                   *EFmsg,
IGRushort                 options,
struct GRvg_construct     *cons_list,
struct GRmd_env           *md_env,
IGRlong                   feature_type,
IGRlong                   solid_type,
IGRlong                   solid_extent,
struct GRid               *base_slgrid,
struct SecSolidInfo       *sec_slinfo,
struct EMSinters          **base_inters,
struct EMSinters          **sec_inters,
struct EMSsftracedata     *base_trace,
struct EMSsftracedata     *sec_trace)
{
  IGRlong                 OMsts, OMmsg, check_present;
  IGRushort               loc_options;
  IGRboolean              is_open;
  IGRboolean              *base_trace_grp_keep, *sec_trace_grp_keep;

  /*
   * Initalize the return  and message status
   */
  OMsts                 = OM_S_SUCCESS;
  OMmsg                 = EMS_S_Success;
  *EFmsg                = EMS_S_Success;

  /*  *************    LOCAL VARIABLES INITIALIZATION  **************** */

  sec_trace_grp_keep    = NULL;
  base_trace_grp_keep   = NULL;
  check_present         = 0;
 
  is_open = sec_slinfo->num_v_surfs ? TRUE : FALSE;

  /*
   * Validate the incoming arguments, if any of them are NULL, error out
   * as invalid arguments.
   */
  if (!cons_list || !md_env || !solid_type || !solid_extent || !base_inters ||
      !sec_inters || !base_trace || !sec_trace || !feature_type)
      add$status (test = TRUE, msg = *EFmsg, code = EMS_E_InvalidArg, 
          str = "EFkeep_right_trace_groups : Invalid Arguments",
          action = GOTO_VALUE, value = wrapup);

  /*
   * First check the options and take the action accordingly: 
   *       The following chart shows, in which case the all the trace groups 
   *       need to be kept and in all other cases, we need to select some of
   *       the trace groups. If the caller specified in any one of the foll-
   *       owing options just return without modifying the trace groups oth-
   *       erwise go ahead.
   *
   * Cases in which direct boolean is sufficient 
   * -------------------------------------------
   *       feature_type: Add material
   *         is_open   : FALSE (profile is closed)
   *            solid_type : Projected/ Revolved/ Skinned
   *               solid_extent :  1. From/To
   *                               2. Finite/Symmetric
   *       feature_type: Remove Material
   *         is_open   : FALSE (Profile is Closed)
   *            solid_type : Projected/ Revolved/ Skinned
   *               solid_extent : 1. Thru - All
   *                              2. From/To  
   *                              3. Finite/Symmetric
   *         is_open   : TRUE (Profile is Open)
   *            solid_type : Projected/ Revolved/ Skinned
   *               solid_extent : 1. Thru - All
   */
           
  if (feature_type & EMSadd_material)
  {
    if (!is_open && ((solid_extent & EMSfeature_from_to) || 
                      (solid_extent & EMSfeature_finite)  ||
                      (solid_extent & EMSfeature_symmetric)))
    {
      *EFmsg = EMS_S_Success;
      goto wrapup;
    }
  }
  else if (feature_type & EMSremove_material)
  {
    if (!is_open && ((solid_extent & EMSfeature_thru_all) ||  
                    (solid_extent & EMSfeature_from_to)  ||
                    (solid_extent & EMSfeature_finite)   ||
                    (solid_extent & EMSfeature_symmetric)))
    {
      *EFmsg = EMS_S_Success;
      goto wrapup;
    }

    if (is_open && (solid_extent & EMSfeature_thru_all)) 
    {
      *EFmsg = EMS_S_Success;
      goto wrapup;
    }
  }

  /*
   * STEP : 1 GET THE INFO. REGARDING WHICH GROUPS NEED TO BE KEPT 
   * *************************************************************
   */

  /*
   *  To/Thru Next option
   */
  if (((solid_extent & EMSfeature_to_next) || 
        (solid_extent & EMSfeature_thru_next))) 
  {
      OMsts = EFget_right_trace_groups_to_thru_next(&OMmsg, options, 
                    cons_list, md_env, feature_type, solid_type, base_slgrid, 
                    sec_slinfo, base_inters, sec_inters, base_trace, sec_trace, 
                    &loc_options, &check_present, &sec_trace_grp_keep, 
                    &base_trace_grp_keep);
      add$status (test = !(1&OMsts&OMmsg), msg = *EFmsg, code = OMmsg,
          str = "EFkeep_right_trace_groups : EFget_right_trace_groups_to_thru_next error",
          action = GOTO_VALUE, value = wrapup);
  }
  /*
   * From To/Finite Option
   */  
  else if ((solid_extent & EMSfeature_from_to) ||
           (solid_extent & EMSfeature_finite) )
  {
      OMsts = EFget_right_trace_groups_from_to_finite(&OMmsg, options, 
                    cons_list, md_env, feature_type, solid_type, solid_extent,
                    base_slgrid, sec_slinfo, base_inters, sec_inters, 
                    base_trace, sec_trace, &loc_options, &check_present, 
                    &sec_trace_grp_keep, &base_trace_grp_keep);
      add$status (test = !(1&OMsts&OMmsg), msg = *EFmsg, code = OMmsg,
          str = "EFkeep_right_trace_groups : EFget_right_trace_groups_from_to_finite error",
          action = GOTO_VALUE, value = wrapup);
  }

  /*
   * STEP : 2  MODIFY THE TRACE GROUPS
   * *********************************
   */
  if (sec_trace_grp_keep || base_trace_grp_keep || check_present)
  {
     OMsts = EFaddrm_modify_trace_groups (&OMmsg, loc_options, cons_list,
                     md_env, sec_inters, base_inters, sec_trace, base_trace,
                     NULL, NULL, NULL, NULL, check_present,
                     sec_trace_grp_keep, base_trace_grp_keep);
     add$status (test = !(1&OMsts&OMmsg), msg = *EFmsg, code = OMmsg,
         str = "EFkeep_right_trace_groups : EFaddrm_modify_trace_groups error",
         action = GOTO_VALUE, value = wrapup);
  }

wrapup : 
  
  /*
   * free the sort pts and bad pts
   */
  if (sec_trace_grp_keep)
      om$dealloc(ptr = sec_trace_grp_keep);
  if (base_trace_grp_keep)
      om$dealloc(ptr = base_trace_grp_keep);

  EMWRAPUP(*EFmsg, *EFmsg, "In EFkeep_right_trace_groups");
  return OMsts;
}

/* ------------------------------------------------------------------------- */
/*                      Support Functions Listing                            */ 
/* ------------------------------------------------------------------------- */

/*
  ABSTRACT

    Marks the trace groups which needs to be kept in "ToNext/ThruNext" option
    of Add/Remove Material.
 
  DESCRIPTION

    Given the intersection and trace data of the base and secondary solids in
    case of ToNext/ThruNext option, it marks the groups which needs to be ke-
    pt to add/remove right size of the material from the base solid. Here the
    algorithm works in the parametric space of the secondary solid. 
 
  RETURN CODE

    EMS_S_Success - If every thing goes fine.
    EMS_I_AddRmNoIntToNextSurf - In case of add material, ToNext option, if
                    the operation results in infinite addition of material.
    EMS_E_AddRmNoIntToNextSurf - Same as above, but during recompute. 
    EMS_E_Fail - If there is any failure.
 
  NOTES

    The secondary solid which is input to this routine is a "EMSgensolid". So 
    the last two components are capping surfaces.
*/

IGRlong  EFget_right_trace_groups_to_thru_next( 
IGRlong                   *EFmsg,
IGRushort                 options,
struct GRvg_construct     *cons_list,
struct GRmd_env           *md_env,
IGRlong                   feature_type,
IGRlong                   solid_type,
struct GRid               *base_slgrid,
struct SecSolidInfo       *sec_slinfo,
struct EMSinters          **base_inters,
struct EMSinters          **sec_inters,
struct EMSsftracedata     *base_trace,
struct EMSsftracedata     *sec_trace,
IGRushort                 *trace_options,
IGRlong                   *check_present,
IGRboolean                **sec_trace_grp_keep,
IGRboolean                **base_trace_grp_keep)
{
  /* Local variables */ 

  IGRint                  i, j, base_num_grps, sec_num_grps, ncomps;
  IGRint                  base_ngrps, *base_grps, sec_ngrps, *sec_grps;
  IGRint                  *loc_sec_grps;
  IGRint                  loc_base_ngrps, *loc_base_grps, loc_sec_ngrps; 
  IGRlong                 OMsts, OMmsg;
  IGRshort                mat_type;
  IGRushort               loc_options, group_options;
  IGRdouble               *mat;
  IGRdouble               chttol, end_parms[4];
  IGRboolean              *loc_base_grp_keep, *loc_sec_grp_keep, found, error;
  struct GRid             endcaps_grid[2], endcap_grid;
  struct GRid             *modsfs_grid, *sec_slgrid;
  struct EMSinters        *inters;
  struct EMSintobj        *intobj;
  struct EMSsftracedata   *tracedata;

  IGRint                  num_sfs, index, index0, index1, v_surf;
  OM_S_CHANSELECT         to_comps; 
  IGRboolean              is_open;
  OMuword                 os;
  GRobjid                 *slcomps=NULL;

  /*
   * Initalize the return status
   */
  OMsts                 = OM_S_SUCCESS;
  OMmsg                 = EMS_S_Success;
  *EFmsg                = EMS_S_Success;

  /* 
   * Local variables initialization  
   */

  mat                   = md_env->md_env.matrix;
  error                 = FALSE;
  inters                = NULL;
  mat_type              = md_env->md_env.matrix_type;
  sec_grps              = NULL;
  sec_ngrps             = 0;
  tracedata             = NULL;
  base_grps             = NULL;
  base_ngrps            = 0;
  modsfs_grid           = NULL;
  loc_sec_grps          = NULL;
  loc_sec_ngrps         = 0;
  loc_base_grps         = NULL;
  loc_base_ngrps        = 0;
  group_options         = NULL;
  loc_sec_grp_keep      = NULL;
  loc_base_grp_keep     = NULL;
  loc_options           = 0;
  *check_present        = 0;

  /* suppress compiler warning */
  options = options;
  base_slgrid = base_slgrid;

  sec_slgrid = &sec_slinfo->grid;
  os = sec_slgrid->osnum;
  is_open = sec_slinfo->num_v_surfs ? TRUE : FALSE;

  EMmake_chanselect(GRcmpowner_to_components, &to_comps);

  BSEXTRACTPAR (&OMmsg, BSTOLCHRDHT, chttol);

  /*
   * Validate the incoming arguments, if any of them are NULL, error out
   * as invalid arguments.
   */
  if (!cons_list || !md_env || !solid_type || !base_inters || !sec_inters ||
      !base_trace || !sec_trace || !feature_type || !trace_options || 
      !sec_trace_grp_keep || !base_trace_grp_keep)
  {
    add$status (test = TRUE, msg = *EFmsg, code = EMS_E_InvalidArg,
        str = "EFget_right_trace_groups_to_thru_next : Invalid Arguments",
        action = GOTO_VALUE, value = wrapup);
  }

  /*
   * get the number of groups 
   */
  base_num_grps = base_trace->num_grps;
  sec_num_grps  = sec_trace->num_grps;
  
  if (sec_num_grps == 1) 
  {
    /*
     * There is only one trace group is resulted  from  the  intersection
     * bet. the base and secondary solids, this will only mean that there
     * is "NO TO NEXT SURFACE  THAT  IS  FULLY INTERSECTING THE SECONDARY 
     * SOLID". So, Send the Information Message  that  there  is  no full 
     * intersection with the To Next Surface.
     */

    if (feature_type & EMSadd_material) 
    {
      /*
       * Add material feature. When adding material, it should be always
       * be bounded. But, this will result in un-bounded addition of ma-
       * terial. So, set the return code such that it represents the si-
       * tuation.
       */

      if (ASbroadcast_in_progress)
        *EFmsg = EMS_E_AddRmNoIntToNextSurf;
      else
        *EFmsg = EMS_I_AddRmNoIntToNextSurf;
      add$status (test = TRUE, msg = *EFmsg, code = *EFmsg, 
          str = "EFget_right_trace_groups_to_thru_next : Number of trace groups is one.");
    }
    else 
    {
      /*
       * Remove material feature. The operation may result in "Thru-All"
       * case. It is fine, as we are removing the material from the base
       * solid and the final result will be a part of  base  solid.  Get
       * out with success.
       */

      *EFmsg = EMS_S_Success;
    }
    
    goto wrapup;
  }
        
  base_ngrps = 0;
  base_grps = NULL;
  sec_ngrps = 0;
  sec_grps = NULL;

  if (feature_type & EMSadd_material)
  { 
    /*
     * Add Material - To Next feature. 
     * -------------------------------
     * Step #1:
     *
     * Get all the connected faces to the first capped surface of the secondary 
     * solid. This can be done by the following mechanism.
     *
     * Get all the trace groups which contains  atleast one  intersection  on
     * the capped surface of the secondary solid  which contains the profile.
     * The first capped surface id stored in the  secondary solid information 
     * structure is the one which encompasses the profile. 
     *
     * If there is atleast one trace group which contains this capped surface
     * means, the profile is lying inside the volume of the base solid other-
     * wise it is lying outside the volume of the base solid. 
     *
     * If the number of trace groups containing this capped surface is  zero, 
     * i.e. profile is lying outside the volume of the base solid,  then  the
     * profile must be a closed one,to result in bounded addition of material.
     *
     * If the number  of trace groups containing this capped surface is  non-
     * zero, i.e. profile is lying inside the volume of the base solid, there
     * is a possibility that we may end up in retaining all/a part  of  these 
     * trace groups depending on whether the base profile is closed/open.
     */
 
    endcaps_grid[0].objid = sec_slinfo->capsurfs_id[0];
    endcaps_grid[0].osnum = os;
    endcaps_grid[1].objid = sec_slinfo->capsurfs_id[1];
    endcaps_grid[1].osnum = os;
    endcap_grid = endcaps_grid[0];

    /*
     * get all the trace groups containing this end cap.   
     */
    EFfind_group_numbers_from_sfid(&OMmsg, &endcap_grid, sec_trace, 
                                    base_trace, &sec_ngrps, &sec_grps,
                                    &base_ngrps, &base_grps);  
    add$status (test = !(1&OMmsg), msg = *EFmsg, code = EMS_E_Fail,
        str = "EFget_right_trace_groups_to_thru_next : EFfind_group_numbers_from_sfid error",
        action = GOTO_VALUE, value = wrapup);
  }

  if (sec_ngrps)
  {
    /*
     * There are some trace groups containing the end cap which encompasses
     * the profile. Allocate the memory for the boolean flags which  stores
     * the info. regarding what trace groups to keep.
     */

    loc_base_grp_keep = (IGRboolean *) om$malloc (size =
                                       base_num_grps * sizeof(IGRboolean));
    loc_sec_grp_keep  = (IGRboolean *) om$malloc (size =
                                       sec_num_grps * sizeof(IGRboolean));
    add$status (test = !loc_base_grp_keep || !loc_sec_grp_keep,
        msg = *EFmsg, code = EMS_E_NoDynamicMemory, 
        str = "EFget_right_trace_groups_to_thru_next : Insufficient Memory",
        action = GOTO_VALUE, value = wrapup);
 
    /*
     * Initialize such that, nothing will be kept.
     */
 
    for (i=0; i<base_num_grps; i++)
      loc_base_grp_keep[i] = FALSE;
    for (i=0; i<sec_num_grps; i++)
      loc_sec_grp_keep[i]  = FALSE;
  }

  /*
   * get all the component surfaces of the secondary solid. One point to note
   * here is, the solid which is input to this routine is a "EMSgensolid". So
   * the last two components are end caps and others are produced by project-
   * ing/revolving/skinning the base profile.
   */

  ncomps  = GetObjectNumCompsOnChannel (sec_slgrid->objid, os, &to_comps);
  slcomps = (GRobjid *) alloca (ncomps * sizeof(GRobjid));
  GetObjectCompsOnChannel (sec_slgrid->objid, os, ncomps, &to_comps, slcomps);

  /*
   * Initialize v_surf to zero.
   */
  v_surf = 0;
  do
  {
    /*
     * For each component surface produced by projecting/revolving/skinning
     * the profile along a given vector/axis/trace curve, do the following.
     */

    if (sec_ngrps) 
    {
      /*
       * Add material - To Next. Open / closed profile and the endcap contai-
       * ning the profile plane intersects with the base solid.
       */

      if (is_open)
      {
        /*
         * The base profile which is input to create the feature is open one.
         * This open profile is extended and closed and a secondary solid  is
         * generated from the closed profile. So, we should  delete  all  the 
         * trace groups which falls in extended segments of the profile.
         */

        /*
         * get the indices of the surfaces generated by the extended segments
         * of the profile.
         */

        index0 = sec_slinfo->surfs_index[v_surf*2];
        index1 = sec_slinfo->surfs_index[v_surf*2+1];
 
        /*
         * get the number of surfaces "num_sfs" which is nothing but  the no.
         * of components of the original open profile and get all the surface 
         * IDs which are generated by the extended and non-extended segements
         * of the original profile. This eliminates the surfaces generated by
         * the added additional segments of the modified closed profile.
         */

        num_sfs = index1 - index0 + 1;

        modsfs_grid = (struct GRid *) alloca (num_sfs * sizeof(struct GRid));
        add$status (test = !modsfs_grid, msg = *EFmsg, 
            code = EMS_E_NoDynamicMemory,
            str = "EFget_right_trace_groups_to_thru_next : Insufficient Memory",
            action = GOTO_VALUE, value = wrapup);
       
        for (i=0, index=index0; i<num_sfs; i++, index++)
        {
          modsfs_grid[i].objid = slcomps[index];
          modsfs_grid[i].osnum = os;
        }

        /*
         * get the U,V parameters on the surfaces generated by the extended 
         * segments of the profile i.e. end segments, corresponding to  the 
         * end points of the original open profile.
         */

        OM_BLOCK_MOVE (&sec_slinfo->parms[v_surf*4], end_parms, 
                       4 * sizeof(double));

        /*
         * get all the trace groups consisting  of  intermediate  surfaces
         * i.e. surfaces generated by non-extended segements  of  original
         * profile, and mark them as "TO BE KEPT".
         */

        for (i=1; i<num_sfs-1; i++)
        {
          /* 
           * for each intermediate surface do the following.
           */
          loc_sec_grps    = NULL; loc_sec_ngrps   = 0;
          loc_base_grps   = NULL; loc_base_ngrps  = 0;

          /*
           * get all the trace groups which contains this surface. Mark all
           * these groups as "TO BE KEPT".
           */

          EFfind_group_numbers_from_sfid(&OMmsg, &modsfs_grid[i], 
                        sec_trace, base_trace, &loc_sec_ngrps, 
                        &loc_sec_grps, &loc_base_ngrps, &loc_base_grps);
          add$status (test = !(1&OMmsg), msg = *EFmsg, code = EMS_E_Fail,
              str = "EFget_right_trace_groups_to_thru_next : EFfind_group_numbers_from_sfid error",
              action = GOTO_VALUE, value = wrapup);

          for (j=0; j<loc_sec_ngrps; j++)
          {
            loc_sec_grp_keep[ loc_sec_grps[j] ]   = TRUE;
            loc_base_grp_keep[ loc_base_grps[j] ] = TRUE;
          }

          if (loc_sec_grps) 
              om$dealloc (ptr = loc_sec_grps);
          if (loc_base_grps) 
            om$dealloc (ptr = loc_base_grps);
        }


        /*
         * Now, get all the trace groups on the surface  generated  by the 
         * first extended segment of the profile, falling in the range  of 
         * non-extended profile segment. Mark all these groups  as "TO  BE 
         * KEPT".
         */

        loc_sec_grps    = NULL; loc_sec_ngrps   = 0;
        loc_base_grps   = NULL; loc_base_ngrps  = 0;
        group_options   = GROUPS_BETWEEN_THE_PARAMETER_VALUES |
                          GROUPS_WITH_ZERO_V_PARAMETER; 

        for (i=0; i<2; i++)
        {
          OMsts = EFget_groups_from_options(&OMmsg, group_options, 
                            &modsfs_grid[0], end_parms, sec_inters, 
                            sec_trace, base_inters, base_trace, 
                            &loc_sec_ngrps, &loc_sec_grps, &loc_base_grps);
          add$status (test = !(1&OMsts&OMmsg), msg = *EFmsg, code = EMS_E_Fail,
              str = "EFget_right_trace_groups_to_thru_next : EFget_groups_from_options (BETWEEN_THE_PARAMETER_VALUES | JUST_BEFORE_THE_PARAMETER) error",
              action = GOTO_VALUE, value = wrapup);

          if (loc_sec_ngrps)
            break;
 
          group_options |= GROUP_JUST_BEFORE_THE_PARAMETER ;
        }

        for (i=0; i<loc_sec_ngrps; i++)
        {
          loc_sec_grp_keep[ loc_sec_grps[i] ]   = TRUE;
          loc_base_grp_keep[ loc_base_grps[i] ] = TRUE;
        }

        if (loc_sec_grps)
          om$dealloc(ptr = loc_sec_grps);
        if (loc_base_grps)
          om$dealloc(ptr = loc_base_grps);

              
        if (num_sfs > 1)
        {
          /*
           * Number of components of original open profile is more than one.
           * Now, get all the trace groups on the surface  generated  by the
           * second extended segment of the profile, falling in the range of
           * non-extended profile segment. Mark all these groups  as "TO  BE
           * KEPT".
           */

          loc_sec_grps    = NULL; loc_sec_ngrps   = 0;
          loc_base_grps   = NULL; loc_base_ngrps  = 0;
          group_options   = GROUPS_BETWEEN_THE_PARAMETER_VALUES |
                            GROUPS_WITH_ZERO_V_PARAMETER ; 

          for (i=0; i<2; i++)
          {
            OMsts = EFget_groups_from_options(&OMmsg, group_options,
                          &modsfs_grid[num_sfs-1], &end_parms[2], sec_inters,
                          sec_trace, base_inters, base_trace, 
                          &loc_sec_ngrps, &loc_sec_grps, &loc_base_grps);
            add$status (test = !(1&OMsts&OMmsg), msg = *EFmsg, code = EMS_E_Fail,
                str = "EFget_right_trace_groups_to_thru_next : EFget_groups_from_options (BETWEEN_THE_PARAMETER_VALUES | GROUP_JUST_AFTER_THE_PARAMETER) error",
                action = GOTO_VALUE, value = wrapup);
             
            if (loc_sec_ngrps)
              break;
             
            group_options |= GROUP_JUST_AFTER_THE_PARAMETER ;
          }

          for (i=0; i<loc_sec_ngrps; i++)
          {
            loc_sec_grp_keep[ loc_sec_grps[i] ]   = TRUE;
            loc_base_grp_keep[ loc_base_grps[i] ] = TRUE;
          }

          if (loc_sec_grps)
            om$dealloc (ptr = loc_sec_grps);
          if (loc_base_grps)
            om$dealloc (ptr = loc_base_grps);
        }      

        /*
         * Now, for each group set the keep/delete flags correctly, depending
         * on the information we got in the above steps.
         */
        for (i=0; i<sec_num_grps; i++)
        {
          found = FALSE;
          for (j=0; j<sec_ngrps; j++)
          {
            if (i == sec_grps[j]) 
            {
              found = TRUE;
              break;
            }
          }
          if (!found) loc_sec_grp_keep[i] = FALSE;
        }
          
        for (i=0; i<base_num_grps; i++)
        {
          found = FALSE;
          for (j=0; j<base_ngrps; j++)
          {
            if (i == base_grps[j])
            {
              found = TRUE;
              break;
            }
          }
          if (!found) loc_base_grp_keep[i] = FALSE;
        }

        /*
         * In case of add material we will try to delete the extreme trace
         * groups. So that the invalid inputs such as profile  ends  lying  
         * outside the base solid material will not result in "Inifinite 
         * addition of material. So, get the extreme trace group and mark 
         * it as deletable. 
         */

        loc_sec_grps  = NULL; loc_sec_ngrps   = 0;
        loc_base_grps = NULL; loc_base_ngrps  = 0;
        group_options = GROUP_WITH_FIRST_INTOBJ | GROUPS_WITH_ZERO_V_PARAMETER;

        for (i=0; i<2 && !loc_sec_ngrps; i++)
        {
          OMsts = EFget_groups_from_options(&OMmsg, group_options,
                        (!i) ? &modsfs_grid[0] : &modsfs_grid[num_sfs-1], 
                        (!i) ? &end_parms[0] : &end_parms[2], sec_inters,
                        sec_trace, base_inters, base_trace, &loc_sec_ngrps, 
                        &loc_sec_grps, &loc_base_grps);
          add$status (test = !(1&OMsts&OMmsg), msg = *EFmsg, 
              code = EMS_E_Fail, str = "EFget_right_trace_groups_to_thru_next : EFget_groups_from_options error",
              action = GOTO_VALUE, value = wrapup);

          group_options = GROUP_WITH_LAST_INTOBJ | GROUPS_WITH_ZERO_V_PARAMETER;
        }

        if (loc_sec_ngrps)
        {
          loc_sec_grp_keep [loc_sec_grps[0]] = FALSE;
          loc_base_grp_keep [loc_base_grps[0]] = FALSE;
        }                  

        /*
         * In case of ToNext/ThruNext option as the solid  generated  is  not 
         * of right length, the extreme endcap should not be the part of  the
         * final solid. So, mark the trace groups which consists of this cap.
         */

        if (endcap_grid.objid != endcaps_grid[0].objid)
          endcap_grid.objid = endcaps_grid[0].objid;
        else
          endcap_grid.objid = endcaps_grid[1].objid;

        EFfind_group_numbers_from_sfid(&OMmsg, &endcap_grid, sec_trace,
                                  base_trace, &sec_ngrps, &sec_grps,
                                  &base_ngrps, &base_grps);
        add$status (test = !(1&OMmsg), msg = *EFmsg, code = EMS_E_Fail,
            str = "EFget_right_trace_groups_to_thru_next : EFfind_group_numbers_from_sfid error",
            action = GOTO_VALUE, value = wrapup);
              
        for (i=0; i<sec_ngrps; i++)
          loc_sec_grp_keep[ sec_grps[i] ] = FALSE; 

        for (i=0; i<base_ngrps; i++)
          loc_base_grp_keep[ base_grps[i] ] = FALSE; 

      } /* if of (is_open) */

      else 

      {
        /*
         * The base profile which is input to create the feature is  closed 
         * one. Mark all the trace groups which contains the endcap surface
         * encompassing the original open profile. Also, find is there  any 
         * trace group which contains a single intersection which is closed.
         */

        IGRint      grp_num=0;
        IGRboolean  single_closed_group = FALSE;

        for (i=0; i<base_ngrps; i++)
          loc_base_grp_keep[ base_grps[i] ] = TRUE;
        for (i=0; i<sec_ngrps; i++)
        {
          grp_num = sec_grps[i];
          loc_sec_grp_keep[ sec_grps[i] ]   = TRUE;
       
          if (!single_closed_group && 
              sec_trace->num_subgrps_grp[grp_num] == 1)
          {
            if (sec_trace->num_elems_subgrp[grp_num][0] == 1)
               single_closed_group = TRUE;
          }
        }

        if (single_closed_group)
        {
          IGRint  caps_found = 0;

          inters = *sec_inters;
          do
          { 
            if ((caps_found == 2)  ||  
                ((inters->this_obj.objid != endcaps_grid[0].objid) &&
                (inters->this_obj.objid != endcaps_grid[1].objid)))
            {
              /*
               * For each capped surface intersection list do the following.
               */
              intobj = Intobj_with_minV(&OMmsg, inters);
              add$status (test = !(1&OMmsg), msg = *EFmsg, code = EMS_E_Fail, 
                  str = "EFget_right_trace_groups_to_thru_next : Intobj_With_minV  error",
                  action = GOTO_VALUE, value = wrapup);

              intobj->props |= EMSintobj_tmpmarked;
              *check_present = EMSintobj_tmpmarked;

              EFget_trace_group_from_intobj(&OMmsg, intobj, sec_trace, 
                                            &grp_num); 
              add$status (test = !(1&OMmsg), msg = *EFmsg, code = EMS_E_Fail, 
                  str = "EFget_right_trace_groups_to_thru_next : EFget_trace_group_from_intobj  error",
                  action = GOTO_VALUE, value = wrapup);

              loc_sec_grp_keep[grp_num] = TRUE;

              EFget_trace_group_from_intobj(&OMmsg, intobj->other_intobj_node, 
                                             base_trace, &grp_num); 
              add$status (test = !(1&OMmsg), msg = *EFmsg, 
                  code = EMS_E_Fail, str = "EFget_right_trace_groups_to_thru_next : EFget_trace_group_from_intobj  error",
                  action = GOTO_VALUE, value = wrapup);

              loc_base_grp_keep[grp_num] = TRUE;
            }
            else
            {
              caps_found++;
            }

            inters = inters->next;

          } while(inters);

        } /* end of if (single_closed_group) */ 

      } /* end of (is_open) */

      loc_options = KEEP_TRACE_GROUP;

    } /* if of (sec_ngrps) */

    else  
    {
      /* 
       * Add material : Profile is outside the volume of the base solid, so 
       * end cap containing profile plane doesn't intersect with  the  base            * solid. 
       *
       * In case of open profiles, this is going produce invalid  result  as 
       * result in unbounded addition of material. So, get out with informa-
       * tive message.
       *
       * In case of a closed profile, we should keep only one trace group to
       * produce the right result. Keeping this group will ensure  that  the 
       * capped surface encompassing the original profile will be a part  of 
       * the final feature.This can be done by getting all the intersections
       * closure to this capped surface (the intersections on  the  surfaces  
       * connected to capped surface closure to capped surface) and  marking
       * them.
       */

      if (is_open && (feature_type & EMSadd_material))
      {
        if (ASbroadcast_in_progress)
        {
          add$status (test = TRUE, msg = *EFmsg, 
              code = EMS_E_AddRmNoIntToNextSurf, 
              str = "EFget_right_trace_groups_to_thru_next : (Open Profile) The End cap of the secondary solid does not intersect with the base solid",
              action = GOTO_VALUE, value = wrapup);
        }
        else 
          error = TRUE;
      }
          
      inters = *sec_inters;
      /*** fix for TR # 119603619 ****/

      if(solid_type & EMSfeature_revolved)
      {
      do
      {
        if (!EFisAncestryValid(&OMmsg,inters->this_obj.objid,
                                   inters->this_obj.osnum ,
                                           OPP_EMSplane_class_id, TRUE))
        {
        intobj = Intobj_with_minV(&OMmsg, inters);
        add$status (test = !(1&OMmsg), msg = *EFmsg, code = EMS_E_Fail,
            str = "EFkeep_right_trace_groups_to_thru_next : Intobj_with_min V error",
            action = GOTO_VALUE, value = wrapup);
        intobj->props |= EMSintobj_tmpmarked;
        } 
        inters = inters->next;
      } while (inters);
      } 
      else
      {
      do
      {
       intobj = Intobj_with_minV(&OMmsg, inters);
       
       add$status (test = !(1&OMmsg), msg = *EFmsg, code = EMS_E_Fail, 
       str = "EFkeep_right_trace_groups_to_thru_next : Intobj_with_min V error",              action = GOTO_VALUE, value = wrapup);         
  
       intobj->props |= EMSintobj_tmpmarked;
       
       inters = inters->next;
      } while (inters && (feature_type & EMSremove_material));
      } 
      loc_options = KEEP_TRACE_GROUP;
      loc_sec_grp_keep = NULL; loc_base_grp_keep = NULL;
      *check_present = EMSintobj_tmpmarked;
      break;

    } /* end of if (sec_ngrps) */

    v_surf ++;

  } while (v_surf < sec_slinfo->num_v_surfs);
  
  if (loc_sec_grp_keep)
  {
    *check_present = EMSintobj_tmpmarked;

    for (i=0; i<sec_num_grps; i++)
    {
      if (loc_sec_grp_keep[i])
      {
        intobj = sec_trace->elems[i][0];
        intobj->props |= EMSintobj_tmpmarked;
      }
    }
  }

  *trace_options        = loc_options;
  *sec_trace_grp_keep   = loc_sec_grp_keep;
  *base_trace_grp_keep  = loc_base_grp_keep; 
 
wrapup : 
  
  if (error && (1&*EFmsg))
    *EFmsg = EMS_I_AddRmNoIntToNextSurf;

  return OMsts;
}

/*
  ABSTRACT

    Marks the trace groups which needs to be kept in "Finite/FromTo" option
    of Add/Remove Material.

  DESCRIPTION

    Given the intersection and trace data of the base and secondary solids in
    case of Finite/FromTo option, it marks the groups which needs to  be kept 
    to add/remove right  size  of the material from the base solid. Here, the 
    algorithm works in the parametric space of the secondary solid.

  RETURN CODE

    EMS_S_Success - If every thing goes fine.
    EMS_I_AddRmInfinite - In case of add material if the operation results in 
                          infinite addition of material.
    EMS_E_AddRmInfinite - Same as above, but during recompute.
    EMS_E_Fail - If there is any internal failure.

  NOTES

    The secondary solid which is input to this routine is a "EMSgensolid". So 
    the last two components are capping surfaces.
*/

IGRlong  EFget_right_trace_groups_from_to_finite(
IGRlong                   *EFmsg,
IGRushort                 options,
struct GRvg_construct     *cons_list,
struct GRmd_env           *md_env,
IGRlong                   feature_type,
IGRlong                   solid_type,
IGRlong                   solid_extent,
struct GRid               *base_slgrid,
struct SecSolidInfo       *sec_slinfo,
struct EMSinters          **base_inters,
struct EMSinters          **sec_inters,
struct EMSsftracedata     *base_trace,
struct EMSsftracedata     *sec_trace,
IGRushort                 *trace_options,
IGRlong                   *check_present,
IGRboolean                **sec_trace_grp_keep,
IGRboolean                **base_trace_grp_keep)
{
  /* Variables for Status Information    */
  IGRlong                    OMsts, OMmsg;
 
  /* Variables for groups Information    */
  IGRint                     base_ngrps, sec_ngrps;
  IGRint                     base_num_grps, sec_num_grps;
  IGRushort                  group_opts, loc_opts;
  IGRboolean                 *loc_base_grp_keep, *loc_sec_grp_keep; 
  IGRboolean                 all_groups_marked;

  /* Variables for the components of the secondary solid */
  IGRdouble              end_parms[4];
  struct GRid            endcaps_grid[2], *modsfs_grid, *sec_slgrid;

  /* Channel info. Variable              */
  OM_S_CHANSELECT            to_comps; 

  /* General Variables declaration       */
  IGRint                     i, j, num_end_segments; 
  IGRint                     loc_sec_ngrps, *loc_sec_grps; 
  IGRint                     loc_base_ngrps, *loc_base_grps;
  IGRboolean                 is_open;
  OMuword                    os;
  struct EMSintobj           *intobj = NULL;

  /* New Variables */
  IGRint                     ncomps=0, v_surf=0, index, index0, index1;
  IGRint                     num_sfs=0;
  GRobjid                    *slcomps=NULL;
   

  /* Initiialize the Status return codes */
  OMsts  = OM_S_SUCCESS;
  OMmsg  = EMS_S_Success;
  *EFmsg = EMS_S_Success;

  /* Local variables Initializataion     */ 
  sec_ngrps              = 0;
  base_ngrps             = 0;
  loc_base_grp_keep      = NULL;
  loc_sec_grp_keep       = NULL;
  modsfs_grid            = NULL;
  loc_opts               = NULL;
  loc_sec_ngrps          = 0;
  loc_sec_grps           = NULL;
  loc_base_ngrps         = 0;
  loc_base_grps          = NULL;

  /* suppress compiler warning */
  options = options;
  base_slgrid = base_slgrid;

  sec_slgrid = &sec_slinfo->grid;
  os = sec_slgrid->osnum;
  is_open = sec_slinfo->num_v_surfs ? TRUE : FALSE;

  /* Validation of Incoming Arguments    */
  if (!cons_list || !md_env || !solid_type || !base_inters || !sec_inters ||
      !base_trace || !sec_trace || !feature_type || !trace_options ||
      !sec_trace_grp_keep || !base_trace_grp_keep)
      add$status (test = TRUE, msg = *EFmsg, code = EMS_E_InvalidArg,
          str = "EFget_right_trace_groups_from_to_finite : Invalid Arguments",
          action = GOTO_VALUE, value = wrapup);

  /* Initialize the Outgoing Variables   */
  *check_present        = 0;
  *trace_options        = NULL;
  *sec_trace_grp_keep   = NULL;
  *base_trace_grp_keep  = NULL;


  /*
   * control comes to this function, only in case of the following options :
   *    a. Open Profile
   *    b. FromTo/Finite 
   * If at all this function is being called in other options, just return
   * success.
   */
  if (!(is_open) || 
      !((solid_extent & EMSfeature_from_to) || 
         (solid_extent & EMSfeature_finite)))
  {
      *EFmsg = EMS_S_Success;
      goto wrapup;
  }

  if (sec_trace->num_grps == 1)
  {
    /*
     * Number of trace groups is one, which might some times result in infinite
     * addition of material, but not always. For the time being assume that 
     * this is not an error condition. Anyway, user can decide himself whether
     * he needs the resultant feature or not. If not he can undo and continue.
     */

    *EFmsg = EMS_S_Success;
    add$status (test = TRUE, msg = *EFmsg, code = *EFmsg,
        str = "EFget_right_trace_from_to_finite : Number of trace groups is one.", action = GOTO_VALUE, value = wrapup);

  }

  base_num_grps = base_trace->num_grps;
  sec_num_grps  = sec_trace->num_grps ;

  endcaps_grid[0].objid = sec_slinfo->capsurfs_id[0];
  endcaps_grid[0].osnum = os;
  endcaps_grid[1].objid = sec_slinfo->capsurfs_id[1];
  endcaps_grid[1].osnum = os;

  /* 
   * get the "cmpowner_to_components" channel info.
   */
  OMsts =  EMmake_chanselect(GRcmpowner_to_components, &to_comps);
  add$status (test = !(1&OMsts), msg = *EFmsg, code = EMS_E_Fail,
      str = "EFget_right_trace_groups_from_to_finite : EMmake_chanselect error",
      action = GOTO_VALUE, value = wrapup);

  /*
   * This is option is set in case of solid of revolution with 360 deg. sweep 
   * angle, in which case capped surfaces does not present. So, no need for us
   * to check whether the capped surfaces are intersecting with the base solid
   * or not. 
   */

  if (endcaps_grid[0].objid == NULL_OBJID) 
    goto Skip_CapsCheck;

  /* 
   * The incoming secondary solid can be any of the following types : 
   *     1. solid of projection
   *     2. solid of revolution
   *     3. solid of skinning
   *     4. gen solid
   * In case of first three solids, the end caps available on "cmpowner_to_com-
   * ponents" at indices 1 and 2.
   * In case gen solid endcaps will be the  last two components of the solid 
   * and gensolid results in only "From/To Option".
   */

  /*
   * Check whether both the end caps intersect with the base solid or not,
   * if both the end caps intersects with the base solid then go ahead 
   * otherwise, there is no way one can constrain the secondary solid so,
   * goto wrapup by issuing the success i.e. We need to keep all the groups.
   */
      
  // check for the first end cap 
  (void) EFfind_group_numbers_from_sfid(&OMmsg, &endcaps_grid[0], 
                     sec_trace, (struct EMSsftracedata *) NULL, &sec_ngrps,
                     (IGRint **) NULL, (IGRint *) NULL, (IGRint **) NULL);
  add$status (test = !(1&OMmsg), msg = *EFmsg, code = EMS_E_Fail,
      str = "EFget_right_trace_groups_from_to_finite : EFfind_group_numbers_from_sfid error",
      action = GOTO_VALUE, value = wrapup);

  /*
   * if first cap surface  is intersecting with the base solid, then check 
   * for the second cappped surface. 
   */

  if (sec_ngrps && (endcaps_grid[1].objid != NULL_OBJID))
  {
    (void) EFfind_group_numbers_from_sfid(&OMmsg, &endcaps_grid[1],
                  sec_trace, (struct EMSsftracedata *) NULL, &sec_ngrps,
                  (IGRint **) NULL, (IGRint *) NULL, (IGRint **) NULL);
    add$status (test = !(1&OMmsg), msg = *EFmsg, code = EMS_E_Fail,
        str = "EFget_right_trace_groups_from_to_finite : EFfind_group_numbers_from_sfid error",
        action = GOTO_VALUE, value = wrapup);
  }
   
  if (!sec_ngrps) 
  {
    /*
     * Both or one of the end capped surface(s) is (are) not intersecting with
     * the base solid. So, there is nothing much I can do here, as it  is  not 
     * constrained in it's length, where as it should have been. So, flag pro-
     * per message and get out of the routine.
     */ 

    add$status (test = TRUE, msg = *EFmsg, code = EMS_S_Success,
        str = "Msg : EFget_right_trace_groups_from_to_finite : None of the capped surfaces of the secondary solid intersecting with the base solid",
        action = GOTO_VALUE, value = wrapup);
  }


Skip_CapsCheck: 

  /* 
   * allocate the memory and mark all the groups as deletable
   */

  loc_base_grp_keep = (IGRboolean *) om$malloc (size =
                                       base_num_grps * sizeof(IGRboolean));
  loc_sec_grp_keep  = (IGRboolean *) om$malloc (size =
                                       sec_num_grps * sizeof(IGRboolean));
  add$status (test = !loc_base_grp_keep || !loc_sec_grp_keep, msg = *EFmsg, 
      code = EMS_E_NoDynamicMemory,
      str = "EFget_right_trace_groups_from_to_finite : Insufficient Memory",
      action = GOTO_VALUE, value = wrapup);

  for (i=0; i<base_num_grps; i++)
    loc_base_grp_keep[i] = FALSE;
  for (i=0; i<sec_num_grps; i++)
    loc_sec_grp_keep[i]  = FALSE;

  ncomps  = GetObjectNumCompsOnChannel (sec_slgrid->objid, os, &to_comps);
  slcomps = (GRobjid *) alloca (ncomps * sizeof(GRobjid));
  GetObjectCompsOnChannel (sec_slgrid->objid, os, ncomps, &to_comps, slcomps);

  for (v_surf=0; v_surf<sec_slinfo->num_v_surfs; v_surf++)
  {
    index0 = sec_slinfo->surfs_index[v_surf*2];
    index1 = sec_slinfo->surfs_index[v_surf*2+1];
 
    num_sfs = index1 - index0 + 1;

    modsfs_grid = (struct GRid *) alloca (num_sfs * sizeof(struct GRid));
    add$status (test = !modsfs_grid, msg = *EFmsg,code = EMS_E_NoDynamicMemory,
        str = "EFget_right_trace_groups_to_thru_next : Insufficient Memory",
        action = GOTO_VALUE, value = wrapup);

    for (i=0, index=index0; i<num_sfs; i++, index++)
    {
      modsfs_grid[i].objid = slcomps[index];
      modsfs_grid[i].osnum = os;
    }

    OM_BLOCK_MOVE (&sec_slinfo->parms[v_surf*4], end_parms, 4*sizeof(double));

    /*
     * Both the end caps are intersecting with the base solid. Now we will 
     * go ahead and mark the groups need to be kept. The algorithm : 
     * Before we move on to the algorithm, a note on the modified profile.
     * NOTE : The modified profile consists all the intermediate segments of
     *        the original profile i.e. leaving the end segments, and the 
     *        end segments are merged with the extended segments and the end
     *        segments are closed by using a line joining the end poitns of
     *        the end segments.
     *
     * Algorithm:
     * **********
     *      O  Mark all the groups as deletable.
     *      O  get all the surfaces generated by the intermediate components 
     *         of the unmodified profile. Mark all the groups containing these
     *         surfaces as one of the inters node.
     *      O  get the surfaces generated by the end segments and find the pa-
     *         meter values corresponding to the end pts of the original prof-
     *         ile by projecting them on to the modified  profile.
     *      O  Say,
     *              S1      - surface generated by the end segment.  
     *              u1, u2  - parameter values of the modified profile corres-
     *                        ponding to the end points of  the end segmet of 
     *                        unmodified profile. (The  point at parameter u2
     *                        corresponds to an end point of one of the 
     *                        segment of the original profile.For more details
     *                        refer to the following figure. 
     *
     *                 ------ -------  --------   (original profile)
     *                 u1   u2         u1     u2
     *    ******** ****-****- *******  -******-**** ******* (modified profile)
     *    (The points correspond to u1 and u2 are shown with "-" symbol on 
     *      modified profile)
     *           1. pick up all the intobjs on S1 whose start and end points
     *              (UV points) having u parameter values in between u1 and u2
     *              and mark all the groups containing these intobjs. 
     *           2. For the first end segment surface
     *              if (u1 < u2)
     *              then
     *                  pick up the group with the intobj whose start and end
     *                  u parameter values are just less than u1. 
     *              else 
     *                  pick up the group with the intobj whose start and end
     *                  u parameter values are just greater than than u1.
     *              For the second end segement surface
     *              if (u1 < u2)
     *              then
     *                  pick up the group with the intobj whose start and end
     *                  u parameter values are just greater than u2.
     *              else
     *                  pick up the group with the intobj whose start and end
     *                  u parameter values are just less than than u2.
     *              Mark the above groups as TO BE KEPT.
     *           3. For the first end segment surface
     *              if (u1 < u2)
     *              then 
     *                   pickup the group containing an intobj with the least
     *                   u parameter value 
     *              else
     *                   pickup the group containing an intobj with the max  
     *                   u parameter value
     *               Mark the above group as deletable one.
     */
   
    /*
     * Now mark all the groups containing the surfaces generated by the inte-
     * rmediate segments of the unmodified profile. There will be intermediate
     * components only if the number of segments of the profile is greater
     * than 2. So, we will enter into thsi following loop only if the number 
     * of components are greater than two. 
     */ 

    for (i=1; i<num_sfs-1; i++)
    {
      loc_sec_grps   = NULL;
      loc_sec_ngrps  = 0   ; 
      loc_base_grps  = NULL;
      loc_base_ngrps = 0   ;

      (void) EFfind_group_numbers_from_sfid(&OMmsg, &modsfs_grid[i], 
                           sec_trace, base_trace, &loc_sec_ngrps, 
                           &loc_sec_grps, &loc_base_ngrps, &loc_base_grps);
      add$status (test = !(1&OMmsg), msg = *EFmsg, code = EMS_E_Fail,
          str = "EFget_right_trace_groups_from_to_finite : EFfind_group_numbers_from_sfid error",
          action = GOTO_VALUE, value = wrapup);
      
      for (j=0; j<loc_sec_ngrps; j++)
      {
        loc_sec_grp_keep[ loc_sec_grps[j] ]   = TRUE;
        loc_base_grp_keep[ loc_base_grps[j] ] = TRUE;
      }
  
      if (loc_sec_grps)  om$dealloc(ptr = loc_sec_grps) ; 
      if (loc_base_grps) om$dealloc(ptr = loc_base_grps); 
    }

    /*
     * get all the groups containing intojbs on the end segment surfaces with
     * start and end u-parameter values between specified u-paramter values 
     * and mark them as TO BE KEPT.
     */
    num_end_segments = (num_sfs > 1) ? 2 : 1;  
 
    for (i=0; i<num_end_segments; i++)
    {
      group_opts        = GROUPS_BETWEEN_THE_PARAMETER_VALUES;
      loc_sec_grps      = NULL; 
      loc_sec_ngrps     = 0;
      loc_base_grps     = NULL; 
      loc_base_ngrps    = 0;
      all_groups_marked = TRUE;

      OMsts = EFget_groups_from_options(&OMmsg, group_opts, 
                    (!i)? &modsfs_grid[0] : &modsfs_grid[num_sfs-1],
                    (!i)? end_parms : &end_parms[2], sec_inters, sec_trace,
                    base_inters, base_trace, &loc_sec_ngrps, &loc_sec_grps,
                    &loc_base_grps);
      add$status (test = !(1&OMsts&OMmsg), msg = *EFmsg, code = EMS_E_Fail,
          str = "EFget_right_trace_groups_from_to_finite : EFget_groups_from_options error",
          action = GOTO_VALUE, value = wrapup); 

      for (j=0; j<loc_sec_ngrps; j++) 
      {
        loc_sec_grp_keep[loc_sec_grps[j]]   = TRUE; 
        loc_base_grp_keep[loc_base_grps[j]] = TRUE; 
      }

      if (!loc_sec_ngrps)
      {
        if (!i)
        {
          if (end_parms[0] < end_parms[1])
            group_opts = GROUP_JUST_BEFORE_THE_PARAMETER;
          else
            group_opts = GROUP_JUST_AFTER_THE_PARAMETER;
        }
        else
        {
          if (end_parms[2] < end_parms[3])
            group_opts = GROUP_JUST_AFTER_THE_PARAMETER;
          else
            group_opts = GROUP_JUST_BEFORE_THE_PARAMETER;
        }

        OMsts = EFget_groups_from_options(&OMmsg, group_opts,
                      (!i)? &modsfs_grid[0] : &modsfs_grid[num_sfs-1],
                      (!i)? end_parms : &end_parms[2], sec_inters, sec_trace,
                      base_inters, base_trace, &loc_sec_ngrps, &loc_sec_grps,
                      &loc_base_grps);
        add$status (test = !(1&OMsts&OMmsg), msg = *EFmsg, code = EMS_E_Fail,
            str = "EFget_right_trace_groups_from_to_finite : EFget_groups_from_options error",
            action = GOTO_VALUE, value = wrapup);

        for (j=0; j<loc_sec_ngrps; j++)
        {
          loc_sec_grp_keep[loc_sec_grps[j]]   = TRUE;
          loc_base_grp_keep[loc_base_grps[j]] = TRUE;
        }
      }

      /* 
       * Trivial check :
       */   

      for (j=0; j<sec_num_grps; j++)
      {
        if (!loc_sec_grp_keep[j])
        {
          all_groups_marked = FALSE;
          break;
        } 
      }
      if (all_groups_marked) goto for_end;
          

      /*
       * In case of Remove Material we need to do  the following :
       */
      if ((feature_type & EMSremove_material) && loc_sec_ngrps)   
      {
        IGRint       l, m, group;
        IGRdouble    loc_parms[2];
        IGRboolean   found = FALSE;    
        struct GRid  sfgrid, end_sfgrid;

        if ((group_opts & GROUP_JUST_BEFORE_THE_PARAMETER) ||
            (group_opts & GROUP_JUST_AFTER_THE_PARAMETER)  ||
            (loc_sec_ngrps == 1))
        {
          group = loc_sec_grps[0]; 
        }
        else
        {
          if (!i)
          {
            if (end_parms[0] < end_parms[1])
            {
              group_opts = GROUP_JUST_AFTER_THE_PARAMETER;
              loc_parms[0] = end_parms[0];
              loc_parms[1] = 0.0;
            }
            else
            {
              group_opts = GROUP_JUST_BEFORE_THE_PARAMETER;
              loc_parms[0] = end_parms[0];
              loc_parms[1] = 1.0;     
            }
          }
          else
          {
            if (end_parms[2] < end_parms[3])
            {
              group_opts = GROUP_JUST_BEFORE_THE_PARAMETER;
              loc_parms[0] = end_parms[3];
              loc_parms[1] = 1.0;     
            }
            else
            {
              group_opts = GROUP_JUST_AFTER_THE_PARAMETER;
              loc_parms[0] = end_parms[3];
              loc_parms[1] = 0.0;
            }
          }

          if (loc_sec_grps)  om$dealloc(ptr = loc_sec_grps) ;
          if (loc_base_grps) om$dealloc(ptr = loc_base_grps);

          OMsts = EFget_groups_from_options(&OMmsg, group_opts,
                      (!i)? &modsfs_grid[0] : &modsfs_grid[num_sfs-1],
                      loc_parms, sec_inters, sec_trace, base_inters, 
                      base_trace, &loc_sec_ngrps, &loc_sec_grps,
                      &loc_base_grps);
          add$status (test = !(1&OMsts&OMmsg), msg = *EFmsg, 
              code = EMS_E_Fail, str = "EFget_right_trace_groups_from_to_finite : EFget_groups_from_options error",
              action = GOTO_VALUE, value = wrapup);

          group = loc_sec_grps[0];

        }
        end_sfgrid = ((!i)? modsfs_grid[0] : modsfs_grid[num_sfs-1]);  

        for (l=0; l<sec_trace->num_subgrps_grp[group]; l++)
        {
          intobj = sec_trace->elems[group][l];

          for (m=0; m<sec_trace->num_elems_subgrp[group][l]; m++)
          {
            sfgrid = intobj->this_obj_node->this_obj;
            if ((sfgrid.objid == end_sfgrid.objid) &&
                (sfgrid.osnum == end_sfgrid.osnum))
            {
              found = TRUE;
              break; 
            }
          }

          if (found) break;
        } 

        intobj->props |= EMSintobj_tmpmarked;
        *check_present = EMSintobj_tmpmarked; 
      }

    for_end :
      if (loc_sec_grps)  om$dealloc(ptr = loc_sec_grps) ;
      if (loc_base_grps) om$dealloc(ptr = loc_base_grps);
      if (all_groups_marked) break;
    } 
    
    /*
     * Now get the group containing the first or last intobj corresponding to
     * one of the end segment surfaces and mark it as DELETABLE.
     */

    if ((feature_type & EMSadd_material) && 
        (solid_type & EMSfeature_projected)) 
    {
      loc_sec_grps    = NULL;
      loc_sec_ngrps   = 0;
      loc_base_grps   = NULL;
      loc_base_ngrps  = 0;
      group_opts      = NULL;
      if (end_parms[0] < end_parms[1])
        group_opts |= GROUP_WITH_FIRST_INTOBJ;
      else
        group_opts |= GROUP_WITH_LAST_INTOBJ;

      OMsts = EFget_groups_from_options(&OMmsg, group_opts, &modsfs_grid[0],
                  (IGRdouble *) NULL, sec_inters, sec_trace, base_inters, 
                  base_trace, &loc_sec_ngrps, &loc_sec_grps, &loc_base_grps);
      add$status (test = !(1&OMsts&OMmsg), msg = *EFmsg, code = EMS_E_Fail,
          str = "EFget_right_trace_groups_from_to_finite : EFget_groups_from_options error",
          action = GOTO_VALUE, value = wrapup);
 
      for (j=0; j<loc_sec_ngrps; j++)
      {
        loc_sec_grp_keep[loc_sec_grps[j]]   = FALSE;
        loc_base_grp_keep[loc_base_grps[j]] = FALSE;
      }
      if (loc_sec_grps)  om$dealloc(ptr = loc_sec_grps) ;
      if (loc_base_grps) om$dealloc(ptr = loc_base_grps);
    }
 
    loc_opts = KEEP_TRACE_GROUP;
  }

  if (loc_sec_grp_keep)
  {
    *check_present = EMSintobj_tmpmarked;

    for (i=0; i<sec_num_grps; i++)
    {
      if (loc_sec_grp_keep[i])
      {
        intobj = sec_trace->elems[i][0];
        intobj->props |= EMSintobj_tmpmarked;
      }
    }
  }

  *trace_options        = loc_opts;
  *sec_trace_grp_keep   = loc_sec_grp_keep;
  *base_trace_grp_keep  = loc_base_grp_keep;

wrapup : 
  return OMsts;
}    

/*
  ABSTRACT
 
    Given a surface and intersection trace data and trace group number, it
    returns TRUE if the surface presents in the trace group otherwise ret-
    urns FALSE.

  RETURN CODE

    TRUE  - Surface presents in the given trace group.
    FALSE - Otherwise.

  NOTES

    None
*/

IGRboolean  EFis_sf_in_trace_group(sfgrid, group_num, tracedata)
struct GRid             *sfgrid;
IGRint                  group_num;
struct EMSsftracedata  *tracedata; 
{
  IGRint           i,j;
  IGRboolean       found;
  struct GRid      this_sfgrid;
  struct EMSintobj *intobj;

  found = FALSE;

  for (i=0; i<tracedata->num_subgrps_grp[group_num]; i++)
  {
    intobj = tracedata->elems[group_num][i];
    for (j=0; j<tracedata->num_elems_subgrp[group_num][i]; j++)
    {
      this_sfgrid = intobj->this_obj_node->this_obj;
      if ((sfgrid->objid == this_sfgrid.objid) &&
          (sfgrid->osnum == this_sfgrid.osnum) )
      {
        found = TRUE;
        break;
      }
    }
    if (found) break;
  }

  return found;
}


/*
  ABSTRACT 

    Given the intersection data, trace data, a surface and the parameters (U) 
    on the surface it returns the all the trace groups which lies in between
    /above/below (depending on options) these parameters with V parameter as
    ZERO.

  RETURN CODE

    EMS_S_Success  - If everything goes well.
    EMS_E_Fail     - Any internal failure.

  NOTES

    The memory for all the output arguments is allocated inside this routine.
    So, it is the caller's responsibility to free the allocated memory.
*/

IGRlong  EFget_groups_from_options(
IGRlong                *EFmsg,
IGRushort              options,
struct GRid            *sfgrid,
IGRdouble              *end_parms,
struct EMSinters       **sec_inters,
struct EMSsftracedata  *sec_trace,
struct EMSinters       **base_inters,
struct EMSsftracedata  *base_trace,
IGRint                 *ngrps,
IGRint                 **sec_grps,
IGRint                 **base_grps)
{
  IGRint                  i, j, k, l, m, num_grps,loc_ngrps, num_cvs, group_num;
  IGRint                  num_mid_intobjs, *loc_sec_grps, *loc_base_grps, size;
  IGRint                  first_group_num, other_first_group_num;
  IGRint                  last_group_num, other_last_group_num;
  IGRlong                 OMsts, OMmsg;
  IGRdouble               beg_uvpt[2], end_uvpt[2], min_param, max_param;
  IGRdouble               min_param1, max_param1, partol;
  IGRdouble               min = 0, max = 0, u_par;
  IGRboolean              found;
  struct GRid             this_sfgrid, this_uvgrid;
  struct GRid             *mid_intobj_grid, beg_intobj_grid, end_intobj_grid;
  struct GRid             first_intobj_grid, last_intobj_grid;
  struct EMSinters        *inters;
  struct EMSintobj        *intobj;
 
  OMsts                   = OM_S_SUCCESS;
  OMmsg                   = EMS_S_Success;
  *EFmsg                  = EMS_S_Success;
  inters                  = NULL; 
  intobj                  = NULL;
  loc_ngrps               = 0; 
  last_group_num          = -1;
  other_last_group_num    = -1;
  mid_intobj_grid         = NULL;
  num_mid_intobjs         = 0;
  first_group_num         = -1;
  other_first_group_num   = -1;
  end_intobj_grid.objid   = NULL_OBJID;
  beg_intobj_grid.objid   = NULL_OBJID;
  last_intobj_grid.objid  = NULL_OBJID;
  first_intobj_grid.objid = NULL_OBJID;
  min_param  = max_param   = 0;
  min_param1 = max_param1 = 0;

  /* Validate the incoming arguments */
  if (!options || !sfgrid || !sec_inters || !base_inters || !sec_trace || 
      !base_trace || !ngrps || !sec_grps || !base_grps)
    add$status (test = TRUE, msg = *EFmsg, code = EMS_E_InvalidArg,
        str = "EFget_groups_from_options : Invalid Arguments",
        action = GOTO_VALUE, value = wrapup);

  if (((options & GROUPS_BETWEEN_THE_PARAMETER_VALUES) || 
        (options & GROUP_JUST_BEFORE_THE_PARAMETER) ||
        (options & GROUP_JUST_AFTER_THE_PARAMETER)) && !end_parms)
    add$status (test = TRUE, msg = *EFmsg, code = EMS_E_InvalidArg,
        str = "EFget_groups_from_options : Invalid Arguments",
        action = GOTO_VALUE, value = wrapup);

  /*
   * 
   */
  num_grps = sec_trace->num_grps;
  BSEXTRACTPAR (&OMmsg, BSTOLPARAM, partol);
 
  /*
   * get all the intobjs on this surface.     
   */
  inters = *sec_inters;

  while(inters) 
  {
    if ((sfgrid->objid == inters->this_obj.objid) &&
        (sfgrid->osnum == inters->this_obj.osnum) )
    {
      intobj = inters->cvs;
      break;
    }
   inters = inters->next;
  } 

  if (!intobj)  /* This surface is not participating in the inters list. */
  {
    *ngrps = 0;
    if (sec_grps ) *sec_grps = NULL;
    if (base_grps) *base_grps = NULL;
    goto wrapup;
  }

  /* 
   * get all the intobjs, those have their starting and ending u parameters
   * between the specified parameters (end_parms) and store them in a temp. 
   * array. Also get the intobj that has u parameter value just less than 
   * end_parms[0] and also get the intobj that has u parameter value just 
   * greater than end_parms[1].
   */

  num_cvs = inters->num_cvs; /* number of intobjs */
  if (end_parms)
  {
    if (end_parms[0] > end_parms[1])
    {
      max = end_parms[0];
      min = end_parms[1];
    }
    else
    {
      max = end_parms[1];
      min = end_parms[0];
    }
  } 

  for (i=0; i<num_cvs; i++)
  {
    /* 
     * if there is only one intersection curve just this intobj as the 
     * beg_intobj_grid intobj and break the loop
     */ 
    if (num_cvs == 1)
    {
      beg_intobj_grid = *(intobj->this_uvintobj.data.object); 
      break;
    }

    /*
     * number of intojbs is greater than one, so do the following.
     *
     * get the end pts (UV) of the intobj.
     */
    this_uvgrid.objid = intobj->this_uvintobj.data.object->objid;
    this_uvgrid.osnum = intobj->this_uvintobj.data.object->osnum;

    OMsts = om$send(msg = message EMSedge.EMendpts(
                                   &OMmsg, beg_uvpt, end_uvpt,
                                   NULL,  NULL, NULL),
                     senderid = NULL_OBJID,
                     targetid = this_uvgrid.objid,
                     targetos = this_uvgrid.osnum);
    add$status (test = !(1&OMsts&OMmsg), msg = *EFmsg, code = EMS_E_Fail,
        str = "EFget_groups_from_options : EMSedge.EMendpts error",
        action = GOTO_VALUE, value = wrapup);

    if (options & GROUPS_WITH_ZERO_V_PARAMETER)
    {
      if (beg_uvpt[1] < partol)
        u_par = beg_uvpt[0];
      else if (end_uvpt[1] < partol)
        u_par = end_uvpt[0];
      else 
      {
        intobj = intobj->next;
        continue;
      }
    }
    else
    {
      if (beg_uvpt[0] < end_uvpt[0]) 
        u_par = beg_uvpt[0];
      else
        u_par = end_uvpt[0];
    }

    if ((options & GROUPS_BETWEEN_THE_PARAMETER_VALUES) && 
       (u_par >= min) && (u_par <= max)) 
    {
      if (!mid_intobj_grid)
        mid_intobj_grid = (struct GRid *) om$malloc (size = 
                             (num_mid_intobjs+1) * sizeof(struct GRid));
      else
        mid_intobj_grid = (struct GRid *) om$realloc(
                            ptr = (IGRchar *) mid_intobj_grid, size = 
                            (num_mid_intobjs+1) * sizeof(struct GRid));
      add$status (test = !mid_intobj_grid, msg = *EFmsg, 
          code = EMS_E_NoDynamicMemory,
          str = "EFget_groups_from_options : Insufficient Memory",
          action = GOTO_VALUE, value = wrapup);
      mid_intobj_grid[num_mid_intobjs] = this_uvgrid;
      num_mid_intobjs ++;
    }

    else if ((options & GROUP_JUST_BEFORE_THE_PARAMETER) && (u_par < min))
    {
      if (beg_intobj_grid.objid == NULL_OBJID)
      {
        max_param = u_par; 
        beg_intobj_grid = this_uvgrid;
      }
      else if (u_par > max_param)
      {
        max_param = u_par; 
        beg_intobj_grid = this_uvgrid;
      }
    }

    else if ((options & GROUP_JUST_AFTER_THE_PARAMETER) && (u_par > max))
    {
      if (end_intobj_grid.objid == NULL_OBJID)
      {
        min_param = u_par;
        end_intobj_grid = this_uvgrid;
      }
      else if (u_par < min_param)
      {
        min_param = u_par; 
        end_intobj_grid = this_uvgrid;
      }
    }

    if (options & GROUP_WITH_FIRST_INTOBJ)
    {
      if (first_intobj_grid.objid == NULL_OBJID)
      { 
        min_param1 = u_par;
        first_intobj_grid = this_uvgrid;
      }
      else if (u_par < min_param1)
      {
        min_param1 = u_par;
        first_intobj_grid = this_uvgrid;
      }
    }

    if (options & GROUP_WITH_LAST_INTOBJ)
    {
      if (last_intobj_grid.objid == NULL_OBJID)
      {
        max_param1 = u_par;
        last_intobj_grid = this_uvgrid;
      }
      else if (u_par > max_param1)
      {
        max_param1 = u_par;
        last_intobj_grid = this_uvgrid;
      }
    }

    intobj = intobj->next;
  }

  size = num_mid_intobjs + 
         ((beg_intobj_grid.objid != NULL_OBJID)   ? 1 : 0) +
         ((end_intobj_grid.objid != NULL_OBJID)   ? 1 : 0) + 
         ((first_intobj_grid.objid != NULL_OBJID) ? 1 : 0) + 
         ((last_intobj_grid.objid != NULL_OBJID)  ? 1 : 0) ; 
  if (size)
  { 
    loc_sec_grps = (IGRint *) om$malloc (size = size * sizeof(IGRint));
    EMerr_hndlr(!loc_sec_grps, *EFmsg, EMS_E_NoDynamicMemory, wrapup);
    loc_base_grps = (IGRint *) om$malloc (size = size * sizeof(IGRint));
    EMerr_hndlr(!loc_base_grps, *EFmsg, EMS_E_NoDynamicMemory, wrapup);
  }
  else
  {
#ifdef DEBUG
    printf("Msg: Size is ZERO in EFget_groups_from_options\n");
#endif
    add$status (test = TRUE, msg = *EFmsg, code = EMS_S_Success,  
                str = "Msg: Size is ZERO in EFget_groups_from_options",
                action = GOTO_VALUE, value = wrapup);
  }
 
  l = 0;  
  for (i=0; i<num_grps; i++)
  {
    found = FALSE;
    for (j=0; j<sec_trace->num_subgrps_grp[i]; j++)   
    {
      intobj = sec_trace->elems[i][j]; 
      for (k=0; k < sec_trace->num_elems_subgrp[i][j]; k++)
      {
        this_sfgrid = intobj->this_obj_node->this_obj;
        if ((sfgrid->objid == this_sfgrid.objid) &&
            (sfgrid->osnum == this_sfgrid.osnum))
        {
          this_uvgrid.objid = intobj->this_uvintobj.data.object->objid;
          this_uvgrid.osnum = intobj->this_uvintobj.data.object->osnum;

          for (m=0; m < num_mid_intobjs && l < num_mid_intobjs; m++)
          {
            if (this_uvgrid.objid == mid_intobj_grid[m].objid &&
                this_uvgrid.osnum == mid_intobj_grid[m].osnum)
            {
              found = TRUE;
              break; 
            }
          }

          if (found)
          {
            /*
             * get the corresponding group number from base solid 
             * trace information
             */
            EFget_trace_group_from_intobj(&OMmsg, intobj->other_intobj_node, 
                                          base_trace, &group_num);
            add$status (test = !(1&OMmsg) , msg = *EFmsg, 
                code = EMS_E_Fail,  
                str = "EFget_groups_from_options : EFget_trace_group_from_intobj error",
                action = GOTO_VALUE, value = wrapup);

            loc_sec_grps[loc_ngrps]  = i;
            loc_base_grps[loc_ngrps] = group_num;
            loc_ngrps++; l++;
            break;
          } 

          else if ((this_uvgrid.objid == beg_intobj_grid.objid) &&
                   (this_uvgrid.osnum == beg_intobj_grid.osnum))
          {
            /*
             * get the corresponding group number from base solid
             * trace information
             */
            EFget_trace_group_from_intobj(&OMmsg, intobj->other_intobj_node, 
                                          base_trace, &group_num);
            add$status (test = !(1&OMmsg) , msg = *EFmsg, 
                code = EMS_E_Fail,  
                str = "EFget_groups_from_options : EFget_trace_group_from_intobj error",
                action = GOTO_VALUE, value = wrapup);

            loc_sec_grps[loc_ngrps]  = i;
            loc_base_grps[loc_ngrps] = group_num;
            loc_ngrps++;  
            found = TRUE;
            break;
          }

          else if ((this_uvgrid.objid == end_intobj_grid.objid) &&
                   (this_uvgrid.osnum == end_intobj_grid.osnum))
          {
            /*
             * get the corresponding group number from base solid
             * trace information
             */
            EFget_trace_group_from_intobj(&OMmsg, intobj->other_intobj_node, 
                                          base_trace, &group_num);
            add$status (test = !(1&OMmsg) , msg = *EFmsg, 
                code = EMS_E_Fail,  
                str = "EFget_groups_from_options : EFget_trace_group_from_intobj error",
                action = GOTO_VALUE, value = wrapup);

            loc_sec_grps[loc_ngrps]  = i;
            loc_base_grps[loc_ngrps] = group_num;
            loc_ngrps++;
            found = TRUE;
            break;
          }

          else if ((this_uvgrid.objid == first_intobj_grid.objid) &&
                   (this_uvgrid.osnum == first_intobj_grid.osnum))
          {
            /*
             * get the corresponding group number from base solid
             * trace information
             */
            EFget_trace_group_from_intobj(&OMmsg, intobj->other_intobj_node,
                                          base_trace, &group_num);
            add$status (test = !(1&OMmsg) , msg = *EFmsg, 
                code = EMS_E_Fail,  
                str = "EFget_groups_from_options : EFget_trace_group_from_intobj error",
                action = GOTO_VALUE, value = wrapup);

            first_group_num = i;
            other_first_group_num = group_num;
          }

          else if ((this_uvgrid.objid == last_intobj_grid.objid) &&
                   (this_uvgrid.osnum == last_intobj_grid.osnum))
          {
            /*
             * get the corresponding group number from base solid
             * trace information
             */
            EFget_trace_group_from_intobj(&OMmsg, intobj->other_intobj_node,
                                          base_trace, &group_num);
            add$status (test = !(1&OMmsg) , msg = *EFmsg, 
                        code = EMS_E_Fail,  
                str = "EFget_groups_from_options : EFget_trace_group_from_intobj error",
                action = GOTO_VALUE, value = wrapup);

            last_group_num = i;
            other_last_group_num = group_num;
          }
        }
        intobj = intobj->next;
      }
      if (found) break;
    }
  }

  if (first_group_num  != -1)
  {
    loc_base_grps[loc_ngrps] = other_first_group_num;
    loc_sec_grps[loc_ngrps]  = first_group_num;
    loc_ngrps ++;
  }

  if (last_group_num  != -1)
  {
    loc_base_grps[loc_ngrps] = other_last_group_num;
    loc_sec_grps[loc_ngrps]  = last_group_num;
    loc_ngrps ++;
  }

  *ngrps     = loc_ngrps;
  *sec_grps  = loc_sec_grps;
  *base_grps = loc_base_grps;

wrapup : 
  if (mid_intobj_grid)
      om$dealloc(ptr = mid_intobj_grid);

  EMWRAPUP(*EFmsg, *EFmsg, "In EFget_groups_from_options");
  return  OMsts; 
}                     

/*
  ABSTRACT
   
    Given trace data and a surface, it returns the group indices which 
    contain the surface.
 
  DESCRIPTION
 
    Given a surface and the trace group, this function finds the all the
    groups containing that surface and returns the number of groups con-
    taining this surface and the group numbers and on request it will  
    also find the other trace group numbers contained by this intobj node.
 
  RETURN CODE

    None
 
  NOTES

    None
*/

void EFfind_group_numbers_from_sfid (
         EFmsg,
         sfgrid,
         this_tracedata,
         other_tracedata,
         this_num_grps,
         this_grp_numbers,
         other_num_grps,
         other_grp_numbers)
IGRlong                 *EFmsg;
struct GRid             *sfgrid;
struct EMSsftracedata   *this_tracedata, *other_tracedata;
IGRint                  *this_num_grps, **this_grp_numbers;
IGRint                  *other_num_grps, **other_grp_numbers;
{
  IGRint            i, j, k, *this_grp_nums, *other_grp_nums;
  IGRint            this_ngrps, other_ngrps;
  IGRlong           OMmsg;
  IGRboolean        group_found; 
  struct GRid       this_sfgrid;
  struct EMSintobj  *intobj;


  OMmsg  = EMS_S_Success;
  *EFmsg = EMS_S_Success;
  this_grp_nums  = NULL;
  other_grp_nums = NULL;
 
  /* Validate the input arguments */
  if (!sfgrid || !this_tracedata || !this_num_grps)
    add$status (test = TRUE, msg = *EFmsg, code = EMS_E_InvalidArg,
        str = "EFfind_group_numbers_from_sfid : Invalid Arguments",
        action = GOTO_VALUE, value = wrapup);
 
  this_ngrps = 0; 
  other_ngrps = 0; 
  if (this_grp_numbers)  *this_grp_numbers = NULL;
  if (other_grp_numbers) *other_grp_numbers = NULL;

  if (this_grp_numbers)
  {
    this_grp_nums = (IGRint *) om$malloc (size = this_tracedata->num_grps * 
                                            sizeof(IGRint));
    add$status (test = !this_grp_nums, msg = *EFmsg, 
        code = EMS_E_NoDynamicMemory,
        str = "EFfind_group_numbers_from_sfid : Insufficient Memory",
        action = GOTO_VALUE, value = wrapup);
  }

  if (other_grp_numbers)
  {
    other_grp_nums = (IGRint *) om$malloc (size = this_tracedata->num_grps * 
                                            sizeof(IGRint));
    add$status (test = !other_grp_nums, msg = *EFmsg, 
        code = EMS_E_NoDynamicMemory,
        str = "EFfind_group_numbers_from_sfid : Insufficient Memory",
        action = GOTO_VALUE, value = wrapup);
  }
  
  for (i=0; i<this_tracedata->num_grps; i++) 
  {
    group_found = FALSE;
    for (j=0; j<this_tracedata->num_subgrps_grp[i]; j++)
    {
      intobj = this_tracedata->elems[i][j];  
      for (k=0; k<this_tracedata->num_elems_subgrp[i][j]; k++) 
      {
        this_sfgrid = intobj->this_obj_node->this_obj;
        if ((sfgrid->objid == this_sfgrid.objid) &&
            (sfgrid->osnum == this_sfgrid.osnum)) 
        {
          group_found = TRUE;
          if (this_grp_numbers) this_grp_nums[this_ngrps] = i;
          this_ngrps ++;
          if (other_grp_numbers && other_num_grps && other_tracedata)
          {
            EFget_trace_group_from_intobj(&OMmsg, intobj->other_intobj_node,
                              other_tracedata, &other_grp_nums[other_ngrps]); 
            add$status (test = !(1&OMmsg), msg = *EFmsg, code = OMmsg,
                str = "EFfind_group_numbers_from_sfid : EFget_trace_group_from_intobj error",
                action = GOTO_VALUE, value = wrapup);

            other_ngrps ++;
          }
          break;
        }
        intobj = intobj->next;
      } /* for (k=0; ...) */

      if (group_found) 
        break;
    } /* for (j=0; ...) */
  } /* for (i=0; ...) */


  if (!this_ngrps) 
  {
    /*
     * No group found.
     */

    if (this_grp_nums)  om$dealloc(ptr = this_grp_nums); 
    this_grp_nums = NULL;
    if (other_grp_nums) om$dealloc(ptr = other_grp_nums); 
    other_grp_nums = NULL;
  }

  else if (this_ngrps != this_tracedata->num_grps)
  {
    /*
     * Groups are found.
     */

    if (this_grp_numbers)
    { 
      this_grp_nums = (IGRint *) om$realloc(
                                    ptr  = (IGRchar *) this_grp_nums, 
                                    size = this_ngrps * sizeof(IGRint));
      add$status (test = !this_grp_nums, msg = *EFmsg, 
          code = EMS_E_NoDynamicMemory,
          str = "EFfind_group_numbers_from_sfid : Insufficient memory",
          action = GOTO_VALUE, value = wrapup);
    }

    if (other_grp_numbers)
    { 
      other_grp_nums = (IGRint *) om$realloc(
                                    ptr  = (IGRchar *) other_grp_nums, 
                                    size = other_ngrps * sizeof(IGRint));
      add$status (test = !other_grp_nums, msg = *EFmsg, 
          code = EMS_E_NoDynamicMemory,
          str = "EFfind_group_numbers_from_sfid : Insufficient memory",
          action = GOTO_VALUE, value = wrapup);
    }
  }

  if (this_grp_numbers)  *this_grp_numbers  = this_grp_nums;
  if (other_grp_numbers) *other_grp_numbers = other_grp_nums;
  if (this_num_grps) *this_num_grps  = this_ngrps;
  if (other_num_grps) *other_num_grps = other_ngrps;   

wrapup :
  EMWRAPUP(*EFmsg, *EFmsg, "In EFfind_group_numbers_from_sfid");
}


/*
  ABSTRACT
 
    Given the trace data, an intobj it returns the group index which 
    contains the intobj.
 
  RETURN CODE

    None
 
  NOTES

    None
*/

void    EFget_trace_group_from_intobj (
        EFmsg,
        intobj,
        tracedata,
        group_number)
IGRlong                 *EFmsg;
struct EMSintobj        *intobj;
struct EMSsftracedata   *tracedata;
IGRint                  *group_number;
{
  IGRint                  i, j, k;
  IGRboolean              group_found;
  GRobjid                 intobj_id;
  GRspacenum              intobj_os;
  struct EMSintobj        *intobj_loc;

  *EFmsg = EMS_S_Success;

  group_found   = FALSE;
  intobj_id     = intobj->this_uvintobj.data.object->objid;
  intobj_os     = intobj->this_uvintobj.data.object->osnum;

  for (i=0; i<tracedata->num_grps; i++)
  {  
    for (j=0; j<tracedata->num_subgrps_grp[i]; j++)
    {
      intobj_loc = tracedata->elems[i][j];

      for (k=0; k<tracedata->num_elems_subgrp[i][j]; k++)
      {
        if ((intobj_id == intobj_loc->this_uvintobj.data.object->objid) &&
            (intobj_os  == intobj_loc->this_uvintobj.data.object->osnum))
        {  
          group_found   = TRUE;
          *group_number = i;
          break;
        }
        intobj_loc = intobj_loc->next;
      }
      if (group_found)
        break;
    }
    if (group_found)
      break;
  }

  add$status (test = !group_found, msg = *EFmsg, code = EMS_E_Fail,
      str = "EFget_trace_group_from_intobj : No group with the given intobj",
      action = GOTO_VALUE, value = wrapup);

wrapup:

  EMWRAPUP (*EFmsg, *EFmsg, "In EFget_trace_group_from_intobj");
}


/*
  ABSTRACT
 
    Returns TRUE if the given surface is in the intersection list otherwise
    returns FALSE. If TRUE and asked for the inters it returns the interse-
    tion list of the surface. 
 
  DESCRIPTION 
 
    This function finds whether the given surface is participating in the 
    given inters list. It returns TRUE if the surface participates in the
    inters list otherwise FALSE.

  RETURN CODE

    TRUE  - If the surface is there in the intersection list.
    FALSE - Otherwise 
 
  NOTES

    None
*/

IGRboolean   EFis_sf_in_inters(sfgrid, inters, sf_inters)
struct GRid       *sfgrid;
struct EMSinters  **inters, **sf_inters;
{
  IGRboolean          sf_in_inters;
  struct   EMSinters  *loc_inters;

  loc_inters = NULL;
  sf_in_inters = FALSE;

  loc_inters = *inters;

  while(loc_inters)
  {
    if ((sfgrid->objid == loc_inters->this_obj.objid) &&   
        (sfgrid->osnum == loc_inters->this_obj.osnum) )
    {
      sf_in_inters = TRUE;
      break;
    }
    loc_inters = loc_inters->next;
  }

  if (sf_inters) 
    *sf_inters = loc_inters;
 
  return (sf_in_inters);
}

/*
  ABSTRACT 

    Given the intersection data, it returns the intobj with minimum V parame-
    ter value on it. In case of contending intobjs, it returns the first one.

  RETURN CODE

    EMS_S_Success - If everything goes well.
    EMS_E_Fail    - Any internal failure.

  NOTES

    None
*/

struct EMSintobj * Intobj_with_minV(
IGRlong           *EFmsg,
struct EMSinters  *inters)
{
  IGRint             i;
  IGRlong            OMsts, OMmsg;
  IGRdouble          uvrange[4], temp, minV;
  struct EMSintobj   *intobj = NULL, *minVintobj = NULL;

  *EFmsg = EMS_S_Success;
  OMmsg  = EMS_S_Success;
  OMsts  = OM_S_SUCCESS ;

  // Validate the incoming arguments
  add$status (test = !inters, msg = *EFmsg, code = EMS_E_InvalidArg,
      str = "Intobj_with_minV : Invalid Arguments error",
      action = GOTO_VALUE, value = wrapup);

  for (intobj = inters->cvs, i=0; i < inters->num_cvs;
       intobj = intobj->next, i++)
  {
    if (intobj->this_uvintobj.datatype == EMSdata_object)
    {
      OMsts = om$send(msg = message EMSedge.EMgetrange(&OMmsg, uvrange,
                                       NULL),
                      senderid = NULL_OBJID,
                      targetid = intobj->this_uvintobj.data.object->objid,
                      targetos = intobj->this_uvintobj.data.object->osnum);
      add$status (test = !(1&OMsts&OMmsg), msg = *EFmsg, code = EMS_E_Fail,
          str = "Intobj_with_minV : EMSedge.EMgetrange error",
          action = GOTO_VALUE, value = wrapup);
    }

    else if (intobj->this_uvintobj.datatype == EMSdata_poly2d ||
             intobj->this_uvintobj.datatype == EMSdata_poly3d)
    {
      EM2dbx(intobj->this_uvintobj.data.poly->num_points,
             intobj->this_uvintobj.data.poly->points, uvrange);
    }

    else
    {
      add$status (test = TRUE, msg = *EFmsg, code = EMS_E_InvalidArg,
          str = "Intobj_with_minV : Invalid Intobj error",
          action = GOTO_VALUE, value = wrapup);
    }

    if (!i)
    {
      minV = uvrange[1];
      minVintobj = intobj;
    }
    else
    {
      temp =  uvrange[1];
      if (temp < minV)
      {
        minVintobj = intobj;
        minV = temp;
      }
    }
  }

wrapup :

  return  minVintobj;
}


/* ------------------------------------------------------------------------- */
/*                        Unused Functions Listing                           */
/* ------------------------------------------------------------------------- */

/*
  ABSTRACT
     Given the number of trace groups and the group numbers this function 
     keeps/deletes that group in the trace data. This function will be driven 
     by an option, which will enable the caller to specify whether to keep or 
     to delete the specified groups.
 
  RETURN CODE
 
  NOTES

     Unused Function
*/

void  EFdel_keep_trace_groups(
IGRlong                *EFmsg,  
IGRboolean             delete,
IGRboolean             *grp_del_flags,
struct EMSinters       **inters,
struct EMSsftracedata  *trace)
{
   IGRint                   i,j,k;
   IGRlong                  OMmsg;
   struct EMSintobj         *intobj_del;
   extern struct EMSintobj  *EMdelintobj();

   OMmsg = EMS_S_Success;
   *EFmsg = EMS_S_Success;
  
   /* Validate the incoming arguments */
   if (!grp_del_flags || !trace)
       add$status (test = TRUE, msg = *EFmsg, code = EMS_E_InvalidArg,
           str = "EFdel_keep_trace_groups : Invalid Arguments",
           action = GOTO_VALUE, value = wrapup);
     
   for (i=0; i<trace->num_grps; i++)
   {
       if ((delete ? (grp_del_flags[i] == TRUE):(grp_del_flags[i] == FALSE)))
       {
           for (j=0; j<trace->num_subgrps_grp[i]; j++)
           {
               intobj_del = trace->elems[i][j];
               for (k=0; k<trace->num_elems_subgrp[i][j]; k++)
               {
                   intobj_del->props |= EMSintobj_deletable; 
                   intobj_del         = intobj_del->next;
               }
           } 
       }
   }
 
   EMdelintobj_selective(&OMmsg, NULL, *inters, EMSintobj_deletable, NULL);
   add$status (test = !(1&OMmsg), msg = *EFmsg, code = OMmsg,
       str = "EFget_trace_group_from_intobj : EMdelintobj_selective error",
       action = GOTO_VALUE, value = wrapup);

wrapup :
   EMWRAPUP(*EFmsg, *EFmsg, "In EFdel_keep_trace_groups");
}

/*
  ABSTRACT
 
    Given a composite curve and the index, it returns the end points of 
    the component at the index and the component id.
 
  RETURN CODE 
 
  NOTES

    Unused function
*/

IGRlong  EFget_component_endpts(EFmsg, md_env, composite_grid, component_no, 
                                 component_grid, end_pts)
IGRlong          *EFmsg;
struct GRmd_env  *md_env;
IGRint           component_no;
struct GRid      *composite_grid, *component_grid;
IGRpoint         *end_pts;
{
    IGRint       ncomps, count;
    IGRlong      OMsts, OMmsg;
    struct GRid  comp_grid;

    OMsts = OM_S_SUCCESS;
    OMmsg = EMS_S_Success;
    *EFmsg = EMS_S_Success;

    /* Validate the incoming arguments */
    if (!composite_grid || !end_pts)
       add$status (test = TRUE, msg = *EFmsg, code = EMS_E_InvalidArg,
           str = "EFget_component_endpts : Invalid Arguments",
           action = GOTO_VALUE, value = wrapup);

    if (component_no >= 0) /* if the given comp. number is a valid one then
                              get the number of components */
    {
        OMsts = om$send(msg = message GRowner.GRget_number_components(
                                       &OMmsg, &ncomps),
                         senderid = NULL_OBJID,
                         targetid = composite_grid->objid,
                         targetos = composite_grid->osnum);
        add$status (test = !(1&OMsts&OMmsg), msg = *EFmsg, code = EMS_E_Fail,
            str = "EFget_component_endpts : GRget_number_components error",
            action = GOTO_VALUE, value = wrapup);
      
        /* 
         * component number is greater than the number of components, error 
         * out
         */  
        if (component_no > (ncomps - 1))
            add$status (test = TRUE, msg = *EFmsg,code = EMS_E_Fail,
                str = "EFget_component_endpts : Component number is greater thanthe number of components",
                action = GOTO_VALUE, value = wrapup);

        /*
         * get the component
         */
        OMsts = om$send(msg = message GRowner.GRget_components(
                                       &OMmsg, md_env, &comp_grid,
                                       1, &count, component_no, component_no),
                         senderid = NULL_OBJID,
                         targetid = composite_grid->objid,
                         targetos = composite_grid->osnum);
        add$status (test = !(1&OMsts&OMmsg), msg = *EFmsg, code = EMS_E_Fail,
            str = "EFget_component_endpts : GRget_components",
            action = GOTO_VALUE, value = wrapup);
    }
    else
    {
        comp_grid = *composite_grid;
    }

    /*
     * get the end pts of the component
     */
    OMsts = om$send(msg = message GRcurve.GRendpts(
                                   &OMmsg, &md_env->md_env.matrix_type,
                                   md_env->md_env.matrix, end_pts[0], 
                                   end_pts[1]),
                     senderid = NULL_OBJID,
                     targetid = comp_grid.objid,
                     targetos = comp_grid.osnum);
    add$status (test = !(1&OMsts&OMmsg), msg = *EFmsg, code = EMS_E_Fail,
        str = "EFget_component_endpts : GRcurve.GRendpts error",
        action = GOTO_VALUE, value = wrapup);

    if (component_grid)
        *component_grid = comp_grid;  

wrapup :
    EMWRAPUP(*EFmsg, *EFmsg, "EFget_component_endpts");
    return OMsts;
}

/*
  ABSTRACT

  RETURN CODE

  NOTES

    Unused function
*/

IGRlong  EFget_sort_pts(EFmsg, md_env, num_sfs, sfs_grid, xyz_pts, sort_pts)
IGRlong          *EFmsg;
struct GRmd_env  *md_env;
IGRint           num_sfs;
struct GRid      *sfs_grid;
IGRpoint         *xyz_pts;
struct EMparms   **sort_pts;
{
   IGRint          cnt;
   IGRlong         OMsts, OMmsg;
   IGRdouble       uvpt[2];
   struct EMparms  *loc_sort_pts; 

   OMsts = OM_S_SUCCESS;
   OMmsg = EMS_S_Success; 
   *EFmsg = EMS_S_Success;
   loc_sort_pts = NULL;

   /* Validate the incoming arguments */
   if (!num_sfs || !sfs_grid || !xyz_pts || !sort_pts)
       add$status (test = TRUE, msg = *EFmsg, code = EMS_E_InvalidArg,
           str = "EFget_sort_pts : Invalid Arguments",
           action = GOTO_VALUE, value = wrapup);

   *sort_pts = NULL;
   /* 
    * allocate the memory for the sort pts (number of sort pts equal to the 
    * number of surfaces
    */ 
   loc_sort_pts = (struct EMparms *) om$malloc (size = 
                                           num_sfs * sizeof(struct EMparms));
   add$status (test = !loc_sort_pts, msg = *EFmsg, code = EMS_E_NoDynamicMemory,
       str = "EFget_sort_pts : Insufficient memory",
       action = GOTO_VALUE, value = wrapup);

   /*
    * now get the sort pts on the surfaces by getting the u,v parameters
    * corresponding to the given xyz pt
    */      
   for (cnt=0; cnt<num_sfs; cnt++)
   {
       OMsts = om$send(msg = message EMSsubbs.EMpratmpt(
                                      &OMmsg, &md_env->md_env.matrix_type, 
                                      md_env->md_env.matrix, 1,
                                      (IGRdouble *) xyz_pts[cnt],
                                      uvpt, NULL, NULL),
                        senderid = NULL_OBJID,
                        targetid = sfs_grid[cnt].objid,
                        targetos = sfs_grid[cnt].osnum);
       add$status (test = !(1&OMsts&OMmsg), msg = *EFmsg, code = EMS_E_Fail,
           str = "EFget_sort_pts : EMSsubbs.EMpratmpt error", 
           id = sfs_grid[cnt].objid, osnum = sfs_grid[cnt].osnum,
           action = GOTO_VALUE, value = wrapup);
  
       loc_sort_pts[cnt].leaf_id = sfs_grid[cnt];
       loc_sort_pts[cnt].u = uvpt[0]; 
       loc_sort_pts[cnt].v = uvpt[1]; 
    }

    *sort_pts = loc_sort_pts;

wrapup :
    if (!(1&OMsts&*EFmsg) && loc_sort_pts)
    {
        om$dealloc(ptr = loc_sort_pts);
        *sort_pts = NULL;
    }
    EMWRAPUP(*EFmsg, *EFmsg, "In EFget_sort_pts"); 
    return OMsts;
}

/*
  ABSTRACT
 
  RETURN CODE

  NOTES

    Unused function.
*/

IGRlong   EFget_channel_objects(EFmsg, obj_grid, chan, from_index, 
                                 to_index, chan_objs_grid)
IGRlong          *EFmsg;
struct GRid      *obj_grid;
OM_S_CHANSELECT  *chan;
IGRint           from_index, to_index;
struct GRid      **chan_objs_grid;
{
   IGRint        cnt, num_objects, i;
   IGRlong       OMsts, OMmsg;
   struct GRid   *loc_objs_grid; 

   OMsts = OM_S_SUCCESS;
   OMmsg = EMS_S_Success; 
   *EFmsg = EMS_S_Success;
   loc_objs_grid = NULL;

   /* Validate the incoming arguments */
   if (!obj_grid || !chan || !chan_objs_grid || (to_index < from_index))
       add$status (test = TRUE, msg = *EFmsg, code = EMS_E_InvalidArg,
           str = "EFget_channel_objects : Invalid Arguments",
           action = GOTO_VALUE, value = wrapup);

   num_objects = to_index - from_index + 1;
   loc_objs_grid = (struct GRid *) om$malloc (size = num_objects * 
                                                     sizeof(struct GRid));
   add$status (test = !loc_objs_grid, msg = *EFmsg,code = EMS_E_NoDynamicMemory,
       str = "EFget_channel_objects : Insufficient Memory",
       action = GOTO_VALUE, value = wrapup);

   for (cnt = from_index, i=0; cnt <= to_index; cnt++, i++)
   {
       OMsts = om$get_objid_at_index(
                                objid        = obj_grid->objid,
                                osnum        = obj_grid->osnum,
                                index        = cnt,
                                objidaddr    = &loc_objs_grid[i].objid,
                                osnumaddr    = &loc_objs_grid[i].osnum, 
                                p_chanselect = chan);
       add$status (test = !(1&OMsts), msg = *EFmsg, code = EMS_E_OMerror,
           str = "EFget_channel_objects : om$get_objid_at_index error",
           id = obj_grid->objid, osnum = obj_grid->osnum,
           action = GOTO_VALUE, value = wrapup);
   }
   
   *chan_objs_grid = loc_objs_grid;

wrapup :
   if (!(1&OMsts&OMmsg) && loc_objs_grid)
   {
       om$dealloc(ptr = loc_objs_grid);
       *chan_objs_grid = NULL;
   }
   EMWRAPUP(*EFmsg, *EFmsg, "In EFget_channel_objects");
   return OMsts;
}

/*
  ABSTRACT
    Sorts the intersections on a surface in the ascending order by projecting
    the intersections on to a plane along a specified vector.

  RETURN CODE

  NOTES
*/

IGRlong  EFsort_intobjs_by_projecting_along_vector_onto_plane(EFmsg, inters,
         vector, plane, sort_index)
IGRlong             *EFmsg;
struct EMSinters    *inters;
IGRvector           vector;
struct IGRplane     *plane;
IGRint              **sort_index;
{
   BSrc             BSmsg; 
   IGRint           i, j, *indx, num_intobjs;
   IGRlong          OMsts, OMmsg;
   IGRpoint         pt1, pt2, int_pt1;
   IGRpoint         plane_point, plane_normal;
   IGRdouble        *dist, dist1;
   IGRboolean       BSsts;
   struct EMSintobj *intobj;

   OMsts = OM_S_SUCCESS;
   OMmsg = EMS_S_Success;
   *EFmsg = EMS_S_Success;
  
   /* Validate the incoming arguments */
   if (!inters || !sort_index || !plane)
       add$status (test = TRUE, msg = *EFmsg, code = EMS_E_InvalidArg,
           str = "EFsort_intobjs_by_projecting_along_vector_onto_plane : Invalid Arguments",
           action = GOTO_VALUE, value = wrapup);
  
   /* Allocate the memory for storing sorted ntersection indexes. This 
      index correspond to the intobjs number in the inters list. Also
      allocate the memory for storing the distances for sorting out. */ 

   indx = NULL; 
   intobj = NULL;
   num_intobjs = inters->num_cvs;

   indx = (IGRint *) om$malloc (size = num_intobjs * sizeof(IGRint));
   add$status (test = !indx, msg = *EFmsg, code = EMS_E_NoDynamicMemory,
           str = "EFsort_intobjs_by_projecting_along_vector_onto_plane : Insufficient Memory ",
           action = GOTO_VALUE, value = wrapup);

   dist = (IGRdouble *) alloca (num_intobjs * sizeof(IGRdouble));
   add$status (test = !dist, msg = *EFmsg, code = EMS_E_NoDynamicMemory,
           str = "EFsort_intobjs_by_projecting_along_vector_onto_plane : Insufficient Memory ",
           action = GOTO_VALUE, value = wrapup);

   /*
    * Take the end points of the each intobj construct a line segment by taking
    * a point along the 'vector' specified. Find the intersection between this
    * inf. line with the given plane and store the maximum of the distances 
    * generated by the intersection of the lines generated by the two end pts
    * of the intobjs. These distances will be used for sorting out the intojbs.
    */  

   OM_BLOCK_MOVE(plane->point, plane_point, sizeof(IGRpoint));
   OM_BLOCK_MOVE(plane->normal, plane_normal, sizeof(IGRvector));
   memset(dist, 0,  num_intobjs * sizeof(IGRdouble));

   /* normalize the normal vector */
   BSnorvec(&BSmsg, plane_normal);
   add$status (test = BSERROR(BSmsg), msg = *EFmsg, code = EMS_E_BSerror,
           str = "EFsort_intobjs_by_projecting_along_vector_onto_plane : BSnorvec error",
           action = GOTO_VALUE, value = wrapup);

   intobj = inters->cvs;
   for (i=0; i<num_intobjs; i++)
   {
        memset(pt1, 0, sizeof(IGRpoint));
        memset(int_pt1, 0, sizeof(IGRpoint));

        /* get the mid point of the intobj */
        (void) EFgetmidpt_xyz(&OMmsg, NULL, &intobj->this_xyzintobj, pt1);
        add$status (test = !(1&OMmsg), msg = *EFmsg, code = EMS_E_Fail,
           str = "EFsort_intobjs_by_projecting_along_vector_onto_plane : EFgetmidpt_xyz error",
           action = GOTO_VALUE, value = wrapup);
  
        /* get the other point on the infiinite line. */ 
        for (j=0; j<3; j++)
             pt2[j] = pt1[j] + vector[j];  

        /* get the intersection points of the infinite lines with the plane */
        BSxlnpl(&BSmsg, plane_normal, plane_point, pt1, pt2, int_pt1); 
        add$status (test = BSERROR(BSmsg), msg = *EFmsg, code = EMS_E_BSerror,
           str = "EFsort_intobjs_by_projecting_along_vector_onto_plane : BSxlnpl error",
           action = GOTO_VALUE, value = wrapup);

        dist1 = BSdistptpt(&BSmsg, pt1, int_pt1);
        add$status (test = BSERROR(BSmsg), msg = *EFmsg, code = EMS_E_BSerror,
           str = "EFsort_intobjs_by_projecting_along_vector_onto_plane : BSdistptpt error",
           action = GOTO_VALUE, value = wrapup);

        dist[i] = dist1;
        intobj = intobj->next;
   } 

   BSsts = BStagsort(&BSmsg, &num_intobjs, dist, indx);
   add$status (test = BSERROR(BSmsg), msg = *EFmsg, code = EMS_E_BSerror,
       str = "EFsort_intobjs_by_projecting_along_vector_onto_plane : BStagsort error",
       action = GOTO_VALUE, value = wrapup);

   *sort_index = indx;

wrapup :
   EMWRAPUP(*EFmsg, *EFmsg, 
                     "EFsort_intobjs_by_projecting_along_vector_onto_plane"); 
   return OMsts;
}

/*
 ABSTRACT

 RETURN CODE

 NOTES

   Unused function
*/

void   EFgetmidpt_xyz(EFmsg, md_env, intdata, mid_pt) 
IGRlong              *EFmsg;
struct GRmd_env      *md_env;
struct EMSdataselect *intdata;
IGRdouble            *mid_pt;
{
   IGRint               midpt_no;
   IGRlong              OMsts, OMmsg;
   IGRdouble            par;

   /* Initialize the return status */
   OMsts  = OM_S_SUCCESS ;
   OMmsg  = EMS_S_Success; 
   *EFmsg = EMS_S_Success;

   /* Validate the input arguments */
   if (!intdata || !mid_pt || 
       ((intdata->datatype == EMSdata_object) && !md_env))  
       add$status (test = TRUE, msg = *EFmsg, code = EMS_E_InvalidArg,
           str = "EFgetmidpt_xyz : Invalid Arguments",
           action = GOTO_VALUE, value = wrapup);

   switch(intdata->datatype)
   {
      case EMSdata_object:
           par = 0.5;
           OMsts = om$send(msg = message GRvg.EMptatpr(&OMmsg, 
                                          &md_env->md_env.matrix_type, 
                                          md_env->md_env.matrix,
                                          &par, 1, mid_pt), 
                            senderid = NULL_OBJID,
                            targetid = intdata->data.object->objid,
                            targetos = intdata->data.object->osnum);
           add$status (test = !(1&OMsts&OMmsg), msg = *EFmsg, code = EMS_E_Fail,
               str = "EFgetmidpt_xyz : GRvg.EMptatpr error",
               id = intdata->data.object->objid,
               osnum = intdata->data.object->osnum,
               action = GOTO_VALUE, value = wrapup);
           break;

      case EMSdata_poly3d:
           midpt_no = intdata->data.poly->num_points / 2;
           OM_BLOCK_MOVE(&intdata->data.poly->points[midpt_no * 3],
                          mid_pt, sizeof(IGRpoint));
           break;

      case EMSdata_curve3d:
           midpt_no = intdata->data.curve->num_poles / 2;
           OM_BLOCK_MOVE(&intdata->data.curve->poles[midpt_no * 3],
                          mid_pt, sizeof(IGRpoint));
           break;

      default : 
           EMerr_hndlr(TRUE, *EFmsg, EMS_E_InvalidArg, wrapup);
    } 

wrapup : 
    EMWRAPUP(*EFmsg, *EFmsg, "EFgetmidpt_xyz");
    return;
}    

/*
  ABSTRACT

    Gets all the components on to-component channel.
 
  RETURN CODE
 
  NOTES
   
    Unused Function.
*/

IGRlong   EFget_tocomp_channel_components(
          EFmsg,
          md_env,
          obj_grid,
          ncomps,
          comps_grid)
IGRlong          *EFmsg;
struct GRmd_env  *md_env;
struct GRid      *obj_grid, **comps_grid;
IGRint           *ncomps;
{
    IGRint       cnt, junk;
    IGRlong      OMsts, OMmsg;
    struct GRid  *comps;
   
    /* Initialize the return status */
    OMsts  = OM_S_SUCCESS ;
    OMmsg  = EMS_S_Success;
    *EFmsg = EMS_S_Success; 
    cnt    = 0;
    comps  = NULL;

    /* Validate the incoming arguments */
    if (!md_env || !obj_grid || (!ncomps && !comps_grid))
        add$status (test = TRUE, msg = *EFmsg, code = EMS_E_InvalidArg,
            str = "EFget_tocomp_channel_components : Invalid Arguments",
            action = GOTO_VALUE, value = wrapup);

    /* get the number of components */
    OMsts = om$send(msg = message GRowner.GRget_number_components(
                                   &OMmsg, &cnt),
                     senderid = NULL_OBJID,
                     targetid = obj_grid->objid, 
                     targetos = obj_grid->osnum);
    add$status (test = !(1&OMsts&OMmsg), msg = *EFmsg, code = EMS_E_InvalidArg,
        str = "EFget_tocomp_channel_components : GRget_number_components error",
        action = GOTO_VALUE, value = wrapup);
    if (ncomps) *ncomps = cnt;

    if (comps_grid) /* if asked for the component ids */
    {
        comps = NULL;
        comps = (struct GRid *) om$malloc (size = cnt * sizeof(struct GRid));
        add$status (test = !comps, msg = *EFmsg, code = EMS_E_NoDynamicMemory,
            str = "EFget_tocomp_channel_components : Insufficient Memory",
            action = GOTO_VALUE, value = wrapup);
     
        OMsts = om$send(msg = message GRowner.GRget_components(
                                       &OMmsg, md_env, comps, cnt, &junk, 
                                       0, cnt-1), 
                         senderid = NULL_OBJID,
                         targetid = obj_grid->objid,
                         targetos = obj_grid->osnum);     
        add$status (test = !(1&OMsts&OMmsg), msg = *EFmsg, code = EMS_E_Fail,
            str = "EFget_tocomp_channel_components : GRget_components error",
            id = obj_grid->objid, osnum = obj_grid->osnum,
            action = GOTO_VALUE, value = wrapup);

        *comps_grid = comps;
    }
    
wrapup : 
    return OMsts;
}

/*
  ABSTRACT
 
    Given the modified, unmodified profile and the composite surface 
    generated by the modified profile, it returns the the surface ids
    generated by the unmodified profile components and for surfaces  
    generated by the end segments of the unmodified profile it finds
    the parameter values of the surface which constitutes the surface
    by the end segments of the unmodified profile.

  RETURN CODE
 
  NOTES
 
    It is assumed that the incoming profiles are properly parametrized
    so that a parameter value on the profile corrsponds to the same 
    parameter value on the surface.
*/

IGRlong   EFget_unmodified_profile_surface_ids(
IGRlong               *EFmsg,
IGRlong               solid_type,
struct GRmd_env       *md_env,
struct GRid           *prof_grid,
struct GRid           *modprof_grid,
struct GRid           *compsf_grid,
struct GRid           *sfs_grid,
IGRdouble             *end_parms)
{
    BSrc             BSmsg;
    IGRint           i, j, k, n, cnt, prof_ncomps, modprof_ncomps, indx; 
    IGRlong          OMsts, OMmsg; 
    IGRpoint         *prof_endpts, *modprof_endpts, proj_pt;
    IGRshort         mat_type;
    IGRdouble        dist, *mat, tol, *point;
    IGRboolean       found = FALSE;
    struct GRid      *prof_comps_grid, *modprof_comps_grid, end_grid, 
                     *compsf_comps_grid;
    struct GRparms   proj_parms;

    
    /* Initialize the return status */
    OMsts  = OM_S_SUCCESS ;
    OMmsg  = EMS_S_Success;
    *EFmsg = EMS_S_Success;

    prof_endpts        = NULL;
    modprof_endpts     = NULL;
    prof_comps_grid    = NULL;
    compsf_comps_grid  = NULL;
    modprof_comps_grid = NULL;

    /* Validate the incoming arguments */
    if (!md_env || !prof_grid || !modprof_grid || !sfs_grid || !compsf_grid )
        add$status (test = TRUE, msg = *EFmsg, code = EMS_E_InvalidArg,
            str = "EFget_unmodified_profile_surface_ids : Invalid Arguments",
            action = GOTO_VALUE, value = wrapup);

    mat      = md_env->md_env.matrix;
    mat_type = md_env->md_env.matrix_type;
    BSEXTRACTPAR (&OMmsg, BSTOLCHRDHT, tol);

    /* 
     * get the profile components 
     */  
    OMsts = EFget_tocomp_channel_components(&OMmsg, md_env, prof_grid,
					     &prof_ncomps, &prof_comps_grid);
    if (OMmsg == EMS_E_InvalidArg) /* only one segment */
    {
        OMmsg       = EMS_S_Success;
	prof_ncomps = 1;
	prof_comps_grid = prof_grid;
    }
    else
        add$status (test = !(1&OMsts&OMmsg), msg = *EFmsg, code = EMS_E_Fail,
            str = "EFget_unmodified_profile_surface_ids : EFget_tocomp_channel_components error",
            action = GOTO_VALUE, value = wrapup);

    /* 
     * get the modified profile components 
     */
    OMsts = EFget_tocomp_channel_components(&OMmsg, md_env, modprof_grid,
				       &modprof_ncomps, &modprof_comps_grid);
    if (OMmsg == EMS_E_InvalidArg)
    {
      OMmsg = EMS_S_Success;
      modprof_ncomps = 1;
      modprof_comps_grid = modprof_grid;
    }
    else 
      add$status (test = !(1&OMsts&OMmsg), msg = *EFmsg, code = EMS_E_Fail,
          str = "EFget_unmodified_profile_surface_ids : EFget_tocomp_channel_components error",
          action = GOTO_VALUE, value = wrapup);

    /*
     * get the composite surface's component ids 
     */
    OMsts = EFget_tocomp_channel_components(&OMmsg, md_env, compsf_grid,
                                             &cnt, &compsf_comps_grid);
    if (OMmsg == EMS_E_InvalidArg)
    {
      OMmsg = EMS_S_Success;
      cnt = 1;
      compsf_comps_grid = compsf_grid;
    }
    else
      add$status (test = !(1&OMsts&OMmsg), msg = *EFmsg, code = EMS_E_Fail,
          str = "EFget_unmodified_profile_surface_ids : EFget_tocomp_channel_components error",
          id = compsf_grid->objid, osnum = compsf_grid->osnum ,
          action = GOTO_VALUE, value = wrapup);

    /* 
     * get the endpts of the modified and unmodified profile segments 
     */
    prof_endpts = (IGRpoint *) alloca (sizeof(IGRpoint) * prof_ncomps * 2);
    add$status (test = !prof_endpts, msg = *EFmsg, code = EMS_E_NoDynamicMemory,
        str = "EFget_unmodified_profile_surface_ids : Insufficient Memory",
        action = GOTO_VALUE, value = wrapup);
  
    modprof_endpts = (IGRpoint *) 
                           alloca (sizeof(IGRpoint) * modprof_ncomps * 2);
    add$status (test = !modprof_endpts, msg = *EFmsg, 
        code = EMS_E_NoDynamicMemory,
        str = "EFget_unmodified_profile_surface_ids : Insufficient Memory",
        action = GOTO_VALUE, value = wrapup);

    for (i=0; i<prof_ncomps; i++)
    {
	 OMsts = om$send(msg = message GRcurve.GRendpts(
					&OMmsg, &mat_type, mat, 
					prof_endpts[i*2], prof_endpts[i*2+1]),
		     senderid = NULL_OBJID,
		     targetid = prof_comps_grid[i] .objid,
		     targetos = prof_comps_grid[i].osnum);
         add$status (test = !(1&OMsts&OMmsg), msg = *EFmsg, code = EMS_E_Fail,
             str = "EFget_unmodified_profile_surface_ids : GRcurve.GRendpts error",
             id = prof_comps_grid[i] .objid, osnum = prof_comps_grid[i].osnum,
             action = GOTO_VALUE, value = wrapup);
    }  
    
    for (i=0; i<modprof_ncomps; i++)
    {
	 OMsts = om$send(msg = message GRcurve.GRendpts(
				    &OMmsg, &mat_type, mat,
				    modprof_endpts[i*2], modprof_endpts[i*2+1]),
		     senderid = NULL_OBJID,
		     targetid = modprof_comps_grid[i].objid,
		     targetos = modprof_comps_grid[i].osnum);
         add$status (test = !(1&OMsts&OMmsg), msg = *EFmsg, code = EMS_E_Fail,
             str = "EFget_unmodified_profile_surface_ids : GRcurve.GRendpts error",
             id = modprof_comps_grid[i] .objid, 
             osnum = modprof_comps_grid[i].osnum,
             action = GOTO_VALUE, value = wrapup);
    }
	
    /* 
     * Match the end points of the unmodified profile with the end poitns of
     * the modified profile and get indices of the modified profile segments
     * with which it is matching. 
     */  
    for (i=0; i<prof_ncomps; i++)
    {
       if (i>1  && i<prof_ncomps-1)
       add$status (test = !found, msg = *EFmsg, code = EMS_E_Fail,
           str = "EFget_unmodified_profile_surface_ids : No Match for the profile segment",
           action = GOTO_VALUE, value = wrapup);
       
       found = FALSE;

       /*
        * In case of first and last components, project the start/end point
        * of the unmodified profile on to the modified profile to get the 
        * modified profile component with which this end segments matches.
        * For rest of the segments as it is a full overlap, just check the
        * end points match, this will give the matching segment number.
        */
       if ((i==0) || (i==prof_ncomps-1))
       {
          n = (i ? (i*2 + 1) : i*2);
	       
	  OMsts = om$send(msg = message GRgraphics.GRptproject(
                                         &OMmsg, &mat_type, mat, prof_endpts[n],
                                         proj_pt, &proj_parms),
			   senderid = NULL_OBJID,
			   targetid = modprof_grid->objid,
			   targetos = modprof_grid->osnum);
          add$status (test = !(1&OMsts&OMmsg), msg = *EFmsg, 
              code = EMS_E_Fail, str = "EFget_unmodified_profile_surface_ids : GRptproject error", 
              id = modprof_grid->objid, osnum = modprof_grid->osnum,
              action = GOTO_VALUE, value = wrapup);

          end_grid = proj_parms.leaf_id;
          for (k=0; k<modprof_ncomps; k++)
          {
             if (end_grid.objid == modprof_comps_grid[k].objid &&
                 end_grid.osnum == modprof_comps_grid[k].osnum )
             {
                indx = k;
                break;
             }
          }
       }
       else
       {
          for (j=0; j<modprof_ncomps; j++) 
	  {
             dist = BSdistptpt(&BSmsg, prof_endpts[i*2], modprof_endpts[j*2]);  
             if ((fabs(dist)) < tol)
             {
                dist = BSdistptpt(&BSmsg, prof_endpts[i*2+1],
				   modprof_endpts[j*2+1]);
		if (dist < tol)
		{
		  found = TRUE;
		  indx = j; 
		  break;
		}
             }
             else 
             {
                dist = BSdistptpt(&BSmsg, prof_endpts[i*2+1],
                                   modprof_endpts[j*2]);
		if ((fabs(dist)) < tol)
		{
                  dist = BSdistptpt(&BSmsg, prof_endpts[i*2],
				     modprof_endpts[j*2 + 1]);
		  if (dist < tol)
		  {
		    found = TRUE;
		    indx = j;
		    break;
		  }
                }
             }
          }
       }

       sfs_grid[i] = compsf_comps_grid[indx];

       /*
        * In case of first and last components we need to find parameter values
        * of the surface corresponding to end points of the segments. So project        * the end points of the unmodified profile on to the surface at the 
        * modified profile index and find the respective u-parameter values.
        * Thus : 
        *   end_parms[0]  - u-parameter value of the surface correspond to 
        *                   the start point of the first segment of the un
        *                   modified profile.
        *   end_parms[1] - u-parameter value of the surface correspond to
        *                   the end point of the first segment of the un-
        *                   modified profile. 
        *   end_parms[2]  - u-parameter value of the surface correspond to
        *                   the start point of the last segment of the un
        *                   modified profile.
        *   end_parms[3] - u-parameter value of the surface correspond to
        *                   the end point of the last segment of the un-
        *                   modified profile.
        */
       if ((i == 0) || (i == prof_ncomps - 1))
       {
          if (solid_type & EMSfeature_projected)
          {
             n = (i ? 3 : 0);
             end_parms[n] = proj_parms.u;
          
             point = (i ? prof_endpts[i*2] : prof_endpts[i*2+1]);  
             
             OMsts = om$send(msg = message GRgraphics.GRptproject(
                                    &OMmsg, &mat_type, mat, point, proj_pt, 
                                    &proj_parms),
                     senderid = NULL_OBJID,
                     targetid = end_grid.objid,
                     targetos = end_grid.osnum);
             add$status (test = !(1&OMsts&OMmsg), msg = *EFmsg, 
                 code = EMS_E_Fail, str = "EFget_unmodified_profile_surface_ids : GRptproject error",
                 id = end_grid.objid, osnum = end_grid.osnum ,
                 action = GOTO_VALUE, value = wrapup);

             n = (i ? 2 : 1);
             end_parms[n] = proj_parms.u;
          }
          else if (solid_type & EMSfeature_revolved)
          {
             n = (i ? 2 : 0);
             for (k=0; k<2; k++)
             {
                OMsts = om$send(msg = message GRgraphics.GRptproject(&OMmsg,
                                               &mat_type, mat, 
                                               prof_endpts[i*2+k], proj_pt, 
                                               &proj_parms),
                                 senderid = NULL_OBJID,
                                 targetid = sfs_grid[i].objid, 
                                 targetos = sfs_grid[i].osnum);
                add$status (test = !(1&OMsts&OMmsg), msg = *EFmsg, 
                    code = EMS_E_Fail, str = "EFget_unmodified_profile_surface_ids : GRptproject error",
                    id = sfs_grid[i].objid, osnum = sfs_grid[i].osnum ,
                    action = GOTO_VALUE, value = wrapup);
                end_parms[n++] = proj_parms.u;
             }
          } 
          else if (solid_type & EMSfeature_skinned)
          {
          }
       }
    }
  
wrapup : 
    if (prof_comps_grid && prof_ncomps > 1)
        om$dealloc(ptr = prof_comps_grid);
    if (modprof_comps_grid && modprof_ncomps > 1)
        om$dealloc(ptr = modprof_comps_grid); 
    if (compsf_comps_grid && cnt > 1) 
        om$dealloc(ptr = compsf_comps_grid);

    EMWRAPUP(*EFmsg, *EFmsg, "In EFget_unmodified_profile_surface_ids");
    return OMsts;
}

/*
  ABSTRACT

  RETURN CODE

  NOTES

    Unused Function.
*/

void  EFget_surface_group_range(
IGRlong                *EFmsg,
struct GRid            *sfgrid,
struct EMSsftracedata  *tracedata,
IGRint                 grp_num,
IGRdouble              *uvrange)
{
IGRint              i, j;
IGRlong             OMsts, OMmsg;
IGRdouble           minU, maxU, minV, maxV;
IGRboolean          first_time = TRUE;
struct EMSintobj    *intobj = NULL;

   OMsts  = OM_S_SUCCESS ;
   OMmsg  = EMS_S_Success;
   *EFmsg = EMS_S_Success;

   // Validate the incoming arguments ...
   if (!sfgrid || !tracedata || !uvrange || grp_num > (tracedata->num_grps-1))
       add$status (test = TRUE, msg = *EFmsg, code = EMS_E_InvalidArg,
           str = "EFget_surface_group_range : Invalid Arguments error",
           action = GOTO_VALUE, value = wrapup);

   for (i=0; i<tracedata->num_subgrps_grp[grp_num]; i++)
   {
      intobj = tracedata->elems[grp_num][i];

      for (j=0; j<tracedata->num_elems_subgrp[grp_num][i]; j++)
      {
         if ((intobj->this_obj_node->this_obj.objid == sfgrid->objid) &&
             (intobj->this_obj_node->this_obj.osnum == sfgrid->osnum))
         {
           /*
            * get the uv range of this intobj
            */
           if (intobj->this_uvintobj.datatype == EMSdata_object)
           {
              OMsts = om$send(msg = message EMSedge.EMgetrange(&OMmsg,
                                             uvrange, NULL),
                       senderid = NULL_OBJID,
                       targetid = intobj->this_uvintobj.data.object->objid,
                       targetos = intobj->this_uvintobj.data.object->osnum);
              add$status (test = !(1&OMsts&OMmsg), msg = *EFmsg,
                  code = EMS_E_Fail,
                  str = "EFget_surface_group_range : EMgetrange error",
                  action = GOTO_VALUE, value = wrapup);
           }
           else if (intobj->this_uvintobj.datatype == EMSdata_poly2d ||
                    intobj->this_uvintobj.datatype == EMSdata_poly3d)
           {
              EM2dbx(intobj->this_uvintobj.data.poly->num_points,
                      intobj->this_uvintobj.data.poly->points, uvrange);
           }
           else
           {
              add$status (test = TRUE, msg = *EFmsg, code = EMS_E_InvalidArg,
                  str = "EFget_surface_group_range : Invalid Intobj error",
                  action = GOTO_VALUE, value = wrapup);
           }

           if (first_time)
           {
              first_time = FALSE;
              minU = uvrange[0];
              minV = uvrange[1];
              maxU = uvrange[2];
              maxV = uvrange[3];
           }
           else
           {
              if (uvrange[0] < minU) minU = uvrange[0];
              if (uvrange[1] < minV) minV = uvrange[1];
              if (uvrange[2] > maxU) maxU = uvrange[2];
              if (uvrange[3] > maxV) maxV = uvrange[3];
           }

        }
        intobj = intobj->next;
     }
  }

  uvrange[0] = minU; uvrange[1] = minV;
  uvrange[2] = maxU; uvrange[3] = maxV;

wrapup :
  return;
}

end implementation EMSsfboolean;
