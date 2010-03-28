/******************************************************************************

Method:   

    change

Description:    

    The change method changes the non geometric attributes of the elements
    on the provided chanselect according to the active COdpb instance
    structure or the dpb if there is no active structure.

History:    jay wallingford     04/10/89    creation date
            dhm                 07/09/92    ANSI conversion.

Bugs:       There are no known bugs.

Notes:

******************************************************************************/

class implementation COdpb;

#include <coimport.h>
#include <gotextdef.h>
#include <igrdp.h>
#include <dp.h>

from GRvg	import GRchglevel, GRchgcolor, GRchgweight, 
                       GRchgstyle, GRchgdp;
from GRtext     import GRchgtextattr;

method change ( IGRint * msg;
                IGRuint mask;
                OM_S_CHANSELECT * chansel )
{
    IGRint                  status = OM_S_SUCCESS;
    IGRlong                 ok = MSSUCC;
    struct GRid             md_id;
    enum GRdpmode           display_mode; 
    struct GRmd_env         path;          /* Work space for gr$pass macro. */
    IGRint                  upd_mask;
    struct COdpb_attr       *p;
    struct COdpb_attr       attr;

    /*
     * Set a pointer to the active attribute structure.
     */
    if (om$dimension_of ( varray = me->Attr ) && (me->Active != -1)) 
    {
        p = &me->Attr[me->Active];
    }
    else 
    {
        status = om$send ( msg = message COdpb.get_dpb 
                                            ( msg,
                                              mask,
                                              (p = &attr) ),
                           targetid = my_id );
        _err_ck2(status, *msg);
    }

    /*
     * Chanselect must be initialized
     */
    if ( !chansel )
    {
        *msg = MSFAIL;
        goto quit;
    }

    ex$get_cur_mod( id = &md_id.objid, 
                    osnum = &md_id.osnum );

    /*
     * Erase the located object(s) if the
     * change is anything other than a color.
     */

    if ( (mask != CO_color) )
    {
        display_mode = GRbe;
        status = gr$gsdisplay ( msg = msg, 
                                dpmode = display_mode,
                                display_id = &md_id,
                                p_chanselect = chansel);

        _err_ck2(status,*msg);
    }

    /* 
     * Change the located object(s) symbology according to the mask.
     */
    if ( mask == CO_disp )
    {
        status = gr$gspass (msg = msg,
                            pass_msg = message GRvg.GRchgdp( &ok, 
                                                             &p->dpb_Display),
                            path = NULL,
                            p_chanselect = chansel);

        _err_ck2(status,*msg);
    }
    else 
    {
        if ( mask & CO_level )
        {
            status = gr$gspass (msg = msg,
                                pass_msg = message GRvg.GRchglevel( &ok, 
                                                                    &p->Level),
                                path = NULL,
                                p_chanselect = chansel);

            _err_ck2(status,*msg);
        }
        if ( mask & CO_color ) 
        {
            status = gr$gspass (msg = msg,
                                pass_msg = message GRvg.GRchgcolor( &ok, 
                                                                    0,
                                                                    &p->dpb_Display.color),
                                path = NULL,
                                p_chanselect = chansel);
    
            _err_ck2(status,*msg);
        }

        if ( mask & CO_weight ) 
        {
            status = gr$gspass (msg = msg,
                                pass_msg = message GRvg.GRchgweight( &ok, 
                                                                     &p->dpb_Display.weight),
                                path = NULL,
                                p_chanselect = chansel);

            _err_ck2(status,*msg);  
        }

        if ( mask & CO_style ) 
        {
             status = gr$gspass (msg = msg,
                                 pass_msg = message GRvg.GRchgstyle ( &ok, 
                                                                      &p->dpb_Display.style),
                                 path = NULL,
                                 p_chanselect = chansel);
    
            _err_ck2(status,*msg);
        }
    }

    if ( mask & CO_text )
    {
        upd_mask = 0;

        /* 
         * Change the text's symbology according to mask.
         */
        if ( mask & CO_font )     upd_mask |= GRTEXT_FONT;
        if ( mask & CO_just )     upd_mask |= GRTEXT_JUST;
        if ( mask & CO_height )   upd_mask |= GRTEXT_HEIGHT;
        if ( mask & CO_width )    upd_mask |= GRTEXT_WIDTH;
        if ( mask & CO_charsp )   upd_mask |= GRTEXT_CHAR_SP;
        if ( mask & CO_linesp )   upd_mask |= GRTEXT_LN_SP;

        if (upd_mask) 
        {
             status = gr$gspass (msg = msg,
                                 pass_msg = message GRtext.GRchgtextattr( 
                                            &ok,
                                            &path,
                                            upd_mask,
                                            &p->TextSymb),
                                 path = &path,
                                 p_chanselect = chansel);

            _err_ck2(status,*msg);
        }
    }

    /* 
     * Redisplay the located object(s) so it(they) will reflect any 
     * symbology changes.
     */

     display_mode = GRbd;
     status = gr$gsdisplay ( msg = msg, 
                             dpmode = display_mode,
                             display_id = &md_id,
                             p_chanselect = chansel);
     if ( !(status & *msg & 1) ) *msg = MSFAIL;


quit:

    if ( !(status & *msg & 1) ) *msg = MSFAIL;

    return(status);
}

end implementation COdpb;
