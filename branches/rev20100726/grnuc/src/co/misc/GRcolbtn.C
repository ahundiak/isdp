/*
Name
        GRcolbtn.C

Description
        This file contains functions used to highlight menu buttons by playing
        with the colors.

Notes
        The functions here assume that the caller is highlighting a button by
        using symbols which complement each other.  The off_symbol is the same
        symbol that is normally shown on the button.  The on_symbol is a
        negative image of off_symbol, and will be displayed in a color to draw
        attention to the button (green is used by default).

        The FORMS terminology for button symbols and colors is a bit
        confusing.  The practical mapping is shown below.

        off_color       controls        off_symbol when button is "out"
        off_color2      controls        on_symbol when button is "out"
        on_color        controls        off_symbol when button is "in"
        on_color2       controls        on_symbol when button is "in"

History
        mrm     07/23/93        creation
*/

#include <stdio.h>
#include <alloca.h>
#include <FI.h>
#include "OMminimum.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "wl.h"
#include "cm.h"
#include "igewindef.h"
#include "igecolor.h"
#include "igecolmacros.h"
#include "comisc.h"

#ifndef TRUE
#define TRUE    1
#endif

typedef struct
{
    char *cmdkey;
    int filled_icon_index;
    int fill_color;
    int fill_in_color;
    int outline_icon_index;
    int outline_color;
    int otl_in_color;
}   GRbinfo;

/*
Name
        GRdisplay_has_fixed_vlt

Description
        This function determines whether the machine has a fixed color table.
        It is mainly used to keep things viewable on ancient machines.
*/

int GRdisplay_has_fixed_vlt()
{
    static int has_fixed_vlt = -1;

    if (has_fixed_vlt == -1)
    {
        WLuint16 screen_no;
        WLuint32 context_no;
        int screen_type, sts ;
        IGRshort phys_slot, fixed_vlt_size = 0;
        
        sts = WLget_active_screen(&screen_no, &screen_type);
        if (sts != WL_SUCCESS)
            return(FALSE);
        sts = CMget_exnuc_forms_context(screen_no,&context_no);
        if (sts != CM_SUCCESS)
            return(FALSE);

        ige$get_FI_COLOR_phys_slot(context_no = context_no,
                                   FI_DEFINE = FI_BLUE,
                                   phys_slot_num = &phys_slot,
                                   fixed_vlt = &fixed_vlt_size);
        has_fixed_vlt = (fixed_vlt_size) ? TRUE : FALSE;
    }
    return(has_fixed_vlt);
}

/*
Name
        GRcolor_button

Description
        This function adjusts the colors and symbols of the specified menu
        button.
*/

int GRcolor_button(Form form,
                   int label,
                   int filled_icon_index,
                   int fill_color,
                   int fill_in_color,
                   int outline_icon_index, 
                   int otl_color,
                   int otl_in_color)
{
    /* set the indices */
    FIg_set_on_symbol_index(form, label, filled_icon_index);
    FIg_set_off_symbol_index(form, label, outline_icon_index);

    /* set the colors for when the button is "out" */
    FIg_set_off_color(form, label, otl_color);
    FIg_set_off_color2(form, label, fill_color);

    /* set the colors for when the button is "in" (depressed) */
    FIg_set_on_color(form, label, otl_in_color);
    FIg_set_on_color2(form, label, fill_in_color);

    /* display the results */
    FIg_set_state_off(form, label);
    FIg_display(form, label);

    return(TRUE);
}

/*
Name
        GRcustom_hilite_button_callback

Description
        This function is set up by GRcustom_hilite_button to be called from
        GRmonkey_with_forms for each bar menu.
*/

void GRcustom_hilite_button_callback(Form form, GRbinfo *b)
{
    int label;

    /* check for the desired button */
    if (GRfind_button_on_menu_bar(b->cmdkey, &form, &label))
    {
        GRcolor_button(form, label,
                       b->filled_icon_index, b->fill_color, b->fill_in_color,
                       b->outline_icon_index, b->outline_color,
                       b->otl_in_color);
    }
}

/*
Name
        GRcustom_hilite_button

Description
        This function hilites a bar menu button by changing its colors and
        symbol indices.  The colors used are specified by the caller.  All
        displayed bar menus will be searched and updated.  If state is 0, then
        the menu button is returned to the default colors (but the symbol
        indices are still required).
*/

void GRcustom_hilite_button(char *command_key,
                            int state,
                            int filled_icon_index,
                            int input_fill_color,
                            int outline_icon_index,
                            int input_outline_color)
{
    GRbinfo binfo;
    
    /* pick the colors to use */
    if (state)
    {
        if (GRdisplay_has_fixed_vlt())
        {
            binfo.outline_color = input_outline_color;
            binfo.fill_color = input_fill_color;
        }
        else
        {
            binfo.outline_color = FI_BLACK;
            binfo.fill_color = FI_OFF_WHITE;
        }
    }
    else
    {
        binfo.outline_color = FI_BLACK;
        binfo.fill_color = FI_LT_GREY;
    }
    binfo.fill_in_color = FI_MED_GREY;
    binfo.otl_in_color = FI_WHITE;
    binfo.cmdkey = command_key;
    binfo.filled_icon_index = filled_icon_index;
    binfo.outline_icon_index = outline_icon_index;

    GRmonkey_with_forms(GR_FI_BAR_MENU_TYPE | GR_FI_TEAR_OFF_BAR_MENU_TYPE,
                        GRcustom_hilite_button_callback, &binfo);
}

/*
Name
        GRhilite_button

Description
        This function hilites a bar menu button by changing its symbol indices
        and colors.  The colors used are green and black.  For more details,
        see GRcustom_hilite_button above.
*/

void GRhilite_button(char *command_key,
                     int state,
                     int filled_icon_index,
                     int outline_icon_index)
{
    GRcustom_hilite_button(command_key, state, filled_icon_index, FI_GREEN, 
                           outline_icon_index, FI_BLACK);
}

/*
Name
        GRcolor_menu_button

Description
        This function is used to simply change the color of a bar menu icon.
        It is used to make the Delete command turn red when active.  This
        function is referenced from the COtools.color_menu_button.

History
        mrm     09/15/93    moved here from COtoolsi.I, 'cause I could never
                            remember where I put it
*/

typedef struct
{
    char *cmdkey;
    int color;
}   GRhlbinfo;

void GRcolor_menu_button_callback(Form form, GRhlbinfo *b)
{
    int label;

    if (GRfind_button_on_menu_bar(b->cmdkey, &form, &label))
    {
        FIg_set_off_color(form, label, b->color);       /* button out */
        FIg_set_on_color(form, label, b->color);        /* button in  */
        FIg_display(form, label);
    }
}

void GRcolor_menu_button(char *cmdkey, int color)
{
    GRhlbinfo b;

    b.cmdkey = cmdkey;
    b.color = color;
    GRmonkey_with_forms(GR_FI_BAR_MENU_TYPE | GR_FI_TEAR_OFF_BAR_MENU_TYPE,
                        GRcolor_menu_button_callback, &b);
}
