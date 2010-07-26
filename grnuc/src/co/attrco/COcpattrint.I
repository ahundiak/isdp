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

Methods:

History:

    jay wallingford     03/15/89    creation date

******************************************************************************/
class implementation COcpattr;

#include <coimport.h>

/*\
Abstract
     
    This method initializes the form and sets the mask.

Method

    form_init

History

	Jay Wallingford           12/21/87  Design and Implementation.

\*/

method form_init ()
{
    IGRlong        ok;
    IGRlong        status;
    IGRlong        nret = 0;
    IGRint         i;
    IGRint         labels[9];     
    IGRint         toggles[9];
    IGRint         state;

    status = OM_S_SUCCESS;

    /*
     * Get the current module enviroment.
     * This is needed for the first call to update form since
     * the module enviroment is not fetched until wakeup.
     */
    ex$get_cur_mod ( id = &me->ModuleInfo.md_id.objid,
                     osnum = &me->ModuleInfo.md_id.osnum );
     
    /*
     * Allocate a dpb structure and seed it.
     */
    if ( om$vla_set_dimension ( varray = me->Attr, size = 1 ) ) 
    {
        /*
         * Make this structure the active structure.
         */
        me->Active = 0;

        /*
         * Seed the attribute structure with data from the dpb.
         */
        status = om$send ( msg = message COdpb.get_dpb ( (int *)&ok, 
                                                         ( (me->mytype == COPYSYMB) ?
                                                           CO_sym : (CO_sym | CO_text) ), 
                                                         NULL ),
                           targetid = my_id );
        _err_ck2(status,ok);
    }

    /* 
     * Designate the query mask.
     * These are the toggles which are common to both the copysymb
     * and copytxsymb forms.
     */
    labels[0] = LEVEL_TOGGLE;  toggles[0] = CO_level;
    labels[1] = COLOR_TOGGLE;  toggles[1] = CO_color;
    labels[2] = WEIGHT_TOGGLE; toggles[2] = CO_weight;

    switch ( me->mytype )
    {
        case COPYTXSYMB:

            /* 
             * These are the toggles which are used by the copytxsymb
             * form.
             */
            labels[3] = FONT_TOGGLE;     toggles[3] = CO_font;
            labels[4] = HEIGHT_TOGGLE;   toggles[4] = CO_height;
            labels[5] = WIDTH_TOGGLE;    toggles[5] = CO_width;
            labels[6] = CHARSP_TOGGLE;   toggles[6] = CO_charsp;
            labels[7] = LINESP_TOGGLE;   toggles[7] = CO_linesp;
            labels[8] = JUST_TOGGLE;     toggles[8] = CO_just;
            nret = 9;
            break;

        case COPYSYMB:
            /* 
             * Set up the query mask for the style
             * which is found only on the copysymb form.
             */
            labels[3] = STYLE_TOGGLE; toggles[3] = CO_style;
            nret = 4;
            break;
    }
    
    /*
     *
     * Query the form to determine the state of the toggles.
     *
     * Note: By performing a query instead of assuming that the toggle     
     * states are the same as they were on construction of the form, 
     * the user is able to modify the default toggle states to his/her  
     * preference with form builder.                                 
     *
     */
    me->mask = 0x0;

    for ( i=0; i<nret; i++ )
    {
        FIg_get_state(me->status_display_form_ptr, labels[i], &state);
        if ( state ) me->mask |= toggles[i];
    }

    /*
     * Update all fields on the form.
     */
    status = om$send ( msg = message COcpattr.form_update ( (me->mytype == COPYSYMB) ?
                                                            CO_copysymb : CO_copytxpa ),
                       targetid = my_id );
     _err_ck(status);

quit:

    return status;
}


end implementation COcpattr;
