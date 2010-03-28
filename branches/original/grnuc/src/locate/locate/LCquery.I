/*
Name
        LCquery

Description
	This function is the one called by the lc$query macro.  It
	provides an interface to the Rtree during a locate and an update
	operation.

Notes
	The make message calls are necessary because the method on
	the module requires a pointer to a message and not a message 
	structure.

	The class mask passed in through the classptr is passed to the
	graphics objects but currently is not supported.  The classmask
	in the GRlc_locate structure is currently supported.  There is 
	expected to be a window of time when both are supported and then
	the name field in the GRlc_locate structure be removed.

History
	rc      07/20/87    Started documentation.
        mrm     10/18/89    Check for OM_W_REJECTED_METHOD for update, 
                            condensed the make_messages and message sends
	DLB	06/23/91    Got sick of the OM-E-AMBIGUOUS-CHANNAME warnings
			    in GRmod_passon so I tacked the "module." to the
			    front of the primary channel string.  This BLASTED
			    bug has been in this code for over 3 years!!!
			    Oh what a tough one to fix! 
        scw     07/13/92    Ansi conversion
        mrm     03/15/93    Filter out OM_E_NOSUCHCLASS for locate cases
        spr     06/15/93    Added GR_dlist_upd_loc for display lists and
                            sending of display_pass or skew_display_pass
*/

class implementation Root;

#include "grimport.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "igr.h"
#include "gr.h"
#include "exdef.h"
#include "ex.h"
#include "igrdp.h"
#include "godef.h"
#include "go.h"
#include "griodef.h"
#include "grio.h"
#include "dp.h"
#include "dpdef.h"
#include "dpmacros.h"
#include "lcdef.h"
#include "lc.h"
#include "OMindex.h"
#include "OMminimum.h"
#include "OMerrordef.h"
#include "dpstruct.h"
#include "lcpriv.h"

from module import GRmod_passon;
from GRgraphics import GRdisyourself, GRlocate;

int LCquery (rc, mod, locate_type, loc_parms, action_handler, 
             act_parms, classptr, levels, locate_args)

IGRlong               *rc;               /* return code               */
struct GRmd_env       *mod;              /* identity of the module-   */
                                         /* also defines the          */
                                         /* relationship between the  */
                                         /* module  and world coord.  */
enum GRlocate_types   *locate_type;      /* type of locate to perform */
IGRchar               *loc_parms;        /* parameters for loc oper   */
IGRint               (*action_handler)();/* pointer to function       */
IGRchar               *act_parms;        /* parameters for act oper   */
GRlc_classptrs         classptr;
IGRint                *levels;
IGRchar               *locate_args;
{
    IGRint              is_ortho = 1;
    IGRint        	how_big;
    IGRint         	begin = 0;
    IGRint         	fin = 0;
    IGRint            	level[32];
    IGRint        	which_error;
    IGRlong             retb1;
    IGRlong             sts;
    IGRlong        	msg;
    IGRvector           vec1, vec2;
    struct GRid		window;
    struct GRlc_cp_loc  *cp_params;
    struct GRlc_rp_loc  *rp_params;
    struct GRlc_pt_loc  *pt_params;
    struct GRlc_bl_loc  *bl_params;
    struct GRlc_upd_loc *upd_params;
    struct GRlc_cvl     cvl;          /* locate communication vector list */
    struct LCpasskludge pass_kludge;
    struct LCskewkludge skew_kludge;
    struct LClockludge  loc_kludge;
    struct LCupdkludge  upd_kludge;
    SKEW_KEY_3D_DBL	skew_range;
    OM_S_SKEW_DESC	skew_key;
    DB_3D_DBL_BOX       dbl_range, object_range;
    OM_S_KEY_DESC       rtree_key, key;
    OM_S_MESSAGE        pass_message, obj_message;


    /*
     *  since the rtree will automatically make any conversions 
     *  necessary make the required input to 3D_DBL.
     */

    rtree_key.type = KEY_3D_DBL;
    rtree_key.key.p_3ddbl = &dbl_range;

    key.type = KEY_3D_DBL;
    key.key.p_3ddbl = &object_range;

    /*
     *	The locate type can be locate or update.
     */
 
    if ((*locate_type == GR_upd_loc) ||
        (*locate_type == GR_dlist_upd_loc) )
    {
        upd_params = (struct GRlc_upd_loc *)loc_parms;

        /*
         *  If the view is orthogonal then copy the range.
         */

        if (upd_params->is_ortho)
	{
	    memcpy((char *)rtree_key.key.p_3ddbl,
                   (char *)upd_params->upd_range,
                   sizeof (DB_3D_DBL_BOX));
	}
	else
	{
            /*
             *  Otherwise the view is rotated in some way, so do a skew scan.
             *  This is necessary for speed of search.
             */

	    is_ortho = 0;
	    skew_key.type = KEY_3D_DBL;
	    skew_key.key.p_skew_3ddbl = &skew_range;
	    MAunitvc(rc, upd_params->view_vector, vec2);

	    skew_range.sx = vec2[0];
	    skew_range.sy = vec2[1];
	    skew_range.sz = vec2[2];

            LC_fill_skew (&skew_range, upd_params->upd_range,
                           upd_params->upd_range2);
	}

        /* format the update message */

        how_big = sizeof (struct LCupdkludge);

        upd_kludge.msg		= &upd_params->msg;
	upd_kludge.mx_type 	= &mod->md_env.matrix_type;
        upd_kludge.mat 		= mod->md_env.matrix;
	upd_kludge.mode 	= &upd_params->mode;
	upd_kludge.alt_symb 	= upd_params->alt_symb;
	upd_kludge.sp_info	= upd_params->sp_info;
	upd_kludge.range_key	= &key;

        om$make_message (classname = "GRgraphics",
	                 methodname = "GRdisyourself",
			 size = how_big,
			 p_arglist = &upd_kludge,
			 p_msg = &obj_message);
    }
    else 
    {
        switch (*locate_type)
        {
            case GR_rp_loc:
                rp_params = (struct GRlc_rp_loc *) loc_parms;
                cvl.attributes.obj_attr = rp_params->obj_attr;
                cvl.attributes.acc_rt_prism = rp_params->rt_prism;
                cvl.button = rp_params->datapoint;
                cvl.prism_attr = rp_params->prism_attr;
	    	window.objid = rp_params->datapoint.objid;
    	 	window.osnum = rp_params->datapoint.osnum;
                cvl.attributes.acc_tolerance = rp_params->tolerance ;
                cvl.classes = (classptr) ? classptr->eligible_classes : NULL;
		if (rp_params->is_ortho)
		{
   	            memcpy((char *)rtree_key.key.p_3ddbl,
                           (char *)rp_params->upd_range,
                           sizeof (DB_3D_DBL_BOX));
		}
		else
		{
		    is_ortho = 0;
		    skew_key.type = KEY_3D_DBL;
		    skew_key.key.p_skew_3ddbl = &skew_range;

		    MAunitvc(rc, rp_params->view_vector, vec2);

		    skew_range.sx = vec2[0];
		    skew_range.sy = vec2[1];
		    skew_range.sz = vec2[2];

                    LC_fill_skew (&skew_range, rp_params->upd_range,
                                  rp_params->skew_range);

		}
		break;

            case GR_cv_loc:
                cp_params = (struct GRlc_cp_loc *) loc_parms;
                cvl.attributes.obj_attr = cp_params->obj_attr;
                cvl.attributes.acc_cv_prism = cp_params->cv_prism;
                cvl.button = cp_params->datapoint;
                cvl.prism_attr = cp_params->prism_attr;
                window.objid = cp_params->datapoint.objid;
                window.osnum = cp_params->datapoint.osnum;
                cvl.attributes.acc_tolerance = cp_params->tolerance ;
                cvl.classes = (classptr) ? classptr->eligible_classes : NULL;

                if (cp_params->is_ortho)
                {
                   memcpy((char *)rtree_key.key.p_3ddbl, 
                          (char *)cp_params->upd_range,
                          sizeof(DB_3D_DBL_BOX));
                }
                else
                {
                    is_ortho = 0;
                    skew_key.type = KEY_3D_DBL;
                    skew_key.key.p_skew_3ddbl = &skew_range;

                    MAunitvc(rc, cp_params->view_vector, vec2);

                    skew_range.sx = vec2[0];
                    skew_range.sy = vec2[1];
                    skew_range.sz = vec2[2];

                    LC_fill_skew (&skew_range, cp_params->upd_range,
                                  cp_params->skew_range);
                }
                break;

            case GR_bl_loc:
                bl_params = (struct GRlc_bl_loc *) loc_parms;
                cvl.attributes.acc_point[0] = bl_params->datapoint.x;
                cvl.attributes.acc_point[1] = bl_params->datapoint.y;
                cvl.attributes.acc_point[2] = bl_params->datapoint.z;
                cvl.button = bl_params->datapoint;
                cvl.attributes.obj_attr = bl_params->obj_attr;
	    	window.objid = bl_params->datapoint.objid;
    	 	window.osnum = bl_params->datapoint.osnum;
                cvl.attributes.acc_line = bl_params->boreline;
                cvl.attributes.acc_tolerance = bl_params->tolerance ;
                cvl.classes = (classptr) ? classptr->eligible_classes : NULL;
		if (bl_params->is_ortho)
		{
	            memcpy((char *)rtree_key.key.p_3ddbl,
                           (char *)bl_params->upd_range,
                           sizeof(DB_3D_DBL_BOX));
		}
		else
		{
		    is_ortho = 0;
		    skew_key.type = KEY_3D_DBL;
		    skew_key.key.p_skew_3ddbl = &skew_range;

		    vec1[0] = bl_params->boreline.point1[0] - 
				bl_params->boreline.point2[0];

		    vec1[1] = bl_params->boreline.point1[1] - 
				bl_params->boreline.point2[1];

		    vec1[2] = bl_params->boreline.point1[2] - 
				bl_params->boreline.point2[2];
		    MAunitvc(rc, vec1, vec2);

		    skew_range.sx = vec2[0];
		    skew_range.sy = vec2[1];
		    skew_range.sz = vec2[2];

                    LC_fill_skew (&skew_range, bl_params->upd_range,
                                  bl_params->skew_range);
		}
		break;

            case GR_pt_loc :
                pt_params = (struct GRlc_pt_loc *) loc_parms;
                cvl.attributes.acc_point[0] = pt_params->datapoint.x;
                cvl.attributes.acc_point[1] = pt_params->datapoint.y;
                cvl.button = pt_params->datapoint;
	    	window.objid = pt_params->datapoint.objid;
    	 	window.osnum = pt_params->datapoint.osnum;
                cvl.attributes.acc_point[2] = pt_params->datapoint.z;
                cvl.attributes.acc_tolerance = pt_params->tolerance ;
                cvl.attributes.obj_attr = pt_params->obj_attr;
                cvl.classes = (classptr) ? classptr->eligible_classes : NULL;
                memcpy((char *)rtree_key.key.p_3ddbl,
                       (char *)pt_params->upd_range,
                       sizeof(DB_3D_DBL_BOX));
                break;
       
        }

        /*
         *  If no levels are specified then get the active levels from the
         *  window.
         */

        if (!levels)
        {

            struct var_list list[2];

            list[0].var = LEVELS;
            list[0].var_ptr = (char *)level;
            list[0].num_bytes = sizeof(IGRint)*32;
            list[0].bytes_returned= &retb1;
            list[1].var = END_PARAM;
            list[1].var_ptr = NULL;
            list[1].num_bytes = 0;
            list[1].bytes_returned = NULL;

	    
            cvl.levels = level;
/*            *rc = GRwnparam (rc, &inq_set, &window, &which_error,
                             LEVELS, level, sizeof (IGRint) * 32, &retb1,
                             END_PARAM, NULL, 0, NULL); */
              *rc = dp$inq_set_gragad( msg = rc,
                              osnum = window.osnum,
                              gragad_objid = window.objid,
                              which_error = &which_error,
                              var_list = list );

            if (!(*rc & 1))
            {
                *rc = 0; 
                return (0);
            }
        }
        else 
        {
            cvl.levels = levels;
        }

        LClayer (cvl.levels, mod->md_id.objid, mod->md_id.osnum);

        /* format the locate message */

        cvl.attributes.type = *locate_type ;
        cvl.action_handler = action_handler; 

        cvl.msg = sts;
        cvl.module = *mod;  
        cvl.locate_args = (struct LC_action_args *)locate_args;
        cvl.act_parms = act_parms;

        loc_kludge.cvl = &cvl;
        loc_kludge.range_key = &key;

	how_big = sizeof (struct LClockludge);

        om$make_message (classname = "GRgraphics",
                         methodname = "GRlocate",
                         size = how_big,
                         p_arglist = &loc_kludge,
                         p_msg = &obj_message);
    }

    /* format the rtree pass message */

    if (is_ortho)
    {
        pass_kludge.msg = &obj_message;
        pass_kludge.p_select_key = &rtree_key;
        pass_kludge.p_criteria = NULL;
        pass_kludge.p_target_key = &key;
        pass_kludge.user_compare = NULL;
        pass_kludge.ret = (IGRint *)&sts;

        how_big = sizeof (struct LCpasskludge);

        om$make_message (classname = "GRrtree",
                         methodname = (*locate_type == GR_dlist_upd_loc) ? "display_pass" : "pass",
                         size = how_big,
                         p_arglist = &pass_kludge,
                         p_msg = &pass_message);
    }
    else
    {
        skew_kludge.msg = &obj_message;
        skew_kludge.p_key = &skew_key;
        skew_kludge.p_criteria = NULL;
        skew_kludge.p_target_key = &key;
        skew_kludge.user_compare = NULL;
        skew_kludge.ret = (IGRint *)&sts;

        how_big = sizeof (struct LCskewkludge);

        om$make_message (classname = "GRrtree",
                         methodname = (*locate_type == GR_dlist_upd_loc) ? "skew_display_pass" : "skew_pass",
                         size = how_big,
                         p_arglist = &skew_kludge,
                         p_msg = &pass_message);
    }       

    /* now send these 2 embedded messages to module */

    /*Added module. to the front of primary string.*/
    sts = om$send (msg = message module.GRmod_passon
                        (&msg, &pass_message, "module.primary", &begin, &fin),
                   senderid = NULL_OBJID, 
                   targetid = mod->md_id.objid,
                   targetos = mod->md_id.osnum);
    if (!(sts & 1))
    {
        if ( ((*locate_type == GR_upd_loc) || (*locate_type == GR_dlist_upd_loc)) &&
            ((sts == OM_W_REJECTED_METHOD) || (sts == OM_W_UNKNOWN_MSG)))
        {
            return (1);
        }
        else if ( (*locate_type != GR_upd_loc) &&
                  (*locate_type != GR_dlist_upd_loc) &&
                  (sts == OM_E_NOSUCHCLASS) )
        {
            //  This might get hit in cases where an application object was
            //  the last thing hit during the rtree pass.  Don't let this
            //  filter back as a failure.  TR119301868.

            return(1);
        }
        else
        {
#ifdef DEBUG
            om$report_error (sts = sts);
#endif
	    *rc = sts;
            return (0);
        }
    }
    return (1);
}
end implementation Root;
