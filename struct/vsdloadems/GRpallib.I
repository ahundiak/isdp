/*
Library:

    Palette Library
   
Description:

    This library defines all functions used to create, modify and manage 
    palettes. The class GRpalmgr is used to store these palettes in the
    object space.
   
Functions:

Notification
    
    GRpal_nofify
    GRpal_window_icon_routine
    GRpal_button_intercept_routine
   
Set Location
    
    GRpal_set_collapse_location
    
Node 

    GRpal_create_node
    GRpal_delete_node
    
File 

    GRpal_set_paths
    GRpal_get_paths
    GRpal_check_file
    GRpal_check_icon
    GRis_palette_file
    
Creation

    GRpal_add_popup_icons
    GRpal_create
    GRpal_del_cmd
    GRpal_set_outline_fp
    GRpal_get_cmd_icon
    GRpal_add_cmd
    GRpal_recreate
    GRpal_recreate_autodismiss
    
Save

    GRpal_get_header_info
    GRpal_get_cmd_info
    GRpal_save_file
    GRpal_check_palmgr
    
Delete

    GRpal_delete
     
Query

    GRpal_get_last_cmd
   
History:

    jay wallingford     04/10/89    creation date
    scw                 06/23/92    added static ANSI C prototypes
    mrm                 06/30/92    added GRis_palette_file
    Sudha		08/30/94    In GRpal_add_cmd swap FIg_set_symbol_file
				    and FIg_set_symbol_index - Fix TR# 119417560
    
Bugs:

    There are no known bugs.
    
Notes:

*/

class implementation GRpalmgr;

#include <grimport.h>
#include <stdio.h>
#include <ctype.h>
#include <unistd.h>
#include <exlocale.h>
#ifdef  ENV5
#include <tools.h>
#endif
#include <sys/param.h>
#include <sys/types.h>
#include "dpgraphics.h"
#include "igewinmacros.h"
#include "msdef.h"
#include "msmacros.h"
#include "grmsg.h"

extern char                 EX_version[];
extern int                  JNL_playback();

/* 
 * Palette library globals defined in src/go/globalgo.
 */
extern struct palette_cmd   GRpal_cur_cmd;               /* Last Command */
extern int                  (* GRpal_btn_locate_func)(); /* Locate Func. */
extern struct palette     * GRpal_palettes;              /* Linked List  */

%safe
static int            GRpal_num_fp = 0;    /* Number of .otl file pointers   */
static FILE        ** GRpal_fp = NULL;     /* .otl file pointers             */
static int            GRpal_num_paths = 0; /* Number of palette search paths */
static char        ** GRpal_paths = NULL;  /* Palette search paths           */
static unsigned char  GRpal_label = 0;     /* Next available form label      */
static unsigned int   GRpal_slots = 0;     /* Collapse slot mask             */
static struct standard_st stan_st = {0,0,0,0,FI_DEFAULT | FI_NOT_DISPLAYED,
                                     0.0,0.0,"","","","",NULL,FI_WHITE,
                                     FI_BLACK,FI_WHITE,FI_BLACK,0,0,0};
%endsafe

%safe
/*
 *  ANSI static prototype
 */
#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif
#if defined(__cplusplus)
extern "C" {
#endif

static int GRpal_set_collapse_location __((Form form_id, int *form_slot));
static struct palette *GRpal_create_node __((void));
static int GRpal_delete_node __((struct palette *p));
static int GRpal_set_paths __((void));

#if defined(__cplusplus)
}
#endif
#undef __
%endsafe


/****************************************************************************
    NOTIFICATION
 ****************************************************************************/

/*
extern int GRpal_notify ( form_label, label, value, form_ptr )
    int     form_label;
    int     label;
    double  value;
    char   *form_ptr;
{
    return (1);
}
*/

/*
 * Function:
 *  
 *      GRpal_window_icon_routine
 *
 * Description:
 *
 *      This routine is invoked whenever a window icon is selected from
 *      the form. Currently only the delete icon is trapped.
 *
 */
extern int GRpal_window_icon_routine ( form_label, icon_id, form )
    int     form_label;
    int     icon_id;
    Form    form;
{

    struct palette  *p;

    p = GRpal_palettes;
    while ( p ) 
    {
        if ((p->label == form_label) && (p->form == form))
        {
            if ( icon_id == PAL_DEL_FORM )
                GRpal_delete(p);
            break;
        }
        else p = p->next;
    }

    return (1);
}

/*
 * Function:
 *  
 *      GRpal_button_intercept_routine
 *
 * Description:
 *
 *      This routine is invoked when an event occurs over a palette. 
 *      Three event response actions are handeled by the routine:
 *
 *          o If a command button is being depressed the global current
 *            command structure is updated.
 *
 *          o If a user locate function global pointer is set the
 *            user supplied locate function is invoked.
 *
 *          o If a command button is being depressed and the palette
 *            is autodismiss, the palette is deleted.
 *
 */
extern int GRpal_button_intercept_routine ( form, 
                                            xpos, ypos,
                                            button,
                                            trans,
                                            t_tag )
    Form    form;
    int     xpos, ypos;
    int     button;
    int     trans;
    int     t_tag;
{
    struct palette * p;
    int xsize, ysize;
    int journaling = 0;
    int label;
    int palcmd_invoked = 0;

    p = GRpal_palettes;

    /*
     * And a single click on the middle mouse button
     * has occured.
     */
#ifdef X11
    if ( (button == Button2) && 
         ((trans == SINGLE_CLICK) || (trans == DOWN)) ) 
#else
    if ( (button == MIDDLE_BUTTON) && 
         ((trans == SINGLE_CLICK) || (trans == DOWN)) ) 
#endif
    {
        /*
         * Find the palette which was touched.
         */
        while ( p->form != form ) p = p->next;
        GRpal_cur_cmd.p = p;

        /*
         * Determine which row-column was touched.
         */
        FIg_get_size (p->form, GRpal_group + 1, &xsize, &ysize);

        /*
         * If the button fell on a command button update the current
         * command structure.
         */
        if ( (xpos > 3) && (xpos < ((xsize * p->cols) + (PAL_BORDER/2))) &&
             (ypos > 3) && (ypos < ((ysize * p->rows) + (PAL_BORDER/2))) )
        {
            GRpal_cur_cmd.col = (xpos - 3) / xsize;
            GRpal_cur_cmd.row = (ypos - 3) / ysize;

            /*
             * Calculate the label for that row-column.
             */
            GRpal_cur_cmd.label = (GRpal_cur_cmd.row * p->cols) + 
                                   GRpal_cur_cmd.col + 
                                   GRpal_group + 1;

            /*
             * If a locate has been requested.
             */
            if ( GRpal_btn_locate_func )
            {
                /*
                 * Call the supplied function.
                 */
                (*GRpal_btn_locate_func)();

                /*
                 * Set the func pointer to NULL.
                 */
                GRpal_btn_locate_func = NULL;

                return (1); 
            }

            palcmd_invoked = 1;
        }
    }
#ifdef X11
    else if ( (button == Button1) && 
              ((trans == SINGLE_CLICK) || (trans == DOWN)) ) 
#else
    else if ( (button == LEFT_BUTTON) && 
              ((trans == SINGLE_CLICK) || (trans == DOWN)) ) 
#endif
    {
        int vs_xpos, vs_ypos, screen, x, y, vs;

        FIf_get_location(form, &vs_xpos, &vs_ypos);
        vs_xpos += xpos;
        vs_ypos += ypos;
        IGEinq_mouse_pos(&screen, &x, &y);
        ige$inq_term_info(screen_no = screen, vs_no = &vs);
        MS_process_pocket(vs, vs_xpos, vs_ypos);
        return (1);
    }

    journaling = JNL_playback();
    
    /*
     * If journaling isn't active.
     */
    if ( !journaling )
    {
        /*
         * Process the point.
         */
        FIf_process_point ( form, xpos, ypos, button, trans, t_tag );
    }
    else if (journaling && 
             FIf_find_gadget(form,FI_FORM_GROUP,xpos,ypos,&label)==FI_SUCCESS )
    {
        /*
         * Process the point.
         */
        FIf_process_point ( form, xpos, ypos, button, trans, t_tag );
    }        

    /*
     * If a command was invoked ...
     */
    if (palcmd_invoked)
    {
        /*
         * Delete the palette if it is autodismiss.
         */
        if (p->props & PAL_AUTODISMISS) GRpal_delete (p);
    }

    return(1);
}

/****************************************************************************
    SET LOCATION
 ****************************************************************************/
/*
 * Function:
 *  
 *      GRpal_set_collapse_location
 *
 * Description:
 *
 *      This is an internal routine which is used to determine a position
 *      for the palette's collapse icon. This position is returned as a
 *      bit mask which the palette stores. On a collapse event the palette
 *      uses this bit mask to calculate where it should collapse. If there 
 *      are no more collapse slots available -1 is returned and the palette
 *      collapses in it's default position.
 *
 */
static int GRpal_set_collapse_location ( form_id , form_slot )
    Form    form_id;
    int *   form_slot;
{
    unsigned int mask;

    /*
     * Find a collapse slot for the palette.
     */
    mask = 0x01;

    for ( *form_slot = 0; *form_slot < 16; (*form_slot)++, mask <<= 1)
        if ( !(GRpal_slots & mask) ) 
            break;
     
    if ( *form_slot != 16 ) 
    {
        GRpal_slots |= mask;
        FIf_set_collapse_location ( form_id, 7 + (*form_slot * 65), 760 );
    }
    else *form_slot = (-1);

    return (PAL_S_SUCCESS);
}

/****************************************************************************
    LINKED LIST FUNCTIONS
 ****************************************************************************/
/*
 * Function:
 *  
 *      GRpal_create_node
 *
 * Description:
 *
 *      This is an internal routine which creates and links in a palette
 *      node into the palette linked list.
 *
 */
static struct palette * GRpal_create_node ()
{
    struct palette  *p, *q;

    q = NULL;

    if (p = (struct palette *) om$malloc (size = sizeof (struct palette)))
    {
        p->next = NULL;

        if (GRpal_palettes == NULL) GRpal_palettes = p;
        else 
        {
            q = GRpal_palettes;
            while ( q->next ) q = q->next;
            q->next = p;
        }
    }

    return (p);
}

/*
 * Function:
 *  
 *      GRpal_delete_node
 *
 * Description:
 *
 *      This is an internal routine which deletes a palette node from 
 *      the palette linked list.
 *
 */
static int GRpal_delete_node ( p )
    struct palette  *p;
{
    struct palette  *q;

    if ( GRpal_palettes ) 
    {
        q = GRpal_palettes;

        if ( q != p ) 
        {
            while ( q->next && q->next != p ) q = q->next;

            if ( q->next == p ) q->next = p->next;
            else return (0);
        }
        else GRpal_palettes = q->next;

        om$dealloc ( ptr = p );
    }
    else return (0);

    return (1);
}

/****************************************************************************
    FILES
*****************************************************************************/

#define MAX_PATHS 15
#define BIG_BUFFER 1024

/*
 * Function:
 *  
 *      GRpal_set_paths
 *
 * Description:
 *
 *      This is an internal routine which sets up a list of pointers
 *      to directories where user palettes may be found. The list is
 *      derived from the PALPATH environmental variable defined by
 *      the user. This list is used when a palette is recreated from
 *      a palette ascii file.
 *
 *
 * History DLB 12/04/91 malloc strlen+2 instead of +1 since strlen does not
 *                      return len with null term.  1 byte overwrite was
 *                      occuring.
 */
static int GRpal_set_paths ()
{
    char * p, * q = NULL, path[BIG_BUFFER];
    int i, ok=TRUE, len;
    char language[40];
    
    if ( !GRpal_num_paths ) 
    {
        /*
         * Add the current working directory and the
         * user defined palette paths.
         */
        if (p = (char *)getenv("PALPATH")) 
        {
            if ( p[len = strlen(p)] == ':') p[len--] = '\0';

            if (q = malloc(len + 4)) 
            {
                strcpy(q, ".:");
                strcat(q, p);
                strcat(q, ":");
            }
        }

        /*
         * Add the product palette paths.
         */
        for ( i = 0; ok == TRUE; i++ ) 
        {
            if ( ok = ex$get_path ( index = i, 
                                    path = path, 
                                    len = BIG_BUFFER ) )
            {
                strcat (path, "config/");
                ex$language(language = language);
                strcat (path, language);
                strcat (path,"/palettes");

                /*
                 * If the palettes dir exits in this product's 
                 * config directory.
                 */
                if ( !access ( path, 00 ) ) 
                {
                    /*
                     * Add the path to the list.
                     */
                    if ( q )  
                    {
                        q = realloc(q, strlen(q) + strlen(path) + 2);
                        strcat(q, path);
                        strcat(q, ":");
                    }
                    else    
                    {
                        q = malloc(strlen(path) + 2); /*DLB +2 not +1*/
                        strcpy(q, path);
                        strcat(q, ":");
                    }
                }
            }
        }

        if ( q ) 
        {
            /*
             * Allocate a block of MAX_PATHS path pointers.
             */
            GRpal_paths = (char * *)calloc(MAX_PATHS, sizeof(char *));

            /*
             * Set the pointers to all the paths.
             */
            while ((GRpal_num_paths < MAX_PATHS) && *q )
            {
                GRpal_paths[GRpal_num_paths++] = q;
                q = strchr(q, ':');
                *q++ = '\0';
            }
        }
    }

    return (1);
}

/*
 * Function:
 *  
 *      GRpal_get_paths
 *
 * Description:
 *
 *      This routine returns a list of pointers to directories where 
 *      user palettes may be found.
 *
 */
extern int GRpal_get_paths (paths, num)
    char *** paths;
    int *    num;
{
    GRpal_set_paths();
    *paths = GRpal_paths;
    *num = GRpal_num_paths;
    return (1);
}

/*
Function
        GRpal_reset_paths

Description
        This function reinitializes the palette directory list.  It is called
        from switchprod to make sure that new paths are recognized, as well as
        to ensure that old paths are no longer used.
*/

extern void GRpal_reset_paths()
{
    if (GRpal_num_paths)
    {
        /*
            Free the memory allocated in GRpal_set_paths that holds the
            directory specifications.  Note that although GRpal_paths points
            inside this memory multiple times, only the first pointer needs to
            be freed, since the memory was allocated in one big chunk.
        */
        free(GRpal_paths[0]);

        /* free the path pointer array */
        free(GRpal_paths);

        /* reset the static variables to their original states */
        GRpal_paths = NULL;
        GRpal_num_paths = 0;

        /* call GRpal_set_paths to set up the new list */
        GRpal_set_paths();
    }
}


/*
 * Function:
 *  
 *      GRpal_check_file
 *
 * Description:
 *
 *      This routine returns a the full pathname of a palette ascii
 *      file and it's access properties.
 *
 */
extern int GRpal_check_file (filename, fullname, check)
    char * filename;
    char * fullname;
    int    check;
{
    char ** paths;
    int     num, i;
    char    path[MAXPATHLEN];

    if ( !access(filename, check) )
    {
        if ( fullname ) strcpy(fullname, filename);
        return (1);
    }

    GRpal_get_paths ( &paths, &num );
   
    for (i=0; i<num; ++i)
    {
        strcpy(path, paths[i]);
        strcat(path, "/");
        strcat(path, filename);

        if ( !access(path, check) ) 
        {
            if ( fullname ) strcpy(fullname, path);
            return(1);
        }
    }
    
    return (0);
}

/*
 * Function:
 *  
 *      GRpal_check_icon
 *
 * Description:
 *
 *      This routine returns a the full pathname and access properties
 *      of an icon file.
 *
 */
extern int GRpal_check_icon (filename, fullname, check)
    char * filename;
    char * fullname;
    int    check;
{
    int i, ok=TRUE;
    char language[40];
    char path[MAXPATHLEN];

    /*
     * If the file exists.
     */
    if ( !access (filename, check) ) 
    {
        if ( fullname ) strcpy(fullname, filename);
        return(1);
    }

    /*
     * Search the products config/$language/icons directory for
     * the icon file.
     */
    for (i=0; ok == TRUE; i++) 
    {
        if ( ok = ex$get_path ( index = i, 
                                path = path, 
                                len = MAXPATHLEN ) )
        {
            strcat (path,"config/");

            /*
             * Get the language.
             */
            ex$language(language = language);
            strcat (path, language);
            strcat (path, "/icons/");
            strcat (path, filename);

            /*
             * If the file exists.
             */
            if ( !access (path, check) ) 
            {
                if ( fullname ) strcpy(fullname, path);
                return(1);
            }
        }
    }
    return (0);
}

/*
Function
        GRis_palette_file

Synopsis
        int GRis_palette_file(filename, input_fp)
        int ()          output - TRUE  - file is a palette file
                                 FALSE - file is not a palette file
        char *filename  input  - the name of the file to check
        FILE *input_fp  input  - an open file pointer to the file to check

Description
        This function will determine whether a file is a palette file.  Either
        filename or input_fp may be used to specify the file to check, with
        filename taking precedence.  If filename is used, the file will be
        opened "r" and closed before the function exits.  If input_fp is used,
        the function will rewind(input_fp) before exiting.

Algorithm
        The file should contain several commas in the first line, so that is
        checked first.  If at least one is present, then the first line is
        checked for exactly 13 fields.

History
        mrm     06/30/92    creation
*/

int GRis_palette_file(filename, input_fp)
char *filename;
FILE *input_fp;
{
    char version[64];
    FILE *fp;
    int sts = FALSE;
    char path[MAXPATHLEN];
    int properties, rows, cols, color, xpos, ypos;
    int xsize, ysize, btn_x, btn_y, btn_on_color, btn_off_color;

    path[0] = NULL;
    if (filename)
    {
	if (!GRpal_check_file(filename, path, R_OK) || 
		(!(fp = (FILE *)fopen(path, "r"))) )
    	{
		return(FALSE);
    	}
    }
    else if (input_fp)
    {
        fp = (FILE *)input_fp;
        rewind(fp);
    }
    else
    {
        return(FALSE);
    }

    if (fgets(version, 64, fp))
    {
        if (strchr(version, ','))
        {
            rewind(fp);

            if (fscanf(fp,"%[^,],%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d\n",
                       version, &properties,&rows,&cols,&color,&xpos,&ypos,
                       &xsize,&ysize,&btn_x,&btn_y,&btn_on_color,
                       &btn_off_color) == 13)
                sts = TRUE;
        }
    }

    if (filename)
        fclose(fp);
    else
        rewind(input_fp);

    return(sts);
}

/************************************************************************/
/*    CREATE                                                            */
/************************************************************************/
/*
 * Function:
 *  
 *      GRpal_add_popup_icons
 *
 * Description:
 *
 *      This routine adds the palette specific popup icons to a palette.
 *
 */
extern void GRpal_add_popup_icons (p)
    struct palette * p;
{
#ifndef X11
    char path[256];
    int win_id;

    /*
     * Find the palette symbol library on disk.
     */
    if (GRpal_check_icon ("GRfrm.sym", path, 04)) 
    {
        /*
         * Find the window the form is on.
         */
        FIf_get_window ( p->form, &win_id );

        /*
         * Add the delete palette icons.
         */
        Create_win_user_icon ( win_id, 
                               path,
                               PAL_DEL_FORM,
                               RIGHT_SIDE_ICON, 
                               PAL_DEL_FORM );
/*      Set_win_user_icon ( win_id, PAL_DEL_FORM, 1 ); */
        Update_win_icon (win_id);

    }
#endif
}

/*
 * Function:
 *  
 *      GRpal_create
 *
 * Description:
 *
 *      This routine creates a blank palette.
 *
 */
extern struct palette *
GRpal_create ( msg,             /* Return code defined in palgo.h */
               properties,      /* Defined in palgo.h */
               rows, cols,      /* Number of rows/cols for the palette */
               color,           /* Background color for the palette */
               xpos, ypos,      /* X/Y position of upper left corner */
               xsize, ysize,    /* X/Y size of palette, may introduce scale */
               btn_x, btn_y,    /* X/Y size of button before scale */
               btn_on_color, btn_off_color ) /* Color of button */
    int  *msg;
    int  properties,
         rows, cols,
         color,
         xpos, ypos,
         xsize, ysize,
         btn_x, btn_y,
         btn_on_color, btn_off_color;
{
    int             GRpal_window_icon_routine ();
    int             GRpal_button_intercept_routine ();
    int	            n, x, y;
    int             label;
    struct palette *q, *p;

    *msg = PAL_S_SUCCESS;

    /*
     * Set up the palette search paths if it hasn't been done.
     */
    if ( !GRpal_num_paths) GRpal_set_paths ();


    q = NULL;

    /*
     * Create a new palette node. 
     */
    if ( !(p = GRpal_create_node ()) ) 
    {
        *msg = PAL_E_ABORT;
        goto quit;
    }

    /* 
     * Initialize palette's instance data. 
     */
    p->label = ++GRpal_label;
    p->slot = 0;
    p->rows = rows;
    p->cols = cols;
    p->btn_x = btn_x;
    p->btn_y = btn_y;
    p->props = 0;

    /*
     * Create a new form.
     */
    if ( FIf_new ( p->label, "", NULL, &p->form ) ) 
    {
        GRpal_delete_node ( p );
        *msg = PAL_E_ABORT;
        goto quit;
    }

    /*
     * Set up the form.
     */
    FIf_set_collapse_symbol ( p->form, "collapse.icon", 2 );
    FIf_set_attr ( p->form, 
                   FI_LINE_BORDER | FI_NO_BEZEL | 
                   ((properties & PAL_COLLAPSED) ? FI_DISPLAY_COLLAPSED : 0) );
    FIf_set_color( p->form, color );
    FIf_set_size ( p->form, 
                   (cols * btn_x) + PAL_BORDER, 
                   (rows * btn_y) + PAL_BORDER );

    FIf_set_orig_location ( p->form,
                           (cols * btn_x) + PAL_BORDER,
                           (rows * btn_y) + PAL_BORDER );

    GRpal_set_collapse_location ( p->form, &p->slot );
    
#ifndef X11
    FIf_set_window_level ( p->form, FI_NORMAL_PRIORITY );
#endif

    /*
     * Set up the notify routines.
     */
    FIf_set_window_icon_routine ( p->form, GRpal_window_icon_routine );
    FIf_set_button_intercept_routine ( p->form, GRpal_button_intercept_routine );

    /*
     * Create a group on the form and make it single select. 
     */
    FIg_new ( p->form, FI_GROUP, GRpal_group );
    FIgrp_set_single_select_on ( p->form, GRpal_group );

    /*
     * Add blank non_displayable buttons to the form.
     */
    stan_st.off_color = btn_off_color;
    stan_st.on_color = btn_on_color;

    for (n=1, y=0; y<rows; y++)
    {
        for (x=0; x<cols; x++)
        {
            label = n++ + GRpal_group;

            /*
             * Create a button.
             */
            FIg_new ( p->form, FI_BUTTON, label);
            stan_st.xlo = (x * btn_x) + 3;
            stan_st.ylo = (y * btn_y) + 3;     
            stan_st.xhi = stan_st.xlo + btn_x;
            stan_st.yhi = stan_st.ylo + btn_y;

            FIg_set_standard_variables ( p->form, label, &stan_st );
            FIg_add_to_group ( p->form, label, GRpal_group);
        }
    }

    /*
     * Scale the form if a xsize and ysize have been passed in.
     */
    if ( (xsize > 0) && (ysize > 0) )
    {
        FIf_set_size ( p->form, xsize, ysize );
    }

    /*
     * Update the position of the form.
     */
    FIf_set_location ( p->form, xpos, ypos );

    /*
     * Display the form.
     */
    if (!(properties & PAL_NODISPLAY)) 
    {
        FIf_display ( p->form );
    }

    /*
     * Add the appropriate icons to the pop up.
     */
    GRpal_add_popup_icons (p);

    /*
     * Make sure a palette manager object is created in 
     * this object space.
     */
    GRpal_check_palmgr();

    /*
     * Set the palette properties.
     */
    p->props |= (properties & PAL_AUTODISMISS) ? PAL_AUTODISMISS : 0;

quit:

    return ( (*msg & 1) ? p : NULL );
}

/*
 * Function:
 *  
 *      GRpal_del_cmd
 *
 * Description:
 *
 *      This routine deletes a command button from a palette.
 *
 */
extern int GRpal_del_cmd( p, row, col )
    struct palette * p;
    int row, col;
{
    int     label;

    /*
     * Erase the button.
     */
    label = (row * p->cols) + col + GRpal_group + 1;

    FIg_erase (p->form, label);
    
    FIg_set_attr (p->form, stan_st.attr_mask);

    return(PAL_S_SUCCESS);
}

/*
Function
        GRpal_set_outline_fp

Description
        This routine sets up a list of file pointers to the
        $PRODUCT/config/$LANGUAGE/menus/*.otl files. These files are
        scanned when a button is added to a palette. It may be a little
        arrogant to keep all these files opened during the session but
        it sure is quicker than opening them when ever a button is
        added.

History
        mrm     12/11/91    added *bar.otl to the files searched, since some
                            commands have icons which are exclusively on the
                            bar menu (and not on the panel or pocket menus).
*/
#define A_LOT_OF_FPS 50
extern int GRpal_set_outline_fp ()
{
    char path[256], language[16], *p, file_path[256];
    int i, ok = TRUE;
    FILE *fp[A_LOT_OF_FPS];
    DIR *dp;
    struct dirent *dp_ptr;

    /* return if the outline files have already been opened for this session */
    if (GRpal_num_fp && GRpal_fp)
        return(GRpal_num_fp);

    /* get the current language */
    ex$language(language = language);

    /* loop through each product */
    for (i = 0, GRpal_num_fp = 0; 
         (ok == TRUE) && (GRpal_num_fp < A_LOT_OF_FPS); 
         i++)
    {
        if (ok = ex$get_path(index = i, path = path, len = 256))
        {
            /* construct the path to the menus directory */
            sprintf(&path[strlen(path)], "config/%s/menus", language);

	    /* open the "menus" directory for this product to find the
               outline files */
            if (!(dp = (DIR *)opendir(path))) continue;

            if (dp_ptr = (struct dirent *)readdir(dp))
            {
		while (dp_ptr)
                {
                    if ((p = strrchr (dp_ptr->d_name, 'p')) ||
                        (p = strrchr (dp_ptr->d_name, 'b')))
  		    {
                        /* find the *pan.otl, *pkt.otl, and *bar.otl files
                           for this product */
         		if ( !strcmp(p, "pan.otl") ||
			     !strcmp(p, "pkt.otl") ||
			     !strcmp(p, "bar.otl") )
                        {
			    strcpy(file_path,path);
                            strcat(file_path, "/");
                            strcat(file_path, dp_ptr->d_name);

                            if (fp[GRpal_num_fp] =
                                                (FILE *)fopen(file_path, "r")) 
                            {
                            	++GRpal_num_fp;
                            }
                        }
                    }
            	    dp_ptr = readdir(dp);
		}
            }
	    closedir(dp);
        }
    }

    /* set up the static fps */
    GRpal_fp = (FILE **)calloc(GRpal_num_fp, sizeof (FILE *));

/*  for ( j = 0, i = GRpal_num_fp; i > 0; ) GRpal_fp[j++] = fp[--i];*/

/* TR 90N3123 Begin */

    for ( i = 0; i < GRpal_num_fp ; i++ ) GRpal_fp[i] = fp[i];

/* TR 90N3123 End */

    return (GRpal_num_fp);
}


/*
 * Function:
 *  
 *      GRpal_get_cmd_icon
 *
 * Description:
 *
 *      Given a command key this routine returns it's symbol file 
 *      and symbol number. The file pointers set by GRpal_set_outline_fp
 *      are used to search for this information.
 *
 */
extern int GRpal_get_cmd_icon (cmd_key, symbol_file, symbol )
char *cmd_key;
char *symbol_file;
int  *symbol;
{
    int i;
    char *sep = ",", *p, *q, line[256];
    FILE *fp;

    for (i = 0; i < GRpal_num_fp; ++i)
    {
        fp = GRpal_fp[i];
        while (fgets(line,256,fp) != NULL) 
        {
            q = line;
            while (isspace(*q)) q++;
            if (p = strtok(q,sep)) 
            {
                if (!strcmp(p,cmd_key)) 
                {
                    if (p = strtok(0,sep)) 
                    {
                        while (isspace(*p)) p++;
                        strcpy(symbol_file,p);
                        if (p = strtok(0,sep)) 
                        {
                            sscanf(p,"%d",symbol);
                            rewind(fp);
                            return(1);
                        }
                    }
                }
            }
        }
        rewind(fp);
    }
    return(0);
}

/*
 * Function:
 *  
 *      GRpal_add_cmd
 *
 * Description:
 *
 *      This routine adds a command to a palette.
 *
 */
extern int GRpal_add_cmd( p, row, col, type, command, symbol_file, symbol )
    struct palette  *p;         /* Palette to add command to */
    int             row, col;   /* Row/col to add to */
    int             type;       /* FI_CMD_STRING or FI_CMD_KEY  in FI.h */
    char            *command, *symbol_file; /* Command key/string */
    int             symbol;     /* Symbol number */
{
    int    label,msg;
    char   text[16];
    float  bodysize;
    int    old_y_size, x_size, y_size;
    struct palette * gp;

    msg = PAL_S_SUCCESS;

    /*
     * See if p is a valid palette.
     */
    gp = GRpal_palettes;
    
    while (gp)
    {
        if (gp == p) break;
        gp = gp->next;
    }
    
    if (!gp)
    {
        msg = PAL_E_ABORT;
        goto quit;
    }
      
    /*
     * Setup the button.
     */
    label = (row * p->cols) + col + GRpal_group + 1;

    FIg_set_command (p->form, label, command);

    /*
     * If a symbol file was provided set the icon.
     */
    if ((symbol >= 0) && (symbol_file))
    {
        FIg_set_attr (p->form, label, FI_DEFAULT | type);

	/* when a palette is resized, we are trying to activate the gadget with
	FIg_set_symbol_file without setting the index. Because of which, it gets
	wrong symbol , structure being filled with 0's is being sent to 
	_FI_sym_scale_up_x_down_y in which the if condition fails and XcreatePixmap
	fails with insufficient resources. To fix the problem, set the index first
	and then set the symbol file. - Fix TR# 119417560 */
	
        FIg_set_symbol_index (p->form, label, symbol);
        FIg_set_symbol_file (p->form, label, symbol_file);
    }
    else /* set the command text */
    {
        /*
         * Determine the bodysize for the font.
         */
        old_y_size = (p->rows * p->btn_y) + PAL_BORDER;
        FIf_get_size (p->form, &x_size, &y_size);
        /* cast ints to float for proper arithmetic (TR91N0634) */
        bodysize = (((float)y_size/(float)old_y_size) * 15.0) + 0.5;
        FIg_set_attr (p->form, label, FI_DEFAULT | type | FI_TEXT_GADGET );
        FIg_set_font (p->form, label, "swiss742b", bodysize);
        FIg_set_justification (p->form, label, FI_CENTER_JUSTIFIED );

        if ((symbol == -1) && (symbol_file) && (symbol_file[0]))
        {
            strncpy(text, symbol_file, PAL_MAX_LABEL);
        }
        else
        {
            strncpy(text, command, PAL_MAX_LABEL);
        }
        text[PAL_MAX_LABEL] = NULL;
        FIg_set_text (p->form, label, text);
    }

    /* 
        Set the button according to whether the attached command is active in
        the current product
    */

    GRvalidate_button(command, p->form, &label);

    FIg_activate (p->form, label);
    FIg_display (p->form, label);

quit:

     return msg;
}

/************************************************************************/
/*    RECREATE                                                          */
/************************************************************************/
/*
Function
        GRpal_recreate

Description
       This routine recreates a palette from a palette ascii file.
*/
extern struct palette * GRpal_recreate(msg, filename)
int  *msg; 
char *filename;
{
    FILE *fp;
    char path[MAXPATHLEN];
    char symbol_file[80], command[PAL_MAX_CMD_LENGTH], version[50];
    int properties, rows, cols, row, col, color, xpos, ypos, xsize, ysize;
    int btn_x, btn_y, btn_on_color, btn_off_color, i, symbol,len;
    int command_type, version_change = FALSE, rewrite_file = FALSE;
    struct palette *p = NULL;

    *msg = PAL_S_SUCCESS;
    path[0] = NULL;

    if(!(*filename))
    {
        *msg = PAL_E_ABORT;
        goto quit;
    }

    if( !GRis_palette_file(filename,(FILE *) NULL))
    {
        *msg = PAL_E_ABORT;
            goto quit;
    }

    if (!GRpal_check_file(filename, path, R_OK) || 
        !(fp = (FILE *)fopen(path, "r")))
    {
        *msg = PAL_E_ABORT;
            goto quit;
    }

    /* read in the file header */

    if (fscanf(fp,"%[^,],%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d\n",
               version,
               &properties,&rows,&cols,&color,&xpos,&ypos,
               &xsize,&ysize,&btn_x,&btn_y,&btn_on_color, &btn_off_color)
        == 13)
    {
        /* check for unreasonable data */

        if ((rows > 15) || (cols > 15)  || (rows < 1)    || (cols < 1)    || 
            (xpos < 0)  || (ypos < 0)   || (xpos > 1183) || (ypos > 883)  ||
            (btn_x < 0) || (btn_y < 0)  || (btn_x > 500) || (btn_y > 500) ||
            (color < 0) || (color > 14) || 
            (xsize > (1183 * 2)) || (ysize > (883 * 2)) || /* 2x for 27" */
            (btn_on_color < 0) || (btn_on_color > 14) ||
            (btn_off_color < 0) || (btn_off_color > 14))
        {
            *msg = PAL_E_ABORT;
            goto quit;
        }

        /* check for a version change */

        if (strcmp(version, EX_version))
        {
            /* the palette file needs to be updated */
            version_change = TRUE;
            rewrite_file = TRUE;

            /* open the outline files */
            GRpal_set_outline_fp ();
        }

        /* create a blank palette, making sure that it is properly
           y-adjusted */

        if (!(p = GRpal_create(msg, properties, rows, cols, color, xpos,
                               (properties & PAL_YADJUSTED) ? ypos : ypos + 55,
                               xsize, ysize, btn_x, btn_y,
                               btn_on_color, btn_off_color)))
            goto quit;
    }
    else 
    {
        *msg = PAL_E_ABORT;
        goto quit;
    }
    
    /* put the buttons on the palette */

    while (fscanf(fp, "%d,%d,%[^,],%d,%[^,],%d\n", 
                  &row, &col, command, &command_type, symbol_file, &symbol)
           == 6)
    {
        /* Substitute '%' for ',' in the command string.  This is because
           the ',' is used for two purposes here -- as a separator in the
           command string and in the palette file.  (TR90N1634) */

	len = strlen(command);
	for (i = 0; i < len; ++i)
            if (command[i]=='%')  
                command[i]= ',';

	len = strlen(symbol_file);
	for (i = 0; i < len; ++i)
            if (symbol_file[i]=='%') 
                symbol_file[i]= ','; 

        /* check/update command icons */

        if (version_change && (command_type == FI_CMD_KEY) && (symbol != -1))
        {
            if (!GRpal_get_cmd_icon(command, symbol_file, &symbol )) 
            {
                /* replace the symbol file name with the command key */
                strncpy(symbol_file, command, PAL_MAX_LABEL);
                symbol_file[PAL_MAX_LABEL] = '\0';
                symbol = -1;

                /* don't modify the file; the symbol file name is now bogus */
                rewrite_file = FALSE;   
            }
        }

        /* add the command to the palette */
        GRpal_add_cmd(p, row, col, command_type, command, symbol_file, symbol);
    }

    fclose(fp);

    /* if the version has changed the file needs to be saved */
    if (version_change && rewrite_file && p)
        GRpal_save_file( p, path, PAL_DONT_ASK_BEFORE_SAVE );

quit:
    return((*msg&1) ? p : NULL);
}

/*
 * Function:
 *  
 *      GRpal_recreate_autodismiss
 *
 * Description:
 *
 *      This routine recreates a palette for a palette ascii file
 *      and makes that palette autodismiss.
 *
 */
extern struct palette * GRpal_recreate_autodismiss ( msg, filename )
    int * msg; 
    char * filename;
{
    struct palette  * p;

    p = GRpal_recreate (msg, filename);

    if (*msg & 1) p->props |= PAL_AUTODISMISS;

    return ((*msg & 1) ? p : NULL );
}


/************************************************************************/
/*    SAVE                                                              */
/************************************************************************/

/*
 * Function:
 *  
 *      GRpal_get_header_info
 *
 * Description:
 *
 *      This routine returns all information necessary to fully define
 *      a palette except for it's commands. This routine is used when
 *      a palette is saved to an ascii file or to an object space.
 *
 */
extern int GRpal_get_header_info ( p,
                                   xpos, ypos,
                                   xsize, ysize,
                                   rows, cols,
                                   btn_x, btn_y,
                                   color,
                                   btn_on_color, btn_off_color,
                                   properties )
    struct palette * p;
    int * xpos, * ypos,
        * xsize, * ysize,
        * rows, * cols,
        * btn_x, * btn_y,
        * color,
        * btn_on_color, * btn_off_color,
        * properties;
{
    /*
     * Save the palette's information.
     */
    *rows = p->rows;
    *cols = p->cols;
    *btn_x = p->btn_x;
    *btn_y = p->btn_y;

    FIf_get_color(p->form, color);
    FIf_is_collapsed (p->form, properties);
    *properties = (*properties) ? PAL_COLLAPSED : NULL;
/*--------------------------------------------------------------------------
    Begin TR: 91N0711 - Flag that the palette to be saved has been adjusted
                        55 pixels in the y direction.
  -------------------------------------------------------------------------*/
    *properties |= PAL_YADJUSTED;
/*--------------------------------------------------------------------------
    End   TR: 91N0711
  -------------------------------------------------------------------------*/

    *properties |= p->props;

    FIf_get_location(p->form, xpos, ypos);
    FIf_get_size(p->form, xsize, ysize);

    FIg_get_on_color(p->form, GRpal_group + 1, btn_on_color);
    FIg_get_off_color(p->form, GRpal_group + 1, btn_off_color);

    return(1);
}

/*
 * Function:
 *  
 *      GRpal_get_cmd_info
 *
 * Description:
 *
 *      This routine returns all information necessary to fully define
 *      a palette command.
 *
 */
extern int GRpal_get_cmd_info ( p,
                                label,
                                command,
                                command_type,
                                symbol_file,
                                symbol )
    struct palette * p;
    int label;
    char * command;
    int * command_type;
    char * symbol_file;
    int * symbol;
{                                    
    int attributes;

    /*
     * Get the command.
     */
    FIg_get_command ( p->form, label, command );

    /*
     * Determine the type of the command.
     */
    FIg_get_attr (p->form, label, &attributes);

    *command_type = (attributes & FI_CMD_STRING) ? FI_CMD_STRING : FI_CMD_KEY;

    if ( symbol_file )
    {
        /*
         * Get the symbol file
         */
        FIg_get_symbol_file ( p->form, label, symbol_file );

        /*
         * If this is not a button with a command string on it
         * get the symbol.
         */
        if ( strcmp(symbol_file, "swiss742b" ) )
        {
            /*
             * Get the symbol
             */
            FIg_get_off_symbol_index ( p->form, label, symbol );
        }
        else /* Get the text string on the button */
        {
            FIg_get_text ( p->form, label, symbol_file );
            symbol_file[PAL_MAX_LABEL] = '\0'; 
            *symbol = -1;
        }
    }

    return (1);
}

/*
Function
        GRpal_save_file

Description
        This routine saves a palette to a palette ascii file.

Notes
	third arg (ask) added for 2.4 build re: TR #119305947
*/
extern int GRpal_save_file(p, filename, ask)
struct palette *p;
char *filename;
int  ask;        /* if file exists, do we ask about overwriting it */
{
    FILE    *fp;
    char    symbol_file[MAXPATHLEN];
    char    command[PAL_MAX_CMD_LENGTH];
    int     symbol, properties, rows, cols, row, col, color, xpos, ypos;
    int     xsize, ysize, btn_x, btn_y, btn_on_color, btn_off_color;
    int     label, attributes, command_type, len, i;

    /*
     * Make sure the file doesn't already exist
     */
    if (ask == PAL_ASK_BEFORE_SAVE )
    {
      fp = fopen ( filename, "r" );
      if (fp)
      {
        char buffer [DI_PATH_MAX];

        fclose ( fp );
        ex$message ( msgnumb = GR_P_FlExOv, buff = buffer );
        if (GRconfirm_box ( buffer ) != TRUE)
          return ( 0 );
      }
    }
    /* open the file for write */

    if (!(fp = (FILE *)fopen(filename, "w")))
    {
        return(0);
    }

    /* get the header info */

    GRpal_get_header_info(p, &xpos, &ypos, &xsize, &ysize, &rows, &cols,
                          &btn_x, &btn_y, &color, &btn_on_color,
                          &btn_off_color, &properties);
                                                        
    /* write out the palette header */

    fprintf(fp, "%s,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d\n",
            EX_version, properties, rows, cols, color, xpos, ypos,
            xsize, ysize, btn_x, btn_y, btn_on_color, btn_off_color);

    /* write out each button's row, col, symfile, symbol and command name */

    label = GRpal_group;
    for (row = 0; row < p->rows; ++row)
    {
        for (col = 0; col < p->cols; ++col)
        {
            ++label;

            FIg_get_attr(p->form, label, &attributes);

            if (!(attributes & FI_NOT_DISPLAYED))
            {
                /* get the button info */

                GRpal_get_cmd_info(p, label, command, &command_type,
                                   symbol_file, &symbol);

                /* Substitute '%' for ',' in the command string.  This
                   is because the ',' is used for two purposes here --
                   as a separator in the command string and in the
                   palette file.  (TR90N1634) */

		len = strlen(command);
		for (i = 0; i < len; ++i)
                    if (command[i]==',') 
                        command[i]= '%';

		len = strlen(symbol_file);
		for (i = 0; i < len; ++i)
                    if (symbol_file[i]==',') 
                        symbol_file[i]= '%';

                /* write out the info */

                fprintf(fp, "%d,%d,%s,%d,%s,%d\n",
                        row, col, command, command_type, symbol_file, symbol);
            }
        }
    }

    fflush (fp);
    fclose (fp);

    return(1);
}

/*
 * Function:
 *  
 *      GRpal_check_palmgr
 *
 * Description:
 *
 *      This routine makes sure that a palette manager is created and
 *      initialized in the current object space.
 *
 */
extern int GRpal_check_palmgr ()
{ 
    OM_S_OBJID mod_objid, super_objid;
    OMuword    mod_osnum;

    ex$get_cur_mod ( id = &mod_objid,
                     osnum = &mod_osnum );

    ex$get_super ( mod_id = mod_objid,
                   mod_osnum = mod_osnum,
                   super_name = "palmgr",
                   create = TRUE,
                   super_class = "GRpalmgr",
                   super_id = &super_objid );
    return(1);
}

/************************************************************************/
/*   DELETE                                                             */
/************************************************************************/

/*
 * Function:
 *  
 *      GRpal_delete
 *
 * Description:
 *
 *      This routine delete and erases a palette.
 *
 */
extern int GRpal_delete ( p )
    struct palette  *p;
{
    int     msg = PAL_S_SUCCESS;
    int     mask = 1;

    /*
     * Delete the form if it hasn't been done already.
     */
    if (p->form) FIf_delete ( p->form );

    /*
     * Free up my collapse slot. This will cause a problem since when 
     * collapsed menu icon is moved it should free up the slot but 
     * GRpal_slots will not reflect this! The outcome will be slots that 
     * appear empty but aren't internally. Need to find a way to detect a 
     * move collapse icon...if this occurs set p->slot to -1 and free up 
     * the slot!
     */
    if ( p->slot != -1 ) GRpal_slots ^= (mask << p->slot);

    /*
     * Delete the node.
     */
    GRpal_delete_node ( p );

    return (msg);
}

/*
 * Function:
 *  
 *      GRpal_get_last_cmd
 *
 * Description:
 *
 *      This routine information about the last command selected
 *      from a palette.
 *
 */
extern int GRpal_get_last_cmd ( p, label, row, col )
    struct palette ** p;
    IGRint          * label;
    IGRint          * row;
    IGRint          * col;
{
    if (GRpal_cur_cmd.p)
    {
        if (p)      *p     = GRpal_cur_cmd.p;
        if (label)  *label = GRpal_cur_cmd.label;
        if (row)    *row   = GRpal_cur_cmd.row;
        if (col)    *col   = GRpal_cur_cmd.col;

        return (PAL_S_SUCCESS);
    }
    else return (PAL_W_NOCMD);
}

end implementation GRpalmgr;

