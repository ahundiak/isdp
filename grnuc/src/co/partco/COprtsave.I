/* #######################    APOGEE COMPILED   ######################## */
class implementation COpart;

#include <coimport.h>
#include <exdef.h>
#include <grerr.h>
#include <grdpbdef.h>
#include <grdpb.h>
#include <grdpbmacros.h>
#include <grsymdef.h>
#include <grsym.h>
#include <grsymmacros.h>
#include <toolco.h>
#include "partdef.h"

from IGEgragad  import  DPinrot;
from GRgraphics import  GRconstruct, GRcopy, GRadd_component, GRdelete;

IGRint COpart_save_func ( msg,
                          mod_env,
                          part,
                          origin,
                          cell_name,
                          cell_desc )
    IGRint          * msg;
    struct GRmd_env * mod_env;
    struct GRid     * part;
    struct GRevent  * origin;
    IGRchar         * cell_name;
    IGRchar         * cell_desc;
{
    IGRint                   om_msg = OM_S_SUCCESS;
    struct GRsymbol_lib_file asl_file;
    struct GRmd_env          asl_env, env_info, temp_asl_env;
    struct IGRsymboldef      geometry;
    struct GRnamdesc         namdesc; 
    struct GRvg_construct    const_list;  
    struct GRid              sdh, new_part;
    struct GRobj_env         component;
    IGRint                   count, one = 1, four = 4, i;
    IGRdouble                origin_pt[3], t_origin_pt[3];
    IGRmatrix                symbol_matrix, inv_symbol_matrix;
    IGRint                   matrix_type;
    IGRint                   buffersize, nret;

    *msg = MSSUCC;

    /*
     * Get the module if it is not specified.
     */
    if (!mod_env)
    {
        mod_env = &env_info;
        buffersize = sizeof (struct GRmd_env);
        gr$get_module_env ( msg = msg,
                            sizbuf = &buffersize,
                            buffer = mod_env,
                            nret = &nret );
    }
                            
    /*
     * Get the active cell library.
     */
    om_msg = gr$symget_asl_info ( msg = msg, file = &asl_file );

    if (om_msg & *msg & 1)
    {
        if (*msg != GR_I_NOSL)
        {
            gr$symget_asl_env ( msg = msg, asl_env = &asl_env );

        }
        else
        {
            *msg = GR_E_NO_FILE;
        }
    }

    /*
     * If everything is ok ...
     */
    if (om_msg & *msg & 1)
    {

        /*
         *  Get world to view rotation matrix.
         */
        om_msg = om$send( msg = message IGEgragad.DPinrot ( msg, 
                                                            symbol_matrix ), 
                          senderid = NULL_OBJID,
                          targetid = origin->event.button.objid,
                          targetos = origin->event.button.osnum);

        if ( om_msg & *msg & 1 )
        {
            /*
             *  Add the origin to the symbol creation matrix.
             */
            origin_pt[0] = origin->event.button.x;
            origin_pt[1] = origin->event.button.y;
            origin_pt[2] = origin->event.button.z;

            MAtypemx(msg, symbol_matrix, &matrix_type);
            MAoptsxform (msg, &one, &matrix_type,
                         symbol_matrix, origin_pt, t_origin_pt);

            symbol_matrix[3]  -= t_origin_pt[0];
            symbol_matrix[7]  -= t_origin_pt[1];
            symbol_matrix[11] -= t_origin_pt[2];

            /*
             *  Create the symbol definition header.
             */
            sdh.osnum = asl_env.md_id.osnum;

            om_msg = om$construct ( osnum = asl_env.md_id.osnum,
                                    classname = "GRsmdfhdr",
                                    p_objid = &sdh.objid );

            if ( om_msg & 1 )
            {
                /*
                 * Fill in the construction list arguments.
                 */
                for (i=0; i < 3; ++i)
                {
                    geometry.diag_pt1[i] = 0.0;
                    geometry.diag_pt2[i] = 0.0;
                }

                strcpy ( namdesc.name_symbol, cell_name ); 
                strcpy ( namdesc.desc_symbol, cell_desc ); 
                
                buffersize = sizeof (const_list.level);
                gr$get_active_level ( msg = msg,
                                      sizbuf = &buffersize,
                                      buffer = &const_list.level,
                                      nret = &nret );
                                    
                const_list.msg = msg;
                const_list.env_info = &asl_env;
                const_list.newflag = NULL;
                const_list.properties = GRIS_NEW | GRIS_LOCATABLE | 
                                        GRIS_DISPLAYABLE;
                const_list.geometry = &geometry;
                const_list.display = NULL;
                const_list.class_attr = &namdesc;
                const_list.name = "";

                /*
                 * Construct the symbol definition header.
                 */
                om_msg = om$send ( msg = message GRgraphics.GRconstruct 
                                                         ( &const_list ),
                                   senderid = NULL_OBJID,
                                   targetid = sdh.objid,
                                   targetos = sdh.osnum);

                if ( om_msg & *msg & 1 )
                {
                    /* 
                     *  Build a temporary module environment with a NULL_OBJID in the
                     *  module id to specify not to add the object to any index
                     *  objects.
                     */
                    temp_asl_env = asl_env;
                    temp_asl_env.md_id.objid = NULL_OBJID;

                    MAinvmx  ( msg, &four, symbol_matrix, inv_symbol_matrix);   
                    MAmulmx  ( msg, 
                               &four, &four, &four, 
                               inv_symbol_matrix, 
                               asl_env.md_env.matrix,
                               temp_asl_env.md_env.matrix );
                    MAtypemx ( msg, 
                               temp_asl_env.md_env.matrix, 
                               &temp_asl_env.md_env.matrix_type);

                    /*
                     *  Copy the part from active module space into the 
                     *  active symbol library space.
                     */
                    new_part.osnum = asl_env.md_id.osnum;
                    om_msg = om$send ( msg = message GRgraphics.GRcopy 
                                                                ( msg,
                                                                  mod_env,
                                                                  &temp_asl_env,
                                                                  &new_part.objid ),
                                       senderid = NULL_OBJID,
                                       targetid = part->objid,
                                       targetos = part->osnum );

                    if ( om_msg & *msg & 1 )
                    {
                        /* 
                         * Add the new part to the symbol definition header.
                         */
                        count = 1;
                        component.obj_id = new_part;
                        component.mod_env = temp_asl_env;
                        
                        om_msg = om$send ( msg = message GRowner.GRadd_components 
                                                                ( msg, 
                                                                  &temp_asl_env, 
                                                                  &count,
                                                                  &component, 
                                                                  NULL, NULL ),
                                           senderid = NULL_OBJID,
                                           targetid = sdh.objid,
                                           targetos = sdh.osnum);
            
                        if ( om_msg & *msg & 1 )
                        {
                            /*
                             * Save the symbol library.
                             */
                            gr$symsave_asl (msg = msg);
                        }
                        else
                        {
                            /*
                             * Delete the new part.
                             */
                            om$send ( msg = message GRgraphics.GRdelete ( msg, &asl_env ),
                                      senderid = NULL_OBJID,
                                      targetid = new_part.objid,
                                      targetos = new_part.osnum );
                        }
                    }
                }
            }

            /*
             * If anything failed ...
             */
            if ( !(om_msg & *msg & 1) )
            {
                /*
                 * Delete the part.
                 */
                om$send ( msg = message GRgraphics.GRdelete ( msg, &asl_env ),
                          senderid = NULL_OBJID,
                          targetid = sdh.objid,
                          targetos = sdh.osnum );
            }
        }
    }
    
    return (om_msg);
}

end implementation COpart;
