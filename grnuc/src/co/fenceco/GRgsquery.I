/* #######################    APOGEE COMPILED   ######################## */


/*\
Name
   GRgsquery_all

Description
   This method will pass the locate message to all graphics objects 
   in the rtree.

   *msg              IGRlong              Return code
   *loc_env          struct GRmd_env      The environment for a locate
   *attributes       struct GRlc_locate   The attributes describing the
                                          criteria that the object must
                                          pass.
   *classinfo        struct GRlc_classes  The classes to be located
   layers[]          IGRint               The layers to search.
   *button           struct EX_button     A button 

Notes
   If layers are NULL then elements on all layers will be accepted.

Return Values
   MSSUCC  -- successful completion
   MSFAIL  -- failure

History
   Gray Winn   07/15/87    Creation Date
   scw         07/10/92    ansi conversion
\*/

class implementation Root;

#include "coimport.h"
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
#include "lcdef.h"
#include "lc.h"
#include "OMindex.h"
#include "OMminimum.h"
#include "dpstruct.h"

from module import GRmod_passon;

#argsused
IGRint GRgsquery_all( msg, loc_env, attributes, classinfo, layers, button,
                             action_handler, action_args)

IGRlong               *msg;
struct GRmd_env       *loc_env;
struct GRlc_locate    *attributes;
struct GRlc_classes   *classinfo;
IGRint                 layers[];
struct EX_button      *button;
IGRint                 (*action_handler)();
IGRchar               *action_args;
{
IGRlong             om_msg;
IGRlong             ret_msg;
IGRint              i;
IGRint              begin = 0;
IGRint              fin = 0;
IGRint              size;
IGRint              all_layers[DP_NUM_OF_LEVELS/32 + 1];
DB_3D_DBL_BOX       dbl_range;
OM_S_KEY_DESC       rtree_key;
DB_3D_DBL_BOX       object_range;
OM_S_KEY_DESC       key;
OM_S_MESSAGE        pass_message;
OM_S_MESSAGE        loc_message;
struct GRlc_cvl     cvl;

struct lockludge
{
    struct GRlc_cvl *cvl;
    OM_p_KEY_DESC    range_key;
} loc_kludge;

struct passkludge
{
    OM_p_MESSAGE    msg;
    OM_p_KEY_DESC   p_select_key;
    char          *p_criteria;
    OM_p_KEY_DESC   p_target_key;
    int             (*user_compare)();
    int            *ret;          
} pass_kludge;

    /*
     *  since the rtree will automatically make any conversions 
     *  necessary make the required input to 3D_DBL.
     */

    rtree_key.type = KEY_3D_DBL;
    rtree_key.key.p_3ddbl = &dbl_range;
    key.type = KEY_3D_DBL;
    key.key.p_3ddbl = &object_range;

    cvl.msg = ret_msg;
    cvl.module = *loc_env;  
    cvl.button = *button;
    cvl.action_handler = action_handler; 
    cvl.act_parms = action_args;
    cvl.attributes.type = GR_crit_loc;
    cvl.attributes.obj_attr = *attributes;
    cvl.attributes.acc_tolerance = 0;
    cvl.locate_args = NULL;
    cvl.prism_attr = NULL;


    if(classinfo == NULL)
    {
        cvl.classes = NULL;
    }else
    {
        cvl.classes = classinfo->eligible_classes;
    }
    
    /* 
     *  Form the range tree box.
     */

    rtree_key.key.p_3ddbl->xmin = GRDGNLIMITS_MIN_D;
    rtree_key.key.p_3ddbl->ymin = GRDGNLIMITS_MIN_D;
    rtree_key.key.p_3ddbl->zmin = GRDGNLIMITS_MIN_D;
    rtree_key.key.p_3ddbl->xmax = GRDGNLIMITS_MAX_D;
    rtree_key.key.p_3ddbl->ymax = GRDGNLIMITS_MAX_D;
    rtree_key.key.p_3ddbl->zmax = GRDGNLIMITS_MAX_D;

    if (layers == NULL)
    {
        for (i=0; i < DP_NUM_OF_LEVELS; i++)
        {
            all_layers[i/32] |= (1<<(i % 32));
        }
        cvl.levels = all_layers;
    }else
    {
        cvl.levels = layers;
    }
    LClayer (cvl.levels, loc_env->md_id.objid, loc_env->md_id.osnum);

    /*
     *  Build the locate message
     */

    loc_kludge.cvl = &cvl;
    loc_kludge.range_key = &key;
    size = sizeof (struct lockludge);
    om_msg = om$make_message (
                classname="GRgraphics",
                methodname="GRlocate",
                size=size,
                p_arglist=&loc_kludge,
                p_msg=&loc_message);
    
    /*
     *  Build the pass message
     */

    pass_kludge.msg = &loc_message;
    pass_kludge.p_select_key = &rtree_key;
    pass_kludge.p_criteria = NULL;
    pass_kludge.p_target_key = &key;
    pass_kludge.user_compare = NULL;
    pass_kludge.ret = (IGRint *)&ret_msg;

    size = sizeof (struct passkludge);

    om_msg = om$make_message (
                classname="GRrtree",
                methodname="pass",
                size=size,
                p_arglist=&pass_kludge,
                p_msg=&pass_message);

    /*
     *  Now send these 2 embedded messages to module
     */

    om_msg = om$send (msg = message module.GRmod_passon ( &ret_msg, 
                &pass_message, "module.primary", &begin, &fin),
                senderid = NULL_OBJID, 
                targetid = loc_env->md_id.objid,
                targetos = loc_env->md_id.osnum);

    if (!(1&om_msg))
    {
        return (0);
    }
    return (1);
}
end implementation Root;

