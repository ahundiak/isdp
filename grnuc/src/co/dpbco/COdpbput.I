/******************************************************************************

Method:   

    put

Description:    

    The put method loads non geometric attibutes into the active COdpb
    structure or the dpb if no structure is active from the provide value.

History:    

    jay wallingford     04/10/89    creation date
    dhm                 07/09/92    ANSI conversion.

Bugs:       

    There are no known bugs.

Notes:

******************************************************************************/

class implementation COdpb;

#include <coimport.h>
#include "dpdls.h"

extern int COdpb_get_font ();
extern int COdpb_get_just ();

/*
 * This variable is set and unset by the co= command. It
 * is a temporary kludge, which should be taken out by 2.0.
 * Talk to Brad Robbins. This is also in the COdpb.put_dpb 
 * method.
 */
extern IGRboolean        COInvisibleColor;

method put ( IGRint * msg;
             IGRuint mask;
             IGRchar * value;
             IGRint type )
{
    IGRint                  status = OM_S_SUCCESS;
    OM_S_OBJID              mod_objid;
    OMuword                 mod_osnum;
    struct COdpb_attr       attr;
    struct COdpb_attr       *p;
    IGRint                  allocated;
    unsigned short	    pattern;

    *msg = MSSUCC;

    allocated = om$dimension_of ( varray = me->Attr );

    /*
     * Set a pointer to the active attribute structure.
     */	
    p = (allocated && (me->Active != -1) ) ? 
        &me->Attr[me->Active] : &attr;

    if ( type == CO_string ) 
    {
        ex$get_cur_mod ( id = &mod_objid,
                         osnum = &mod_osnum );
    }

    if ( mask & CO_vg ) 
    {
        if ( mask & CO_disp ) 
        {
            if ( CO_color & mask )
            {
                IGRushort   color;

                switch (type)
                {
                case CO_disp_struct:
                    color = ((struct IGRdisplay *)value)->color;
                    break;
                case CO_double:
                    color = *((IGRdouble *)value);
                    break;
                case CO_integer:
                    color = *((IGRint *)value);
                    break;
                case CO_string:
                    /*
                     * Set COInvisibleColor to TRUE if keyin is invisible. 
                     * Set COInvisibleColor to FALSE otherwise.
                     */
                    if ( ! strcmp(value,"invisible") )
                    {
                        COInvisibleColor = TRUE;
                        goto quit;
                    }
                    else if ( ! strcmp(value, "visible") )
                    {
                        COInvisibleColor = FALSE;
                        goto quit;
                    }
                    else
                    {
                        /* 
                         * Get the name of active color if one exits.
                         */
                        *msg = ige$get_color_from_name(name = value,
                                                       color = (IGRshort *) &color,
                                                       mod_id = mod_objid,
                                                       mod_osnum = mod_osnum);
                        if ( !(*msg & 1) ) 
                        {
                            *msg = CO_E_INVINP;
                            goto quit;
                        }
                    }
                    break;
                case CO_default:
                    color = *((IGRushort *)value);
                    break;
                default:
                    *msg = MSFAIL;
                    goto quit;
                }

                /*
                 * Change the background color (0) only by string.
                 */
                if ( (color > CO_lo_color && color <= CO_hi_color) ||
                     (color == CO_lo_color && type == CO_string) )
                    p->dpb_Display.color = color;
                else
                    *msg = CO_E_INVINP;
            }

            if ( mask & CO_weight ) 
            {
                IGRuchar    weight;

                switch (type)
                {
                case CO_disp_struct:
                    weight = ((struct IGRdisplay *)value)->weight;
                    break;
                case CO_double:
                    weight = *((IGRdouble *)value);
                    break;
                case CO_integer:
                    weight = *((IGRint *)value);
                    break;
                case CO_default:
                    weight = *((IGRuchar *)value);
                    break;
                default:
                    *msg = MSFAIL;
                    goto quit;
                }

                if ( (IGRint) weight >= CO_lo_weight && (IGRint) weight <= CO_hi_weight )
                    p->dpb_Display.weight = weight;
                else 
                    *msg = CO_E_INVINP;
            }

            if ( mask & CO_style ) 
            {
                IGRuchar    style;

                switch (type)
                {
                case CO_disp_struct:
                    style = ((struct IGRdisplay *)value)->style;
                    break;
                case CO_double:
                    style = *((IGRdouble *)value);
                    break;
                case CO_integer:
                    style =*((IGRint *)value);
                    break;
                case CO_string:
                    *msg = COdpb_get_style( value,
                                            &style,
                                            CO_name_to_attr );
                    if ( !(*msg & 1) )
                    {
                        *msg = CO_E_INVINP;
                        goto quit;
                    }
                    break;
                case CO_default:
                    style = *((IGRuchar *)value);
                    break;
                default:
                    *msg = MSFAIL;
                    goto quit;
                }
            
		DPinq_style( (IGRshort) style, &pattern );
                if ( (IGRint) style >= CO_lo_style && pattern && (IGRint) style < MAX_STYLES )
                    p->dpb_Display.style = style;
                else
                    *msg = CO_E_INVINP;
            }
        }
        else if ( mask & CO_scales ) 
        {
            IGRdouble   scale = 0.0;

            if ( mask & CO_scale )
                mask |= CO_scales;

            if ( mask & CO_xscale )
            {
                switch (type)
                {
                case CO_scale_struct:
                    scale = ((struct GRdpb_scale *)value)->Active_xscale;
                    break;
                case CO_double:
                case CO_default:
                    scale = *((IGRdouble *)value);
                    break;
                case CO_integer:
                    scale = *((IGRint *)value);
                    break;
                default:
                    *msg = MSFAIL;
                    goto quit;
                }

                if ( scale > CO_lo_scale )
                    p->Scale.Active_xscale = scale;
                else
                    *msg = CO_E_INVINP; 
            }

            if ( mask & CO_yscale ) 
            {
                switch (type)
                {
                case CO_scale_struct:
                    scale = ((struct GRdpb_scale *)value)->Active_yscale;
                    break;
                case CO_double:
                case CO_default:
                    scale = *((IGRdouble *)value);
                    break;
                case CO_integer:
                    scale = *((IGRint *)value);
                    break;
                default:
                    *msg = MSFAIL;  
                    goto quit;
                }

                if ( scale > CO_lo_scale )
                    p->Scale.Active_yscale = scale;
                else
                    *msg = CO_E_INVINP; 
            }

            if ( mask & CO_zscale ) 
            {
                switch (type)
                {
                case CO_scale_struct:
                    scale = ((struct GRdpb_scale *)value)->Active_zscale;
                    break;
                case CO_double:
                case CO_default:
                    scale = *((IGRdouble *)value);
                    break;
                case CO_integer:
                    scale = *((IGRint *)value);
                    break;
                default:
                    *msg = MSFAIL;  
                    goto quit;
                }

                if ( scale > CO_lo_scale )
                    p->Scale.Active_zscale = scale;
                else
                    *msg = CO_E_INVINP; 
            }
        }
        else if ( mask & CO_level ) 
        {
            IGRshort    level;

            switch (type)
            {
            case CO_double:
                level = *(IGRdouble *)value;
                break;
            case CO_integer:
                level = *(IGRint *)value;
                break;
            case CO_string:
                /* 
                 * Convert the level number to a name.
                 */
                status = dp$levels_name_to_number(msg = msg,
                                                  number = &level,
                                                  name = value,
                                                  mod_objid = mod_objid,
                                                  osnum = mod_osnum);
                if ( !( *msg & status & 1) )
                {
                    *msg = CO_E_INVINP;
                    goto quit;
                }
                break;
            case CO_default:
                level = *(IGRshort *)value;
                break;
            default:
                *msg = MSFAIL;  
                goto quit;
            }
            
            if ( level >= CO_lo_layer && level <= CO_hi_layer )
                p->Level = level;
            else
                *msg = CO_E_INVINP;
        }
        else if ( mask & CO_angle ) 
        {
            switch (type)
            {
            case CO_double:
            case CO_default:
                p->Angle = *(IGRdouble *)value;
                break;
            default:
                *msg = MSFAIL;
                goto quit;
            }
        }
    }
    else if ( mask & CO_text ) 
    {
        IGRulong font_type;
        
        if (font_type = (mask & (CO_font | CO_frac | CO_symb | CO_ascii)))
        {
            IGRshort   *font_p = NULL;
            IGRshort   *value_p = NULL;
            IGRshort   font;
            IGRchar    font_name[80];
                
            switch (font_type)        
            {
            case CO_font:
                font_p = &(p->TextSymb.Active_font);
                value_p = &(((struct GRdpb_text_symb *)value)->Active_font);
                break;
            case CO_frac:
                font_p = &(p->TextSymb.Active_fraction_font);
                value_p = &(((struct GRdpb_text_symb *)value)->Active_fraction_font);
                break;
            case CO_symb:
                font_p = &(p->TextSymb.Active_symbol_font);
                value_p = &(((struct GRdpb_text_symb *)value)->Active_symbol_font);
                break;
            case CO_ascii:
                font_p = &(p->TextSymb.Active_ascii_font);
                value_p = &(((struct GRdpb_text_symb *)value)->Active_ascii_font);
                break;
            }

            switch (type)
            {
            case CO_default:
                font = *(IGRshort *)value;
                break;
            case CO_integer:
                font = *(IGRint *)value;
                break;
            case CO_double:
                font = *(IGRdouble *)value;
                break;
            case CO_string:
                /*
                 * Search for the font name.
                 */
                *msg = COdpb_get_font(value,
                                      &font, 
                                      font_type,
                                      CO_name_to_attr);
                if ( !(*msg & 1) )
                {
                    *msg = CO_E_INVINP;
                    goto quit;
                }
                break;
            case CO_text_struct:
                font = *value_p;
                break;
            default:
                *msg = MSFAIL;  
                goto quit;
            }

            if ( type != CO_string )
            {
                /*
                 * See if it is a legal font.
                 */
                *msg = COdpb_get_font(font_name,
                                      &font, 
                                      font_type,
                                      CO_attr_to_name);
                if ( !(*msg & 1) )
                {
                    *msg = CO_E_INVINP;
                    goto quit;
                }
            }

            *font_p = font;
        }

        if ( mask & CO_just ) 
        {
            IGRshort    just;

            switch (type)
            {
            case CO_double:
                just = *(IGRdouble *)value;
                break;
            case CO_integer:
                just = *(IGRint *)value;
                break;
            case CO_text_struct:
                just = ((struct GRdpb_text_symb *)value)->Active_just;
                break;
            case CO_string:
                if ( ! COdpb_get_just( value,
                                       &just,
                                       CO_name_to_attr ) )
                {
                    *msg = CO_E_INVINP;
                    goto quit;
                }
                break;
            case CO_default:
                just = *(IGRshort *)value;
                break;
            default:
                *msg = MSFAIL;
                goto quit;
            }

            if ( just >= CO_lo_just && just <= CO_hi_just )
                p->TextSymb.Active_just = just;
            else
                *msg = CO_E_INVINP;
        }

        if ( mask & CO_size ) 
            mask |= CO_height | CO_width;

        if ( mask & CO_height )
        {
            switch (type)
            {
            case CO_double:
            case CO_default:
                p->TextSymb.Active_height = *(IGRdouble *)value;
                break;
            case CO_string:
                {
                IGRchar buffer[80];

                /* 
                 * Convert string to working units.
                 */
                co$epp( msg = msg,
                        string = value,
                        sizebuf = 80,
                        buffer = buffer );

                co$expreval( msg = msg,
                             expression = buffer,
                             unit_type = "UOM_DISTANCE",
                             result = &p->TextSymb.Active_height );
                }
                break;
            case CO_text_struct:
                p->TextSymb.Active_height = ((struct GRdpb_text_symb *)value)->Active_height;
                break;
            default:
                *msg = MSFAIL;
                goto quit;
            }
        }

        if ( mask & CO_width ) 
        {
            switch (type)
            {
            case CO_double:
            case CO_default:
                p->TextSymb.Active_width = *(IGRdouble *)value;
                break;
            case CO_string:
                {
                IGRchar buffer[80];

                /* 
                 * Convert string to working units.
                 */
                co$epp( msg = msg,
                        string = value,
                        sizebuf = 80,
                        buffer = buffer );

                co$expreval( msg = msg,
                             expression = buffer,
                             unit_type = "UOM_DISTANCE",
                             result = &p->TextSymb.Active_width );
                }
                break;
            case CO_text_struct:
                p->TextSymb.Active_width = ((struct GRdpb_text_symb *)value)->Active_width;
                break;
            default:
                *msg = MSFAIL;
                goto quit;
            }
        }

        if ( mask & CO_charsp )
        {
            switch (type)
            {
            case CO_double:
            case CO_default:
                p->TextSymb.Active_charspac = *(IGRdouble *)value;
                break;
            case CO_text_struct:
                p->TextSymb.Active_charspac = ((struct GRdpb_text_symb *)value)->Active_charspac;
                break;
            default:
                *msg = MSFAIL;
            }
        }

        if ( mask & CO_linesp ) 
        {
            switch (type)
            {
            case CO_double:
            case CO_default:
                p->TextSymb.Active_linespac = *(IGRdouble *)value;
                break;
            case CO_text_struct:
                p->TextSymb.Active_linespac = ((struct GRdpb_text_symb *)value)->Active_linespac;
                break;
            default:
                *msg = MSFAIL;
            }
        }
    }

    if (!allocated && (*msg & 1) && ( me->Active != -1)) 
    {
        status = om$send ( msg = message COdpb.put_dpb ( msg,
                                                         mask,
                                                         p ),
                           targetid = my_id );

        _err_ck2(status, *msg);
    }

quit:

    return (status);
}

end implementation COdpb;
