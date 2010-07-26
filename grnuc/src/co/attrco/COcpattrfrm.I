/* #######################    APOGEE COMPILED   ######################## */
/*
 COPYRIGHT
                     COPYRIGHT INTERGRAPH CORPORATION
                              < 1986, 1987 >
  
              Including software  and  its  file formats, and
              audio-visual displays; all rights reserved; may
              only  be  used   pursuant   to  the  applicable
              software     license     agreement;    contains
              confidential  and  proprietary  information  of
              intergraph and/or other  third parties which is
              protected  by  copyright,   trade  secret,  and
              trademark  law,  and  may  not  be  provided or
              otherwise made available  without prior written
              authorization.
  
  
                         RESTRICTED RIGHTS LEGEND
              Use, duplication,  or  disclosure  by  the U.S.
              Government is  subject  to  restrictions as set
              forth in subdivision  (b)(3)(ii)  of the Rights
              in Technical Data  and Computer Software clause
              at 52.227-7013.
  
  
              Intergraph Corporation
              One Madison Industrial Park
              Huntsville, Al 35807-4201
  
 */ 

/******************************************************************************

Description:

    These methods support the copy symbology and copy text parameters
    forms.

Overrides:

    from CEO form_notification

History:

    jay wallingford     03/15/89    creation date

******************************************************************************/
class implementation COcpattr;

#include <coimport.h>
#include <FI.h>

extern int COtool_fi_message ();

/*
Abstract
     
     This method processes form input.



History

	Jay Wallingford 12/21/87  Design and Implementation.
        jhw             02/15/89  Converted to cbase forms.
        jhw             06/15/89  Changed to COdpb subclass.

*/
                           
method form_notification ( IGRint form_label; 
                           IGRint gadget_label; 
                           IGRdouble value; 
                           Form form_ptr )
{
    IGRint          status = OM_S_SUCCESS;
    IGRlong         msg = MSSUCC;
    IGRuint         upd_mask = 0;
    IGRuint         mask = 0;
    IGRuint         old_mask;
    IGRlong         errmsg = 0;
    IGRdouble       d;
    IGRint          i, type = 0;
    IGRchar         str[BUFSIZ];
    IGRchar *       value_p = NULL;

    /*
     * Get the text string. This will simply fail if the gadget is not
     * a field.
     */
    *str = '\0';
    FIfld_get_text (form_ptr, gadget_label, 0, 0, BUFSIZ, str, &i, &i);

    /*
     * Save the old mask. This will be used to determine if a toggle was hit.
     */
    old_mask = me->mask;

    /* 
     * Switch on command type.
     */
    switch ( me->mytype ) 
    {
    case COPYTXSYMB:

        switch ( gadget_label ) 
        {
        case FONT_TOGGLE:
            me->mask ^= CO_font;
            break;

        case HEIGHT_TOGGLE:
            me->mask ^= CO_height;
            break;

        case WIDTH_TOGGLE:
            me->mask ^= CO_width;
            break;

        case CHARSP_TOGGLE:
            me->mask ^= CO_charsp;
            break;

        case LINESP_TOGGLE:
            me->mask ^= CO_linesp;
            break;

        case JUST_TOGGLE:
            me->mask ^= CO_just;
            break;
                         
        case FONT_ALPHA_FIELD:

            upd_mask = mask = CO_font;
            errmsg = GR_E_FtNotFnd;
            value_p = str;
            type = CO_string;

            break;

        case JUST_ALPHA_FIELD:

            upd_mask = mask = CO_just;
            errmsg = GR_E_InvJust;
            value_p = str;
            type = CO_string;

            break;
                         
        case JUST_VALUE_FIELD:

            upd_mask = CO_just;
            errmsg = GR_E_InvJust;

            if ( sscanf(str,"%d",&i) == 1 ) 
            {
                mask = CO_just;
                value_p = (char *)&i;
                type = CO_integer;
            }

            break;

        case HEIGHT_ALPHA_FIELD:

            upd_mask = mask = CO_height;
            errmsg = GR_E_InvTxtHt;
            value_p = str;
            type = CO_string;

            break;

        case WIDTH_ALPHA_FIELD:

            upd_mask = mask = CO_width;
            errmsg = GR_E_InvTxtWd;
            value_p = str;
            type = CO_string;

            break;


        case CHARSP_VALUE_FIELD:

            upd_mask = CO_charsp;
            errmsg = GR_E_InvCs;

            if ( sscanf(str,"%lf",&d) == 1 ) 
            {
                mask = CO_charsp;
                value_p = (char *)&d,
                type = CO_double;
            }

            break;

        case LINESP_VALUE_FIELD:

            upd_mask = CO_linesp;
            errmsg = GR_E_InvLs;

            if ( sscanf(str,"%lf",&d) == 1 ) 
            {
                mask = CO_linesp;
                value_p = (char *)&d;
                type = CO_double;
            }

            break;
        }
    
        if ( (upd_mask) || (me->mask != old_mask) ) break;

    case COPYSYMB:

        switch ( gadget_label ) 
        {
        case LEVEL_TOGGLE:
            me->mask ^= CO_level;
            break;

        case COLOR_TOGGLE:
            me->mask ^= CO_color;
            break;

        case WEIGHT_TOGGLE:
            me->mask ^= CO_weight;
            break;

        case STYLE_TOGGLE:
            me->mask ^= CO_style;
            break;

        case LEVEL_ALPHA_FIELD:

            upd_mask = mask = CO_level;
            errmsg = GR_E_InvLy;
            value_p = str;
            type = CO_string;

            break;

        case LEVEL_VALUE_FIELD:
            upd_mask = CO_level;
            errmsg = GR_E_InvLy;

            if ( sscanf(str,"%d",&i) == 1 ) 
            {
                mask = CO_level;
                value_p = (char *)&i;
                type = CO_integer;
            }

            break;

        case COLOR_ALPHA_FIELD:
            upd_mask = mask = CO_color;
            errmsg = GR_E_InvCo;
            value_p = str;
            type = CO_string;

            break;

        case COLOR_VALUE_FIELD:

            upd_mask = CO_color;
            errmsg = GR_E_InvCo;
            
            if ( sscanf(str,"%d",&i) == 1 ) 
            {
                mask = CO_color;
                value_p = (char *)&i;
                type = CO_integer;
            }

            break;

        case WEIGHT_VALUE_FIELD:

            upd_mask = CO_weight;
            errmsg = GR_E_InvWt;

            if ( sscanf(str,"%d",&i) == 1 ) 
            {
                mask = CO_weight;
                value_p = (char *)&i;
                type = CO_integer;
            }
            break;

        case STYLE_VALUE_FIELD:          

            upd_mask = CO_style;
            errmsg = GR_E_InvSt;

            if ( sscanf(str,"%d",&i) == 1 ) 
            {
                mask = CO_style;
                value_p = (char *)&i;
                type = CO_integer;
            }

            break;

        case ACTIVE_BUTTON:
            /*
             * Set the dpb according to my attribute data.
             */
            status = om$send( msg = message COdpb.put_dpb ( (int *)&msg, 
                                                            me->mask, 
                                                            NULL ),
                              targetid = my_id );
            _err_ck2(status, msg)

            /* 
             * Pop the MakeActSymb button back up.
             */
            FIg_set_state_off(me->status_display_form_ptr, ACTIVE_BUTTON);

            break;

        case QUIT_BUTTON:
            {
            IGRint              sizbuf, nret;
            struct IGRdisplay   display;

            FIg_set_state_off(me->status_display_form_ptr, QUIT_BUTTON);

            status = om$send( msg = message CEO.erase_form_by_label ( form_label,
                                                                      0,
                                                                      (int *)&msg ),
                              targetid = my_id );

            _err_ck2(status, msg);

            me->form_requested = FALSE;

            /*
             * KLUDGE: Since this form is a save/restore form on most occasions
             *         the adp form will not be updated when the set active 
             *         parameters button is pressed.  
             * 
             * Get and put the display symbology to cause the adp form to 
             * update after this form has been erased.
             */
            sizbuf = sizeof(struct IGRdisplay);
            gr$get_active_display ( msg = &msg,
                                    sizbuf = &sizbuf,
                                    buffer = &display,
                                    nret = &nret ); 

            gr$put_active_display ( msg = &msg,
                                    sizbuf = &sizbuf,
                                    buffer = &display );
            
            }
            break;

        } /* end switch on gadget_label */   

        break;

    } /* end switch on me->mytype */

    /*
     * If a mask is specified update the COdpb instance.
     */
    if ( mask ) 
    {

        status = om$send ( msg = message COdpb.put ( (int *)&msg, 
                                                     mask,
                                                     value_p,
                                                     type ),
                           targetid = my_id );
        _err_ck(status);

        if ( msg & 1 ) errmsg = 0;
    }
    
    /*
     * Construct and display messages for any error that might have 
     * occured.
     */
    if ( errmsg ) COtool_fi_message ( me->status_display_form_ptr,
                                      MSG_FIELD,
                                      errmsg,
                                      40 );
    /*
     * Update the form if necessary.
     */
    if ( upd_mask ) 
    {
        status = om$send ( targetid = my_id,
                           msg = message COcpattr.form_update(upd_mask) );
        _err_ck(status);
    }
      
quit:
    return status;

}

end implementation COcpattr;
