/* #######################    APOGEE COMPILED   ######################## */
class implementation COpart;

#include <coimport.h>
#include <OMindex.h>
#include <exdef.h>
#include <grerr.h>
#include <grdpbdef.h>
#include <grdpb.h>
#include <grdpbmacros.h>
#include <grsymdef.h>
#include <grsym.h>
#include <grsymmacros.h>
#include <madef.h>
#include <toolco.h>
#include "partdef.h"

from GRgraphics import GRdelete, GRdisplay;
from GRowner    import GRdrop;

IGRint COpart_place_func ( msg,
                           mod_env,
                           origin_event,
                           scale,
                           angle,
                           level,
                           part,
                           num )
    IGRint             * msg;
    struct GRmd_env    * mod_env;
    struct GRevent     * origin_event;
    struct GRdpb_scale * scale;
    IGRdouble          * angle;
    IGRshort           * level;
    struct GRid        * part;
    IGRint             * num;
{
    IGRint                   om_msg = OM_S_SUCCESS;
    struct GRmd_env          * sdh_env_p;
    struct GRactive_symbol_def asdh;
    struct GRid              cl_id, sdh_id;
    IGRdouble                origin[3];
    IGRmatrix                rot_matrix;
    IGRint                   buffersize, nret;
    struct GRmd_env          mod_env_buffer;
    struct GRdpb_scale       scale_buffer;
    IGRdouble                angle_buffer;
    IGRshort                 level_buffer;
    enum   GRdpmode          mode;

    *msg = MSSUCC;

    /*
     * If the cellib and cell are not specified use the active symbol
     * definition.
     */
    om_msg = gr$symget_active_symbol (msg = msg, act_symbol_def = &asdh);

    if (om_msg & *msg & 1)
    {
        sdh_env_p = &asdh.symbol_env;
        sdh_id.osnum = asdh.symbol_env.md_id.osnum;
        sdh_id.objid = asdh.objid;

        *msg = COpart_get_parts_in_cell ( &sdh_id, NULL, num );

        if (*msg & 1)
        {
            /*
             * Get the module if it is not specified.
             */
            if (!mod_env)
            {
                mod_env = &mod_env_buffer;
                buffersize = sizeof (struct GRmd_env);
                gr$get_module_env ( msg = msg,
                                    sizbuf = &buffersize,
                                    buffer = mod_env,
                                    nret = &nret );
            }
                            
            /*
             *  Get the scale if it is not provided.
             */
            if (!scale)
            {
                scale = &scale_buffer;
                buffersize = sizeof(struct GRdpb_scale);
                gr$get_active_scale ( msg = msg,
                                      sizbuf = &buffersize,
                                      buffer = scale,
                                      nret = &nret );
            }

            /*
             *  Get the angle if it is not provided.
             */
            if (!angle)
            {
                angle = &angle_buffer;
                buffersize = sizeof(IGRdouble);
                gr$get_active_angle ( msg = msg,
                                      sizbuf = &buffersize,
                                      buffer = angle,
                                      nret = &nret );
            }

            /*
             *  Get the level if it is not provided.
             */
            if (!level)
            {
                level = &level_buffer;
                buffersize = sizeof(IGRshort);
                gr$get_active_level ( msg = msg,
                                      sizbuf = &buffersize,
                                      buffer = level,
                                      nret = &nret );
            }
              
            GRget_window_matrix ( msg, 
                                  origin_event->event.button.osnum,
                                  origin_event->event.button.objid, 
                                  rot_matrix, 
                                  NULL );
                              
            origin[0] = origin_event->event.button.x;
            origin[1] = origin_event->event.button.y;
            origin[2] = origin_event->event.button.z;
                
            /*
             *  Place the cell.
             */
            om_msg = gr$sym_cl_place ( msg = msg,
                                       origin = origin,
                                       angle = angle,
                                       scale = scale,
                                       level = *level,
                                       rot_matrix = rot_matrix,
                                       symbol_env = sdh_env_p,
                                       target_env = mod_env,
                                       sdh_id = &sdh_id,
                                       cl_id = &cl_id );
                                                   

            if (om_msg & *msg & 1)
            {
                /*
                 * Get the id's for the new cell's parts.
                 */
                *msg = COpart_get_parts_in_cell ( &cl_id, part, num );

                if (*msg & 1)
                {
                    /*
                     * Display the cell.
                     */
                    mode = GRbd;
                    om$send ( msg = message GRgraphics.GRdisplay( (long *)msg,
                                                                  &mod_env->md_env.matrix_type,
                                                                  mod_env->md_env.matrix,
                                                                  &mode,
                                                                  &mod_env->md_id ),
                              senderid = NULL_OBJID,
                              targetid = cl_id.objid,
                              targetos = cl_id.osnum );

                    /*
                     * Drop the cell.
                     */
                    om_msg = om$send ( msg = message GRowner.GRdrop ( (long *)msg, 
                                                                      mod_env ),
                                       senderid = NULL_OBJID,
                                       targetid = cl_id.objid,
                                       targetos = cl_id.osnum );
                }
            }
        }
    }
    else *msg = CO_E_NO_CELL;
    
    return (om_msg);
}

IGRint COpart_get_parts_in_cell ( cl_id, part, num )
    struct GRid * cl_id;
    struct GRid * part;
    IGRint      * num;
{   
    IGRint      i, count, part_count = 0, msg = MSSUCC;
    struct GRid gr_id;
    OMuword     classid, part_classid;
    OM_S_CHANSELECT comp_chan;
    
    GRget_to_comp_info (&comp_chan, cl_id->osnum, cl_id->objid, &count);
    
    om$get_classid ( classname = "GRpart",
                     p_classid = &part_classid );

    for (i=0; i<count; ++i)
    {
        om$get_objid_at_index ( objid = cl_id->objid,
                                osnum = cl_id->osnum,
                                p_chanselect = &comp_chan,
                                index = i,
                                objidaddr = &gr_id.objid,
                                osnumaddr = &gr_id.osnum );
                                
        om$get_classid ( objid = gr_id.objid,
                         osnum = gr_id.osnum,
                         p_classid = &classid );

        if ( om$is_ancestry_valid ( superclassid = part_classid,
                                    subclassid = classid ) 
                     == OM_S_SUCCESS )
        {
            if (part && (*num > part_count))
            {
                part[part_count] = gr_id;
            }
            
            ++part_count;
        }
    }
    
    if (*num < part_count) msg = MSFAIL;
    
    *num = part_count;

    return (msg);
}

end implementation COpart;
