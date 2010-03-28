/******************************************************************************

Method:   

    extract

Description:    

    The extract method extracts  non geometric attributes from the elements
    on the provided chanselect and loads them into the active COdpb instance
    structure or the dpb if there is no active structure.

History:    

    jay wallingford     04/10/89    creation date
    dhm                 07/09/92    ANSI conversion.

Bugs:       

    There are no known bugs.

Notes:

******************************************************************************/

class implementation COdpb;

#include <coimport.h>
#include <grgsdef.h>
#include <grgsmacros.h>

from GRvg   import GRgetsymb;
from GRtext import GRgettxattr;

method extract ( IGRint * msg;
                 IGRuint mask;
                 OM_S_CHANSELECT * chansel )
{
    IGRint                  status = OM_S_SUCCESS;
    struct GRobj_env        obj_env;
    IGRint                  count;

    /*
     * If a chanselect was provided.
     */
    if ( chansel ) 
    {
        status = gr$gsget_objects( msg = msg,
                                   array = &obj_env,
                                   size = sizeof(struct GRobj_env),
                                   count = &count,
                                   from_obj = 0,
                                   to_obj = 0,
                                   p_chanselect = chansel );
        _err_ck2( status, *msg );

        if ( count != 1 ) 
        {
            *msg = MSFAIL;
            goto quit;
        }

        /*
         * If any symbology changes are to be made get the symb from
         * the object.
         */
        if ( mask & CO_vg ) {

            struct GRsymbology      symb;

            /*
             * Get the symbology from the element.
             */     
            status = om$send ( msg = message GRvg.GRgetsymb( (IGRlong *) msg,
                                     &symb ),
                               targetid = obj_env.obj_id.objid,
                               targetos = obj_env.obj_id.osnum);

            _err_ck2(status,*msg);

            if ( mask & CO_disp ) {
                status = om$send ( msg = message COdpb.put ( msg,
                                                            (IGRuint) CO_disp,
                                                            (IGRchar *) &symb.display_attr,
                                                            CO_disp_struct ),
                                   targetid = my_id );
                _err_ck2(status,*msg);
            }

            if ( mask & CO_level ) {
                status = om$send ( msg = message COdpb.put ( msg,
                                                            (IGRuint) CO_level,
                                                            (IGRchar *) &symb.level,
                                                             CO_default ),
                                   targetid = my_id );
                _err_ck2(status,*msg);
            }
        }

        /*
         * If any text symbology is to be extracted do so.
         */
        if ( mask & CO_text ) 
        {
            struct IGRestx          text_attr;
            struct GRdpb_text_symb  text;

           /*
            * Get the text symbology from the element.
            */
           status = om$send ( msg = message GRtext.GRgettxattr( (IGRlong *) msg,
                                                                &text_attr, 
                                                                NULL, 
                                                                NULL ),
                              targetid = obj_env.obj_id.objid,
                              targetos = obj_env.obj_id.osnum );

           _err_ck2(status,*msg);

           text.Active_font = text_attr.font;
           text.Active_just = text_attr.just;
           text.Active_width = text_attr.width;
           text.Active_height = text_attr.height;
           text.Active_flags = text_attr.flag;
           text.Active_linespac = text_attr.line_spac;
           text.Active_charspac = text_attr.char_spac;

           status = om$send ( msg = message COdpb.put ( msg,
                                                        (IGRuint) mask & CO_text,
                                                        (IGRchar *) &text,
                                                        CO_text_struct ),
                              targetid = my_id );
           _err_ck2(status,*msg);

        }
    }

quit:

    if ( !(status & *msg & 1) ) *msg = MSFAIL;

    return(status);
}

end implementation COdpb;


