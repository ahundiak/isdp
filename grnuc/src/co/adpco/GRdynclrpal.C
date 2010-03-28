/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

     FUNCTION NAME:             GRdyncolorpal
 
     Abstract:

      This function will either update or dynamically create a color palette.
If a color palette already exists and the number of active colors has not
changed, the colors of the palette's buttons will be updated and the buttons
will be redisplayed.  If a palette doesn't exist, one wil be created with a
button for each active color.
-----
%SC%

     VALUE =  GRdyncolorpal(msg,palette_label,palette_x1,palette_y1,
                            palette_x2,palette_y2,form_ptr,num_colors)
-----
%EN%
 
     ON ENTRY:

        NAME       DATA TYPE                    DESCRIPTION
     ----------   ------------        ----------------------------------------
     palette_label IGRint             label of the group gadget with which the
                                      color buttons are associated
     palette_x1    IGRint             x-coordinate of upper left corner of the
                                      palette on the form
     palette_y1    IGRint             y-coordinate of upper left corner of the
                                      palette on the form
     palette_x2    IGRint             x-coordinate of lower right corner of the
                                      palette on the form
     palette_y2    IGRint             y-coordinate of lower right corner of the
                                      palette on the form
     form_ptr      Form               pointer to form to create the color
                                      palette for
     *num_colors   IGRshort           number of color buttons on the
                                      color palette
-----
%EX%

     ON EXIT:

        NAME       DATA TYPE               DESCRIPTION
     ----------   ------------   -----------------------------------
     *msg         IGRlong        return code
                                    MSSUCC    - if successful
                                    MSFAIL    - if failure
     *num_colors  IGRshort       number of color buttons on the color
                                 palette (number of active colors)
-----
%MD%

     MODULES AND METHODS INVOKED:

     modules:
     methods:

-----
%RL%

      RELATIONS REFERENCED:

----- 
%NB%

     NOTES:  
-----

%CH%
     CHANGE HISTORY:
        
        WBC  08/11/87 : Design date.
        WBC  08/11/87 : Creation date.
        WBC  06/19/89 : Updated to work with c-based forms.
        dhm  10/18/91 : fixed symbol file problem.
        dhm  07/13/92 : ANSI conversion.
        jdu  05/12/93 : fixed for 2.4 color scheme  color pallet only used for generate set
-----
%PD%
--------------------------------------------------------------------
               M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------
   This function will either update or dynamically create a color
palette.  If a color palette already exists and the number of active
colors has not changed, the colors of the palette's buttons will be
updated and the buttons will be redisplayed.  If a palette doesn't
exist, one wil be created with a button for each active color.
----*/
/*EH*/

#define GRCOLOR_OFFSET  10000
#define MAX_BUTTON_SIZE 45

#include "coimport.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "gr.h"
#include "igr.h"
#include "igrdp.h"
#include "adpdef.h"
#include "FI.h"
#include "FIdyn.h"
/* #include "fistruct.h" */
#include "msdef.h"
#include "exmacros.h"
#include "igewindef.h"
#include "igecolor.h"
#include "igecolordef.h"
#include "igecolmacros.h"
#include "igewinmacros.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "wl.h"

IGRint GRdyncolorpal(msg,palette_label,palette_x1,palette_y1,
                     palette_x2,palette_y2,form_ptr,num_colors)

IGRlong        *msg;          /* return code                          */
IGRint         palette_label; /* label of the group gadget with which */
                              /* the color buttons are associated     */
IGRint         palette_x1;    /* x-coordinate of upper left corner of */
                              /* the palette on the form              */
IGRint         palette_y1;    /* y-coordinate of upper left corner of */
                              /* the palette on the form              */
IGRint         palette_x2;    /* x-coordinate of lower right corner   */
                              /* of the palette on the form           */
IGRint         palette_y2;    /* y-coordinate of lower right corner   */
                              /* of the palette on the form           */
Form           form_ptr;      /* pointer to form to create the color  */
                              /* palette for                          */
IGRshort       *num_colors;   /* number of color buttons on the       */
                              /* color palette                        */
{
    extern IGRdouble       sqrt();
    extern IGRdouble       floor();
    extern IGRdouble       ceil();

    struct GRid            module_grid;
    struct standard_st     dyn_button;
    IGRint                 i, j, k, num_rows, num_cols;
    IGRint                 button_size;
    IGRint                 button_label;
    IGRint                 xpos, ypos;
    IGRshort               num_active_colors;
    IGRshort              abs_color;
    WLuint32 context_no;
    WLhwin_no hwin_no;
    WLuint16 lscreen_no;

    *msg = MSSUCC;

    /*
     *  find the module objid and osnum
     */

    if (!ex$get_cur_mod(id = &module_grid.objid,
                        osnum = &module_grid.osnum))
    {
        *msg = MSFAIL;
        return(FALSE);
    }

    /*
     *  find the number of active colors
     */

    if (!ige$get_num_active_colors(num_colors = &num_active_colors))
    {
        *msg = MSFAIL;
        return(FALSE);
    }

    /*
     * if the active number of colors has changed, create and display a
     * new color palette
     */

    button_label = palette_label + 1; /* button labels begin after palette's */

    FIf_get_window(form_ptr, &hwin_no);
    WLget_logical_screen_from_window( hwin_no, &lscreen_no);
    CMget_active_context( lscreen_no, &context_no );
    if (num_active_colors != *num_colors)
    {
        /*
         * delete the color buttons associated with the color palette except
         * for the background color button
         */

        FIg_add_to_group(form_ptr,GRCOLOR_BACKGROUND_BUTTON,FI_FORM_GROUP);
        FIg_delete(form_ptr,palette_label);

        /*
         *  find the number of rows and columns of color buttons that will
         *  fit on the color palette, depending on the number of user
         *  colors on this device; next calculate the height and width of
         *  the color buttons
         */

        num_rows = (IGRint)floor(sqrt((IGRdouble)num_active_colors));
        num_cols = (IGRint)ceil((IGRdouble)num_active_colors / (IGRdouble)num_rows);

        button_size = (palette_y2 - palette_y1) / num_cols;

        /*
         * don't want the buttons to be larger than a specified size; if they
         * are, change their size to the maximum size
         */

        if (button_size > MAX_BUTTON_SIZE)
        {
            button_size = MAX_BUTTON_SIZE;
        }

        /*
         * center the color palette on the color form
         */

        palette_y1 += ((palette_y2 - palette_y1) - (num_rows * button_size))/2;
        palette_x1 += ((palette_x2 - palette_x1) - (num_cols * button_size))/2;
        ypos = palette_y1;

        /*
         * must initialize a standard variables structure which will be used
         * in dynamically creating the color buttons
         */

        dyn_button.attr_mask = 0;
        dyn_button.value = 0;
        dyn_button.bodysize = 0.0;
        dyn_button.text = NULL;
        dyn_button.help_topic = NULL;
        dyn_button.command = NULL;
        dyn_button.fontname = "GRfrm.sym";
        dyn_button.user_pointer = NULL;
        dyn_button.off_color = 0;
        dyn_button.on_color = 0;
        dyn_button.off_color2 = 0;
        dyn_button.on_color2 = 0;
        dyn_button.symbol_index2 = 0;
        dyn_button.next_in_seq = 0;

        if (num_active_colors < 26)
        {
            dyn_button.symbol_index = 41;         /* "large" square symbol */
        }
        else
        {
            dyn_button.symbol_index = 4;         /* "small" square symbol */
        }

        for (i = 0, k = 1; i < num_rows; ++i)
        {
            xpos = palette_x1;

            for (j = 0; j < num_cols && k <= num_active_colors; ++j, ++k)
            {
                /*
                 * convert the logical color index to the absolute color index
                 */

                if (!ige$get_abs_color_index(context_no = context_no,
                                             log_color = (IGRushort) k,
                                             abs_color = &abs_color))
                {
                    *msg = MSFAIL;
                    return(FALSE);
                }

                /*
                 * add each button gadget to the color form and set its size,
                 * location and color and make it part of the color palette
                 * group
                 */

                FIg_new(form_ptr,FI_BUTTON,button_label);

                dyn_button.xlo = xpos;
                dyn_button.ylo = ypos;
                dyn_button.xhi = xpos + button_size;
                dyn_button.yhi = ypos + button_size;

                FIg_set_standard_variables(form_ptr,button_label,&dyn_button);

                FIg_set_on_color(form_ptr,button_label,
                                 GRCOLOR_OFFSET + abs_color);
                FIg_set_off_color(form_ptr,button_label,
                                  GRCOLOR_OFFSET + abs_color);

                FIg_add_to_group(form_ptr,button_label,palette_label);

                ++button_label;
                xpos += button_size;
            }     /* end the column for loop */
            ypos += button_size;
        }        /* end the row for loop     */

        FIg_activate(form_ptr,palette_label);

        /*
         * add the background button (which already exists on the form) to the
         * color palette
         */

        FIg_add_to_group(form_ptr,GRCOLOR_BACKGROUND_BUTTON,palette_label);
        *num_colors = num_active_colors;
    }
    else
    {
        /*
         * a color palette already exists and the number of colors has not
         * changed; update the color of each button on the palette
         */

        for (i = 1; i <= num_active_colors; ++i, ++button_label)
        {
            /*
             *  convert the logical color index to the absolute color index
             */

            if (!ige$get_abs_color_index(context_no = context_no,
                                         log_color = (IGRushort) i,
                                         abs_color = &abs_color))
            {
                *msg = MSFAIL;
                return(FALSE);
            }

            /*
             * update the on and off color of the button
             */

            FIg_set_on_color(form_ptr,button_label,
                             GRCOLOR_OFFSET + abs_color);
            FIg_set_off_color(form_ptr,button_label,
                              GRCOLOR_OFFSET + abs_color);
        }
    }

    /*
     * update the color of the background button
     */

    if (!ige$get_abs_color_index(context_no = context_no,
                                 log_color = 0,
                                 abs_color = &abs_color))
    {
        *msg = MSFAIL;
        return(FALSE);
    }
    FIg_set_on_color(form_ptr,GRCOLOR_BACKGROUND_BUTTON,
                     GRCOLOR_OFFSET + abs_color);
    FIg_set_off_color(form_ptr,GRCOLOR_BACKGROUND_BUTTON,
                      GRCOLOR_OFFSET + abs_color);

    return(TRUE);
}
