/* $Id: COsglpick.C,v 1.1.1.1 2001/01/04 21:07:28 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/emsfixes/grnuc / COsglpick.C
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: COsglpick.C,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:28  cvs
 *	Initial import to CVS
 *	
 * Revision 1.1  1998/04/29  16:27:20  pinnacle
 * VDS 2.5.1
 *
 * Revision 1.1  1997/05/08  13:20:44  pinnacle
 * New project VDS 250
 *
 * Revision 1.1  1996/07/19  20:33:52  pinnacle
 * Create VDS 241 project
 *
 * Revision 1.1  1994/11/14  22:42:32  pinnacle
 * Create vds.240 from vds.232
 *
 * Revision 1.1  1994/11/08  16:07:00  pinnacle
 * create vds.232
 *
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *
 * -------------------------------------------------------------------*/

/*
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

extern	GRmenu_path_info *GRfind_menu_paths(); 

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

	/*
	 * see if the supported ASCII file in ./config/english/cmdpaths
	 * is equal to the taskname. 
 	 * If true; EMS adds a button in display list.
	 */

        sts = ex$get_cmd_info(string = p_mpi->path[ii].task,
                              mode = EX_CMD_KEY,
                              cmdstr = &cmd_info);
        if (sts & 1){
          if (p_mpi->path[ii].nbuttons + 1 > ncols)
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

