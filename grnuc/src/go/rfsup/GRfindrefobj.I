class implementation GRreffile;

#include "grimport.h"
#include "msdef.h"
#include "godef.h"
#include "refdef.h"
#include "grgsdef.h"
#include "grgsmacros.h"
#include "lcdef.h"

%safe
static int  GRref_objects_found = 0;
%endsafe

#argsused
IGRint REFaction_handler(act_params,
                         new_entry,
                         locate_args,
                         action)
struct IGRchar   *act_params;
struct GRlc_info *new_entry;
struct LC_action_args *locate_args;
IGRchar *action;
{

    GRref_objects_found += 1;

    return(TRUE);
}

IGRint REFinit_count()
{
   GRref_objects_found = 0;
   return TRUE;
}

/* 
 *  Name: GRfindref_objects
 *
 *        This function will return the number of reference file elements
 *         that are passed the given locate criteria.
 *  
 *  History
 *         gang   12/02/92    Creation.
 *         Satya  08/31/94    Commented out the computation of pt1 and pt2
 *			      in case of rp_loc and cv_loc cases as they
 *			      lead to problems in case of CVE/PDD --
 *			      TR# 119420391
 */
#argsused
IGRlong GRfindref_objects(msg,
                          cvl,
                   properties,
                       levels, 
                        objid, 
	                osnum,
                master_to_ref,
                    vw_volume,
                    vw_matrix,
                     vw_origin)

IGRlong			*msg;
struct  GRlc_cvl 	*cvl;
IGRlong			*properties;
IGRint			*levels;
GRobjid			*objid;
GRspacenum		*osnum;
IGRdouble		*master_to_ref;
IGRdouble		*vw_volume;
IGRdouble		*vw_matrix;
IGRdouble		*vw_origin;

{

    IGRlong	OMmsg,
		msg1;

    IGRboolean is_skew;			/* flag for skew view		*/

    IGRdouble *pt1,*pt2;		/* working pointers		*/

    struct GRlc_cvl local_cvl;		/* internal locate information	*/

    OM_S_MESSAGE  pass_msg; 		/* structs for make message	*/

    struct GRlocate_args_struct locate_args;

    IGRdouble world_range[16];

    OMuword classid;
    OMuword *p_classes,w_count,w_flags;
    unsigned long orig_owner_action, orig_props;
    char act_parms[128];
    char *orig_act_parms;

    if (1&(OMmsg = om$make_message(
	classname = "GRgraphics",
        methodname = "GRlocate",
        size = sizeof(struct GRlocate_args_struct),
        p_arglist = &locate_args,
        p_msg = &pass_msg )))
    {

	local_cvl = *cvl;				
        locate_args.cvl = &local_cvl;
 	locate_args.range_key = NULL;
	local_cvl.levels = levels;

	OMmsg = om$send(
	    msg = message GRreffile.GRgetenvironment
		   (msg,&cvl->module,&local_cvl.module),
	    senderid = *objid,
	    targetid = *objid);

	if ( 1 & *msg & OMmsg)
	{

            locate_args.cvl->action_handler = REFaction_handler;
           
            strcpy(act_parms,"Finding_ref_objects");

          /* make all the graphics objects eligible to locate */

            om$get_classid(classname = "GRgraphics", 
                           p_classid = &classid);
          
          /* backup the original values */
         
            p_classes = cvl->classes->p_classes;
            w_count = cvl->classes->w_count;
            w_flags = cvl->classes->w_flags;
            orig_act_parms = cvl->act_parms;
     
            locate_args.cvl->classes->p_classes = &classid;
            locate_args.cvl->classes->w_count = 1;
            locate_args.cvl->classes->w_flags = 1;
            locate_args.cvl->act_parms = act_parms; 
  
          /* backup the original locate properties */

            orig_props = cvl->attributes.obj_attr.properties;
            locate_args.cvl->attributes.obj_attr.properties |= 
              LC_LC_ONLY | LC_DP_ONLY;
            
            orig_owner_action = cvl->attributes.obj_attr.owner_action;
            locate_args.cvl->attributes.obj_attr.owner_action = 
                           LC_NON_GEOM_MOD | LC_REF_HEADER | LC_REF_OBJECTS |
                           LC_ASSOCIATIVE | LC_EXTERN_CONSTRAINED | LC_HANDLES;

            is_skew = (*properties & GRIS_SKEW ? 1 : 0);
            
	    if (cvl->attributes.type == GR_pt_loc)
	    {
		pt1 = pt2 = &cvl->attributes.acc_point[0];
	    }
	    else if (cvl->attributes.type == GR_bl_loc)
	    {
		pt1 = cvl->attributes.acc_line.point1;
		pt2 = cvl->attributes.acc_line.point2;
	    }
/****
            This part of the code is commented as in case of PDD/CVE
	    elements in view is unable to locate the iso view.
	      ---  Satya -- 30th August 1994  --  TR# 119420391.

	    else if(cvl->attributes.type == GR_rp_loc ||
                    cvl->attributes.type == GR_cv_loc)
            {

              if(cvl->attributes.type == GR_rp_loc )
               {
                  MArpextents(&msg1,&cvl->attributes.acc_rt_prism,
                              world_range, &world_range[3]);
               }
              else
               {
                  MAcpextents(&msg1,&cvl->attributes.acc_cv_prism,
                              world_range, &world_range[3]);
               }
               pt1 = &world_range[0];
               pt2 = &world_range[3];
              }
*******/
            else
	    {
		pt1 = pt2 = NULL;
	    }

	    OMmsg = GRrefpass(&msg1,
		&cvl->module.md_env.matrix_type,
		cvl->module.md_env.matrix,
		&local_cvl.module,
		&pass_msg,&is_skew,vw_origin,
		vw_matrix,pt1,pt2,NULL,vw_volume,
		master_to_ref,NULL,
		&cvl->attributes.acc_tolerance,
		objid,osnum);


    	    cvl->msg = local_cvl.msg;
            /* store the original values back */

            cvl->classes->p_classes = p_classes;
            cvl->classes->w_count = w_count;
            cvl->classes->w_flags = w_flags;
            cvl->act_parms = orig_act_parms;

            cvl->attributes.obj_attr.owner_action = orig_owner_action;
            cvl->attributes.obj_attr.properties = orig_props;
       	}
    }
    else				/* make message failed		*/
    {
	*msg = MSFAIL;
    }
    return(GRref_objects_found);
}


end implementation GRreffile;
