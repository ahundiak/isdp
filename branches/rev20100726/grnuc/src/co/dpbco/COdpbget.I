/******************************************************************************

Method:   

    get

Description:    

    The get method fetches non geometric attributes from the active COdpb
    structure or the dpb if no structure is active.

History:    

    jay wallingford     04/10/89    creation date
    dhm                 07/09/92    ANSI conversion.
Bugs:       

    There are no known bugs.

Notes:

******************************************************************************/

class implementation COdpb;

#include <coimport.h>

extern int COdpb_get_just ();
extern int COdpb_get_font ();

method get ( IGRint * msg;
             IGRuint mask;
             IGRchar * value;
             IGRint type )
{
    IGRint                  status = OM_S_SUCCESS;
    OM_S_OBJID              mod_objid;
    OMuword                 mod_osnum;
    IGRchar                 *cvt_list[3];	
    IGRchar                 buffer[3][80];
    IGRshort                num_alias=3;
    IGRdouble               cvt_units[2];
    IGRchar                 *cp;
    struct COdpb_attr       *p, *q;
    struct COdpb_attr       attr;
    IGRshort                field_size;

    *msg = MSSUCC;

    /*
     * Set a pointer to the active attribute structure.
     */
    if ( om$dimension_of ( varray = me->Attr ) &&
         (me->Active != -1) ) 
    {
        p = &me->Attr[me->Active];
    }
    else 
    {
        status = om$send ( msg = message COdpb.get_dpb ( msg,
                                                         mask,
                                                         (p = &attr) ),
                           targetid = my_id );
        _err_ck2(status, *msg);
    }

    status = om$send ( msg = message COdpb.get_dpb ( msg,
                                                         mask,
                                                         (q = &attr) ),
                           targetid = my_id );
     _err_ck2(status, *msg);

    if ( type == CO_string | CO_message ) 
    {
        ex$get_cur_mod ( id = &mod_objid,
                         osnum = &mod_osnum );
    }

    if ( mask & CO_vg ) 
    {
        /*
         * Fill value according to the mask and type.
         */
        if ( mask & CO_disp ) 
        {
            if ( mask & CO_color )
            {
                switch (type)
                {
                case CO_disp_struct:
                    ((struct IGRdisplay *)value)->color = p->dpb_Display.color;
                    break;
                case CO_double:
                    *((IGRdouble *)value) = p->dpb_Display.color;
                    break;
                case CO_integer:
                    *((IGRint *)value) = p->dpb_Display.color;
                    break;
                case CO_message:
                case CO_string:
                    /* 
                     * Get the name of active color if one exits.
                     */
                    buffer[0][0] = '\0';
                    *msg = ige$get_name_from_color(color = q->dpb_Display.color,
                                                   name = (IGRchar *) buffer,
                                                   mod_id = mod_objid,
                                                   mod_osnum = mod_osnum);

                    *msg = ( (*msg & 1) || type == CO_message ) ? MSSUCC : MSFAIL;

                    if ( type == CO_message )
                    {
                        /* 
                         * Construct the Active Color (and it's name) message 
                         */
                        ex$message(msgnumb = GR_I_ActCo,
                                   buff = value,
                                   type = "%u%s",
                                   var = `q->dpb_Display.color,buffer`);
                    }
                    else strcpy (value, (IGRchar *) buffer);
                    break;
                case CO_default:
                    *((IGRushort *)value) = p->dpb_Display.color;
                    break;
                default:
                    *msg = MSFAIL;
                    goto quit;
                }
            }

            if ( mask & CO_weight ) 
            {
                switch (type)
                {
                case CO_disp_struct:
                    ((struct IGRdisplay *)value)->weight = p->dpb_Display.weight;
                    break;
                case CO_double:
                    *((IGRdouble *)value) = p->dpb_Display.weight;
                    break;
                case CO_integer:
                    *((IGRint *)value) = p->dpb_Display.weight;
                    break;
                case CO_default:
                    *((IGRuchar *)value) = p->dpb_Display.weight;
                    break;
                case CO_message:
                    ex$message( msgnumb = GR_I_ActWt,
                                buff = value,
                                type = "%u",
                                var = `q->dpb_Display.weight` );
                    break;
                default:
                    *msg = MSFAIL;
                    goto quit;
                }
            }

            if ( mask & CO_style ) 
            {
                switch (type)
                {
                case CO_disp_struct:
                    ((struct IGRdisplay *)value)->style = p->dpb_Display.style;
                    break;
                case CO_double:
                    *((IGRdouble *)value) = p->dpb_Display.style;
                    break;
                case CO_integer:
                    *((IGRint *)value) = p->dpb_Display.style;
                    break;
                case CO_string:
                    *msg = COdpb_get_style( value,
                                            &(p->dpb_Display.style),
                                            CO_attr_to_name );
                    break;
                case CO_message:
                    ex$message( msgnumb = GR_I_ActSt,
                                buff = value,
                                type = "%u",
                                var = `q->dpb_Display.style` );
                    break;
                case CO_default:
                    *((IGRuchar *)value) = p->dpb_Display.style;
                    break;
                default:
                    *msg = MSFAIL;
                    goto quit;
                }
            }
        } 
        else if ( mask & CO_scales ) 
        {
            IGRint      msgnumb = 0;
            IGRdouble   scale = 1.0;

            if ( mask & CO_scale ) 
            {
                if ( type == CO_message ) 
                {
                    /*
                     * Construct the Active Scale message 
                     */
                    ex$message(msgnumb = GR_I_XsYsZs,
                               buff = value,
                               type = "%g%g%g",
                               var = `p->Scale.Active_xscale,
                                      p->Scale.Active_yscale,
                                      p->Scale.Active_zscale`);
                    goto quit;
                }
                else mask |= CO_scales;
            }

            if ( mask & CO_xscale ) 
            {
                switch (type)
                {
                case CO_scale_struct:
                    ((struct GRdpb_scale *)value)->Active_xscale = p->Scale.Active_xscale; 
                    break;
                case CO_double:
                case CO_default:
                    *((IGRdouble *)value) = p->Scale.Active_xscale;
                    break;
                case CO_integer:
                    *((IGRint *)value) = p->Scale.Active_xscale;
                    break;
                case CO_message:
                    msgnumb = GR_I_ActXsc;
                    scale = p->Scale.Active_xscale;
                    break;
                default:
                    *msg = MSFAIL;  
                    goto quit;
                }
            }
    
            if ( mask & CO_yscale ) 
            {
                switch (type)
                {
                case CO_scale_struct:
                    ((struct GRdpb_scale *)value)->Active_yscale = p->Scale.Active_yscale; 
                    break;
                case CO_double:
                case CO_default:
                    *((IGRdouble *)value) = p->Scale.Active_yscale;
                    break;
                case CO_integer:
                    *((IGRint *)value) = p->Scale.Active_yscale;
                    break;
                case CO_message:
                    msgnumb = GR_I_ActYsc;
                    scale = p->Scale.Active_yscale;
                    break;
                default:
                    *msg = MSFAIL;  
                    goto quit;
                }
            }

            if ( mask & CO_zscale ) 
            {
                switch (type)
                {
                case CO_scale_struct:
                    ((struct GRdpb_scale *)value)->Active_yscale = p->Scale.Active_zscale; 
                    break;
                case CO_double:
                case CO_default:
                    *((IGRdouble *)value) = p->Scale.Active_zscale;
                    break;
                case CO_integer:
                    *((IGRint *)value) = p->Scale.Active_zscale;
                    break;
                case CO_message:
                    msgnumb = GR_I_ActZsc;
                    scale = p->Scale.Active_zscale;
                    break;                 
                default:
                    *msg = MSFAIL;  
                    goto quit;
                }
            }

            if ( type == CO_message )
            {
                /* Construct the Active Scale message */
                ex$message(msgnumb = msgnumb,
                           buff = value,
                           type = "%g",
                           var = `scale`);
            }
        }
        else if ( mask & CO_level ) 
        {
            IGRlong sz_name = 80;

            switch (type)
            {
            case CO_double:
                *(IGRdouble *)value = p->Level;
                break;
            case CO_integer:
                *(IGRint *)value = p->Level;
                break;
            case CO_string:
                /* 
                 * Convert the level number to a name.
                 */
                status = dp$levels_number_to_name(msg = msg,
                                                  number = &p->Level,
                                                  size_name_buffer = &sz_name,
                                                  name = value,
                                                  mod_objid = mod_objid,
                                                  osnum = mod_osnum);
                if ( !( *msg & status & 1) ) *msg = MSFAIL;
                break;
            case CO_default:
                *(IGRshort *)value = p->Level;
                break;
            case CO_message:
                /* 
                 * Construct the Active Level message 
                 */
                ex$message(msgnumb = GR_I_ActLy,
                           buff = value,
                           type = "%d",
                           var = `q->Level`);
                break;
            default:
                *msg = MSFAIL;  
                goto quit;
            }
        }
        else if ( mask & CO_angle ) 
        {
            switch (type)
            {

            case CO_double:
            case CO_default:
                *(IGRdouble *)value = p->Angle;
                break;
            case CO_message:
            case CO_string:
                /* 
                 * Convert to working units 
                 */
                field_size = sizeof(IGRchar) * 240;
                status = co$cvt_imp_to_alias(msg = msg,
                                             osnum = mod_osnum,
                                             unit_type = "UOM_ANGLE",

						/* ** TR 90N1899 
					     	field_size = 32,
								** */
						field_size = &field_size,
                                             working_units = &p->Angle,
                                             num_alias = &num_alias,
                                             cvt_list = buffer);
                _err_ck2(status,*msg); 

                if ( type == CO_message )
                {
                    ex$message(msgnumb = GR_I_ActAng, 
                               buff = value,
                               type = "%s", 
                               var = `buffer`);

                }
                else strcpy(value, (IGRchar *) buffer);
                break;
            default:
                *msg = MSFAIL;
                goto quit;
            }
        }
    }
    else if ( mask & CO_text ) 
    {
        if ( mask & (CO_font | CO_frac | CO_symb | CO_ascii) )
        {
            IGRshort   *font_p = NULL;
            IGRshort   *value_p = NULL;
            IGRshort    flag = FALSE;
        
            switch ( mask )
            {
            case CO_font:
                flag = TRUE;
                font_p = &(p->TextSymb.Active_font);
                value_p = &(((struct GRdpb_text_symb *)value)->Active_font);
            case CO_frac:
                if ( !flag ) 
                {
                    flag = TRUE;
                    font_p = &(p->TextSymb.Active_fraction_font);
                    value_p = &(((struct GRdpb_text_symb *)value)->Active_fraction_font);
                }
            case CO_symb:
                if ( !flag ) 
                {
                    flag = TRUE;
                    font_p = &(p->TextSymb.Active_symbol_font);
                    value_p = &(((struct GRdpb_text_symb *)value)->Active_symbol_font);
                }
            case CO_ascii:
                if ( !flag ) 
                {
                    font_p = &(p->TextSymb.Active_ascii_font);
                    value_p = &(((struct GRdpb_text_symb *)value)->Active_ascii_font);
                }
            }

            switch (type)
            {
            case CO_default:
                *(IGRshort *)value = *font_p;
                break;
            case CO_integer:
                *(IGRint *)value = *font_p;
                break;
            case CO_double:
                *(IGRdouble *)value = *font_p;
                break;
            case CO_message:
            case CO_string:
                /*
                 * Search for the font name.
                 */
                *msg = COdpb_get_font(buffer,
                                      font_p, 
                                      mask,
                                      CO_attr_to_name);
                if ( *msg & 1 ) 
                {
                    if ( type == CO_message )
                    {
                        /* 
                         * Construct the active font message. 
                         */
                        ex$message(msgnumb = GR_I_ActFt,
                                   buff = value,
                                   type = "%s", 
                                   var = `buffer`);
                    }
                    else strcpy(value, (IGRchar *) buffer);
                }
                break;
            case CO_text_struct:
                *value_p = *font_p;
                break;
            default:
                *msg = MSFAIL;  
                goto quit;
            }
        }
        if ( mask & CO_just ) 
        {
            switch (type)
            {
            case CO_double:
                *(IGRdouble *)value = p->TextSymb.Active_just;
                break;
            case CO_integer:
                *(IGRint *)value = p->TextSymb.Active_just;
                break;
            case CO_text_struct:
                ((struct GRdpb_text_symb *)value)->Active_just = p->TextSymb.Active_just;
                break;
            case CO_message:
            case CO_string:
                value[0] = '\0';
                *msg = COdpb_get_just( buffer,
                                       &(p->TextSymb.Active_just),
                                       CO_attr_to_name );
                if ( type == CO_message )
                {
                    /* 
                     * Construct the active text justification message. 
                     */
                    ex$message(msgnumb = GR_I_ActJust, 
                               buff = value,
                               type = "%d%s", 
                               var = `p->TextSymb.Active_just,buffer`);
                }
                else strcpy(value, (IGRchar *) buffer);
                break;
            case CO_default:
                *(IGRshort *)value = p->TextSymb.Active_just;
                break;
            default:
                *msg = MSFAIL;
                goto quit;
            }
        }

        if ( mask & CO_size ) 
        {
            if ( type == CO_message || type == CO_string )
            {
                /* 
                 * Construct the active text size message. 
                 */
                num_alias=1;
                cvt_list[0] = &buffer[0][0];
                cvt_list[1] = &buffer[1][0];
                cvt_units[0] = p->TextSymb.Active_height;
                cvt_units[1] = p->TextSymb.Active_width;
                field_size = sizeof(IGRchar) * 80;
                status = co$cvt_imp_to_alias(msg = msg,
                                             osnum = mod_osnum,
                                             unit_type = "UOM_DISTANCE",
                                             working_units = cvt_units,
                                             num_alias = &num_alias,
                                             num_conversions = 2,
                                             field_size = &field_size,
                                             cvt_list = cvt_list);
                _err_ck2(status,*msg); 
    
                /* 
                 * Strip the first alias from the first string.
                 * (ie) 231.23 ft -> 231.23
                 */
                cp = cvt_list[0];
                while ( (!isalpha(*cp)) && (!isspace(*cp)) ) cp++;
                *cp = '\0';

                ex$message(msgnumb = GR_I_ThTw, 
                           buff = value,
                           type = "%s%s",
                           var  = `cvt_list[0], cvt_list[1]`);
            }
            else mask |= CO_height | CO_width;
        }

        if ( mask & CO_height ) 
        {
            switch (type)
            {
            case CO_double:
            case CO_default:
                *(IGRdouble *)value = p->TextSymb.Active_height;
                break;
            case CO_text_struct:
                ((struct GRdpb_text_symb *)value)->Active_height = p->TextSymb.Active_height;
                break;
            case CO_message:
            case CO_string:
                field_size = sizeof(IGRchar) * 240;
                status = co$cvt_imp_to_alias(msg = msg,
                                             osnum = mod_osnum,
                                             unit_type = "UOM_DISTANCE",
                                             working_units = &p->TextSymb.Active_height,
                                             num_alias = &num_alias,
                                             field_size = &field_size,
                                             cvt_list = buffer);
                _err_ck2(status,*msg); 

                if ( type == CO_message )
                {
                    ex$message(msgnumb = GR_I_ActHt, 
                               buff = value,
                               type = "%s",
                               var  = `buffer`);
                }
                else strcpy(value, (IGRchar *) buffer);
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
                *(IGRdouble *)value = p->TextSymb.Active_width;
                break;
            case CO_text_struct:
                ((struct GRdpb_text_symb *)value)->Active_width = p->TextSymb.Active_width;
                break;
            case CO_message:
            case CO_string:
                field_size = sizeof(IGRchar) * 240;
                status = co$cvt_imp_to_alias(msg = msg,
                                             osnum = mod_osnum,
                                             unit_type = "UOM_DISTANCE",
                                             working_units = &p->TextSymb.Active_width,
                                             num_alias = &num_alias,
                                             field_size = &field_size,
                                             cvt_list = buffer);
                _err_ck2(status,*msg); 

                if ( type == CO_message )
                {
                    ex$message(msgnumb = GR_I_ActWd, 
                               buff = value,
                               type = "%s",
                               var  = `buffer`);
                }
                else strcpy(value, (IGRchar *) buffer);
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
                *(IGRdouble *)value = p->TextSymb.Active_charspac;
                break;
            case CO_text_struct:
                ((struct GRdpb_text_symb *)value)->Active_charspac = p->TextSymb.Active_charspac;
                break;
            case CO_string:
                sprintf(value, "%g", p->TextSymb.Active_charspac);
                break;
            case CO_message:
                /* 
                 * Construct the active char spacing message.
                 */
                ex$message(msgnumb = GR_I_ActCs,
                           buff = value,
                           type = "%g", 
                           var = `p->TextSymb.Active_charspac`);
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
                *(IGRdouble *)value = p->TextSymb.Active_linespac;
                break;
            case CO_text_struct:
                ((struct GRdpb_text_symb *)value)->Active_linespac = p->TextSymb.Active_linespac;
                break;
            case CO_string:
                sprintf(value, "%g", p->TextSymb.Active_linespac);
                break;
            case CO_message:
                /* 
                 * Construct the active line spacing message.
                 */
                ex$message(msgnumb = GR_I_ActLs,
                           buff = value,
                           type = "%g", 
                           var = `p->TextSymb.Active_linespac`);
                break;                
            default:
                *msg = MSFAIL;
		break;
            }
        }
    }
    
quit:

    return (status);
}

end implementation COdpb;

