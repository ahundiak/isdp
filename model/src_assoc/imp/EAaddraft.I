/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsfaddraft;

%safe
#include <math.h>
#include <values.h>
%endsafe
#include "EMSlm.h"
#include "EMSlmdef.h"
#include "EMSdpr.h"
#include "EMSprop.h"
#include "bserr.h"
#include "bsparameters.h"
#include <stdio.h>
#include "OMmacros.h"
#include "EMSas.h"
#include "EMSasfeatdef.h"
#include "EMSasnucdef.h"
#include "EMSconstruct.h"
#include "EMSdef.h"
#include "msdef.h"
#include "msmacros.h"
#include "ECmsg.h"

method EMconstruct_associative(IGRlong *EMmsg; IGRushort options;
		GRobjid  old_objid; IGRint num_parents; IGRchar *parent_info;
		IGRint type; IGRchar *recomp_info; 
		struct GRvg_construct *construct_list)

/*****************************************************************
Description
 This method does the actual construction of  add draft/ replace surf features.

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


Objects connected on the parent channel:
 Profile, depth or surfaces on which slot was made.

History
*******************************************************************/

{
IGRlong 	status;
union 		EMSparent_info *roots = NULL;
IGRuint         *root_type = NULL;
struct 	        GRid my_GRid;
IGRint 	num_angles, num_drafts, ii, i, inx,  index = 0;
IGRuint	surf_par; 
IGRuint root_count;
struct	GRmd_env  *mod;
struct 	GRid solid_grid;
IGRboolean  is_reversed;
IGRdouble draft_angle;
IGRboolean draft_angle_rev;
struct GRid  *surfs_to_draft;
IGRint  part_type, add_draft_type;
struct GRlc_info surf_info[3];
IGRlong buf_size;
struct EMSadd_draft  *addraft_info;
OM_S_CHANSELECT to_comps;
GRobjid *hinges;
IGRboolean ang_rev;

status = OM_S_SUCCESS;
*EMmsg = EMS_S_Success;

my_GRid.objid = my_id;
my_GRid.osnum = OM_Gw_current_OS;
mod = construct_list->env_info;
/* recompute = options & EMSasconst_recompute; */


	addraft_info = (struct EMSadd_draft *)recomp_info;
        add_draft_type = type ;

        if(type== REPLACE_SURFACE)
           num_parents = 3;

	/* Number of parents that I am associated with */
	root_count = num_parents;

        if(num_parents==3)
           add_draft_type = REPLACE_SURFACE;
        else
           add_draft_type = SURFACE_AND_SURFACES;

        if(add_draft_type == SURFACES_AND_EDGES_OR_CRVS_OR_SURFS)
          {
          num_drafts = (num_parents-3)/2;
          }
        else if(add_draft_type == SURFACE_AND_SURFACES)
         {
          num_drafts = (num_parents-4);
         }
        else if(add_draft_type == REPLACE_SURFACE)
         {
          num_drafts = (num_parents-1)/2;
         }

	root_type = (IGRuint *) stackalloc(sizeof(IGRint) * root_count);
	EMerr_hndlr(!root_type, *EMmsg, EMS_E_NoStackMemory,wrapup);

	roots =(union EMSparent_info *) stackalloc(sizeof(union EMSparent_info)
		* root_count);
	EMerr_hndlr(!roots, *EMmsg, EMS_E_NoStackMemory,wrapup);

          
/******* GET PARENT INFORMATION **************************************/

       index=0;
       /* surfaces to be drafted ********************************/

        for(ii=0;ii<num_drafts; ii++)
           {
            root_type[index] = EMSgrid;
            index++;
           }

       /* ref edged or surfaces **********************************/
        if((add_draft_type == SURFACES_AND_EDGES_OR_CRVS_OR_SURFS)
                          ||
          (add_draft_type == REPLACE_SURFACE))
          {
          for(ii=0; ii<num_drafts; ii++)
            {
            root_type[index] = EMSgrid;
            index++;
            }
          }
        else 
          {
           root_type[index] = EMSgrid;
           index++;
          }
           
        if(!(add_draft_type == REPLACE_SURFACE))
        { 
       /* draft angle *******************************************/
          root_type[index] = EMSangle;
          index++;

       /* draft angle rev *******************************************/
          root_type[index] = EMSangle;
          index++;

        }

        root_type[index] = EMSgrid;
        index++;

	status = om$send (msg = message EMSassoc.EMget_parent_info(EMmsg,NULL,
	    		root_count, parent_info, root_type, roots),
	    	targetid = my_id);
	EMerr_hndlr(!(1&status&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);

       surfs_to_draft =
         (struct GRid *)om$malloc(size = sizeof(struct GRid) *num_drafts);

	hinges = (GRobjid *) om$malloc(size= sizeof(GRobjid) * num_drafts);
	EMerr_hndlr(!root_type, *EMmsg, EMS_E_NoStackMemory,wrapup);

       index=0;
       /* surfaces to be drafted ********************************/

        for(ii=0; ii<num_drafts; ii++)
           {
            surfs_to_draft[ii].objid =  roots[index].grobj.grid.objid;
            surfs_to_draft[ii].osnum =  roots[index].grobj.grid.osnum;
            index++;
           }

       /* ref edged or surfaces **********************************/
        ii=0;
        if((add_draft_type == SURFACES_AND_EDGES_OR_CRVS_OR_SURFS)
                          ||
          (add_draft_type == REPLACE_SURFACE))
          {
          for(ii=0; ii<num_drafts;  ii++)
            {
            hinges[ii] =  roots[index].grobj.grid.objid;
            index++;
            }
          }
        else
          {
          hinges[ii] =  roots[index].grobj.grid.objid;
          index++;
          }
          
        if(!(add_draft_type == REPLACE_SURFACE))
        { 
       /* draft angles *******************************************/
          draft_angle =  roots[index].value;
          draft_angle *= M_PI/180.0;
          index++;

       /* draft angle  rev*******************************************/
          draft_angle_rev =  roots[index].value;
          if(draft_angle_rev == 1.0)
               draft_angle *= -1.0;
          index++;
          if(draft_angle_rev == 1.0)
             ang_rev = TRUE;
          else
             ang_rev = FALSE;
        }

/********************
	if(recompute) {
		status = om$send(msg = message GRvg.GRgetsize(EMmsg,
				&surf_info[1].module_info.md_env.matrix_type,
				surf_info[1].module_info.md_env.matrix,
				&buf_size),
			targetid = surf_info[1].located_obj.objid,
			targetos = surf_info[1].located_obj.osnum);

   		EMerr_hndlr (!(1&status&*EMmsg),*EMmsg,EMS_E_Fail,wrapup);

		boundary = (struct IGRbsp_curve *) stackalloc(buf_size);
		if(!boundary) { status = EMS_E_Fail; goto wrapup; }

		status = om$send(msg = message GRvg.GRgetgeom(EMmsg,
				&surf_info[1].module_info.md_env.matrix_type,
				surf_info[1].module_info.md_env.matrix,
				(IGRchar *) boundary),
			targetid = surf_info[1].located_obj.objid,
			targetos = surf_info[1].located_obj.osnum);

   		EMerr_hndlr (!(1&status&*EMmsg),*EMmsg,EMS_E_Fail,wrapup);
		}
**********************/


	/* Create the add draft feature */
       
        if( !(add_draft_type == REPLACE_SURFACE))
        {
          ME.EMSassoc->type = 0;
	  status = om$send(msg = message EMSsfaddraft.EMadd_draft(EMmsg,
                        construct_list->env_info,
                        num_drafts,
                        add_draft_type,
                        NULL,
                        surfs_to_draft,
                        hinges,
                        ang_rev,
                        draft_angle,
			construct_list),
		targetid = my_id);
        }
        else
        {
          ME.EMSassoc->type = REPLACE_SURFACE;
	  status = om$send(msg = message EMSsfaddraft.EMadd_draft(EMmsg,
                        construct_list->env_info,
                        num_drafts,
                        add_draft_type,
                        hinges,
                        surfs_to_draft,
                        NULL,
                        FALSE,
                        0.0,
			construct_list),
		targetid = my_id);
        }
	EMerr_hndlr (!(1&status&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);

wrapup:

        if(hinges)
           om$dealloc(ptr= hinges);

        if(surfs_to_draft)
           om$dealloc(ptr= surfs_to_draft);


	if (root_type) stackfree(root_type);
	EMWRAPUP (*EMmsg,status, "In EAaddraft:error");
	return (status);
}

end implementation EMSsfaddraft;




