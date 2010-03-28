/* #######################    APOGEE COMPILED   ######################## */
/*
Name
        LCdisplay

Description
        This routine will perform a display request for locate.  If
        a request for a display in all windows is requested, the
        graphic gadgets that are active and not delayed are found. 
        Then the first window is highlighted in.  This is the window
        that is passed in.  Then the remaining windows are sent a
        highlight request.  The highlight takes place in a maximum
        of 40 windows.

Synopsis
        IGRlong *msg                O   
        IGRshort *matrix_type       I   
        IGRmatrix matrix            I   
        enum DPmode *highlight_mode I   
        struct GRid *window_id      I   
        OM_S_OBJID objid            I   
        OMuword osnum               I   
        IGRint element              I   
        IGRint window               I   
        struct GRid *mod_id         I   
        struct GRparms *parms       O   
        IGRint *ext_o_element       I   

Return Codes
        The return code of the function will be the om return code from the
        messages sent to display.
History
        scw  07/13/92  ansi conversion
*/

class implementation Root;

#include "grimport.h"
#include "OMerrordef.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "dpdef.h"
#include "dp.h"
#include "dpmacros.h"
#include "gr.h"
#include "referr.h"

from GRgraphics import GRdisplay;
from GRgraphics import GRlocaldp;

IGRint LCdisplay (msg, matrix_type, matrix, hilight_mode, window_id, objid,
                  osnum, element, window, mod_id, parms, ext_o_element)


IGRlong        *msg;            /* return code                              */
IGRshort       *matrix_type;    /* matix type                               */
IGRmatrix      matrix;          /* environment matrix                       */
enum GRdpmode  *hilight_mode;   /* mode of highlight, when in segment       */
                                /* display this is an array of two.         */
struct GRid    *window_id;      /* id of window to display in first.  If    */
                                /* the request is for one window only then  */
                                /* no further highlight will be done after  */
                                /* this one.                                */
OM_S_OBJID     objid;           /* Objid of element to display              */
OMuword        osnum;           /* Spacenumber of element to display        */
IGRint         element;         /* 1 = element display, 0 = segment         */
IGRint         window;          /* 1 = window display,  0 = module          */
struct GRid    *mod_id;         /* what is the module object id             */
struct GRparms *parms;          /* parms structure required only for segment*/
                                /* display                                  */
IGRint         *ext_o_element;  /* Should the element or extensions be drawn*/
                                /* This is used for segment display only.   */
{
    IGRint          return_code;
    IGRint          ii;
    IGRint          number_of_ids;
    struct GRid     window_ids[40];
    IGRint          win_levels[(DP_NUM_OF_LEVELS - 1)/32 + 1];
    IGRint          ref_levels[(DP_NUM_OF_LEVELS - 1)/32 + 1];
    struct var_list gragad_list[2];
    IGRint          element_in_ref = FALSE;
    IGRint          which_error;
    IGRlong         bytes_returned;

    if (window_id == NULL && mod_id == NULL)
    {
        return (0);
    }

    if (!window)
    {
        dp$get_gragad_id (msg = msg,
                          mod_GRid = mod_id,
                          name = "*",
                          array_size = 40,
                          numberofids = &number_of_ids,
                          found_GRids = window_ids,
                          type_gragad = ALL_GG_CLASSES | ACTIVE_GG | 
                                        NO_DELAY_GG);

        for (ii = 0; ii < number_of_ids; ii++)
        {
            if (window_ids[ii].objid == window_id->objid  &&
                window_ids[ii].osnum == window_id->osnum)
            {
                window_ids[ii] = window_ids[0];
                window_ids[0] = *window_id;
                break;
            }
        }
    }
    else
    {
        window_ids[0] = *window_id;
        number_of_ids = 1;
    }

    return_code = OM_S_SUCCESS;
    window = 1;

    /*
     * If a segment display is requested
     */
    if ( !element )
    {
        /*
         * Set up for the dp$inqset.
         */
        gragad_list[0].var = LEVELS;
        gragad_list[0].num_bytes = 
            sizeof(IGRint) * ((DP_NUM_OF_LEVELS -1)/32 + 1);
        gragad_list[0].bytes_returned = &bytes_returned;
        gragad_list[1].var = END_PARAM;

        /*
         * If the object is in a reference file
         */
        GRcheckref(msg, NULL, NULL, NULL, &osnum);

        if ( *msg != GRNOTREFFILE )
        {
            /*
             * Save the reffile levels. These will be used
             * to set the window's levels later.
             */
            return_code = GRgetreflevels ( msg,
                                           matrix_type,
                                           matrix,
                                           &osnum,
                                           ref_levels );

            if (return_code & *msg & 1)
            {
                /*
                 * Note that the element to be displayed is in 
                 * a reference file.
                 */
                element_in_ref = TRUE;
            }
        }
    }

    /*
     * Display the object in all requested windows.
     */
    for (ii = 0; ii < number_of_ids; ii++)
    {
        /*
         * If element display.
         */
        if (element)
        {
            return_code = om$send (msg = message GRgraphics.GRdisplay
                                        (msg, matrix_type, matrix,
                                         hilight_mode, &window_ids[ii]),
                                   targetid = objid,
                                   targetos = osnum,
                                   senderid = NULL_OBJID);
        }
        else /* Segment display */
        {
            /*
             * If the element is in a reference file set the 
             * window's levels to those of the reference file.
             */
            if ( element_in_ref )
            {
                /*
                 * Save this window's levels.
                 */
                gragad_list[0].var_ptr = (IGRchar *)win_levels;
                return_code = dp$inq_set_gragad ( msg = msg,
                                                  inq0_set1 = 0,
                                                  osnum = window_ids[ii].osnum,
                                                  gragad_objid = window_ids[ii].objid,
                                                  which_error = &which_error,
                                                  var_list = gragad_list );

                if (!( return_code & *msg & 1 )) goto wrapup;
                                                  
                /*
                 * Set this window's levels to the reffile levels.
                 */
                gragad_list[0].var_ptr = (IGRchar *)ref_levels;
                return_code = dp$inq_set_gragad ( msg = msg,
                                                  inq0_set1 = 1,
                                                  osnum = window_ids[ii].osnum,
                                                  gragad_objid = window_ids[ii].objid,
                                                  which_error = &which_error,
                                                  var_list = gragad_list );

                if (!( return_code & *msg & 1 )) goto wrapup;
            }
    
            /*
             * Do the segment display.
             */
            return_code = om$send (msg = message GRgraphics.GRlocaldp
                                              ( msg, 
                                                matrix_type, 
                                                matrix, 
                                                parms,
                                                hilight_mode, 
                                               &window_ids[ii],
                                                (IGRshort *)&window, 
                                                (IGRshort *)ext_o_element ),
                                   targetid = objid,
                                   targetos = osnum,
                                   senderid = NULL_OBJID);

            /*
             * If element was in a reference file, reset the window's levels. 
             * This must be done before the check for display errors.
             */
            if ( element_in_ref )
            {
                /*
                 * Restore this window's levels.
                 */
                gragad_list[0].var_ptr = (IGRchar *)win_levels;
                return_code = dp$inq_set_gragad ( msg = msg,
                                                  inq0_set1 = 1,
                                                  osnum = window_ids[ii].osnum,
                                                  gragad_objid = window_ids[ii].objid,
                                                  which_error = &which_error,
                                                  var_list = gragad_list );

                if (!( return_code & *msg & 1 )) goto wrapup;
            }

            if (!(return_code & *msg & 1)) goto wrapup;
        }

        if (return_code != OM_S_SUCCESS) break;
    }

wrapup:

    return (return_code);
}

end implementation Root;
