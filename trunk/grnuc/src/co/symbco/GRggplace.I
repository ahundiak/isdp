/* #######################    APOGEE COMPILED   ######################## */
/*
Name
        GRggplace

Description
        This method is used to place a graphic group.

        IGRlong           *msg           return code 
        IGRint            num_origins    The number of origins (i.e. graphic 
                                         group to be placed).
        IGRpoint          origins[]      The origins of the graphic group
        IGRdouble         *angle         The angle (in radians)
        IGRdouble         scale[]        An array of x,y,z scales
        IGRmatrix         rot_matrix     Matrix defining the way the graphic
                                         group is viewed. (View rotation)
        IGRchar           name[]         The name of the graphic group
        unsigned short    properties     The properties of the new graphic group
        struct IGRdisplay *display       ptr to display attributes for comp.
        IGRchar           *class_attr    Class specifiec attributes
        IGRshort          level          The level of the graphic group comp.
        struct GRmd_env   *symbol_env    Original symbol environment
        struct GRmd_env   *target_env    Environment to construct objects in
        IGRchar           *classname     The class name of the graphic group
        struct GRid       *sdh_id        The symbol definition header
        struct GRid       gg_id[]        The new graphic group id's

Return Values
        MSSUCC  -- successful completion
        MSFAIL  -- failure

History
        Gray Winn   03/31/88    creation date
        mrm         01/13/88    add components to the active owner
        dhm         11/20/91    Get the active level if level is NULL
        dhm         12/16/91    Fixed memory fault problem.
        scw         07/08/92    ANSI conversion
*/

class implementation Root;

#include "coimport.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "gr.h"
#include "igr.h"
#include "igrdp.h"
#include "godef.h"
#include "go.h"
#include "msdef.h"
#include "grsymdef.h"
#include "grsym.h"
#include "vardef.h"
#include "var.h" 
#include "ex.h"
#include "grdpbdef.h"
#include "grdpb.h"
#include "grdpbmacros.h"

from GRgraphics import GRconstruct, GRdelete;
from GRowner import GRadd_to_active_owner;
from GRsmdfhdr import GRcp_sd_to_ams;

#argsused
IGRint GRggplace (msg, num_origins, origins, angle, scale, rot_matrix,
                  name, properties, display, class_attr, level, 
                  symbol_env, target_env, classname, sdh_id, gg_id)

IGRlong           *msg;
IGRint            num_origins;
IGRpoint          origins[];
IGRdouble         *angle;
IGRdouble         scale[];
IGRdouble         rot_matrix[];
IGRchar           name[];
unsigned short    properties;
struct IGRdisplay *display;
IGRchar           *class_attr;
IGRshort          level;
struct GRmd_env   *symbol_env;
struct GRmd_env   *target_env;
IGRchar           classname[];
struct GRid       *sdh_id;
struct GRid       gg_id[];
{
    IGRlong                    sts;
    IGRint                     i;
    IGRint                     constructed;
    IGRpoint                   temp_origin;
    IGRmatrix                  place_matrix;
    struct GRvg_construct      konst;
    struct IGRaltdisplay       alt_display, *p_alt_display;

    *msg = MSSUCC;
    constructed = 0;

    konst.msg = msg;
    konst.newflag = 0;
    konst.name = name;
    konst.properties = properties;
    konst.env_info = target_env;
    konst.geometry = NULL;
    konst.class_attr = NULL;
    konst.display = display;

    /* TR 91N3684
     * Get the active level as the default.   dhm  11/20/91
     */

    if (!level)
    {
      gr$get_active_level( buffer = &konst.level );
    }
    else
    {
      konst.level = level;
    }

    /*
     *  Call a routine to calculate the placement matrix based on the
     *  active angle, active scale, world to view port rotation, 
     *  placement origin.
     */

    temp_origin[0] = 0;
    temp_origin[1] = 0;
    temp_origin[2] = 0;
    sts = GRsmplmat (msg, angle, scale, temp_origin, rot_matrix, place_matrix);

    if (sts & *msg & 1)
    {
        for (i = 0; (i < num_origins) && (sts & *msg & 1); ++i)
        {      
            /*
             *  Construct the graphic group.
             */
             
            gg_id[i].osnum = target_env->md_id.osnum;
            sts = om$construct (classname = classname,
                                osnum = target_env->md_id.osnum,
                                msg = message GRgraphics.GRconstruct (&konst),
                                p_objid = &gg_id[i].objid);
            if (sts & *msg & 1)
            {
                constructed++;

                /*
                 *  Copy the active symbol definition from the local
                 *  cell library to the active module space. The 
                 *  objects should be transformed by the placement
                 *  matrix.  The objects will be added to the 
                 *  appropriate index objects.
                 */

                place_matrix[3] = origins[i][0];
                place_matrix[7] = origins[i][1];
                place_matrix[11] = origins[i][2];

                /*  Fixed memory fault problem.  dhm   */

                if (display)
                {
                  alt_display.color = &display->color;
                  alt_display.weight = &display->weight;
                  alt_display.style = &display->style;

                  p_alt_display = &alt_display;
                }
                else
                  p_alt_display = NULL;

                sts = om$send (msg = message GRsmdfhdr.GRcp_sd_to_ams
                                    (msg, place_matrix, p_alt_display,
                                     &gg_id[i], symbol_env, target_env),
                               senderid = NULL_OBJID,
                               targetid = sdh_id->objid,
                               targetos = sdh_id->osnum);

                if (sts & *msg & 1)
                {
                    /*
                     *  add the graphic group components to the active owner
                     */

                    sts = om$send (msg = message GRowner.GRadd_to_active_owner
                                        (msg, target_env),
                                   senderid = NULL_OBJID,
                                   targetid = gg_id[i].objid,
                                   targetos = gg_id[i].osnum);
                }
            }
        }
    }

    if ((!(sts & *msg & 1)) && constructed)
    {
        for (i = 0; i < constructed; ++i)
        {
            om$send (msg = message GRgraphics.GRdelete (msg, target_env),
                     senderid = NULL_OBJID,
                     targetid = gg_id[i].objid,
                     targetos = gg_id[i].osnum);
        }
    } 
    return (sts);
}
end implementation Root;
