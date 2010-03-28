/*
Name
	APsingle_pick Single Select Form
        COsingle_pick Changed from APsingle_pick

Description
	This function requests the user to make a selection from a list of
	provided items (strings).

Dependencies
	none

History
	07-09-90	jlp		Creation
	12-31-90	jlp		Added dynamic form that could resize
	30 Jul 91	msl		Allow list_width/height to be passed
					in as NULL and compute defaults
        10/23/91        dhm             Converted from FEM to go in GRNUC
        06/23/92        scw             Added static ANSI C prototypes
        01/06/93        elp             Port to NT
        08/16/93        mrm             Added menu path display
	06/13/94	Sudha		Fix for TR#119419610 - display the
					form after resize.

*/

#ifdef ENV5
#include <tools.h>
#endif
#include <stdio.h>
#include <string.h>
#include <FI.h>
#include <FEI.h>
#include <FIdyn.h>
#include "OMminimum.h"
#include "OMerrordef.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "igr.h"
#include "igrdp.h"
#include "ex.h"
#include "exmacros.h"
#include "comisc.h"
#include "msdef.h"
#include "msmacros.h"
#include "grmsg.h"

/* form gadget labels */
#define	TITLE	                11
#define	LIST_FIELD	        12
#define SHOW_PATH               13
#define MENU_PATH_TITLE         818
#define MENU_PATH_SYMBOL        900

/* form dimensions */
#define MIN_HEIGHT	5
#define MAX_HEIGHT	20
#define MIN_WIDTH	40
#define MAX_WIDTH	70

/* gadget dimensions */
#define CHECK_WIDTH     50
#define CHECK_HEIGHT    20
#define CHECK_PAD       10
#define CHECK_PAD_2     20
#define CONTROL_WIDTH   30
#define CONTROL_WIDTH   30
#define SYMBOL_WIDTH    90
#define SYMBOL_HEIGHT   60
#define PAD             10
#define MAX_PATHS       4

/* bar/panel menu gadget labels */
#define LEVEL1_FIRST_INDEX     11
#define LEVEL1_MAX_INDEX       40
#define LEVEL2_FIRST_INDEX     1000
#define LEVEL2_MAX_INDEX       1300

/* GRpick_menu_path actions */
#define HILITE_BUTTON           0
#define RESET_BUTTON            1
#define PICK_BUTTON             2
#define ALMOST_PICK_BUTTON      3

/* misc */
#define MAX(a,b)        ((a > b) ? a : b)
#define MIN(a,b)        ((a < b) ? a : b)
#define COMMAND_LEN     128

typedef struct
{
    char symbol_file[32];
    int symbol_index;
    int hilite_color;
    int action;
}   button_info;

extern GRmenu_path_info *GRfind_menu_paths();

void GRdelete_menu_path_icons(Form form)
{
    int symbol_label;

    symbol_label = MENU_PATH_SYMBOL;
    while (FIg_erase(form, symbol_label) == FI_SUCCESS)
        FIg_delete(form, symbol_label++);
}

int GRexpand_for_menu_path(Form form, int nrows, int ncols)
{
    int w, h, gw, gh, gx, gy, fw, fh, changed = FALSE;
    char text[64];
    struct standard_st st;

    /* delete the old paths */
    GRdelete_menu_path_icons(form);

    /* check whether the form needs expanding */
    w = MAX((ncols * (PAD + SYMBOL_WIDTH)), 300);
    h = MIN(nrows, MAX_PATHS) * (PAD + SYMBOL_HEIGHT) + (PAD * 4);
    FIg_get_location(form, FI_MSG_FIELD, &gx, &gy);
    FIg_get_size(form, FI_MSG_FIELD, &gw, &gh);
    FIf_get_size(form, &fw, &fh);
    if ((w > fw) || (h > fh - gy - gh))
    {
        changed = TRUE;
        FIf_erase(form);
        FIf_set_size(form, MAX(w, fw), gy + gh + h + PAD);

        if (w > fw)
        {
            /* move the control gadgets over against the right edge */
            w -= 6;
            FIg_set_location(form, FI_ACCEPT, w - CONTROL_WIDTH, 6);
            FIg_set_location(form, FI_CANCEL, w - (CONTROL_WIDTH * 2), 6);
            FIg_set_location(form, FI_CVT_TO_PERM_WIN,
                             w - (CONTROL_WIDTH * 3), 6);
        }
        FIf_display(form);
    }

    /* add a title, if not already there */
    if (FIg_unhilite(form, MENU_PATH_TITLE) != FI_SUCCESS)
    {
        memset((char *)&st, 0, sizeof(st));
        st.xlo = PAD;
        st.ylo = fh;
        st.attr_mask = FI_TEXT_GADGET;
        ex$message(msgnumb = GR_I_MenuPathsToCommand, buff = text);
        st.text = text;
        st.fontname = "swiss742b";
        st.bodysize = 20.0;
        st.off_color = FI_BLACK;
        FIg_new(form, FI_TEXT, MENU_PATH_TITLE);
        FIg_set_standard_variables(form, MENU_PATH_TITLE, &st);
        FIg_activate(form, MENU_PATH_TITLE);
        FIg_display(form, MENU_PATH_TITLE);
    }
    return(changed);
}

int GRdisplay_menu_path(char *cmd, Form form)
{
    int sts, symbol_label, x, y, sx, sy, th, tw;
    int ii, jj, row, col, nrows, ncols, dups;
    char *key, task_name[32];
    struct standard_st st;
    struct EX_cmd cmd_info;
    GRmenu_path_info *p_mpi;
    GRmenu_button_info *p_button;

    /* translate the command name into a key */
    sts = ex$get_cmd_info(string = cmd, mode = EX_STRING, cmdstr = &cmd_info);
    if (!(sts & 1)) return(FALSE);
    key = cmd_info.command_key;
    
    /* find the path information */
    if ((p_mpi = GRfind_menu_paths(key)) == NULL)
        return(FALSE);

    /* figure out how much room will be needed for the paths */
    for (ii = 0, nrows = 0, ncols = 0; ii < p_mpi->npaths; ii++)
    {
        if (p_mpi->path[ii].is_duplicate == FALSE)
            nrows++;

        if (p_mpi->path[ii].nbuttons > ncols)
            ncols = p_mpi->path[ii].nbuttons;

      /* ----- VDS PROPOSED FIX -----
       * See if the supported ascii file in ./config/english/cmdpaths
       * is equal to the taskname. 
       * If true; EMS adds a button in display list.
       */       
  
      sts = ex$get_cmd_info( string = p_mpi->path[ii].task,
                             mode = EX_CMD_KEY,
                             cmdstr = &cmd_info);
 
      if (sts & 1) {
         if (p_mpi->path[ii].nbuttons + 1 > ncols )
             ncols = p_mpi->path[ii].nbuttons + 1;
      }

    }

    /* expand the form to accomodate the buttons */
    GRexpand_for_menu_path(form, nrows, ncols);
    
    /* add the buttons */
    dups = 0;
    row = 0;
    symbol_label = MENU_PATH_SYMBOL;
    memset((char *)&st, 0, sizeof(st));
    st.value = 0.0;
    st.off_color = FI_BLACK;
    st.on_color = FI_WHITE;
    st.off_color2 = FI_WHITE;
    st.on_color2 = FI_WHITE;
    FIg_get_location(form, MENU_PATH_TITLE, &x, &y);
    FIg_get_size(form, MENU_PATH_TITLE, &tw, &th);
    sx = PAD;
#ifdef X11
    sy = y + th + (PAD * 2);
#endif
#ifdef ENV5
    sy = y + th + PAD;
#endif
    for (ii = 0; ii < p_mpi->npaths && row < MAX_PATHS; ii++)
    {
        if (p_mpi->path[ii].is_duplicate == FALSE)
        {
            col = 0;
            st.ylo = sy + (row * (SYMBOL_HEIGHT + PAD));

            for (jj = -1; jj < p_mpi->path[ii].nbuttons; jj++)
            {
                if (jj == -1)
                {
                    /* add the task button */
                    st.fontname = "swiss742b";
                    st.bodysize = 14.0;
                    st.attr_mask = FI_TEXT_GADGET;
                    sts = ex$get_cmd_info(string = p_mpi->path[ii].task,
                                          mode = EX_CMD_KEY,
                                          cmdstr = &cmd_info);
                    if (!(sts & 1)) continue;
                    if (p_mpi->path[ii].has_duplicate)
                    {
                        strcpy(task_name, cmd_info.command_name_ptr);
                        strcat(task_name, "*");
                        st.text = task_name;
                    }
                    else
                        st.text = cmd_info.command_name_ptr;
                }
                else
                {
                    p_button = &p_mpi->path[ii].button[jj];
                    st.attr_mask = 0;
                    st.fontname = p_button->symbol_file;
                    st.symbol_index = p_button->off_symbol;
                    st.symbol_index2 =  p_button->on_symbol;
                }
                st.xlo = PAD + (col * SYMBOL_WIDTH);
                st.xhi = st.xlo + SYMBOL_WIDTH;
                st.yhi = st.ylo + SYMBOL_HEIGHT;
                FIg_new(form, FI_BUTTON, symbol_label);
                FIg_set_standard_variables(form, symbol_label, &st);
                FIg_activate(form, symbol_label);
                FIbtn_set_menu_status(form, symbol_label, 1);
                FIg_set_off_color2(form, symbol_label, FI_WHITE);
                FIg_display(form, symbol_label);
                symbol_label++;
                col++;
            }
            row++;
        }
        else
            dups++;
    }

    if (dups)
    {
        ex$message(msgnumb = GR_I_DupPathsFound, buff = cmd);
        FIfld_set_text(form, FI_MSG_FIELD, 0, 0, cmd, FALSE);
    }
    
    free(p_mpi);
    return(TRUE);
}

/*
Name
        GRpick_menu_path

Description
        This command is used to display the path to the command selected
        on the Get Command form.
*/

void GRpick_menu_path(Form form, button_info *b, int lo, int hi)
{
    int i, sts, type, symbol_index, color, x, y, action, displayed;
    char symbol_file[32], cmd[16];

    for (i = lo; i < hi; i++)
    {
        sts = FIg_get_type(form, i, &type);
        if ((sts != FI_SUCCESS) || (type != FI_BUTTON))
            continue;
        if (b->action == RESET_BUTTON)
        {
            FIg_get_off_color(form, i, &color);
            if (color == b->hilite_color)
            {
                FIg_set_off_color(form, i, FI_BLACK);
                FIg_set_on_color(form, i, FI_WHITE);
                FIg_display(form, i);
            }
        }
        else
        {
            sts = FIg_is_displayed(form, i, &displayed);
            if ((sts != FI_SUCCESS) || (!displayed))
                continue;
            sts = FIg_get_symbol_index(form, i, &symbol_index);
            if ((sts != FI_SUCCESS) || (symbol_index != b->symbol_index))
                continue;
            sts = FIg_get_symbol_file(form, i, symbol_file);
            if ((sts != FI_SUCCESS) || (strcmp(symbol_file, b->symbol_file)))
                continue;
            if (b->action == ALMOST_PICK_BUTTON)
            {
                *cmd = NULL;
                FIg_get_command(form, i, cmd);
                action = (*cmd) ? HILITE_BUTTON : PICK_BUTTON;
            }
            else
                action = b->action;

            if (action == HILITE_BUTTON)
            {
                FIg_set_off_color(form, i, b->hilite_color);
                FIg_set_on_color(form, i, b->hilite_color);
                FIg_display(form, i);
            }
            else if (action == PICK_BUTTON)
            {
                FIg_get_location(form, i, &x, &y);
                x += 5;
                y += 5;
#ifdef X11
                FIf_process_point(form, x, y, Button2, ButtonPress, 0);
#endif
#ifdef ENV5
                FIf_process_point(form, x, y, MIDDLE_BUTTON, SINGLE_CLICK, 0);
#endif
            }
        }
    }
}

void GRpick_menu_path_callback(Form form, button_info *b)
{
    int sts, type;

    GRpick_menu_path(form, b, LEVEL1_FIRST_INDEX, LEVEL1_MAX_INDEX);
    sts = FI_get_form_menu_type(form, &type);
    if (type == FI_PANEL_MENU_TYPE || type == FI_TEAR_OFF_PANEL_MENU_TYPE)
        GRpick_menu_path(form, b, LEVEL2_FIRST_INDEX, LEVEL2_MAX_INDEX);
}

/*
Name
        COsingle_pick_callback

Description
        This is the form callback used by COsingle_pick.
*/

#argsused
static void COsingle_pick_callback(
    int     f_label,        /* The label of the form   */
    int     g_label,        /* The label of the gadget */
    double  value,          /* The value of the gadget */
    Form    form)           /* Pointer to the form     */
{
    int sts, i, l, row, pos, resp, flag, display_path;
    int x, y, x1, y1, attr, type;
    long msg, size;
    char cmd[COMMAND_LEN], active_task[32], path_task[32], *c;
    button_info b;
    struct EX_cmd cmd_info;
    
    FIfld_set_text(form, FI_MSG_FIELD, 0, 0, "", FALSE);
    FIf_get_user_pointer(form, (char *)&display_path);

    if (display_path)
    {
        /* unhilite any previously-displayed menu path */
        b.action = RESET_BUTTON;
        b.hilite_color = FI_BLUE;
        GRmonkey_with_forms(GR_FI_BAR_MENU_TYPE |
                            GR_FI_PANEL_MENU_TYPE |
                            GR_FI_TEAR_OFF_BAR_MENU_TYPE |
                            GR_FI_TEAR_OFF_PANEL_MENU_TYPE,
                            GRpick_menu_path_callback, &b);
    }

    switch (g_label)
    {
      case FI_ACCEPT:

        /* get the command the user chose to invoke */
        FIfld_get_active_row(form, LIST_FIELD, &row, &pos);
        FIfld_get_text(form, LIST_FIELD, row, 0, COMMAND_LEN, 
                       cmd, &flag, &pos);

        /* invoke the command */
        resp = CMD_STRING;
        size = strlen(cmd) + 1;
        sts = ex$putque(msg = &msg,
                        response = &resp,
                        byte = &size,
                        buffer = cmd);

        /* no break !! */
        
      case FI_CANCEL:

        /* delete the form */
        FIf_erase(form);
        FIf_delete(form);
        resp = EX_FORM_FINISHED;
        sts = ex$putque(msg = &msg,
                        response = &resp);
        break;
        
      case FI_CVT_TO_PERM_WIN:
        break;
        
      case LIST_FIELD:

        if (display_path)
        {
            /* get the command the user chose to invoke */
            FIfld_get_active_row(form, LIST_FIELD, &row, &pos);
            FIfld_get_text(form, LIST_FIELD, row, 0, COMMAND_LEN, cmd,
                           &flag, &pos);

            /* display the path */
            sts = GRdisplay_menu_path(cmd, form);
            if (!sts)
            {
                ex$message(msgnumb = GR_I_MenuPathNotFound, buff = cmd);
                FIfld_set_text(form, FI_MSG_FIELD, 0, 0, cmd, FALSE);
                GRdelete_menu_path_icons(form);
            }
        }
        break;

      case SHOW_PATH:

        if (value)
        {
            /* unchecked -> checked */
            FIf_set_user_pointer(form, (char *)1);
            COsingle_pick_callback(f_label, LIST_FIELD, value, form);
        }
        else
        {
            /* checked -> unchecked */
            if (display_path)
            {
                GRdelete_menu_path_icons(form);
                FIf_set_user_pointer(form, (char *)0);
            }
        }
        break;
        
      default:

        // Okay, this might be a button.  Try to highlight the menu path
        // displayed by this row of buttons.

        FIg_get_type(form, g_label, &type);
        if (type != FI_BUTTON)
            break;

        if (display_path == FALSE)
            break;

        /* depress the other buttons on this row, raise the other rows */
        i = MENU_PATH_SYMBOL;
        FIg_get_location(form, g_label, &x, &y);
        while (FIg_unhilite(form, i) == FI_SUCCESS)
        {
            FIg_get_location(form, i, &x1, &y1);
            if (y == y1)
                FIg_set_state_on(form, i);
            else
                FIg_set_state_off(form, i);
            i++;
        }

        /* find all the first button on this row */
        FIg_get_location(form, g_label, &x, &y);
        x += 5;
        y += 5;
        while (x > 0)
            x -= SYMBOL_WIDTH;
        x += SYMBOL_WIDTH;
        if (FIf_find_gadget(form, FI_FORM_GROUP, x, y, &l) != FI_SUCCESS)
            break;

        /* check whether the task presented is active */
        FIg_get_attr(form, l, &attr);
        if (attr & FI_TEXT_GADGET)
        {
            x += SYMBOL_WIDTH;
            FIg_get_text(form, l, path_task);
            if (*path_task)
            {
                if (c = strchr(path_task, (int)'*'))
                    *c = NULL;
                sts = ex$get_cmd_info(string = path_task,
                                      mode = EX_STRING,
                                      cmdstr = &cmd_info);
                if (sts & 1)
                {
                    GRget_active_task(active_task);
                    if (strcmp(active_task, cmd_info.command_key) != 0)
                    {
                        /* swap to the task containing this command - Paul
                           said to go for it */
                        char panel[32], bar[32], pocket[32];
                        *panel = NULL;
                        *bar = NULL;
                        *pocket = NULL;
                        sscanf(cmd_info.input_string, "%*s %*s %s %s %s",
                               panel, bar, pocket);
                        GRswap_task(cmd_info.command_key, panel, bar, pocket);
#if 0
                        /* Use this code instead if swapping tasks is
                           considered rude */
                        ex$message(msgnumb = GR_E_CmdInOtherTask,
                                   type = "%s",
                                   var = `path_task`,
                                   buff = cmd);
                        FIfld_set_text(form, FI_MSG_FIELD, 0, 0, cmd, FALSE);
                        break;
#endif
                    }
                }
            }
        }

        /* find the other buttons and "poke" the corresponding menu buttons */
        while (FIf_find_gadget(form, FI_FORM_GROUP, x, y, &l) == FI_SUCCESS)
        {
            b.action = ALMOST_PICK_BUTTON;
            FIg_get_symbol_file(form, l, b.symbol_file);
            FIg_get_symbol_index(form, l, &b.symbol_index);
            GRmonkey_with_forms(GR_FI_BAR_MENU_TYPE |
                                GR_FI_PANEL_MENU_TYPE |
                                GR_FI_TEAR_OFF_BAR_MENU_TYPE |
                                GR_FI_TEAR_OFF_PANEL_MENU_TYPE,
                                GRpick_menu_path_callback, &b);
            x += SYMBOL_WIDTH;
        }
        break;
    }
}

/*
Name
        COcreate_single_pick_form

Description
        This function creates a form containing a list of strings.
*/

int COcreate_single_pick_form(char *title,
                              int num_items,
                              char *item_list[],
                              int list_width,
                              int list_height,
                              Form *ptr_to_list_form)

{
    int sts, bottom_of_list, right_of_list, mx_len, len, i, x, y;
    Form list_form;
    struct standard_st standard_attr;
    
    /* if list_width & height = NULL, then set via algorithm below */
    if (!list_height)
        list_height = (num_items < MIN_HEIGHT) ?
            MIN_HEIGHT : (num_items > MAX_HEIGHT) ? MAX_HEIGHT : num_items;
    if (!list_width)
    {
        mx_len = 0;
        for (i=0; i<num_items; i++)
        {
            len = strlen(item_list[i]);
            if (len > mx_len) mx_len = len;
        }
        
        list_width = (mx_len < MIN_WIDTH) ? MIN_WIDTH :
        (mx_len > MAX_WIDTH) ? MAX_WIDTH : mx_len;
    }
    
    /* create the form */
    
    sts = FIf_new(333, "", COsingle_pick_callback, ptr_to_list_form);
    if (sts != FI_SUCCESS)
        return(FALSE);
    
    list_form = *(ptr_to_list_form);
#if !defined(NT)
    FIf_set_screen(list_form, FI_CURRENT_SCREEN);
#endif
#ifdef X11
    GRget_form_decoration(&x, &y);
    y *= 2;
#else
    y = 0;
#endif
    x = 0;
    FIf_set_location(list_form, x, y + 105);
    right_of_list  = 15 + 9 * list_width;
    bottom_of_list = 45 + 18 * list_height;
    FIf_set_size(list_form, right_of_list + 44, bottom_of_list + 44);
    FIf_set_orig_coord(list_form, right_of_list + 43, bottom_of_list + 53);
    FIf_set_color(list_form, FI_LT_GREY);
    FIf_set_collapse_symbol(list_form, "collapse.icon", 0);
    FIf_set_attr(list_form,
                 FI_SAVE_RESTORE | FI_NOT_SCALABLE | FI_NOT_RESIZABLE);
    
    /*
     * Gadget attributes common to most gadgets here created.  M.S.L Aug 91
     */
    
    standard_attr.next_in_seq = 0;
    standard_attr.attr_mask = 0;
    standard_attr.value = 0.000000;
    standard_attr.bodysize = 15.000000;
    standard_attr.text = "";
    standard_attr.help_topic = "";
    standard_attr.command = "";
    standard_attr.off_color = FI_BLACK;
    standard_attr.on_color = FI_OFF_WHITE;
    standard_attr.symbol_index2 = 0;
    
    /*
        Create the FI_ACCEPT gadget
    */
    
    FIg_new(list_form, FI_BUTTON, FI_ACCEPT);
    standard_attr.xlo = right_of_list + 9; /*365*/
    standard_attr.ylo = 5;
    standard_attr.xhi = right_of_list + 39; /*395*/
    standard_attr.yhi = 35;
    standard_attr.fontname = "FIsym";
    standard_attr.symbol_index = 11;
    FIg_set_standard_variables(list_form, FI_ACCEPT, &standard_attr);
    FIg_set_attr(list_form, FI_ACCEPT, FI_DEFAULT);
    FIg_set_justification(list_form, FI_ACCEPT, FI_CENTER_JUSTIFIED);
    FIbtn_set_auto_pop_up_on(list_form, FI_ACCEPT);
    FIg_activate(list_form, FI_ACCEPT);
    
    /*
        Create the FI_CANCEL gadget
    */
    
    FIg_new(list_form, FI_BUTTON, FI_CANCEL);
    standard_attr.xlo = right_of_list - 21; /*335*/
    standard_attr.ylo = 5;
    standard_attr.xhi = right_of_list + 9; /*365*/
    standard_attr.yhi = 35;
    standard_attr.fontname = "FIsym";
    standard_attr.symbol_index = 8;
    FIg_set_standard_variables(list_form, FI_CANCEL, &standard_attr);
    FIg_set_attr(list_form, FI_CANCEL, FI_DEFAULT);
    FIg_set_justification(list_form, FI_CANCEL, FI_CENTER_JUSTIFIED);
    FIbtn_set_auto_pop_up_on(list_form, FI_CANCEL);
    FIg_activate(list_form, FI_CANCEL);
    
    /*
        Create the FI_CVT_TO_PERM_WIN gadget
    */
    
    FIg_new(list_form, FI_BUTTON, FI_CVT_TO_PERM_WIN);
    standard_attr.xlo = right_of_list - 51; /*335*/
    standard_attr.ylo = 5;
    standard_attr.xhi = right_of_list - 21; /*365*/
    standard_attr.yhi = 35;
    standard_attr.fontname = "FIsym";
    standard_attr.symbol_index = 13;
    FIg_set_standard_variables(list_form, FI_CVT_TO_PERM_WIN, &standard_attr);
    FIg_set_attr(list_form, FI_CVT_TO_PERM_WIN, FI_DEFAULT);
    FIg_set_justification(list_form, FI_CVT_TO_PERM_WIN, FI_CENTER_JUSTIFIED);
    FIbtn_set_auto_pop_up_on(list_form, FI_CVT_TO_PERM_WIN);
    FIg_activate(list_form, FI_CVT_TO_PERM_WIN);
    
    /*
        Create the FI_MSG_FIELD gadget
    */
    
    FIg_new(list_form, FI_FIELD, 10);
    standard_attr.xlo = 15;
    standard_attr.ylo = bottom_of_list + 13; /*190*/
    standard_attr.xhi = right_of_list  + 28; /*384*/
    standard_attr.yhi = bottom_of_list + 31; /*208*/
    standard_attr.attr_mask = 256;
    standard_attr.fontname = "mono821b";
    standard_attr.symbol_index = 13;
    FIg_set_standard_variables(list_form, 10, &standard_attr);
    FIg_set_attr(list_form, 10, FI_TEXT_GADGET);
    FIfld_set_attr(list_form, 10, 0, FI_HORT_SCROLL);
    FIfld_set_mode(list_form, 10, 0, FI_REVIEW);
    FIfld_set_type(list_form, 10, 0, FI_ALPHA);
    FIg_set_high_value(list_form, 10, 0.000000);
    FIg_set_low_value(list_form, 10, 0.000000);
    FIg_activate(list_form, 10);
    FIg_set_justification(list_form, 10, FI_LEFT_JUSTIFIED);
    FIfld_set_format_string(list_form, 10, 0, "%d");
    
    /*
        Create a title string gadget
    */
   
    FIg_new(list_form, FI_TEXT, TITLE);
    standard_attr.xlo = 10;
    standard_attr.ylo = 5;
    standard_attr.xhi = 22;
    standard_attr.yhi = 29;
    standard_attr.attr_mask = 256;
    standard_attr.bodysize = 20.000000;
    standard_attr.fontname = "swiss742b";
    standard_attr.symbol_index = 48;
    FIg_set_standard_variables(list_form, TITLE, &standard_attr);
    FIg_set_attr(list_form, TITLE, FI_TEXT_GADGET);
    FIg_set_text_style(list_form, TITLE, FI_NORMAL_TEXT);
    FIg_set_justification(list_form, TITLE, FI_LEFT_JUSTIFIED);
    FIg_set_text(list_form, TITLE, title);
    FIg_activate(list_form, TITLE);
    
    
    /*
        Create the selection list gadget
    */
    
    FIg_new(list_form, FI_FIELD, LIST_FIELD);
    standard_attr.xlo = 15;
    standard_attr.ylo = 45;
    standard_attr.xhi = right_of_list; /*356*/ 
    standard_attr.yhi = bottom_of_list; /*177*/ 
    standard_attr.attr_mask = 256;
    standard_attr.bodysize = 15.000000;
    standard_attr.fontname = "mono821b";
    standard_attr.symbol_index = 13;
    FIg_set_standard_variables(list_form, LIST_FIELD, &standard_attr);
    FIg_set_attr(list_form, LIST_FIELD, FI_TEXT_GADGET);
    FIfld_set_attr(list_form, LIST_FIELD, 0, FI_VERT_SCROLL |
                   FI_HORT_SCROLL |
                   FI_DISPLAY_VSCROLL);
    FIfld_set_mode(list_form, LIST_FIELD, 0, FI_SINGLE_SELECT);
    FIfld_set_type(list_form, LIST_FIELD, 0, FI_ALPHA);
    FIg_set_high_value(list_form, LIST_FIELD, 0.000000);
    FIg_set_low_value(list_form, LIST_FIELD, 0.000000);
    /*FIfld_set_num_vis_chars(list_form, LIST_FIELD, 0, list_width);*/
    FIg_activate(list_form, LIST_FIELD);
    FIg_set_justification(list_form, LIST_FIELD, FI_LEFT_JUSTIFIED);
    FIfld_set_format_string(list_form, LIST_FIELD, 0, "%d");
    
    /* fill in the form */
    for (i = 0; i < num_items; i++)
        FIfld_set_text(list_form, LIST_FIELD, i, 0, item_list[i], FALSE);
    
    return(TRUE);
}

/*
Name
        COadd_menu_path_toggle

Description
        This function adds a toggle to the list form to turn off the menu path
        display.
*/

int COadd_menu_path_toggle(Form form)
{
    int x, y, w, h, ch, cw;
    char text[64];
    struct standard_st st;
    
    /* contruct the toggle gadget below the list gadget */
    memset((char *)&st, 0, sizeof(st));
    FIg_get_location(form, LIST_FIELD, &x, &y);
    FIg_get_size(form, LIST_FIELD, &w, &h);
    ex$message(msgnumb = GR_P_DisplayMenuPath, buff = text);
    st.xlo = x;
    st.ylo = y + h + CHECK_PAD;
    st.attr_mask = FI_TEXT_GADGET;
    st.value = 1;
    st.bodysize = 15.0;
    st.text = text;
    st.fontname = "mono821b";
    st.off_color = FI_BLACK;
    FIg_new(form, FI_CHECKLIST, SHOW_PATH);
    FIg_set_standard_variables(form, SHOW_PATH, &st);
    FIg_activate(form, SHOW_PATH);
    
    /* expand the form for the new gadget */
    FIg_get_size(form, SHOW_PATH, &cw, &ch);
    FIf_get_size(form, &w, &h);
    FIf_set_size(form, w, h + ch + CHECK_PAD);
    
    /* slide the message field down */
    FIg_get_location(form, FI_MSG_FIELD, &x, &y);
    FIg_set_location(form, FI_MSG_FIELD, x, y + ch + CHECK_PAD);
    
    return(TRUE);
}

/*
Name
        COpick_command_from_list

Description
        This function displays a form containing a list of strings for the
        user to select.  When an entry is selected and accepted (by checking
        off the form), the text of the entry is pushed on the software queue.
        If the display_path arg is TRUE, then the list is assumed to be a
        series of command names, and a separate form is used to display the
        menu path to each command as it is selected.  This option is used by
        the Get Command.
*/

int COpick_command_from_list(
    char *title,        /* i - Form's body text */
    char *item_list[],  /* i - Array of pointers to displayed strings */
    int num_items,      /* i - number of items to be displayed */
    int list_width,     /* i - The displayed list's width in characters */
    int list_height,    /* i - The displayed list's height in characters */
    int display_path,   /* i - Display the menu path to the command */
    Form *form)         /* o - Form created here */
{
    int sts;
    
    sts = OM_S_SUCCESS;
    
    /* create the form */
    sts = COcreate_single_pick_form(title, num_items, item_list,
                                    list_width, list_height, form);
    
    if (display_path)
    {
        /* add the toggle to display the menu path to the selected command */
        COadd_menu_path_toggle(*form);
        GRexpand_for_menu_path(*form, 2, 4);
        FIf_set_user_pointer(*form, (char *)1);
    }
    
    /* display the form (if GRexpand_for_menu_path hasn't already done so */
    FIf_is_displayed(*form, &sts);
    if (!sts)
        FIf_display(*form);
    
    return(sts);
}


int COsingle_pick(
    char *title,        /* i - Form's body text */
    char *item_list[],  /* i - Array of pointers to displayed strings */
    int num_items,      /* i - number of items to be displayed */
    int list_width,     /* i - The displayed list's width in characters */
    int list_height)    /* i - The displayed list's heigth in characters */
{
    return(COpick_command(title, item_list, num_items,
                          list_width, list_height, FALSE));
}
