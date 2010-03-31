class implementation EMSslboolfea;

#include "EMSlm.h"
#include "EMSlmdef.h"
#include "EMSdpr.h"
#include "EMSprop.h"
#include "bserr.h"
#include "bsparameters.h"
#include <stdio.h>
#include "OMmacros.h"
#include "EMSas.h"
#include "EMSdef.h"
#include "EMSasfeatdef.h"
#include "EMSasnucdef.h"
#include "EMSconstruct.h"
#include "nddef.h"
#include "ndmacros.h"
#include "msdef.h"
#include "msmacros.h"
#include "ECmsg.h"
#include "bsprptonsf.h"

#define COUNTERSINK   0
#define COUNTERBORE   1
#define FAIL 0

extern GRclassid OPP_EMSpervcnstr_class_id, OPP_EMSdatpln_class_id;
extern GRclassid OPP_EMSplane_class_id;

from EMScnstr import EMinit;
from EMSparamgm import EMconstruct, EMgetgeom;
from EMSsubbs import EMget_unit_norm;
from EMSpartsupp import EMget_partial_suppress_id, EMget_comp_info;

method EMconstruct_associative(IGRlong *EMmsg; IGRushort options;
                GRobjid  old_objid; IGRint num_par; IGRchar *parent_info;
                IGRint type; IGRchar *recomp_info; 
                struct GRvg_construct *construct_list)

/*****************************************************************
Description
 This method does the actual construction of hole & c-bore/c-sink feature

Arguments
Input
  options: ubiquitous argument. Currently not supported and is set to NULL.
  num_par : number of parents.
  list : GRid of parents.
  type : Type to interpret the recomputation information.
  recomp_info: Recomputation information. 
  construct_list: construction information.

Output
 EMmsg: Completion code.

Notes
 Upon exit the completion code will be one of the following:
  EMS_S_Success : If all goes well.
  EMS_E_Fail : For fatal errors whose exact cause cannot be determined.

Recomputation informaton for feature hole:
 OMuint surface; Surface on which hole was placed.

Objects connected on the parent channel:
 Hole data, profile data for profile hole or
 C-bore/C-sink data
 Solid or surface on which hole or c-bore/c-sink was made.

History

Tapadia 23/03/93 - Fix for TR 119301275. Perpendicular constraint is not 
		   placed on non-planar surfaces as it's currently not 
		   supported. In addition a check is made to see if there are 
		   any constraints on a non-planar surface. If constraints 
		   exist the incoming vector is taken otherwise a vector is 
		   computed given the center point & the surface information.
		   In addition the old axis data is obtained & the new vector
		   reposted back.
DLB     12/31/92 - Support for partial delete of hole, cbore, csink & cutout.
                   This is done by having an EMSpartsupp class object connected
                   on the child channel.  This object contains information
                   about which "group component" was located for deletion.
                   This cons_assoc code has been modified to not generate
                   that particular component.
Tapadia  9/16/92 - Support for selective boolean. If selective boolean files
                   ordinary boolean is invoked (old behavior). Fix for TRs
                   92n5813, 92n5814.
Tapadia  7/27/92 - Modified to support reference planes for holes. In addition
                   a perpendicular constraint is created when the hole axis
                   is normal to the surface/RP at the time of creation (only
                   for circular holes)
DLB      4/02/92 - Dont disconnect components if failure but in recompute.
                        TR92n2956
Tapadia  7/23/91 - Axis is not stored as a parent if it's normal to the
                   surface (holes/c-bores/c-sinks). We get the axis information
                   (i.e if its normal or not) for holes from the recomputation 
                   information.
Tapadia  7/12/91 - All holes have the same diameter & the orientation is the
                   same for all holes - if multiple holes are placed. Also
                   the orientation of multiple c-bore/c-sink is always the
                   same as the first one
Tapadia  6/11/91 - Projected the center point onto the surface 
Tapadia  5/22/91 - Modified so the surface(s) for holes & c-bore/c-sink
                   is in parent list rather than as part of recomp_info.
Tapadia  4/24/91 - Efficient placement of multiple holes of same diameter
Tapadia  4/10/91 - Creation of associativity c-bore/c-sink feature
Tapadia  4/02/91 - Creation of associativity hole feature

Sudha   06/01/93    modified to handle BSprototype headers

*******************************************************************/

{
IGRlong         status, msg_loc;
union           EMSparent_info *roots = NULL;
IGRuint         *root_type = NULL;
struct  GRid    my_GRid, start_surf_GRid, *cvid, *grid_ptr;
IGRint          i,index, num_holes_parts, point_size, part_type;
IGRdouble       v_angle;
IGRvector       axis_vec[1];
IGRboolean      hole_flag, axis_normal, through_hole, recompute, ref_plane,
                end_ref_plane;
IGRpoint        surf_pt, input_pt;
OMuword         dum_os;
struct EMShole  *holes = NULL;
struct GRmd_env *mod, new_env;
struct GRparms  proj_parms;
OM_S_CHANSELECT to_comps, to_children, to_father;
IGRuint         var_par, surf_par, root_count;
IGRushort       hole_type, depth_type;
struct EMSplace_hole *plhole_info;
void EFret_hole_cpart_data_mod();
GRobjid         cnstrobj, part_supp_id=NULL_OBJID, profile_copy_id=NULL_OBJID;
extern IGRboolean EFisAncestryValid();
extern IGRlong  EFpton_refplane(), EFcomp_hole_depth(), EFcomphole_until(), 
                EFcomp_hole_depth_ref(), EFcomphole_until_ref(),
                EFcomp_cut_until();
IGRuint         g_comp_cnt=0;
IGRushort       *g_comp_indices=NULL;


status = msg_loc = OM_S_SUCCESS;
*EMmsg = EMS_S_Success;
point_size = sizeof(IGRpoint);

my_GRid.objid = my_id;
my_GRid.osnum = OM_Gw_current_OS;
mod = construct_list->env_info;
index = 0;
end_ref_plane = FALSE;
surf_par = 1; /* start surface */
recompute = options & EMSasconst_recompute;

status = EMmake_chanselect(GRcmpowner_to_components, &to_comps);
if(!(1&status)) goto wrapup;

/* To simulate EMS 1.4 behavior for non-associative placement */
if(recompute && (!(ME.GRgraphics->properties & GRIS_ASSOCIATIVE))) {
        status = om$send(mode = OM_e_wrt_parent,
                        msg = message EMSslboolfea.EMconstruct_associative(
                                        EMmsg, options, old_objid, num_par, 
                                        parent_info, type, recomp_info, 
                                        construct_list), 
                                targetid = my_id);
        EMerr_hndlr(!(1&status&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);
        goto wrapup;
}

/* Hole & c-bore/cc-sink data is returned */
EFret_hole_cpart_data_mod(EMmsg, type, &hole_flag, &axis_normal,  
                &var_par, &hole_type, &depth_type, &part_type, 
                &through_hole, &ref_plane);

EMerr_hndlr(!(1 & *EMmsg), *EMmsg, EMS_E_Fail, wrapup);

EMmake_chanselect(NDchildren_children, &to_children);
EMmake_chanselect(NDfather_father, &to_father);
status = om$send(msg = message EMSpartsupp.EMget_partial_suppress_id(EMmsg,
                               &part_supp_id, NULL),
                 p_chanselect = &to_children);                 
if (status == OM_W_UNKNOWN_MSG) status = OM_S_SUCCESS;
else if (!(1&status&*EMmsg)) goto wrapup;
                 
if (part_supp_id != NULL_OBJID)
{
  status = om$send(msg = message EMSpartsupp.EMget_comp_info(EMmsg,
                                 &g_comp_cnt, NULL, &g_comp_indices,
                                 NULL),  
                   targetid = part_supp_id);                 
  if (!(1&status&*EMmsg)) goto wrapup;
}

if(hole_flag) {
        struct GRlc_info surf_info[3];
        IGRdouble       hole_depth;
        struct IGRbsp_curve *boundary = NULL;

        plhole_info = (struct EMSplace_hole *)recomp_info;

        /* we get the axis info for holes from recomputation information */
        axis_normal = plhole_info->axis_normal;

        /* Number of parents that I am associated with is num_par - 1 since
        one of my parents is a component parent - not if the reference plane
        is selected */

        if(!ref_plane)
                root_count = num_par - 1;
        else /* The solid is also stored as a part of parent */
                root_count = num_par;   
        num_holes_parts = plhole_info->hole_count;

        /*See if all holes have been suppressed/deleted*/
        if ((num_holes_parts - g_comp_cnt) <= 0) goto wrapup;

        root_type = (IGRuint *) stackalloc(sizeof(IGRint) * root_count);
        EMerr_hndlr(!root_type, *EMmsg, EMS_E_NoStackMemory,wrapup);

        roots =(union EMSparent_info *) stackalloc(sizeof(union EMSparent_info)
                * root_count);
        EMerr_hndlr(!roots, *EMmsg, EMS_E_NoStackMemory,wrapup);

        holes = (struct EMShole *) stackalloc(sizeof(struct EMShole) * 
                num_holes_parts);
        EMerr_hndlr(!holes, *EMmsg, EMS_E_NoStackMemory,wrapup);

        for(i = 0; i < num_holes_parts; i++) {
            /* if only one profile hole is created we don't store the center */
            if(hole_type != 2 || (hole_type == 2 && num_holes_parts > 1)){
                root_type[index] = EMSpoint; /* center */
                index++;
            }
        }
        if(hole_type != 2) { /* vector for circular holes only */
                root_type[index] = EMSvector;   /* axis vector */
                index++;
        }
        if(hole_type != 2) { /* radius */
                root_type[index] = EMSdistance;
                index++;
        }
        if(depth_type == 3) { /* depth */
                root_type[index] = EMSdistance;
                index++;
        }
        if(hole_type == 1) { /* v angle */
                root_type[index] = EMSangle;
                index++;
        }
        if(hole_type == 2) {
                root_type[index] = EMSgrid;
                index++;
        }
        /* start surface information */
        root_type[index] = EMSgrid;

        /* exit surface for thru until hole */
        if(depth_type == 1) { 
                index++;
                root_type[index] = EMSgrid;
        }

        /* The solid selected to place hole */
        if(ref_plane && hole_type != 2) {
                index++;
                root_type[index] = EMSgrid;
        }

        status = om$send (msg = message EMSassoc.EMget_parent_info(EMmsg,NULL,
                        root_count, parent_info, root_type, roots),
                targetid = my_id);
        EMerr_hndlr(!(1&status&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);

        index = 0;
        /* center point */
        for(i = 0; i < num_holes_parts; i++) {
            if(hole_type != 2 || (hole_type == 2 && num_holes_parts > 1)) {
                OM_BLOCK_MOVE(roots[index].point,holes[i].center,point_size);
                index++;
            }
        }
        /* Axis Vector */
        if(hole_type != 2) { /* vector for circular holes only */
                OM_BLOCK_MOVE(roots[index].vector, axis_vec[0], point_size);
                index++;
        }
        /* Radius */
        if(hole_type != 2) {
                holes[0].radius =  0.5 * roots[index].value;
                index++;
        }       

        /* Copy the first radius into subsequent holes if any */
        for(i = 1; i < num_holes_parts; i++) 
                holes[i].radius = holes[0].radius; 

        /* Error out if the hole radius is invalid */
        for(i = 0; i < num_holes_parts; i++) {
                if(hole_type != 2 && holes[i].radius <= 0.0) {
                        ex$message ( msgnumb = EMS_S_InvalidHoleDia,
                                     type = "%d",
                                     var  = `i+1`);
                        sleep(2);
                        *EMmsg = EMS_I_CantRecompute;
                        goto wrapup;
                }
        }

        if(depth_type == 3) { /* read depth */
                for(i = 0; i < num_holes_parts; i++) 
                        holes[i].depth = roots[index].value;
                index++;
        }

        /* Error out if the hole depth is invalid */
        if(holes[0].depth <= 0.0 && depth_type == 3) {
                ex$message ( msgnumb = EMS_S_InvalidHoleDepth);
                sleep(2);
                *EMmsg = EMS_I_CantRecompute;
                goto wrapup;
        }
        if(hole_type == 1) {    /* v-angle */
                v_angle = roots[index].value;
                index++;
        }
        if(hole_type == 2) {    /* profile */
                surf_info[2].located_obj = roots[index].grobj.grid;
                surf_info[2].module_info = roots[index].grobj.env;
                index++;
        }

        /* start surface information */
        surf_info[0].located_obj = roots[index].grobj.grid;

        if(surf_info[0].located_obj.objid == NULL_OBJID) {
                *EMmsg = EMS_I_CantRecompute;
                goto wrapup;
        }
        surf_info[0].module_info = *mod;

        /* exit surface for thru until hole */
        if(depth_type == 1) { 
                index++;
                surf_info[1].located_obj = roots[index].grobj.grid;
                if(surf_info[1].located_obj.objid == NULL_OBJID) {
                        *EMmsg = EMS_I_CantRecompute;
                        goto wrapup;
                }
                surf_info[1].module_info = *mod;
                if(EFisAncestryValid(&msg_loc, surf_info[1].located_obj.objid,
                        surf_info[1].located_obj.osnum, 
                        OPP_EMSdatpln_class_id, FALSE))
                    end_ref_plane = TRUE;
        }

	/* If the selected surface is not planar don't place a perpendicular
	constraint although the user placed a normal hole. This is because
	at the time of recomputation the axis returned is wrong as the
	perpendicular constraint is not supported for non-planar elements */
	
        if(!recompute && axis_normal && hole_type != 2) {
            if(EFisAncestryValid(&msg_loc, surf_info[0].located_obj.objid,
              surf_info[0].located_obj.osnum, OPP_EMSplane_class_id, FALSE) ||
		ref_plane) {
                cvid = &surf_info[0].located_obj;
                grid_ptr = (struct GRid *)parent_info;
                status = om$construct (classid = OPP_EMSpervcnstr_class_id,
                                msg = message EMScnstr.EMinit (EMmsg, NULL,
                                construct_list->env_info, 1, cvid, 
                                EMScnstr_self_constraint, NULL,
                                1, &grid_ptr[num_holes_parts]),
                        p_objid = &cnstrobj);

                EMerr_hndlr(!(1&status&*EMmsg), *EMmsg,EMS_E_Fail, wrapup);
	    }
        }

	/* If the surface is non-planar check if there are any constraints 
	(parallel etc). If there are no constraints evaluate the axis vector
	given the point & the surface information, otherwise take the incoming
	vector */
	
	if(recompute && axis_normal && hole_type != 2) {
	    IGRint father_count = 0;
	    GRobjid vec_objid;
            IGRdouble dir[3];
            if(!EFisAncestryValid(&msg_loc, surf_info[0].located_obj.objid,
              surf_info[0].located_obj.osnum, OPP_EMSplane_class_id, FALSE) && 
		!ref_plane) {
                status = om$get_objid_at_index(objid = my_id,
                               	p_chanselect = &to_father,
                              	index = num_holes_parts,
                              	objidaddr = &vec_objid,
                              	osnumaddr = &dum_os);

		status = om$get_channel_count(objid = vec_objid, 
				osnum = OM_Gw_current_OS,
				p_chanselect = &to_father,
				count= (OMuint *)&father_count);

		/* No constraints are present */
		if(!father_count) {
		    struct EMSgeomdata axis;
                    status = om$send(msg = message EMSsubbs.EMget_unit_norm(
                                EMmsg, FALSE, NULL, 
                                &surf_info[0].module_info.md_env,
                                holes[0].center,dir),
                        targetid = surf_info[0].located_obj.objid,
                        targetos = surf_info[0].located_obj.osnum);

                    EMerr_hndlr (!(1&status&*EMmsg),*EMmsg,EMS_E_Fail,wrapup);
               	    OM_BLOCK_MOVE(dir, axis_vec[0], point_size);
		    
		    /* Get the old axis geomdata */
		    status = om$send(msg = message EMSparamgm.EMgetgeom(EMmsg,
				NULL, &mod->md_env.matrix_type,
				mod->md_env.matrix, &axis),
			senderid = NULL_OBJID,
			targetid = vec_objid,
			targetos = OM_Gw_current_OS);
			
                    EMerr_hndlr (!(1&status&*EMmsg),*EMmsg,EMS_E_Fail,wrapup);

		    /* Repost back the axis geometry */

               	    OM_BLOCK_MOVE(dir, axis.vector, point_size);
		    status = om$send(msg = message EMSparamgm.EMconstruct(EMmsg,
				NULL, &mod->md_env.matrix_type,
				mod->md_env.matrix, &axis),
			senderid = NULL_OBJID,
			targetid = vec_objid,
			targetos = OM_Gw_current_OS);
                    EMerr_hndlr (!(1&status&*EMmsg),*EMmsg,EMS_E_Fail,wrapup);
		}
	    }
	}

        /* get a point on the profile as the center point is not stored */
        if(hole_type == 2 && num_holes_parts == 1) {
                IGRpoint pt_on_prof;
                status = om$send(msg = message GRvg.GRcenter(EMmsg,
                                &surf_info[2].module_info.md_env.matrix_type,
                                surf_info[2].module_info.md_env.matrix,
                                pt_on_prof),
                        senderid = NULL_OBJID,
                        targetid = surf_info[2].located_obj.objid,
                        targetos = surf_info[2].located_obj.osnum);

                EMerr_hndlr (!(1&status&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);
                OM_BLOCK_MOVE(pt_on_prof, holes[0].center, point_size);
        }
        else if(hole_type == 2 && num_holes_parts > 1 && g_comp_cnt) 
        {
          /*DLB - Possible case of suppress/delete of first cutout.
           *      If this happens then must pass in a profile xform'd to
           *      a non-delete/suppress hole in the list.
           */
          IGRuint ii, jj, good_inx;
            
          for(ii=0; ii<g_comp_cnt; ii++) if (g_comp_indices[ii] == 0) break;

          if (ii != g_comp_cnt)
          {
            /*First cutout is suppress/deleted so copy profile to 1st good*/
            IGRmatrix        matrix;

            /*Find the first good part index.*/
            for(ii=0; ii<num_holes_parts; ii++)
            {
              for(jj=0; jj<g_comp_cnt; jj++)
              {
                if (ii == g_comp_indices[jj]) break;
              }
              if (jj == g_comp_cnt) break;  /*ii is a good index to use*/
            }

            good_inx = ii;

            for(ii=14; ii>0; ii--)  matrix[ii] = 0.0;
            matrix[0] = matrix[5] = matrix[10] = matrix[15] = 1.0;

            matrix[3] = holes[good_inx].center[0] - holes[0].center[0];
            matrix[7] = holes[good_inx].center[1] - holes[0].center[1];
            matrix[11] = holes[good_inx].center[2] - holes[0].center[2];

            new_env = surf_info[0].module_info;

            status = om$send(msg = message GRgraphics.GRcptform(EMmsg, 
                                   &surf_info[0].module_info, 
                                   matrix, &new_env, &profile_copy_id),
                             targetid = surf_info[2].located_obj.objid,
                             targetos = surf_info[2].located_obj.osnum);
            if (!(1 & status & *EMmsg)) goto wrapup;

            surf_info[2].located_obj.objid = profile_copy_id;
          }
        }
        
        /* Project the center point on the surface */
        for(i = 0; i < num_holes_parts; i++) {
            OM_BLOCK_MOVE(holes[i].center, input_pt, point_size);
            if(!ref_plane) {
                status = om$send(msg = message EMSsubbs.GRptproject(EMmsg, 
                                &surf_info[0].module_info.md_env.matrix_type,
                                surf_info[0].module_info.md_env.matrix,
                                input_pt, surf_pt, &proj_parms),
                        senderid = NULL_OBJID,
                        targetid = surf_info[0].located_obj.objid,
                        targetos = surf_info[0].located_obj.osnum);

                EMerr_hndlr (!(1&status&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);
            }
            else { /* Reference plane */
                struct GRlc_info *ref_info;
                ref_info = &surf_info[0];
                status = EFpton_refplane(EMmsg, ref_info, input_pt, surf_pt);
                EMerr_hndlr (!(1&status&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);
            }
            OM_BLOCK_MOVE(surf_pt, holes[i].center, point_size);
        }

        /* check - Profile is closed & profile lies on surface */
        if(hole_type == 2 && recompute) { /* profile */
                IGRlong buf_size;
                status = om$send(msg = message GRvg.GRgetsize(EMmsg,
                                &surf_info[2].module_info.md_env.matrix_type,
                                surf_info[2].module_info.md_env.matrix,
                                &buf_size),
                        targetid = surf_info[2].located_obj.objid,
                        targetos = surf_info[2].located_obj.osnum);

                EMerr_hndlr (!(1&status&*EMmsg),*EMmsg,EMS_E_Fail,wrapup);

                boundary = (struct IGRbsp_curve *) stackalloc(buf_size);

                if(!boundary) {
                        status = EMS_E_Fail;
                        goto wrapup;
                }

                status = om$send(msg = message GRvg.GRgetgeom(EMmsg,
                                &surf_info[2].module_info.md_env.matrix_type,
                                surf_info[2].module_info.md_env.matrix,
                                (IGRchar *) boundary),
                        targetid = surf_info[2].located_obj.objid,
                        targetos = surf_info[2].located_obj.osnum);

                EMerr_hndlr (!(1&status&*EMmsg),*EMmsg,EMS_E_Fail,wrapup);

                /* Error out if the profile is not planar or closed */
                if(!boundary->planar || !boundary->phy_closed) {
                        if(!boundary->planar)
                            ex$message ( msgnumb = EMS_S_ProfileNotPlanar)
                        else
                            ex$message ( msgnumb = EMS_S_ProfileNotClosed);
                        sleep(2);
                        *EMmsg = EMS_I_CantRecompute;
                        goto wrapup;
                }
                else { /* test if the profile lies on the surface */
                        IGRboolean on_surf;
                        IGRdouble uv[2];
                        IGRpoint pt;
                        struct IGRbsp_surface *surf = NULL;
/*
 * Modified the code to refer to surf_info[0] instead of surf_info[2].
 * This was causing a memory fault while placing a macro. 
 */
                        
                        status = om$send(msg= message EMSsubbs.GRgetsize(EMmsg,
                                &surf_info[0].module_info.md_env.matrix_type,
                                surf_info[0].module_info.md_env.matrix,
                                &buf_size),
                        targetid = surf_info[0].located_obj.objid,
                        targetos = surf_info[0].located_obj.osnum);
                        EMerr_hndlr(!(1&status&*EMmsg), *EMmsg, EMS_E_Fail,
                                wrapup);
/* end pp 12/23/91 */

                        surf = (struct IGRbsp_surface *) stackalloc(buf_size);
                        if(!surf) {
                                status = EMS_E_Fail;
                                goto wrapup;
                        }
                        status = om$send(msg = message EMSsubbs.GRgetgeom(EMmsg,
                                &surf_info[0].module_info.md_env.matrix_type,
                                surf_info[0].module_info.md_env.matrix,
                                (IGRchar *) surf),
                        targetid = surf_info[0].located_obj.objid,
                        targetos = surf_info[0].located_obj.osnum);
                        EMerr_hndlr(!(1&status&*EMmsg), *EMmsg, EMS_E_Fail,
                                wrapup);

                        if(boundary->rational) {
                                pt[0] = boundary->poles[0]/boundary->weights[0];
                                pt[1] = boundary->poles[1]/boundary->weights[0];
                                pt[2] = boundary->poles[2]/boundary->weights[0];
                        }
                        else 
                                OM_BLOCK_MOVE(boundary->poles, pt, point_size);

                        BSprptonsf(EMmsg, surf, pt, &uv[0], &uv[1], &on_surf);

                        if(*EMmsg != 0) {
                                status = EMS_E_Fail;
                                goto wrapup;
                        }
                        if(!on_surf) {
                                ex$message ( msgnumb = EMS_S_ProfileNotOnSurf);
                                sleep(2);
                                *EMmsg = EMS_I_CantRecompute;
                                goto wrapup;
                        }
                }
        }

        /* Error out if the axis direction is invalid */
        if(recompute && hole_type != 2) {
            for(i = 0; i < num_holes_parts; i++) {
                IGRdouble dir[3],len;
                if(!ref_plane) {
                    status = om$send(msg = message EMSsubbs.EMget_unit_norm(
                                EMmsg, FALSE, NULL, 
                                &surf_info[0].module_info.md_env,
                                holes[i].center,dir),
                        targetid = surf_info[0].located_obj.objid,
                        targetos = surf_info[0].located_obj.osnum);

                    EMerr_hndlr (!(1&status&*EMmsg),*EMmsg,EMS_E_Fail,wrapup);
                        
                    len = axis_vec[0][0] * dir[0] + axis_vec[0][1] * dir[1] +
                        axis_vec[0][2] * dir[2];
                    if(len <= 0) {
                        axis_vec[0][0] *= -1.0;
                        axis_vec[0][1] *= -1.0;
                        axis_vec[0][2] *= -1.0;
                    }
                }
            }
        }

        /* Get the active parent of the surface */
        if(!ref_plane) {
                status = om$send(msg = message EMSsurface.EMgetactiveid(EMmsg,
                                &start_surf_GRid, NULL),
                        senderid = NULL_OBJID,
                        targetid = surf_info[0].located_obj.objid,
                        targetos = surf_info[0].located_obj.osnum);

                EMerr_hndlr (!(1&status&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);

                if(start_surf_GRid.objid == NULL_OBJID) {
                        status = om$get_objid_at_index(objid = my_id,
                                        p_chanselect = &to_comps,
                                        index = 0,
                                        objidaddr = &start_surf_GRid.objid,
                                        osnumaddr = &dum_os);

                        if(!(1&status)) goto wrapup;
                }
        }
        else 
                start_surf_GRid.objid = roots[num_par - 1].grobj.grid.objid;
                
        start_surf_GRid.osnum = OM_Gw_current_OS;

        for(i = 0; i < num_holes_parts; i++) {
                if(depth_type == 3) hole_depth = holes[i].depth;
                if(hole_type == 2) holes[i].radius = 0.0;

                /* Get the unit axis vector for a profile hole */

                if(hole_type == 2 && i == 0) {
                        status = om$send(msg = message EMSsubbs.EMget_unit_norm(
                                        EMmsg, FALSE, NULL, 
                                        &surf_info[0].module_info.md_env,
                                        holes[i].center, axis_vec[0]),
                                targetid = surf_info[0].located_obj.objid,
                                targetos = surf_info[0].located_obj.osnum);

                        EMerr_hndlr (!(1&status&*EMmsg), *EMmsg, EMS_E_Fail, 
                                wrapup);
                }

                /* Whenever there's a recompute I am initializing the axis 
                normal to false as I don't have any idea of the incoming vector
                orientation */

                if(hole_type != 2) axis_normal = FALSE;

                /* Computes the hole axis data */
                if(depth_type == 1 && hole_type != 2) { /*circular thru until */
                    if(!ref_plane && !end_ref_plane) {
                        status = EFcomphole_until(EMmsg, &axis_normal, 
                                axis_vec[0], &surf_info[0], &holes[i]);
                        EMerr_hndlr(!(1&status&*EMmsg), *EMmsg, EMS_E_Fail, 
                                wrapup);
                    }
                    else {
                        status = EFcomphole_until_ref(EMmsg, &axis_normal, 
                                axis_vec[0], &surf_info[0], &holes[i]);
                        EMerr_hndlr(!(1&status&*EMmsg), *EMmsg, EMS_E_Fail, 
                                wrapup);
                    }
                }
                /* circular other types - ALL, NEXT & BLIND without reference
                plane or place cutout - ALL, NEXT & UNTIL */
                else {
                    if(!ref_plane && !end_ref_plane) {
			if(hole_type == 2) { /* Profile holes or cutouts */
			    if(depth_type == 1) /* thru until */
		                status = EFcomp_cut_until(EMmsg, &axis_normal, 
					&depth_type, &hole_depth, axis_vec[0], 
					&surf_info[0], &start_surf_GRid, 
					&holes[i]);
			    else  /* thru next or all */
		            	status = EFcomp_hole_depth(EMmsg, &axis_normal, 
					&depth_type, &hole_depth, axis_vec[0], 
					&surf_info[0], &start_surf_GRid, 
					&holes[i]);
			}
		 	else {
		            status = EFcomp_hole_depth(EMmsg, &axis_normal, 
				&depth_type, &hole_depth, axis_vec[0], 
				&surf_info[0], &start_surf_GRid, &holes[i]);
			}
		    	EMerr_hndlr(!(1&status&*EMmsg), *EMmsg, EMS_E_Fail, 
				wrapup);
		    }
                    else { /* circular other types - reference plane */
                        status = EFcomp_hole_depth_ref(EMmsg, &axis_normal, 
                                &depth_type, &hole_depth, axis_vec[0], 
                                &surf_info[0], &start_surf_GRid, &holes[i]);
                        EMerr_hndlr(!(1&status&*EMmsg), *EMmsg, EMS_E_Fail, 
                                wrapup);
                    }
                }
        }

        /* check made to see if the depth for finite hole is very large.
        If the point doesn't lie in the solid the user is warned */

        if(depth_type == 3) {
            for(i = 0; i < num_holes_parts; i++) {
                IGRulong  location;
                IGRpoint check_pt;

                OM_BLOCK_MOVE(holes[i].axis_line[1], check_pt, point_size);
                status = om$send(msg = message EMSsolid.EMpoint_locate(EMmsg,
                                construct_list->env_info, NULL, check_pt, NULL,
                                &location),
                        senderid = NULL_OBJID,
                        targetid = start_surf_GRid.objid,
                        targetos = start_surf_GRid.osnum);
                if( !(1 & status & *EMmsg)) {
                        ex$message ( msgnumb = EMS_S_ErrorInLocOfPt);
                        status = FAIL; 
                        goto wrapup;
                }
                if(location != EMS_S_INSOLID) {
                        ex$message ( msgnumb = EMS_S_DepthLargeForHole,
                                     type = "%d",
                                     var  = `i+1`);
                        sleep(1);
                }
            }
        }

        /*DLB - Use the group_comp_indices to weed out the partially deleted
         *      or suppressed holes
         */
        for(i=0; i<g_comp_cnt; i++)
        {
          OM_BLOCK_MOVE(&holes[g_comp_indices[i]+1],
                        &holes[g_comp_indices[i]],                        
                        (num_holes_parts - g_comp_indices[i] - 1) *
                        sizeof(struct EMShole));
          num_holes_parts--;
        }

        /* creates the hole feature. Call selective boolean. If it fails invoke
        ordinary boolean */
        if(!ref_plane && hole_type != 2) {
            status = om$send(msg = message EMSslboolfea.EMhole_sel_boolean(
                        EMmsg, hole_type, &depth_type, &surf_info[0], &v_angle, 
                        construct_list, num_holes_parts, holes, 
                        &start_surf_GRid),
                targetid = my_id,
                targetos = my_GRid.osnum);
        }

        if(!(1 & status & *EMmsg) || ref_plane || hole_type == 2) {
            status = om$send(msg = message EMSslboolfea.EMpunch_hole(EMmsg,
                        hole_type, &depth_type, &surf_info[0], &v_angle, 
                        construct_list, num_holes_parts, holes, 
                        &start_surf_GRid),
                targetid = my_id,
                targetos = my_GRid.osnum);

            if (profile_copy_id != NULL_OBJID)
            {
              /*DLB - Delete the copy made earlier regardless of punch stat.*/
              IGRlong loc_msg=EMS_S_Success;
              om$send(msg = message GRgraphics.GRdelete(&loc_msg,
                            &new_env),
                      targetid = profile_copy_id,
                      targetos = surf_info[2].located_obj.osnum);
            }

            EMerr_hndlr (!(1&status&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);
        }

}
else {  /* counterbore/countersink */

        struct  part_data *parts = NULL;
        IGRdouble       bot_ang, ang_or_depth, drill_rad, hole_rad;
        struct GRlc_info surf_info[1];
        IGRlong         EFget_the_hole_depth();

        /* Number of parents that I am associated with is num_par - 1 since
        one of my parents is a component parent */
        root_count = num_par - 1;

        num_holes_parts =  root_count -  surf_par - var_par;

        /*See if all holes have been suppressed/deleted*/
        if ((num_holes_parts - g_comp_cnt) <= 0) goto wrapup;

        root_type = (IGRuint *) stackalloc(sizeof (IGRint) * 
                root_count);
        EMerr_hndlr(!root_type, *EMmsg, EMS_E_NoStackMemory,wrapup);

        roots = (union EMSparent_info *) stackalloc(sizeof
                (union EMSparent_info) * root_count);
        EMerr_hndlr(!roots, *EMmsg, EMS_E_NoStackMemory,wrapup);

        parts  = (struct part_data *) stackalloc(sizeof(struct part_data) * 
            num_holes_parts);
        EMerr_hndlr(!parts, *EMmsg, EMS_E_NoStackMemory,wrapup);

        for(i = 0; i < num_holes_parts; i++) {
                root_type[index] = EMSpoint;    /* center point */
                index++;
        }
        /* Axis vector */
        if(!axis_normal) {
                root_type[index] = EMSvector;
                index++;
        }
        /* hole diameter */
        root_type[index] = EMSdistance;
        index++;

        /* bottom angle & depth for blind hole */
        if(!through_hole) {
                root_type[index] = EMSdistance;
                index++;
                root_type[index] = EMSangle;
                index++;
        }
        /* c-bore/c-sink diameter */
        root_type[index] = EMSdistance;
        index++;

        /* angle or depth */
        if(part_type == COUNTERSINK)
                root_type[index] = EMSangle;
        else
                root_type[index] = EMSdistance;

        /* surface information */
        root_type[root_count - 1] = EMSgrid;

        status = om$send (msg = message EMSassoc.EMget_parent_info(EMmsg,NULL,
                        root_count, parent_info, root_type, roots),
                targetid = my_id);
        EMerr_hndlr(!(1&status&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);

        index = 0;
        for(i = 0; i < num_holes_parts; i++) {  
                /* center */
                OM_BLOCK_MOVE(roots[index].point, parts[i].center, point_size);
                index++;
        }
        /* Axis Vector */
        if(!axis_normal) {
                OM_BLOCK_MOVE(roots[index].vector, parts[0].axis_dir, 
                        point_size);
                index++;
        }

        /* Copy the axis of first c-bore/c-sink into subsequent ones if any */ 
        if(!axis_normal) {
            for(i = 1; i < num_holes_parts; i++) 
                OM_BLOCK_MOVE(parts[0].axis_dir,parts[i].axis_dir,point_size);
        }

        hole_rad = 0.5 * roots[index].value;    /* hole radius */
        index++;
        if(!through_hole) {
                /* read the hole_depth & compute depth point */
                for(i = 0; i < num_holes_parts; i++) 
                        parts[i].hole_depth = roots[index].value; 
                index++;
                bot_ang = roots[index].value;   /* bottom angle - blind hole */
                index++;
        }
        drill_rad = 0.5 * roots[index].value;   /* c-bore/c-sink radius */
        index++;

        /* Error out if hole diameter is greater than c-bore/c-sink diameter */
        if(hole_rad >= drill_rad && recompute) {
            if(part_type == COUNTERBORE)
                ex$message ( msgnumb = EMS_S_CntrBoreDiaGtHole)
            else
                ex$message ( msgnumb = EMS_S_CntrSinkDiaGtHole);
            sleep(2);
            *EMmsg = EMS_I_CantRecompute;
            goto wrapup;
        }

        ang_or_depth = roots[index].value;      /* depth for c-bore or angle
                                                for c-sink */
        index++;

        /* Error out if the counterbore depth is greater than hole depth */
        if(part_type == COUNTERBORE && recompute) {
            if(!through_hole && parts[0].hole_depth <= ang_or_depth) {
                ex$message ( msgnumb = EMS_S_HoleDepthGtCntrD);
                sleep(2);
                *EMmsg = EMS_I_CantRecompute;
                goto wrapup;
            }
        }

        /* Error out if the countersink angle is negative */
        if(part_type == COUNTERSINK && recompute) {
            if(ang_or_depth <= 0.0 || ang_or_depth >= 180.0) {
                ex$message ( msgnumb = EMS_S_InvalidCntrSinkA);
                sleep(2);
                *EMmsg = EMS_I_CantRecompute;
                goto wrapup;
            }
        }

        /* surface information */
        surf_info[0].located_obj = roots[root_count - 1].grobj.grid;

        if(surf_info[0].located_obj.objid == NULL_OBJID) {
                *EMmsg = EMS_I_CantRecompute;
                goto wrapup;
        }

        surf_info[0].module_info = *mod;

        /* Project the center point on the surface */
        for(i = 0; i < num_holes_parts; i++) {
                OM_BLOCK_MOVE(parts[i].center, input_pt, point_size);
                status = om$send(msg = message EMSsubbs.GRptproject(EMmsg, 
                                &surf_info[0].module_info.md_env.matrix_type,
                                surf_info[0].module_info.md_env.matrix,
                                input_pt, surf_pt, &proj_parms),
                        senderid = NULL_OBJID,
                        targetid = surf_info[0].located_obj.objid,
                        targetos = surf_info[0].located_obj.osnum);

                EMerr_hndlr (!(1&status&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);
                OM_BLOCK_MOVE(surf_pt, parts[i].center, point_size);
        }

        /* If axis is normal to surface - compute the axis vector */
        if(axis_normal) {
            for(i = 0; i < num_holes_parts; i++) {
                IGRdouble dir[3];
                status = om$send(msg = message EMSsubbs.EMget_unit_norm(
                                EMmsg, FALSE, NULL, 
                                &surf_info[0].module_info.md_env,
                                parts[i].center, dir),
                        targetid = surf_info[0].located_obj.objid,
                        targetos = surf_info[0].located_obj.osnum);

                EMerr_hndlr (!(1&status&*EMmsg),*EMmsg,EMS_E_Fail,wrapup);
                OM_BLOCK_MOVE(dir, parts[i].axis_dir, point_size);
             }
        }

        if(!through_hole) {
                /* compute depth point */
                for(i = 0; i < num_holes_parts; i++) {
                        parts[i].depth_pt[0] = parts[i].center[0] + 
                                parts[i].hole_depth * parts[i].axis_dir[0];
                        parts[i].depth_pt[1] = parts[i].center[1] + 
                                parts[i].hole_depth * parts[i].axis_dir[1];
                        parts[i].depth_pt[2] = parts[i].center[2] + 
                                parts[i].hole_depth * parts[i].axis_dir[2];
                }
        }
        status = om$send(msg = message EMSsurface.EMgetactiveid(EMmsg,
                        &start_surf_GRid, NULL),
                senderid = NULL_OBJID,
                targetid = surf_info[0].located_obj.objid,
                targetos = surf_info[0].located_obj.osnum);

        EMerr_hndlr (!(1&status&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);

        if(start_surf_GRid.objid == NULL_OBJID) {
                status = om$get_objid_at_index(objid = my_id,
                                        p_chanselect = &to_comps,
                                        index = 0,
                                        objidaddr = &start_surf_GRid.objid,
                                        osnumaddr = &dum_os);

                if(!(1&status)) goto wrapup;
        }
        start_surf_GRid.osnum = OM_Gw_current_OS;

        /* compute c-bore/c-sink depth for through hole */
        if(through_hole) {
             for(i = 0; i < num_holes_parts; i++) {
                status = EFget_the_hole_depth(&surf_info[0].module_info,
                                &axis_normal, &hole_rad, &parts[i], 
                                &start_surf_GRid, NULL_OBJID);
                EMerr_hndlr(!(1&status), *EMmsg, EMS_E_Fail, wrapup);
             }
        }

        /* check made to see if the depth for finite c-bore/c-sink is very 
        large. If the point doesn't lie in the solid the user is warned */
        if(!through_hole) {
            for(i = 0; i < num_holes_parts; i++) {
                IGRpoint check_pt;
                IGRulong location;

                OM_BLOCK_MOVE(parts[i].depth_pt, check_pt, point_size);
                status = om$send(msg = message EMSsolid.EMpoint_locate(EMmsg,
                                construct_list->env_info,NULL, check_pt, NULL,
                                &location),
                        senderid = NULL_OBJID,
                        targetid = start_surf_GRid.objid,
                        targetos = start_surf_GRid.osnum);
                if( !(1 & status & *EMmsg)) {
                        ex$message ( msgnumb = EMS_S_ErrorInLocOfPt);
                        status = FAIL; 
                        goto wrapup;
                }
                if(location != EMS_S_INSOLID) {

                        ex$message ( msgnumb = EMS_S_DepthLargeForHole,
                                     type = "%d",
                                     var  = `i+1`);
                        sleep(1);
                }
            }
        }

        /*DLB - Use the group_comp_indices to weed out the partially deleted
         *      or suppressed holes
         */
        for(i=0; i<g_comp_cnt; i++)
        {
          OM_BLOCK_MOVE(&parts[g_comp_indices[i]+1],
                        &parts[g_comp_indices[i]],                        
                        (num_holes_parts - g_comp_indices[i] - 1) *
                        sizeof(struct part_data));
          num_holes_parts--;
        }

        /* creates the actual c-bore/c-sink feature */
        status = om$send(msg = message EMSslboolfea.EMpunch_counterpart(EMmsg,
                        construct_list, part_type, axis_normal, through_hole,
                        &bot_ang, &surf_info[0], num_holes_parts, parts, 
                        &ang_or_depth, &drill_rad, &hole_rad, 
                        &start_surf_GRid), 
                targetid = my_id,
                targetos = my_GRid.osnum);

        EMerr_hndlr (!(1&status& *EMmsg), *EMmsg, EMS_E_Fail, wrapup);
}

wrapup:
        if (g_comp_indices) om$dealloc(ptr = g_comp_indices);

        /* Disconnect the components when an error occurs */
        /* BUT ONLY IF NOT IN RECOMPUTE!!!! - DLB 4/2/92 TR92n2956*/
        if(!(1&status&*EMmsg) && !recompute)
        {
                IGRlong om_stat, l_msg;
                OMuint comp_count = 0;
                
                om_stat = om$get_channel_count(osnum= my_GRid.osnum,
                                        objid = my_GRid.objid,
                                        p_chanselect = &to_comps,
                                        count = &comp_count);

                if(comp_count) {
                        om$send(msg = message GRconnector.GRdisconn(&l_msg,
                                        &my_GRid),      
                                p_chanselect = &to_comps);
                }
        }

        if (root_type) stackfree(root_type);
        EMWRAPUP (*EMmsg,status, "In EMSslmakehole:error");
        return (status);
}

/* Tapadia - 08/04/91 - Creation 

This function returns the hole & c-bore/c-sink data depending on the type of
hole & if the part is counterbore/countersink */

void EFret_hole_cpart_data_mod(EMmsg, type, hole_flag, axis_normal, var_par, 
                hole_type, depth_type, part_type, through_hole, ref_plane)
IGRlong         *EMmsg;
IGRint          type;
IGRboolean      *hole_flag, *axis_normal;
IGRuint         *var_par;
IGRushort       *hole_type, *depth_type;
IGRint          *part_type;
IGRboolean      *through_hole;
IGRboolean      *ref_plane;
{
        IGRuint cpart_var;

        *EMmsg = EMS_S_Success;
        *hole_flag = *axis_normal = *through_hole = *ref_plane = FALSE;
        cpart_var = 3; /* center, radius & c-bore depth/c-sink angle */
        *part_type = COUNTERSINK;
        *hole_type = 0; /* circular hole */
        *depth_type = 0; /* through all hole */

        switch (type) {
            case EMS_ASCIR_THRU_ALL_HOLE_TYPE_1:
            case EMS_ASCIR_THRU_ALL_REFPLANE:
                *hole_flag = TRUE;
                if(type == EMS_ASCIR_THRU_ALL_REFPLANE)
                        *ref_plane = TRUE;
                break;

            case EMS_ASCIR_THRU_UNTIL_HOLE_TYPE_1:
            case EMS_ASCIR_THRU_UNTIL_REFPLANE:
                *depth_type = 1;
                *hole_flag = TRUE;
                if(type == EMS_ASCIR_THRU_UNTIL_REFPLANE)
                        *ref_plane = TRUE;
                break;

            case EMS_ASCIR_THRU_NEXT_HOLE_TYPE_1:
            case EMS_ASCIR_THRU_NEXT_REFPLANE:
                *depth_type = 2;
                *hole_flag = TRUE;
                if(type == EMS_ASCIR_THRU_NEXT_REFPLANE)
                        *ref_plane = TRUE;
                break;

            case EMS_ASCIR_FINITE_FLAT_HOLE_TYPE_1:
            case EMS_ASCIR_FINITE_FLAT_REFPLANE:
                *depth_type = 3;
                *hole_flag = TRUE;
                if(type == EMS_ASCIR_FINITE_FLAT_REFPLANE)
                        *ref_plane = TRUE;
                break;

            case EMS_ASCIR_FINITE_V_HOLE_TYPE_1:
            case EMS_ASCIR_FINITE_V_REFPLANE:
                *hole_type = 1;
                *depth_type = 3;
                *hole_flag = TRUE;
                if(type == EMS_ASCIR_FINITE_V_REFPLANE)
                        *ref_plane = TRUE;
                break;

            case EMS_ASPRO_THRU_ALL_HOLE_TYPE:
                *hole_type = 2;
                *hole_flag = TRUE;
                break;

            case EMS_ASPRO_THRU_UNTIL_HOLE_TYPE:
                *hole_type = 2;
                *depth_type = 1;
                *hole_flag = TRUE;
                break;

            case EMS_ASPRO_THRU_NEXT_HOLE_TYPE:
                *hole_type = 2;
                *depth_type = 2;
                *hole_flag = TRUE;
                break;

            case EMS_ASCSINK_AXIS_NOR_AND_THRU:
                *axis_normal = TRUE;
                *through_hole = TRUE;
                break;

            case EMS_ASCSINK_AXIS_ALI_AND_THRU:
                *through_hole = TRUE;
                cpart_var++;    /* axis vector */
                break;

            case EMS_ASCSINK_AXIS_NOR_AND_BLIND:
                *axis_normal = TRUE;
                cpart_var += 2;         /* hole depth & c-sink angle */
                break;

            case EMS_ASCSINK_AXIS_ALI_AND_BLIND:
                cpart_var += 3;         /* axis, hole depth & c-sink angle */
                break;

            case EMS_ASCBORE_AXIS_NOR_AND_THRU:
                *part_type = COUNTERBORE;
                *axis_normal = TRUE;
                *through_hole = TRUE;
                break;

            case EMS_ASCBORE_AXIS_ALI_AND_THRU:
                *part_type = COUNTERBORE;
                *through_hole = TRUE;
                cpart_var++;    /* axis vector */
                break;

            case EMS_ASCBORE_AXIS_NOR_AND_BLIND:
                *part_type = COUNTERBORE;
                *axis_normal = TRUE;
                cpart_var += 2;         /* hole depth & c-bore depth */
                break;

            case EMS_ASCBORE_AXIS_ALI_AND_BLIND:
                *part_type = COUNTERBORE;
                cpart_var += 3;         /* axis, hole depth & c-bore depth */
                break;

            default:
                *EMmsg = EMS_I_CantRecompute;
                break;
        }
        *var_par = cpart_var;
}

end implementation EMSslboolfea;
