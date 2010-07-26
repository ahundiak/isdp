/*
Library:

    Pop Up Palette Library
   
Description:

    This library defines all functions used to create, modify and manage 
    pop up palettes.
   
History:

    jay wallingford     08/26/91    creation date
    mrm                 10/06/91    Sun port changes
                        11/11/91    allow single-click invocation
    rlw                 01/29/92    Modified GRpopup_process to work
                                    with journaling and RAP
    mrm                 02/04/92    extended cases which handle journaling,
                                    place the popup on the same screen
                                    as the menu that invoked it
    rlw                 02/21/92    Modified Mike's changes to write to
                                    the journal file only if we are recording.
    rlw                 02/25/92    Modified my fix of 01/29/92 to support X.
    rlw                 03/10/92    Modified to support X journaling API
    scw                 03/12/92    Initialized the name_ptr to NULL in the
                                    GRdisplay_command_name function.
    jjm                 03/16/92    Modified so popups would activate as the
				    cursor is moved across the menu bar
    mrm			03/19/92    Modified to fake save-restore-ness
    mrm                 06/29/92    Modified to allow customization of the 
                                    positioning of the popup, as well as of
                                    the mouse button designated to invoke the
                                    popup.  Also allow popups to be defined by
                                    form files (in addition to palette files).
    mrm                 09/04/92    moved popup positioning code from creation
                                    to whenever popup is referenced
    mrm                 09/09/92    added GRdelete_popups, mainly for use from
                                    switchprod (since popups can differ between
                                    products)
    mrm                 01/30/93    fixed X journaling
    dkk(igi)            10/11/94    fixed a problem in X journaling
*/

class implementation GRpalmgr;

#include <stdio.h>
#include <ctype.h>
#include <limits.h>
#include <string.h>
#include <alloca.h>
#include <sys/param.h>
#include <sys/types.h>
#ifdef ENV5
#include <tools.h>
#endif
#include "dpgraphics.h"
#include "exdef.h"
#include "ex.h"
#include "exlocale.h"
#include "exmacros.h"
#include "execmsg.h"
#include "msdef.h"
#include "msmacros.h"
#include "journal.h"

/* types of popups available */
#define PUSH_AND_HOLD           1
#define CLICK_AND_RELEASE       2

/* label for gadget drawn around popup border */
#define BorderLabel     1776

/* external references */
extern char EX_version[];
extern int JNL_playback();
extern int JNL_journal();
extern int EX_get_cmd_info();

/* structure used for the linked list of popups */
struct popup 
{
    Form form;
    char *palette;
    char *command;
    struct popup *next;
};

/* 
 * Pop up library globals.
 */
%safe
static struct popup  * GRpopup_palettes = NULL; 
static int             GRpopup_num_fp = 0;
static FILE         ** GRpopup_fp = NULL;
static int             GRpopup_justification = PAL_CENTER_JUSTIFY;
#ifdef X11
static int             GRpopup_invocation_button = Button1;
#else
static int             GRpopup_invocation_button = LEFT_BUTTON;
#endif
%endsafe

/****************************************************************************
        Customization Functions
 ****************************************************************************/

/*
Function
        GRset_popup_justification

Description
        This function allows customization of the popup with respect to the
        button which invoked it.  See palgo.h for valid settings.  This is a
        system-wide setting which will be used for all popups.  The
        new/current setting is returned.  If just is NULL, then no change is
        made to the existing setting.
*/

int GRset_popup_justification(just)
int just;
{
    if (just)
        GRpopup_justification = just;
    return(GRpopup_justification);
}

/*
Function
        GRset_popup_invocation_button

Description
        This function allows customization of the mouse button which is used
        to invoke the popup menus.  The valid values depend on the windowing
        system in use (X or Environ V).  This is a system-wide setting which
        will be used for all popups.  The new/current setting is returned.
*/

int GRset_popup_invocation_button(button)
int button;
{
    return(GRpopup_invocation_button = button);
}

/****************************************************************************
    LINKED LIST FUNCTIONS
 ****************************************************************************/
/*
 * Function:
 *  
 *      GRpopup_create_node
 *
 * Description:
 *
 *      This is an internal routine which creates and links in a popup
 *      node into the popup linked list.
 *
 */
static struct popup * GRpopup_create_node()
{
    struct popup  *p, *q;

    q = NULL;

    if (p = (struct popup *)malloc(sizeof(struct popup)))
    {
        p->next = NULL;

        if (GRpopup_palettes == NULL)
            GRpopup_palettes = p;
        else 
        {
            q = GRpopup_palettes;
            while (q->next) q = q->next;
            q->next = p;
        }
    }

    return(p);
}

/*
Function
        GRdelete_popups

Description
        This function deletes all popups.  This can be necessary, for example,
        in switchprod, when the popup definition may differ between products.
        In addition, the pointers to the popup files are all closed, since the
        list of available products may change during a switchprod.  The new
        list will be opened later when any popup is referenced.
*/

void GRdelete_popups()
{
    int i;
    struct popup *p, *n;

    /* free the popup list */
    p = GRpopup_palettes;
    while (p)
    {
        FIf_delete(p->form);
        free(p->palette);
        n = p->next;
        free(p);
        p = n;
    }
    GRpopup_palettes = NULL;

    /* close the file pointers */
    if (GRpopup_fp)
    {
        for (i = 0; i < GRpopup_num_fp; i++)
            fclose(GRpopup_fp[i]);
        free(GRpopup_fp);
        GRpopup_fp = NULL;
        GRpopup_num_fp = 0;
    }
}

/************************************************************************/
/*    FILE                                                              */
/************************************************************************/
/*
 * Function:
 *  
 *      GRpopup_set_fp
 *
 * Description:
 *
 *      This routine sets up a list of file pointers to the 
 *      $PRODUCT/config/popups files. 
 *
 */
#define A_LOT_OF_FPS 50
extern int GRpopup_set_fp()
{
    int i, ok = TRUE;
    FILE * fp[A_LOT_OF_FPS];
    char path[MAXPATHLEN];

    if (GRpopup_num_fp && GRpopup_fp) goto quit;

    for (i = 0; (ok == TRUE) && (GRpopup_num_fp < A_LOT_OF_FPS); i++)
    {
        if (ok = ex$get_path(index = i, path = path, len = 1024))
        {
            /* construct the path to the popups list file */
            strcat(path, "config/popups");
            if (fp[GRpopup_num_fp] = (FILE *)fopen(path, "r")) 
                ++GRpopup_num_fp;
        }
    }

    /* set up the static fps */
    GRpopup_fp = (FILE **)calloc(GRpopup_num_fp, sizeof(FILE *));
    for (i = 0; i < GRpopup_num_fp ; i++) GRpopup_fp[i] = fp[i];

quit:

    return(GRpopup_num_fp);
}

/*
Name
        GRpopup_find

Description
        This routine searches for the popup definition file which goes with
        the specified command and palette combination by scanning the
        config/popup files for a match.

Notes
        The config/popup file is an ASCII file of the format:

                CommandKey[,PaletteName],PopupFile

         The commas are required.  Blank lines and lines beginning with '#'
         are ignored.  The PaletteName field may be absent or empty.

History
        mrm     09/13/93    added support for palette name
*/
extern int GRpopup_find(char *command, char *palette, char *filename)
{
    int i, check_palette;
    char line[1024], *p, *e, *xpalette, *xcommand, *xfilename;
    FILE *fp;

    // make sure the command is not null - TR#119528116
    if ((!command) || (!*command)) return(0);

    // make sure the popup files are open
    if (!GRpopup_set_fp()) return(0);

    // check whether the caller asked to check the palette
    check_palette = (palette && *palette) ? TRUE : FALSE;

    // loop through each popup file
    for (i = 0; i < GRpopup_num_fp; ++i)
    {
        fp = GRpopup_fp[i];
        while (fgets(line, 1024, fp) != NULL) 
        {
            // skip comments & blank lines
            if (*line == '#' || *line == NULL) continue;

            // isolate the command key & check for a matching command
            p = line;
            while (isspace(*p)) p++;
            xcommand = p;
            while (*p && (*p != ',')) p++;
            *p = NULL;
            if (strcmp(xcommand, command) == 0)
            {
                // isolate optional palette name, if present
                p++;
                while (isspace(*p)) p++;
                if (e = strchr(xpalette = p, ','))
                {
                    // isolate & (usually) check the palette name
                    *e = NULL;
                    if (*xpalette &&
                        check_palette &&
                        strcmp(xpalette, palette))
                        continue;
                    p = ++e;
                }

                // isolate the popup file name & copy it into the output arg
                while (isspace(*p)) p++;
                xfilename = p;
                while (isalnum(*p)) p++;
                *p = NULL;
                strcpy(filename, xfilename);

                // bail out
                rewind(fp);
                return(1);
            }
        }
        rewind(fp);
    }
    return(0);
}

/************************************************************************/
/*    CREATE/PROCESS                                                    */
/************************************************************************/
/*
Name
        GRpopup_create

Description
        This routine creates a popup for a given command if it doesn't exist.

Notes
        The form and label args are used to determine the name of the menu
        palette that contains the button in question.  This allows the user
        interface groups to easily add the same popup to different areas of
        the panel menu.  This used to be much uglier for them; they had to use
        command aliases, copy & rename cob command files, etc.  The parent
        palette will only be checked if the application specifies a palette in
        the popup file.

        The bar menu buttons are not part of a palette, and NC attaches popups
        to forms, in addition to menus, so care must be taken to allow these
        buttons to support popups.  If the button is not in a group, or the
        group does not contain any text, then the name of the form is used as
        its palette.  Again, the parent palette will only be checked if the
        application specifies a palette in the popup file.

History
        mrm     09/15/93    added check for button palette
*/
#argsused
extern struct popup *GRpopup_create(msg, command, menu_form, menu_label)
int *msg; 
char *command;
Form menu_form;
int menu_label;
{
    struct popup *pu = NULL;
    int label;
    char filename[MAXPATHLEN], palette[32];

    *msg = PAL_S_SUCCESS;

    // Get the name of the menu palette containing this button - it is stored
    // as text in the button's group.  If the button is not part of a palette,
    // then use the form's name.  See Notes above.
    *palette = NULL;
    if (FIg_get_group_label(menu_form, menu_label, &label) == FI_SUCCESS)
        FIg_get_text(menu_form, label, palette);
    if (*palette == NULL)
        GRget_form_name(menu_form, palette);

    // check whether the command's popup has already been allocated
    pu = GRpopup_palettes;
    while (pu)
    {
        if ((strcmp(pu->command, command) == 0) &&
            ((*palette == NULL) || strcmp(pu->palette, palette) == 0))
            return(pu);
        else
            pu = pu->next;
    }

    // look for a definition in the config/popup files
    if (GRpopup_find(command, palette, filename))
    {
        char path[MAXPATHLEN];
        char symbol_file[80], cmd[80], version[50];
        FILE *fp;
        struct palette *p = NULL;
        Form form = NULL;
        int properties, rows, cols, row, col, color, xpos, ypos;
        int xsize, ysize, btn_x, btn_y, btn_on_color, btn_off_color;
        int i, symbol, len, cmd_type, version_change = FALSE;

        path[0] = NULL;
        *msg = PAL_S_SUCCESS;

        if (!GRpal_check_file(filename, path, 0x04) || 
            !(fp = (FILE *)fopen(path, "r")))
        {
            *msg = PAL_E_ABORT;
            goto quit;
        }

        // Check whether the file is really a palette
        if (GRis_palette_file(NULL, fp))
        {
            // Read in the file header
            if (fscanf(fp,"%[^,],%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d\n",
                       version,
                       &properties,&rows,&cols,&color,&xpos,&ypos,
                       &xsize,&ysize,&btn_x,&btn_y,&btn_on_color,
                       &btn_off_color) == 13)
            {
                // Check for unreasonable data
                if ((rows > 15)         || (cols > 15)          ||
                    (rows < 1)          || (cols < 1)           || 
                    (xpos < 0)          || (ypos < 0)           ||
                    (xpos > 1183)       || (ypos > 883)         ||
                    (btn_x < 0)         || (btn_y < 0)          ||
                    (btn_x > 500)       || (btn_y > 500)        ||
                    (color < 0)         || (color > 14)         || 
                    (xsize > 1183)      || (ysize > 883)        ||
                    (btn_on_color < 0)  || (btn_on_color > 14)  ||
                    (btn_off_color < 0) || (btn_off_color > 14))
                {
                    *msg = PAL_E_ABORT;
                    goto quit;
                }

                // Check for a version change.
                if (strcmp(version, EX_version)) version_change = TRUE;

                // Adjust the properties.
                properties = (properties & PAL_YADJUSTED) | PAL_NODISPLAY;

                // Create a blank palette.
                if (!(p = (struct palette *)
                      GRpal_create(msg, 
                                   properties, 
                                   rows, cols, 
                                   color, 
                                   xpos,
                                   (properties & PAL_YADJUSTED) ? 
                                   ypos : ypos + 55, 
                                   xsize, ysize,
                                   btn_x, btn_y, 
                                   btn_on_color, btn_off_color)))
                    goto quit;
            }
        }
        else if (GRis_form_file(NULL, fp)) // check for a form file
        {
            // create the form
            if (FIf_new(0, path, NULL, &form) == FI_SUCCESS)
            {
                // allocate a fake palette structure - only the form field
                // will be referenced from here on
                p = (struct palette *)alloca(sizeof(struct palette));
                p->form = form;
            }
            else 
            {
                *msg = PAL_E_ABORT;
                goto quit;
            }
        }
        else 
        {
            *msg = PAL_E_ABORT;
            goto quit;
        }
            
        // Open the outline file. 
        if (version_change) GRpal_set_outline_fp();

        // Unset the button intercept routine.
        FIf_set_button_intercept_routine(p->form, NULL);

        // Make the form save restore.
#ifdef X11
        // The form cannot think that it is save-restore in XFORMS because
        // XFORMS (as of 1.0.7) implements its own input loop while a
        // save-restore is active.  Their input loop cycles until an FIf_erase
        // is sent to the form.  That would hose up a popup royally, since it
        // doesn't send FIf_erase until the popup input loop is completed.
        // Therefore, the form must be tricked into becoming an X saveunder
        // window.
    {
        Window w;
        XSetWindowAttributes winatt;

        FIf_get_window(p->form, &w);
        winatt.save_under = TRUE;
        XChangeWindowAttributes(EXdisplay, w, CWSaveUnder, &winatt);
        i = FI_LINE_BORDER | FI_NO_BEZEL;
    }
#else
        i = FI_LINE_BORDER | FI_NO_BEZEL | FI_SAVE_RESTORE;
#endif
        FIf_set_attr(p->form, i);

        if (form == NULL)
        {
             // Put the buttons on the palette.
            while (fscanf(fp,
                          "%d,%d,%[^,],%d,%[^,],%d\n", 
                          &row, &col, cmd, &cmd_type,
                          symbol_file, &symbol) == 6)
            {
                len = strlen(cmd);
                for (i = 0; i < len; i++)
                    if (cmd[i] == '%')  
                    cmd[i] = ',';

                len = strlen(symbol_file);
                for (i = 0; i < len; i++)
                    if (symbol_file[i] == '%') 
                    symbol_file[i] = ','; 
#if GetCurrentSymbol
                // Get the most current version of the symbol using the
                // command key.  This is not really necessary with the popups,
                // since Intergraph should verify them before each release,
                // and it is an expensive (read: slow) operation to do it on
                // first reference to each popup.

                if ((cmd_type == FI_CMD_KEY) &&
                    version_change && (symbol != -1))
                {
                    if (!GRpal_get_cmd_icon(cmd, symbol_file, &symbol)) 
                    {
                        strncpy(symbol_file, cmd, PAL_MAX_LABEL);
                        symbol_file[PAL_MAX_LABEL] = NULL;
                        symbol = -1;
                    }
                }
#endif
                GRpal_add_cmd(p, row, col, cmd_type, cmd, symbol_file,
                              symbol);
            }
        }

        fclose(fp);

#ifdef ENV5
        // Add a colored border to the Environ V popup to distinguish it from
        // the menu beneath it, since sometimes it is not immediately apparent
        // that a popup is present over the panel menu.  This is not necessary
        // for the X Window version since the window manager border sets the
        // popup apart from the menu panel.  TR119302503.
    {
        int width, height;
        struct standard_st st;

        FIg_new(p->form, FI_RECT, BorderLabel);
        FIf_get_size(p->form, &width, &height);
        memset(&st, (int)0, sizeof(st));
        st.xlo = 1;
        st.ylo = 1;
        st.xhi = width - 2;
        st.yhi = height - 2;
        st.attr_mask = FI_2D_LINE;
        st.off_color =
            GRdisplay_has_fixed_vlt() ? FI_LT_YELLOW : FI_OFF_WHITE;
        FIg_set_standard_variables(p->form, BorderLabel, &st);
        FIg_set_line_weight(p->form, BorderLabel, 2);
    }
#endif

#if GetCurrentSymbol
        // If the version has changed the file needs to be resaved.  This
        // should not normally be done for popups, for the reason given above.
        // In addition, it is a real headache in a development environment,
        // since the outline files are in a constant state of change and this
        // would just add to the confusion.
          
        // 06/08/93: 2.4. build/added 3rd arg to call to GRpal_save_file.
        // We don't want to ask the users if we're deciding for them to
        // save the file.  TR # 119305947

        if (version_change && p)
            GRpal_save_file(p, path, PAL_DONT_ASK_BEFORE_SAVE);
#endif

        // Allocate and initialize a popup node.
        pu = GRpopup_create_node();
        i = strlen(palette) + 1;
        pu->palette = (char *)malloc(i + strlen(command) + 1);
        pu->command = &pu->palette[i];
        strcpy(pu->palette, palette);
        strcpy(pu->command, command);
        pu->form = p->form;

        if (form == NULL)
        {
            // Delete the palette node.
            p->form = NULL;
            GRpal_delete(p);
        }
    }
    else
        *msg = PAL_E_ABORT;
    
quit:

    return(pu);
}


/*
Function
        GRdisplay_command_name

Description
        This function displays the command associated with a menu button
        in the status field of the message strip.
*/

extern int GRdisplay_command_name(form, label, command)
Form form;
int label;
char *command;
{
    char *c;
    int mask, length;
    struct EX_cmd excmd;

    if (command)
    {
        c = command;
    }
    else        /* get the command string from the button */
    {
        FIg_get_command_length(form, label, &length);
        if (length)
        {
            c = (char *)alloca(length);
            FIg_get_command(form, label, c);
        }
        else
            return(FALSE);
    }

    /* determine whether string is a key or actual string */
    FIg_get_attr(form, label, &mask);
    if (mask & FI_CMD_KEY)
    {
        excmd.command_name_ptr = NULL;
        EX_get_cmd_info(c, EX_CMD_KEY, &excmd);
        c = excmd.command_name_ptr;
    }

    /* display the string */
    ex$message(in_buff = c, field = ERROR_FIELD, justification = CENTER_JUS);

    return(TRUE);
}

/*
Function
        GRpopup_locate

Description
        Given a command key, this function finds/creates a popup.
*/

extern int GRpopup_locate(msg, command, menu_form, menu_label, pu)
int *msg;
char *command;
Form menu_form;
int menu_label;
struct popup **pu;
{
    // create/retrieve a popup for this command
    *pu = GRpopup_create(msg, command, menu_form, menu_label);

    if (*pu)
    {
        int type;
        int x, y, fxo, fyo, xo, yo, bx, by;

        /*
            Position the popup - note that this is done each time the popup is
            accessed, since some applications may have the same popup at
            different locations in the menu hierarchy, or the user may move
            the menu to a different location or screen, etc.
        */

        /* put the form on the same screen as the menu */
        GRassign_form_screen(menu_form, (*pu)->form);

        /* reposition the popup with respect to the menu */
        FIf_get_location(menu_form, &fxo, &fyo);
        FIg_get_location(menu_form, menu_label, &xo, &yo);
        FI_get_form_menu_type(menu_form, &type);
        if (type == FI_BAR_MENU_TYPE || type == FI_TEAR_OFF_BAR_MENU_TYPE)
        {
            if (GRpopup_justification == PAL_LEFT_JUSTIFY)
                FIf_set_location((*pu)->form, fxo + xo, fyo + yo + 40);
            else
            {
                /* get the popup size; not all the same (eg task list) */
                FIf_get_size((*pu)->form, &x, &y);
 
                /* get the menu button size; not all the same (eg task list) */
                FIg_get_size(menu_form, menu_label, &bx, &by);
 
                /* center the popup under the menu button */
                FIf_set_location((*pu)->form, 
                                 fxo + xo - x/2 + bx/2, fyo + yo + by);
            }
        }
        else
        {
            /* assume all buttons are the same size */
            FIf_get_size((*pu)->form, &x, &y);
            y = fyo + yo - ((y > 66) ? 60 : 0) - 6;
            FIf_set_location((*pu)->form, fxo + xo - x + 90 + 2, y);
        }
    }

    *msg = (*pu) ? PAL_S_SUCCESS : PAL_W_NOCMD;
    return(*msg & 1);
}


/*
Name
        GRpopup_journal_fake_dismiss

Description
        The function writes a fake entry into the journal file which simulates
        a user rejecting one popup and selecting another.
*/

#argsused
void GRpopup_journal_fake_dismiss(type, menu_window)
int type;
#ifdef X11
Window menu_window;
#endif
#ifdef ENV5
int menu_window;
#endif
{
#ifdef X11
    XEvent event;

    if (type == CLICK_AND_RELEASE)
    {
        event.type = ButtonPress;
        event.xbutton.button = Button3;
    }
    else
    {
        event.type = ButtonRelease;
        event.xbutton.button = Button1;
    }

    event.xbutton.window = menu_window;
    event.xbutton.x = 99999;
    event.xbutton.y = 99999;
    event.xbutton.state = 0;
    event.xbutton.time = 0;
    JNL_record_next_event(&event, 1);

    if (type == CLICK_AND_RELEASE)
    {
        event.type = ButtonRelease;
        JNL_record_next_event(&event, 1);
    }
#endif

#ifdef ENV5
    int size;
    struct echo_button echo;

    echo.window = menu_window;
    echo.x = 99999;             /* this shouldn't hit anything :-) */
    echo.y = 99999;
    echo.btype = RIGHT_BUTTON;
    echo.state = SINGLE_CLICK;
    echo.timetag = 0;
    size = sizeof(struct echo_button);
    JNL_record_event(BUTTON_EVENT);
    JNL_record_input(size, (char *)&echo);
#endif
}

/*
Name
        GRpopup_journal_fake_invocation

Description
        The function writes a fake entry into the journal file which simulates
        a user rejecting one popup and selecting another.
*/

#argsused
void GRpopup_journal_fake_invocation(type, menu_window, x, y)
int type;
#ifdef X11
Window menu_window;
#endif
#ifdef ENV5
int menu_window;
#endif
int x, y;
{
#ifdef X11
    XEvent event;

    event.type = ButtonPress;
    event.xbutton.button = Button1;
    event.xbutton.window = menu_window;
    event.xbutton.x = x;
    event.xbutton.y = y;
    JNL_record_next_event(&event, 1);

    if (type == CLICK_AND_RELEASE)
    {
        event.type = ButtonRelease;
        JNL_record_next_event(&event, 1);
    }
#endif

#ifdef ENV5
    int size;
    struct echo_button echo;

    echo.window = menu_window;
    echo.x = x;
    echo.y = y;
    echo.btype = LEFT_BUTTON;
    echo.state = SINGLE_CLICK;
    echo.timetag = 0;
    size = sizeof(struct echo_button);
    JNL_record_event(BUTTON_EVENT);
    JNL_record_input(size, (char *)&echo);
#endif
}

/*
 * Function:
 *  
 *      GRpopup_process
 *
 * Description:
 *
 *      This routine processes a popup for a given command.
 *
 */
extern int GRpopup_process(msg, command, menu_form, menu_label, type)
int  *msg; 
char *command;
Form  menu_form;
int   menu_label;
int   type;     /* PUSH_AND_HOLD or CLICK_AND_RELEASE */
{
    int playback, recording;
    struct popup * pu;


    *msg = PAL_S_SUCCESS;



    /* find/create the popup */
    GRpopup_locate(msg, command, menu_form, menu_label, &pu);

    /* if there is a popup then process it */
    if ((*msg & 1) && pu)
    {
        int mask;
        int label, sts, down_label = -1;
        int win, x, y, button, trans, t_tag;
#ifdef X11
        int root_x,root_y;
	unsigned int keys_buttons;
        long event_mask;
        Window form_window, menu_window, root_w, child_w;
        XEvent event;
#else
        int form_window, menu_window;
#endif
        /* display the popup form, store the windows for use later */
        FIf_display(pu->form);
        FIf_get_window(pu->form, &form_window);
        FIf_get_window(menu_form, &menu_window);

        /*
         * Determine if journal playback is running : rlw 01/29/92
         */
        playback = JNL_playback();
        recording = JNL_journal();

#ifdef X11
	/*
	    This code is present to force each button on the popup to be
	    displayed.  Under X Windows, the popup form will never get
	    the expose event, since the popup code has its own input
	    loop and doesn't exit until the popup is dismissed.  Without
	    the expose event, the FIf_display won't cause everything to
	    be redrawn.  This has been promised to be fixed by the
	    XForms group.  Mack Draper gave me this code fragment.
						    mrm 10/06/91
        */

	while (1)
	{
            JNL_XMaskEvent(EXdisplay, ExposureMask, &event);
            FI_process_event(&event, 1);
            if (event.xany.window == form_window)
                break;
        }
#endif

        while (1)
        {
#ifdef X11
            /* check for (and eat) a button event, taking care not to */
            /* grab more than necessary */
            if (type == CLICK_AND_RELEASE)
                event_mask = ButtonPressMask;
            else
                event_mask = ButtonPressMask | ButtonReleaseMask;
            sts = JNL_XCheckMaskEvent(EXdisplay, event_mask, &event);
	    if (sts)
#else
            /* check for a button event */
            EX_inq_events(&mask);
            if (mask & BUTTON_EVENT)
#endif
            {

#ifndef X11
                /* eat the event that dismissed the popup */
                EX_get_button_data(&win, &x, &y, &button, &trans, &t_tag);
#endif
                if (type == CLICK_AND_RELEASE)
                {
                    /* check the button type */
#ifdef X11
                    if (event.xbutton.button == Button3)
#else
                    if (button == RIGHT_BUTTON)
#endif
                    {
                        /* don't generate a command for right button input */
                        FIg_set_state_off(pu->form, down_label);
                        FIf_erase(pu->form);
                        ex$message(msgnumb = EX_S_Clear);
                        break;
                    }
                }

                /*
                  If we are playing back a journal file then we need to do
                  special processing.  In this case we should have a point
                  which we need to find the label of.  During playback we
                  should never call functions such as Mouseposition() since
                  such things are not recorded.
 
                  rlw 01/30/92
                */

                if (playback || (down_label != -1))
                {
                    if (!playback)
                        /* Pop up the depressed button */
                        sts = FIg_set_state_off(pu->form, down_label);
                    else
                    {
                        /* Get the label of the depressed button. */
#ifdef X11
                        x = event.xbutton.x;
                        y = event.xbutton.y;
#else
                        if (win != 0)
                        {
                            /*
                              If the window number is not 0 (save restore),
                              then the button does not correctly reflect the
                              window in which the event occurred.  Due to the
                              design of EnvironV, a button up event will always
                              occur in the window in which the corresponding
                              button down event occurred.  Therefore, some
                              hoops must be jumped to get the label of the
                              button to be used.  The coordinates in x, y are
                              with respect to the parent form, and must be
                              translated to mean something to the popup.
                            */
                            int mx, my, px, py;

                            FIf_get_location(menu_form, &mx, &my);
                            FIf_get_location(pu->form, &px, &py);
                            x -= px - mx;
                            y -= py - my;
                        }
#endif
                        sts = FIf_find_gadget(pu->form, FI_FORM_GROUP, 
                                              x, y, &down_label);
                    }

                    if (sts == FI_SUCCESS)
                    {
                        /* if a command is hooked to the button, invoke it */

                        FIg_get_attr(pu->form, down_label, &mask);
                        if (mask & (FI_CMD_KEY | FI_CMD_STRING))
                        {
                            /* find the x,y coordinates of the button */
                            FIg_get_location(pu->form, down_label, &x, &y);
                            x += 5; /* i/forms will get confused */
                            y += 5; /* without a little fudge factor */

                            /*
                              Doing a push queue causes RAP problems.  Namely
                              RAP is not notified that a command is being
                              invoked since it is listening to the form/exnuc.
                              By letting the form do the work RAP will be
                              informed of the commands creation.  rlw 01/29/92
                              
                              Note that the button and transition args are set
                              to guarantee the correct response by the form.
                              Otherwise, the form would ordinarily ignore
                              inputs like left button up.
                            */
#ifdef X11
                            FIf_process_point(pu->form, x, y, Button2,
                                              SINGLE_CLICK, t_tag);
#else
                            FIf_process_point(pu->form, x, y, MIDDLE_BUTTON,
                                              SINGLE_CLICK, t_tag);
#endif
                        }
                    }
                }

                FIf_erase(pu->form);
                break;
            }
            else
            {
                /*
                 * Get the dynamic mouse position.
                 */
#ifdef X11
                sts = XQueryPointer(EXdisplay,form_window,&root_w,&child_w,
                                    &root_x,&root_y,&x,&y,&keys_buttons);

		/*
		 * Check if the cursor has moved off the popup
		 */

                if (sts)
				{
                    XWindowAttributes focus_win_attr;

                    XGetWindowAttributes(EXdisplay,form_window,
                                         &focus_win_attr);

                    /*
                     * If the cursor has moved off the popup, set
                     * sts = FALSE so we can see if another popup
                     * on the bar menu should be popped up
                     */

                    if ((x<0)||(y<0)||(x>focus_win_attr.width)||
                        (y>focus_win_attr.height))
                        sts = 0;
		}
#else
                Mouseposition(form_window, &x, &y, &sts);
#endif

                if (sts)
                {
                    /* If a gadget is under the mouse ...*/
                    if (FIf_find_gadget(pu->form, FI_FORM_GROUP,
                                        x, y, &label) == FI_SUCCESS)
                    {
                        int old_down_label;


                        /* Update the active button. */
                        if (((old_down_label = down_label) != -1) && 
                             (down_label != label))
                            FIg_set_state_off(pu->form, down_label);

                        FIg_set_state_on(pu->form, down_label = label);

                        if (old_down_label != down_label)
                        {
                            GRdisplay_command_name(pu->form, down_label,
                                                   (char *)NULL);
                        }
                    }
                    else /* Pop up down button */
                    {
                        if (down_label != -1)
                        {
                            FIg_set_state_off (pu->form, down_label);
                            ex$message(msgnumb = EX_S_Clear);
                        }
                        down_label = -1;
                    }
                }
                else
                {
                    if (down_label != -1)
                    {
                        FIg_set_state_off(pu->form, down_label);
                        ex$message(msgnumb = EX_S_Clear);
                    }
                    down_label = -1;

                    /*
                        Check whether the user has moved the pointer over the
                        menu.  If so, try to process a popup under that part of
                        the menu.
                    */
#ifdef X11
                    sts = XQueryPointer(EXdisplay, menu_window, &root_w,
                                        &child_w, &root_x, &root_y,
                                        &x, &y, &keys_buttons);
#else
                    Mouseposition(menu_window, &x, &y, &sts);
#endif

                    if (sts)
                    {
                        sts = FIf_find_gadget(menu_form,FI_FORM_GROUP, x, y,
                                              &label);
                        if (sts == FI_SUCCESS)
                        {
                            int command_length;

                            FIg_get_command_length(menu_form, label,
                                                   &command_length);

                            if (command_length)
                            {
                                int state;
                                char *new_command;

                                new_command = (char *)alloca(command_length);
                                FIg_get_command(menu_form, label, new_command);

                                if (strcmp(command, new_command))
                                {
// FIX for journaling problem. Changed the order of events. Instead of
// creating the new popup and then dismissing the old one, first dismiss
// the oldone and then create the new one. GRfind_popup() will be called
// twice, which is not too bad.
// fix is needed for X journaling. - 10/11/94 TR#119423646

    								char filename[MAXPATHLEN], palette[32];
									int  lab;

									*palette = NULL;
    								if (FIg_get_group_label(menu_form,
															label, &lab)
 														 == FI_SUCCESS)
        								FIg_get_text(menu_form, lab, palette);
    								if (*palette == NULL)
        								GRget_form_name(menu_form, palette);

                                    // Check whether this button has a popup.
									if (GRpopup_find(new_command, palette,
													 filename))
									{
                                        /* journal a fake dismiss */
                                        if (recording)
                                            GRpopup_journal_fake_dismiss
                                                (type, menu_window);

                                        /*
                                            Erase the current form - this must
                                            be between the fake journal
                                            entries; otherwise playback will
                                            hang in the XFORMS call to
                                            FIf_erase waiting for the unmap
                                            event.
                                        */

                                        FIf_erase(pu->form);
                                        FIg_set_state_off(menu_form, 
                                                          menu_label);
                                        FIg_get_state(menu_form,label,&state);
                                        FIg_set_state_on(menu_form, label);

                                        /* journal a fake invocation */
                                        if (recording)
                                            GRpopup_journal_fake_invocation
                                                (type, menu_window, x, y);

                                    	// Using GRpopup_create rather than
                                    	// GRpopup_find will search the list
                                    	// already in memory, and creating the
                                    	// popup here is no big loss, since it
                                    	// will be immediately invoked below via
                                    	// GRpopup_process.
                                    	if (GRpopup_create(msg, new_command,
                                                       	menu_form, label))
                                    	{
                                        	/* now invoke the new popup */
                                        	sts = GRpopup_process(msg, 
															  new_command,
                                                              menu_form,
                                                              label, type);
                                        	FIg_set_state(menu_form, label,
																 state);
                                        	break;
                                    	}
									}
#if WillingToTolerateFlashing
                                    else
                                    {
                                        GRdisplay_command_name(menu_form,
                                                               label,
                                                               new_command);
                                    }
#endif
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    else
    {
        /*
            No popup present, so display the command name.  Note that this
            code must be here rather than in a calling function in order to
            handle recursive calls.
        */
        GRdisplay_command_name(menu_form, menu_label, command);

        *msg = PAL_W_NOCMD;
    }
    
    return(pu && (*msg & 1));
}

/****************************************************************************
    INTERCEPT ROUTINES
 ****************************************************************************/

/*
Function
        GRmenu_button_intercept_routine

Description
        This routine is invoked when an event occurs over any menu.  If the
        action is a mouse button that has been designated to invoke a popup
        menu, then the popup assigned to the menu button is displayed.  If no
        popup is assigned, then the command name is displayed in the status
        field of the message strip, unless the popup invocation button is also
        the normal menu selection button.  In that case, the the command
        assigned to the button is invoked.

Notes
        This code used to always assume that playback meant to treat the popup
        as a CLICK_AND_RELEASE.  That assumption has been removed, since
        journaling improvements in GRpopup_process allow the input arg "trans"
        to reliably be used to determine how the popup invocation was
        journaled.
*/

int GRmenu_button_intercept_routine(form, xpos, ypos, button, trans, t_tag)
Form    form;
int     xpos, ypos;
int     button;
int     trans;
int     t_tag;
{
    char *command;
    int sts;
    int label;
    int state;
    int type;
    int playback = 0;
    int command_length = 0;

    playback = JNL_playback();

    if ((button == GRpopup_invocation_button) &&
        ((trans == DOWN) || (trans == UP) || (trans == SINGLE_CLICK)))
    {
        if ((trans == DOWN) || (trans == SINGLE_CLICK))
        {
            sts = FIf_find_gadget(form,FI_FORM_GROUP,xpos,ypos,&label);
            if (sts == FI_SUCCESS)
            {
                FIg_get_state(form, label, &state);
                FIg_set_state_on(form, label);
                FIg_get_command_length(form, label, &command_length);


                if (command_length)
                {
                    type = (trans == DOWN) ? PUSH_AND_HOLD : CLICK_AND_RELEASE;
                    command = (char *)alloca(command_length);
                    FIg_get_command(form, label, command);

#if ShowButtonInfo
                {
                    int symbol_index;
                    char symbol_file[32];
                    FIg_get_symbol_file(form, label, symbol_file);
                    FIg_get_symbol_index(form, label, &symbol_index);
                    printf("form, label = %#x, %d; ", form, label);
                    printf("command = %s; ", command);
                    printf("symbol = %s %d\n", symbol_file, symbol_index);
                }
#endif
                    GRpopup_process(&sts, command, form, label, type);
                    if (sts == PAL_W_NOCMD)
                    {
#ifdef X11
                        if (GRpopup_invocation_button == Button2)
#else
                        if (GRpopup_invocation_button == MIDDLE_BUTTON)
#endif
                        {
                            /*
                                Button has no popup, and the system has been
                                customized so that the popup invocation button
                                is the same as the normal command invocation
                                button.  The rule here is that the command be
                                invoked.  Set sts so that processing will fall
                                out to process the point to invoke the
                                command.
                            */

                            sts = FALSE;
                        }
                    }
                }
                FIg_set_state(form, label, state);
                if (sts & 1)
                    /* processed a popup, so bail out now */
                    return(1);
            }
        }
        else 
        {
            ex$message(msgnumb = EX_S_Clear);
            return(1);
        }
    }

    /*
       If playback isn't active or if playback is active and there is a gadget
       at the button location then process the point.
    */

    if ((!playback) || 
        (playback &&
         (FIf_find_gadget(form,FI_FORM_GROUP,xpos,ypos,&label) == FI_SUCCESS)))
    {

        FIf_process_point(form, xpos, ypos, button, trans, t_tag);
    }

    return(1);
}

end implementation GRpalmgr;
