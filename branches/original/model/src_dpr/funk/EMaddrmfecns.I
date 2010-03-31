/* -----------------
 * FOR EMS 4.0 
 * Creation : Sanjay
 * -----------------
 */

/*
 *  Name : 
 *  ------
 *     IGRlong  EMmake_associative_add_rem_matl_feature()
 * 
 *  Description:
 *  ------------
 *     This function is being called by the EMconstruct_associative method and
 *  is the main function call in Add/Remove Mtl. Feature. It takes in the par-
 *  ents of the feature and extracts the options and required data from the 
 *  parent information structure and calls the function "EMcreate_add_rem_mat_
 *  feature" with appropriate arguments.
 *
 *  Arguments :
 *  -----------
 *     IGRlong                         *EFmsg         O   return code
 *     IGRint                          assoc_type     I   associative type
 *     struct GRvg_construct           *cons_list     I   construction list
 *     IGRint                          num_parents    I   number of parents
 *     IGRuint                         *parent_types  I   parent types
 *     struct EMSAddRm_RecompInfo      *recomp_info   I   recompute info.
 *     struct GRid                     *feature_id    O   created feature GRid
 *
 *  Return Values :
 *  ---------------
 *     EMS_S_Success          - Every thing goes fine.
 *     EMS_E_Fail             - Error in construction.
 *     EMS_W_NoIntToNextSurf  - In case of "To Next" option if the created 
 *                              feature is not intersecting with the "To Next"
 *                              surface. It is only a warning message, so it
 *                              produces the result but issues this warning.
 *     EMS_W_Infinite         - In case the feature created is of infinite 
 *                              length or width.
 *     EMS_E_NoIntFromSurf    - In case of "From/To" option if the feature to
 *                              be created does not intersect with the "From" 
 *                              surface selected.
 *     EMS_E_NoIntToSurf      - In case of "From/To" option if the feature to
 *                              be created does not intersect with the "To" 
 *                              surface selected.
 *     EMS_E_Disjoint         - In case the feature results in "Disjoint 
 *                              Boolean" between the base and the secondary
 *                              solid created.
 *                               
 *  History
 *  -------
 *  
 *    Sanjay  :       03/01/94             Creation 
 *    Sanjay  :       05/25/94             Added the header 
 *    Sanjay  :       07/01/94             Changed EMerr_hndlr() calls to 
 *                                         add$stauts() 
 */

class implementation EMSsffeature;

#include <stdio.h>
#include "msdef.h"
#include "igrtypedef.h"
#include "bserr.h"
#include "bsconic.h"
#include "bsparameters.h"
#include "bsdistptpts.h"
#include "nddef.h"
#include "AS_status.h"
#include "exmacros.h"
#include "msmacros.h"
#include "ECmsg.h"
#include "OMmacros.h"
#include "dp.h"
#include "go.h"
#include "grmacros.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "EMStypedef.h"
#include "OMprimitives.h"
#include "emsdef.h"
#include "EMSmsgdef.h"
#include "EMSbnddef.h"
#include "EMSbnd.h"
#include "emsdattyp.h"
#include "emsbool.h"
#include "emssfintdef.h"
#include "emsinterdef.h"
#include "emsedgedef.h"
#include "emsinter.h"
#include "emssfint.h"
#include "EMSasfeatdef.h"
#include "emsfeaopts.h"
#include "emscvexten.h"
#include "EMSmsgdef.h"
#include "EMSfeadef.h"
#include "REaddrmfea.h"
#include "addprot.h"
#include "addrmopts.h"

IGRlong EMmake_associative_add_rem_matl_feature( EFmsg, 
                                                 assoc_type, 
                                                 cons_list, 
                                                 num_parents, 
                                                 parent_types, 
                                                 parents, 
                                                 recomp_info,
                                                 feature_id )
IGRint                              assoc_type, num_parents;
IGRuint                             *parent_types;
IGRlong                             *EFmsg;
struct GRid                         *feature_id;
union  EMSparent_info               *parents;
struct GRvg_construct               *cons_list;
struct EMSAddRm_RecompInfo          *recomp_info;
{
    IGRint           parent_no=0, ii=0;
    IGRlong          sts, loc_msg, solopts, feaopts, matopts;
    IGRvector        proj_vec;
    IGRdouble        start_dist=0, sweep_dist=0, start_angle=0, sweep_angle=0;
    IGRdouble        axis_ends[6];
    IGRboolean       projected, revolved, skinned, finite ;
    struct GRid      prof_grid, from_surf_grid, to_surf_grid, base_solid_grid; 
    struct GRmd_env  prof_env, solid_env;
    struct TraceInfo trace_info;
    
    /*
     * Initialize the local variables and validate the incoming arguments
     */
    sts = OM_S_SUCCESS;
    *EFmsg = EMS_S_Success;
    sweep_angle = 0.0; parent_no = 0; 
    feaopts = matopts = solopts = 0; 
    projected = revolved = skinned = finite = FALSE;
    if( !recomp_info || !cons_list || !parent_types || !feature_id || 
        !parents || (num_parents == 0 ) ) 
    {
        sts = EMS_E_Fail;
        *EFmsg = EMS_E_InvalidArg;
        goto wrapup;
    }

    /*
     * First Populate the options specified from recomp_info
     */
    if( assoc_type == EMS_ASSOC_FEATURE_ADD_MATERIAL ) /* command type */
    {
        matopts |= EMSadd_material;
    }
    else
    {
        matopts |= EMSremove_material;
    } 

    if( recomp_info->props & EMSAddRm_Project ) /* solid type */
    {
        projected = TRUE;
        solopts |= EMSfeature_projected;
    }
    else if( recomp_info->props & EMSAddRm_Revolve )
    {
        revolved = TRUE;
        solopts |= EMSfeature_revolved;
    }
    else if( recomp_info->props & EMSAddRm_Skinned )
    {
        skinned = TRUE;
        solopts |= EMSfeature_skinned;
    }

    if( recomp_info->props & EMSAddRm_ToNext ) /* extent option */
    {
        if( matopts & EMSadd_material) feaopts |= EMSfeature_to_next;
        else feaopts |= EMSfeature_thru_next;
    }
    else if( recomp_info->props & EMSAddRm_FromTo )
    {
        feaopts |= EMSfeature_from_to;
    }
    else if( recomp_info->props & EMSAddRm_Finite )
    {
        feaopts |= EMSfeature_finite;
        if( recomp_info->props & EMSAddRm_Symmetric )
           feaopts |= EMSfeature_symmetric;
    } 
    else if( recomp_info->props & EMSAddRm_ThruAll )
    {
        feaopts |= EMSfeature_thru_all;
    }

    /*
     * Get the profile grid and the module environment info.
     */
    OM_BLOCK_MOVE( &(parents[parent_no].grobj.grid), &prof_grid,
                   sizeof( struct GRid ) );
    OM_BLOCK_MOVE( &(parents[parent_no++].grobj.env), &prof_env,
                   sizeof( struct GRmd_env ) );

    /*
     * Get the sweep direction
     */
    if( projected )
        OM_BLOCK_MOVE( parents[parent_no++].vector, &proj_vec[0],     
                       sizeof( IGRvector ) );
    else if( revolved )
    {
        OM_BLOCK_MOVE( parents[parent_no++].point, &axis_ends[0], 
                       sizeof( IGRpoint ) );
        OM_BLOCK_MOVE( parents[parent_no++].vector, &axis_ends[3], 
                       sizeof( IGRvector ) );
        for( ii=0; ii<3; ii++ )
           axis_ends[ii+3] += axis_ends[ii]; 
    }
    else if( skinned )
        OM_BLOCK_MOVE( &(parents[parent_no++].grobj.grid), &trace_info.grid,
                       sizeof( struct GRid ) );

    /*
     * If finite, then get the start distance / start anlge.
     */
    if( recomp_info->props & EMSAddRm_Finite )
    {
       if( projected )
         start_dist = parents[parent_no++].value;
       else if( revolved ) 
         start_angle = parents[parent_no++].value;
    } 

    /*
     * If finite, get the projection distance / sweep angle 
     */
    if( recomp_info->props & EMSAddRm_Finite )
    {
        finite = TRUE;
        if( projected ) sweep_dist = parents[parent_no++].value;
        else if( revolved ) sweep_angle = parents[parent_no++].value;
    }

    /*
     * If from-to, get the from and to surface ids
     */
    if( recomp_info->props & EMSAddRm_FromTo )
    {
        if(recomp_info->props & EMSAddRm_NoFromSurf )  
        {
          from_surf_grid.objid = NULL_OBJID;
          from_surf_grid.osnum = 0;
        }
        else
        {
          OM_BLOCK_MOVE( &(parents[parent_no++].grobj.grid), &from_surf_grid,
                       sizeof( struct GRid ) );
        }

        if( recomp_info->props & EMSAddRm_NoToSurf )  
        {
          to_surf_grid.objid = NULL_OBJID;
          to_surf_grid.osnum = 0;
        }
        else
        {
          OM_BLOCK_MOVE( &(parents[parent_no++].grobj.grid), &to_surf_grid,
                         sizeof( struct GRid ) );
        }
    }

    /*
     * Get the base solid grid and the module environment
     */
    OM_BLOCK_MOVE( &(parents[parent_no].grobj.grid), &base_solid_grid,
                   sizeof( struct GRid ) );
    OM_BLOCK_MOVE( &(parents[parent_no++].grobj.env), &solid_env, 
                   sizeof( struct GRmd_env ) );

    /*
     * Whether the trace curve need to be reversed.
     */
    if (skinned)
      trace_info.reverse = (recomp_info->props & EMSAddRm_ReverseTrace) ? 
                                                                 TRUE : FALSE;

    prof_env.md_id = cons_list->env_info->md_id;
    solid_env.md_id = cons_list->env_info->md_id;

    /*
     * Now Call the feature placement function
     */
    sts = EMcreate_add_rem_mat_feature( &loc_msg,
                 matopts,
                 solopts, 
                 feaopts,
                 &prof_grid,
                 &prof_env,
                 (recomp_info->props & EMSAddRm_MatInside) ? FALSE: TRUE,
                 (feaopts & EMSfeature_from_to) ? &from_surf_grid : NULL,
                 (feaopts & EMSfeature_from_to) ? &to_surf_grid : NULL,  
                 &solid_env,
                 &base_solid_grid,
                 ( finite && projected ) ? &start_dist : NULL,
                 ( finite && projected ) ? &sweep_dist : NULL,
                 proj_vec,
                 ( finite & revolved ) ? &start_angle : NULL,
                 ( finite & revolved ) ? &sweep_angle : NULL,
                 ( revolved ) ? axis_ends : NULL,
                 ( skinned ) ? &trace_info : NULL,
                 cons_list,
                 *feature_id );
    add$status( test = !(1 & sts & loc_msg), msg = *EFmsg, code = loc_msg,
                str = "EMmake_associative_add_rem_matl_feature : EMcreate_add_rem_mat_feature() error", 
                action = GOTO_VALUE, value = wrapup ); 
wrapup : 
    EMWRAPUP( *EFmsg, sts, "IN EMmake_associative_add_rem_matl_feature" );
    return ( sts );
}

end implementation EMSsffeature;
