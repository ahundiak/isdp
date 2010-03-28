/******************************************************************************

Method:   

    alloc
    dealloc
    active
    get_dpb
    put_dpb

Description:    

    The alloc method allocates a COdpb attribute structure.

    The dealloc method deallocates a COdpb attribute structure.

    The active method makes on of the COdpb attribute structures active.

    The get_dpb loads the active COdpb attribute structure with the specified
    attributes from the global dpb. 

    The put_dpb loads the specified attributes from COdpb attribute 
    structure into the global dpb.
    
History:    

    jay wallingford     04/10/89    creation date
    dhm                 07/09/92    ANSI conversion.

Bugs:       

    There are no known bugs.

Notes:

******************************************************************************/

class implementation COdpb;

method alloc ( IGRint * msg;
               IGRint * index )
{
    IGRint size;


    *msg = MSSUCC;

    size = om$dimension_of ( varray = me->Attr );

    if ( om$vla_set_dimension ( varray = me->Attr, size = ++size ) ) {

        if ( size == 1 ) me->Active = (-1);

        if ( index ) *index = size - 1;
    }
    else *msg = MSFAIL;

                                                  
    return (OM_S_SUCCESS);
}
        
method dealloc ( IGRint * msg;
                 IGRint index )
{
    IGRint max_index;
    IGRint offset;

    max_index = om$dimension_of ( varray = me->Attr ) - 1;

    if ( (index <= max_index) && (index >= 0) ) {
        offset = max_index - index;
        if ( offset ) {
            OM_BLOCK_MOVE ( &me->Attr[index + 1],
                            &me->Attr[index],
                            sizeof(struct COdpb_attr) * offset );
        }
        om$vla_set_dimension ( varray = me->Attr,
                               size = max_index-- );
        me->Active = (me->Active == index) ? (-1) :
                     (me->Active > index)  ? (me->Active - offset) :
                     (me->Active);
    }
    else *msg = MSFAIL;

    return (OM_S_SUCCESS);
}

method active ( IGRint * msg;
                IGRint index )
{
    IGRint max_index;

    max_index = om$dimension_of ( varray = me->Attr ) - 1;

    if ( (max_index != (-1))  && 
         (index <= max_index) && 
         (index >= 0) ) 
    {
        me->Active = index;
    }
    else *msg = MSFAIL;

    return (OM_S_SUCCESS);
}

method get_dpb ( IGRint * msg;
                 IGRuint mask;
                 struct COdpb_attr * attr_p )
{
    IGRint                  status = OM_S_SUCCESS;
    IGRint                  nret,sizbuf;
    struct COdpb_attr       *p;

    /*
     * Set up the active symb pointer.
     */
    if ( attr_p ) {
        p = attr_p;
    }
    else if ( om$dimension_of ( varray = me->Attr ) && me->Active != (-1) ) {
        p = &me->Attr[me->Active];
    }
    else {
        *msg = MSFAIL;
        goto quit;
    }

    if ( mask )
    {
        /*
         * If display attributes are specified.
         */
        if ( mask & CO_disp ) {
            struct IGRdisplay   display;

            sizbuf = sizeof(struct IGRdisplay);
            status = gr$get_active_display ( msg = msg,
                                             sizbuf = &sizbuf,
                                             buffer = &display,
                                             nret = &nret ); 
            _err_ck2(status,*msg);

            if ( mask & CO_color )
                p->dpb_Display.color = display.color;
            if ( mask & CO_weight )
                p->dpb_Display.weight = display.weight;
            if ( mask & CO_style )
                p->dpb_Display.style = display.style;
        }

        /*
         * If level is specified.
         */
        if ( mask & CO_level )
        {
            sizbuf = sizeof(IGRshort);
            status = gr$get_active_level ( msg = msg,
                                           sizbuf = &sizbuf,
                                           buffer = &p->Level,
                                           nret = &nret ); 
            _err_ck2(status,*msg);
        }

        /*
         * If scales are specified.
         */
        if ( mask & CO_scales )
        {
            struct GRdpb_scale      scale;

            sizbuf = sizeof(struct GRdpb_scale);
            status = gr$get_active_scale ( msg = msg,
                                           sizbuf = &sizbuf,
                                           buffer = &scale,
                                           nret = &nret ); 
            _err_ck2(status,*msg);

            if ( mask & CO_scale ) 
                mask |= CO_scales;
            if ( mask & CO_xscale )
                p->Scale.Active_xscale = scale.Active_xscale;
            if ( mask & CO_yscale )
                p->Scale.Active_yscale = scale.Active_yscale;
            if ( mask & CO_zscale )
                p->Scale.Active_zscale = scale.Active_zscale;
        }

        /*
         * If angle is specified.
         */
        if ( mask & CO_angle )
        {
            sizbuf = sizeof(IGRdouble);
            status = gr$get_active_angle ( msg = msg,
                                           sizbuf = &sizbuf,
                                           buffer = &p->Angle,
                                           nret = &nret ); 
            _err_ck2(status,*msg);
        }

        /*
         * If text attributes are specified
         */
        if ( mask & CO_text ) {
            struct GRdpb_text_symb  textsymb;

            sizbuf = sizeof(struct GRdpb_text_symb);
            status = gr$get_text_symb ( msg = msg,
                                        sizbuf = &sizbuf,
                                        buffer = &textsymb,
                                        nret = &nret );
            _err_ck2(status,*msg);

            if ( mask & CO_font )
                p->TextSymb.Active_font = textsymb.Active_font;
            if ( mask & CO_frac )
                p->TextSymb.Active_fraction_font = textsymb.Active_fraction_font;
            if ( mask & CO_symb )
                p->TextSymb.Active_symbol_font = textsymb.Active_symbol_font;
            if ( mask & CO_ascii )
                p->TextSymb.Active_ascii_font = textsymb.Active_ascii_font;
            if ( mask & CO_just )
                p->TextSymb.Active_just = textsymb.Active_just;
            if ( mask & CO_size )
                mask |= CO_height | CO_width;
            if ( mask & CO_width )
                p->TextSymb.Active_width = textsymb.Active_width;
            if ( mask & CO_height )
                p->TextSymb.Active_height = textsymb.Active_height;
            if ( mask & CO_charsp )
                p->TextSymb.Active_charspac = textsymb.Active_charspac;
            if ( mask & CO_linesp )
                p->TextSymb.Active_linespac = textsymb.Active_linespac;
        }
    }

quit:

    return (status);
}

/*
 * This variable is set and unset by the co= command. It
 * is a temporary kludge, which should be taken out by 2.0.
 * Talk to Brad Robbins. This is also in the COdpb.put method.
 */
extern IGRboolean        COInvisibleColor;

method put_dpb ( IGRint * msg;
                 IGRuint mask;
                 struct COdpb_attr * attr_p )
{
    IGRint                  status = OM_S_SUCCESS;
    IGRint                  nret,sizbuf;
    struct COdpb_attr       *p;

    *msg = MSSUCC;

    /*
     * Set up the active symb pointer.
     */
    if ( attr_p ) {
        p = attr_p;
    }
    else if ( om$dimension_of ( varray = me->Attr ) && me->Active != (-1) ) {
        p = &me->Attr[me->Active];
    }
    else {
        *msg = MSFAIL;
        goto quit;
    }

    if ( mask & CO_vg )
    {
        if ( mask & CO_disp ) 
        {
            struct IGRdisplay    display;

            sizbuf = sizeof(struct IGRdisplay);

            status = gr$get_active_display ( msg = msg,
                                             sizbuf = &sizbuf,
                                             buffer = &display,
                                             nret = &nret ); 
            _err_ck2(status,*msg);

            if ( mask & CO_color )
                display.color = p->dpb_Display.color;
            if ( mask & CO_weight )
                display.weight = p->dpb_Display.weight;
            if ( mask & CO_style )
                display.style = p->dpb_Display.style;

            status = gr$put_active_display ( msg = msg,
                                             sizbuf = &sizbuf,
                                             buffer = &display); 
            _err_ck2(status,*msg);

            /* 
             * Clear the invisible color flag. KLUDGE.
             */
            COInvisibleColor = FALSE;
        }

        if ( mask & CO_level ) 
        {
            sizbuf = sizeof(IGRshort);
            status = gr$put_active_level ( msg = msg,
                                           sizbuf = &sizbuf,
                                           buffer = &p->Level ); 
            _err_ck2(status,*msg);
        }

        if ( mask & CO_scales ) 
        {
            struct GRdpb_scale  scale;

            sizbuf = sizeof(struct GRdpb_scale);

            status = gr$get_active_scale ( msg = msg,
                                           sizbuf = &sizbuf,
                                           buffer = &scale,
                                           nret = &nret ); 
            _err_ck2(status,*msg);

            if ( mask & CO_scale ) mask |= CO_scales;
            if ( mask & CO_xscale )
                scale.Active_xscale = p->Scale.Active_xscale;
            if ( mask & CO_yscale ) 
                scale.Active_yscale = p->Scale.Active_yscale;
            if ( mask & CO_zscale )
                scale.Active_zscale = p->Scale.Active_zscale;
           
            status = gr$put_active_scale ( msg = msg,
                                           sizbuf = &sizbuf,
                                           buffer = &scale ); 
            _err_ck2(status,*msg);
        }
    
        if ( mask & CO_angle ) 
        {
            sizbuf = sizeof(p->Angle);
            status = gr$put_active_angle ( msg = msg,
                                           sizbuf = &sizbuf,
                                           buffer = &p->Angle ); 
            _err_ck2(status,*msg);
        }
    }

    /*
     * If GRtext symb is specified
     */
    if ( mask & CO_text ) 
    {
        struct GRdpb_text_symb  textsymb;

        sizbuf = sizeof(struct GRdpb_text_symb);
        status = gr$get_text_symb ( msg = msg,
                                    sizbuf = &sizbuf,
                                    buffer = &textsymb,
                                    nret = &nret );
        _err_ck2(status,*msg);
    
        if ( mask & CO_font )
            textsymb.Active_font = p->TextSymb.Active_font;
        if ( mask & CO_frac )
            textsymb.Active_fraction_font = p->TextSymb.Active_fraction_font;
        if ( mask & CO_symb )
            textsymb.Active_symbol_font = p->TextSymb.Active_symbol_font;
        if ( mask & CO_ascii )
            textsymb.Active_ascii_font = p->TextSymb.Active_ascii_font;
        if ( mask & CO_just )
            textsymb.Active_just = p->TextSymb.Active_just;
        if ( mask & CO_size )
            mask |= CO_height | CO_width;
        if ( mask & CO_width )
            textsymb.Active_width = p->TextSymb.Active_width;
        if ( mask & CO_height )
            textsymb.Active_height = p->TextSymb.Active_height;
        if ( mask & CO_charsp )
            textsymb.Active_charspac = p->TextSymb.Active_charspac;
        if ( mask & CO_linesp )
            textsymb.Active_linespac = p->TextSymb.Active_linespac;

        status = gr$put_text_symb ( msg = msg,
                                    sizbuf = &sizbuf,
                                    buffer = &textsymb );
        _err_ck2(status,*msg);
    }

quit:
    return(status);
}

end implementation COdpb;


