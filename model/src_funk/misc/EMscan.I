/* ###################   APOGEE COMPILED   ################## */
class implementation Root;

#include "EMS.h"
/*
 Abstract
        This utility scans the database of a given module
        and picks up the objects on the R-tree that are within
        a given range and then sends the message provided by
        the caller to the picked up objects. If the class
        of a picked up object does not support the message,
        om return code is ignored and the process is continued.

History
        RC      2/05/87 : Creation date
*/

#include "msdef.h"
#include "OMerrordef.h"
#include "OMmacros.h"
#include "OMindex.h"
# include "OMminimum.h"
# include "igetypedef.h"
# include "igrtypedef.h"
# include "igr.h"
# include "igrdp.h"
# include "dp.h"
# include "godef.h"
# include "gr.h"
# include "go.h"
#include "emserr.h"

from module import GRmod_passon;
from OMindex import pass;

void EMscan (rc,
            search_pt,
            search_tol,
            module_env,
            post_scan_msg)
            
IGRlong         *rc;            /* return code */
IGRpoint         search_pt;     /* world coord. point about which
                                   search is to be made */
IGRdouble       search_tol;     /* search tolerance */
struct GRmd_env *module_env;    /* information of the module
                                   under consideration */
OM_p_MESSAGE    post_scan_msg;  /* the message to be sent to */
                                /* the selected objects */
{

        IGRint          begin_index = 0;
        IGRint          end_index = 0;

        IGRlong         mthd_stat;      /* method return code */
        IGRlong         rtree_mthd_stat;
        IGRlong         OM_stat;        /* om return code */
        
        DB_3D_DBL_BOX   range_box;      /* world coord range in 
                                          which seach is to be conducted */
        OM_S_KEY_DESC   rtree_key;      /* key for rtree search */

        DB_3D_DBL_BOX   object_range;   
        OM_S_KEY_DESC   object_key;     /* key associated with the 
                                         object receiving rtree pass 
                                         message */

        OM_S_MESSAGE    rtree_pass_msg;

/*
        struct rtree_struct
        {
          OM_S_MESSAGE          msg;
          OM_p_KEY_DESC         p_select_key;
          char                  *p_criterion;
          OM_p_KEY_DESC         p_target_key;
          int                   (*user_compare)();
          int                   *ret;
        } rtree_pass_arglist;
*/

        struct OMindex_pass_Msg rtree_pass_arglist;

        *rc = MSSUCC;
        
        /*
         * bulid the range box for rtree search
         */

        rtree_key.type = KEY_3D_DBL;
        rtree_key.key.p_3ddbl = &range_box;
        range_box.xmin = search_pt[0] - search_tol;
        range_box.ymin = search_pt[1] - search_tol;
        range_box.zmin = search_pt[2] - search_tol;
        range_box.xmax = search_pt[0] + search_tol;
        range_box.ymax = search_pt[1] + search_tol;
        range_box.zmax = search_pt[2] + search_tol;

        object_key.type = KEY_3D_DBL;
        object_key.key.p_3ddbl = &object_range;
        
        /*
         * make rtree pass message
         */

        rtree_pass_arglist.msg = post_scan_msg;
        rtree_pass_arglist.p_select_key = &rtree_key;
        rtree_pass_arglist.classlist = NULL;
        rtree_pass_arglist.p_target_key = &object_key;
        rtree_pass_arglist.user_compare = NULL;
        rtree_pass_arglist.ret = (IGRint *)&rtree_mthd_stat;

        OM_stat = om$make_message(classname = "GRrtree",
                                  methodname = "pass",
                                  size = sizeof(rtree_pass_arglist),
                                  p_arglist = &rtree_pass_arglist,
                                  p_msg = &rtree_pass_msg);

        EMomerr_hndlr(OM_stat, wrapup, "EMscan : om$make_message #1" ); 

        /*
         * send a message to the module for 2 level pass to
         * the object
         */

        OM_stat = om$send (msg = message module.GRmod_passon (
                                        &mthd_stat,
                                        &rtree_pass_msg,
                                         "module.primary",
                                        &begin_index,
                                        &end_index),
                            senderid = NULL_OBJID,
                            targetid = module_env->md_id.objid,
                            targetos = module_env->md_id.osnum);

        if (OM_stat == OM_W_UNKNOWN_MSG) OM_stat = OM_S_SUCCESS;
        
        EMomerr_hndlr(OM_stat, wrapup, "EMscan : GRmod_passon" );       
        EMerr_hndlr(!(1 & mthd_stat), *rc, mthd_stat, wrapup);
        
    wrapup:

        return;
  }
        
end implementation Root;
