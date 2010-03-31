
#include <stdio.h>

#include "wl.h"

#ifdef X11
#include "FI.h"
#include "FIdyn.h"

struct FIsym_instance
    {
    unsigned char total_width;  /* Total width of symbol.	 */
    unsigned char total_height; /* Total height of symbol.	 */

    unsigned char xoff; /* x offset of real symbol from start pnt */
    unsigned char yoff; /* y offset of real symbol from start pnt */

    unsigned char sym_height;   /* Height of symbol itself */
    unsigned char sym_width;    /* Width  of symbol itself */

    unsigned char orig_font_height;     /* Original height of symbol itself */
    unsigned char orig_font_width;      /* Original  width of symbol itself */

    Pixmap pixmap;      /* Current scaled Pixmap to use	      */
    /* with XCopyPlane().		      */
    /* If form is not scaled, should be 0 */

    unsigned char sym_index;    /* Index of symbol into symbol file */
    };

struct FIgadget_instance
    {
    unsigned char type;

    char displayed;

    int label;  /* user-assigned gadget label */

    float xlo;  /* upper left  x-position of gadget */
    float ylo;  /* upper left  y-position of gadget */
    float xhi;  /* lower right x-position of gadget */
    float yhi;  /* lower right y-position of gadget */

    float orig_xsize;   /* orig. width  - used for scaling icons */
    float orig_ysize;   /* orig. height - used for scaling icons */

    int font_id;

    int font_width;
    int font_height;

    int on_font_width;
    int on_font_height;

    int text_length;

    int attr_mask;
    int default_attr_mask;

    double value;
    double default_value;

    float bodysize;
    float sym_width_scale_factor;
    float sym_height_scale_factor;

    int next_in_seq;

    int prev_in_seq;

    unsigned char *text;

    char *help_topic;
    char *command;
    char *fontname;

    char *user_pointer;
    char *menu_user_pointer;    /* Used by the menu interface MI */

    int erase_color;
    int off_color;
    int on_color;
    int off_color2;
    int on_color2;

    unsigned char effect;
    unsigned char justification;

    char just_received_passed_data;     /* JAJ:11/18/91	  */
    /* used in pass.c */
    int pass_label;

    unsigned int num_lines;     /* num_lines in text string */
    unsigned int largest_width; /* largest width in string   */

    struct FIgroup_obj *group;
    struct FIform_obj *form;

    struct FIsym_instance symbol_ptr;
    struct FIsym_instance on_symbol_ptr;

    int font_type;
    };


struct FIgroup_instance
    {
    unsigned short size;        /* How many slots currently allocated */

    char dont_pass_on;  /* flag: 0 => DO pass on all functions	 */
    /* to gadgets in the group     */
    /* 1 => DON'T pass on all functions */
    /* to gadgets in the group      */

    char single_select; /* flag: Group keeps only one member active */

    int current_active_gadget;

    int last_active_gadget;

    struct FIgadget_obj **gadgets;      /* Ptrs to gadgets in group	 */

    unsigned short begin_slot;  /* Start looking for next	 */
    /* available slot here.	 */
    };

struct FIgroup_obj
    {
    struct FIgadget_instance FIgadget;
    struct FIgroup_instance FIgroup;
    };


struct FIh_data
    {
    Form parentForm;    /* Parent form pointer    		 */
    Form *childForm;    /* Array of child form pointers	 */
    int childCount;     /* Number of child forms		 */
    int childAlloc;     /* Child array allocated length	 */
    int (*replyFunc) ();        /* Process data from children		 */
    };


struct FIform_obj
    {
    int (*initial_notification_routine) ();
    int (*intercept_routine) ();
    int (*notification_routine) ();
    int (*window_event_routine) ();
    int (*window_icon_routine) ();
    int (*button_event_routine) ();

    int attr_mask;

    long plane_mask;

    int form_label;

    int level;

    int creation_date;

    short orig_xlo;
    short orig_ylo;

    short orig_xsize;
    short orig_ysize;

    short min_xsize;
    short min_ysize;

    short max_xsize;
    short max_ysize;

    short xlo;
    short ylo;
    short xhi;
    short yhi;

    short screen_width; /* Size of screen form first defined on */
    short screen_height;

    short collapse_icon_xpos;
    short collapse_icon_ypos;

    unsigned char bgcolor;
    unsigned char collapse_icon_index;

    char collapse_pos_not_set;

    char activated;

    char screen;        /* This is one of the following:      */
    /* FI_CURRENT_SCRN                  */
    /* FI_DEFAULT_SCRN                  */
    /* FI_HARDCODED_SCRN                */

    char initial_creation;      /* Used to determine if need to    */
    /* store current screen size in  */
    /* form instance.                */
    short seq_off;

    char *collapse_icon_file;
    char *name;
    char *user_pointer;

    char *menu_user_pointer;    /* Used by menu subsystem to   */
    /* determine types of menus MS */

    struct FIh_data *child_node;        /* Used for hierarchical code */

    char *person;       /* Node name and user name. */

    struct FIgroup_obj *group;

    char **description;

    Window Xwindow;     /* X11-4/13/90-New window definition   */
    int Xscreen;        /* New screen definition       */
    /* This is the actual X-screen # that  */
    /* the for's window occupies.          */

    GC Xgc;     /* Graphics context		      */
    GC Xgc_text;        /* Graphics context for text  */

    char builder_mode;

    char adjusted_size;

    int seq_label;      /* Gadget to begin sequencing after */
    /* form is displayed.		    */

    short num_desc;

    unsigned short cmd_os;      /* "Object space number" of the EXNUC     */
    /* command object controlling the form.  */
    unsigned int cmd_oid;       /* "Object id" of the EXNUC		      */
    /* command object controlling the form.  */

    int begin_label;    /* Label to begin search for	      */
    /* next available gadget label.       */
    int begin_neg_label;

    int displayed;
    int initial_form_display;
    };



#endif

#include "OMminimum.h"

#include "igetypedef.h"
#include "igrtypedef.h"
#include "igr.h"
#include "igrdp.h"
#include "gr.h"

#include "hskyoptypes.h"
#include "hsanimate.h"
#include "HSrle.h"
#include "HSsara.h"

#include "HSpr_co_func.h"

#ifdef X11

/*
 *  Prototype declaration for static functions
 */


#if defined (__)
#undef __
#endif

#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C"
    {
#endif

/* HScbox.c */

    static int _FI_notify_routine __ ((int form_label,
                                                          int gadget_label,
                                                          double value,
                                                   struct FIform_obj * fp));

    static void _FI_remove_spaces __ ((char **string));

    static int _FI_add_spaces __ ((char *string,
                                                  Font font_id,
                                                  int font_type,
                                                  int largest_font_width,
                                                  int space_width));


#if defined(__cplusplus)
    }

#endif


#undef __


#define TRUE	1
#define FALSE 	0
#define NULL 	0

#define	SPACE	32
#define	RETURN	10

#define MEMORY_CHUNK		10

#define FORM_LABEL		100
#define TITLE_LABEL		11
#define ACCEPT_LABEL		12
#define CANCEL_LABEL		13
#define BEZEL_LABEL		14
#define ACCEPT_BTN_HEIGHT	32
#define ACCEPT_BTN_WIDTH	32


extern char *calloc ();
extern char *realloc ();

extern int (*FI_find_font_id) ();
extern int (*FI_strlen) ();
extern int (*FI_calc_text) ();

/* Local variables */

static char *scratch;
static char *begin_scratch;
static int button_selected;


static struct standard_st st =
    {
    20, 10, 100, 100, 0, 0, 30.0, NULL, NULL, NULL, "dutch801",
    NULL, FI_BLACK, FI_BLACK, FI_BLACK, FI_BLACK, 11, 0, 0
    };


/*** sml:09-25-91 -- use this for HFI_msg_box, HFI_msg_box2,        ***/
/***               HFI_message_box, HFI_message_box2                ***/
static int dismiss_by_keyboard = 0;


/* ARGSUSED */
static int _FI_notify_routine ( int form_label, int gadget_label, double value, struct FIform_obj *fp)
    {
    button_selected = gadget_label;

    return (FI_SUCCESS);
    }


static void _FI_remove_spaces ( char **string )
    {
    int end;
    char *ch_ptr;

    /*************************/
    /* Remove leading spaces */
    /*************************/

    for (;;)
        {
        if (**string == SPACE)
            {
            *string = (*string) + 1;
            }
        else
            {
            break;
            }
        }

    /**************************/
    /* Remove trailing spaces */
    /**************************/

    end = strlen (*string) - 1;

    ch_ptr = *string + end;

    for (;;)
        {
        if (end < 0)
            {
            break;
            }

        if ((*ch_ptr == SPACE) || (*ch_ptr == RETURN))
            {
            *ch_ptr = NULL;
            }
        else
            {
            break;
            }

        end--;
        ch_ptr--;
        }
    }


static int _FI_add_spaces ( char *string, Font font_id, int font_type,
                               int largest_font_width, int space_width)
    {
    char *begin_string = string;
    int font_height;
    int line_width;
    int num_char;
    int yy = 0;
    int dummy1;
    int found_a_space;


    num_char = FI_strlen (string, font_type);

    /*********************************************/
    /* Calculate the initial width of the string */
    /*********************************************/

    FI_calc_text (font_id, string, num_char, &font_height, &line_width,
                  &dummy1, font_type);

    scratch = begin_scratch;

    found_a_space = FALSE;

    for (;;)
        {
        *scratch = *string;

        /*******************/
        /* Check for space */
        /*******************/

        if (*string == SPACE)
            {
            found_a_space = TRUE;

            /*********************/
            /* Add another space */
            /*********************/

            *(++scratch) = SPACE;

            /***************************************/
            /* Increment the line_width by a space */
            /***************************************/

            line_width += space_width;

            /****************************************/
            /* Quit when the line width is greater	 */
            /* than the largest line width.		 */
            /****************************************/

            if (line_width >= largest_font_width)
                {
                /****************************************/
                /* Copy the rest of the characters	 */
                /* into the string.			 */
                /****************************************/

                strcpy (scratch, string);
                break;
                }

            /************************************/
            /* Search for a non_blank character */
            /************************************/

            for (;;)
                {
                yy++;

                *(++scratch) = *(++string);

                if (*string != SPACE)
                    {
                    break;
                    }
                }
            }

        scratch++;
        string++;

        /**************************************************/
        /* Break when all the characters have been parsed */
        /**************************************************/

        if (++yy > num_char)
            {
            break;
            }
        }

    strcpy (begin_string, begin_scratch);

    return (found_a_space);
    }


/*********************************************************************/
/*** X11-7/5/90-The purpose of this predicate routine is to remove ***/
/*** the events listed, and to only remove expose events for the   ***/
/***  arg passed in.						   ***/
/*********************************************************************/

/*********************************************************************
/ * ARGSUSED * /
static Bool _FI_message_predicate ( Display *display, XEvent *evt, Window *arg )
{
  if ( evt->xany.window == *arg )
    {
      return ( True );
    }
  return ( False );
}
****************************************************** JAJ:11/21/91 ***/


int HFI_confirm_box ( int screen, int xpos, int ypos, char *title, int title_color,
                         char *title_font, double title_bodysize, char *message, int message_color,
                         char *message_font, double message_bodysize, int display_mode,
                         int presentation_mode, int line_length)
    {
    char **orig_pointers;

    char *ch_ptr;

    int status;
    int form_height;

    int title_width;
    int title_height;

    int min_form_size;
    int message_length;
    int num_lines;
    int max_num_lines;
    int font_height;
    int font_width;
    int num_to_copy = 0;
    int current_pos = 0;
    int found_format = FALSE;
    int do_non_format_search;
    int found_a_token;
    int wrap;
    int slots;
    int ii;
    char multi_text[4000];
    int dummy1;
    XEvent event;
    double actual;
    Window window;
    Form form;
    int form_width;
    char **messages;
    Font font_id;
    int font_type;
    int largest_font_width;
    int space_height;
    int space_width;
    XSetWindowAttributes form_xattr;
    extern Display *_FI_display;
    extern int FI_current_screen_width, FI_current_screen_height;

    /*************************/
    /* If NULL string return */
    /*************************/

    if (message[0] == NULL)
        {
        return (FI_SUCCESS);
        }


    /*************************/
    /* Check the line length */
    /*************************/

    if ((line_length <= 0) || (line_length > 1000))
        {
        line_length = 40;
        }


    /*********************************/
    /* Initialize largest_font_width */
    /*********************************/

    largest_font_width = 0;


    /*********************/
    /* Create blank form */
    /*********************/

    status = FIf_new (FORM_LABEL, "", _FI_notify_routine, (Form) & form);
    if (status)
        {
        return (status);
        }

    /**************************/
    /* Calloc scratch strings */
    /**************************/

    scratch = calloc ((unsigned int) (line_length * 2), 1);
    begin_scratch = scratch;


    /************************/
    /* Set up form defaults */
    /************************/


    /*************************************
    FIf_set_screen ( (Form) form, screen );
    *************************************/


    /***********************************************
    if ( presentation_mode & FI_SAVE_RESTORE )
      {
        FIf_set_attr ( (Form) form, FI_SAVE_RESTORE );
      }
    ************************************************/


/**********  THIS CAUSES CORE DUMPS NOW  JAJ:09/11/91 **************
 FIX INVESTIGATE FIX REPAIR
  FIf_set_collapse_symbol ( (Form) form, "collapse.icon", 0 );
********************************************************************/



    /***************************************/
    /* Calculate the form width and height */
    /***************************************/

    FI_find_font_id (message_font, message_bodysize, &font_id, &actual,
                     FI_TEXT, &font_type);

    message_length = FI_strlen (message, font_type);

    num_lines = message_length / line_length + 1;

    if (font_type == FI_FS_7_OR_16_BIT_FONT_TYPE)
        {
        line_length *= 2;
        }

    /*****************************************/
    /* Check for RETURN nested in the string */
    /*****************************************/

    if (strchr (message, RETURN) != NULL)
        {
        found_format = TRUE;
        }

    /************************************************/
    /* Add buffer because the num_lines may grow	 */
    /* because of wraps on word boundaries.		 */
    /************************************************/

    num_lines++;
    max_num_lines = num_lines;

    messages = (char **) calloc ((unsigned int) num_lines,
                                 sizeof (char *));

    orig_pointers = (char **) calloc ((unsigned int) num_lines,
                                      sizeof (char *));

    /***********************************/
    /* Set num_lines to 0 before begin */
    /***********************************/

    num_lines = 0;

    for (;;)
        {
        wrap = FALSE;

        do_non_format_search = TRUE;

        if (found_format)
            {
            /*************************************/
            /* Find return nested in the message */
            /*************************************/

            for (ii = current_pos; ii != strlen (message); ii++)
                {
                if (message[ii] == RETURN)
                    {
                    num_to_copy = (ii + 1) - current_pos;

                    do_non_format_search = FALSE;

                    break;
                    }
                }
            }

        if (num_to_copy > line_length)
            {
            do_non_format_search = TRUE;
            }

        if (do_non_format_search)
            {
            if ((message_length - current_pos) < line_length)
                {
                num_to_copy = message_length - current_pos;
                }
            else
                {
                num_to_copy = line_length;
                wrap = TRUE;
                }
            }

        if (num_to_copy <= 0)
            {
            break;
            }

        /****************************************/
        /* Adjust the num_to_copy so that	 */
        /* it breaks on a word boundary.	 */
        /****************************************/

        if (wrap)
            {
            found_a_token = FALSE;

            ch_ptr = &message[current_pos];

            for (ii = 0; ii != num_to_copy; ii++)
                {
                if ((*ch_ptr == SPACE) || (*ch_ptr == '-'))
                    {
                    found_a_token = TRUE;
                    }

                ch_ptr++;
                }

            /**********************************************/
            /* Search the string only if there is a space */
            /**********************************************/

            if (found_a_token)
                {
                ch_ptr = &message[num_to_copy + current_pos];

                for (;;)
                    {
                    /* If the next char after the num_to_copy */
                    /* is a space or a dash then it is a	  */
                    /* perfect match.			  */

                    if ((*ch_ptr == SPACE) || (*ch_ptr == '-'))
                        {
                        break;
                        }

                    num_to_copy--;
                    ch_ptr--;
                    }
                }
            }

        if (num_to_copy <= 0)
            {
            num_to_copy = line_length;
            }

        if (display_mode == FI_FITTED)
            {
            /*****************************************/
            /* Calloc extra space for FI_FITTED text */
            /*****************************************/

            slots = num_to_copy + line_length;
            }
        else
            {
            slots = num_to_copy;
            }

        messages[num_lines] = calloc ((unsigned int) slots,
                                      sizeof (char *));

        /************************************************/
        /* Save the original pointer to the string	 */
        /* so they can be freed later.			 */
        /************************************************/

        orig_pointers[num_lines] = messages[num_lines];


        /******************************************************/
        /* Copy the character into the current message string */
        /******************************************************/

        strncpy (messages[num_lines], &message[current_pos],
                 num_to_copy);

        _FI_remove_spaces (&messages[num_lines]);

        current_pos += num_to_copy;


        FI_calc_text (font_id, messages[num_lines],
                      FI_strlen (messages[num_lines], font_type),
                      &font_height, &font_width, &dummy1, font_type);

        if (font_width > largest_font_width)
            {
            largest_font_width = font_width;
            }

        num_lines++;

        /**************************************************/
        /*** Expand the messages array if FITTED TEXT	***/
        /*** and the num_lines have grown past bounds.	***/
        /**************************************************/

        if (num_lines >= max_num_lines)
            {
            max_num_lines += MEMORY_CHUNK;

            messages = (char **) realloc ((char *) messages,
                          (unsigned int) (max_num_lines * sizeof (char *)));

            orig_pointers = (char **) realloc ((char *) orig_pointers,
                          (unsigned int) (max_num_lines * sizeof (char *)));
            }
        }

    /**********************************/
    /* Calculate the width of a space */
    /**********************************/

    FI_calc_text (font_id, " ", 1, &space_height, &space_width, &dummy1,
                  font_type);


    if ((num_lines > 1) && (display_mode == FI_FITTED))
        {
        /* This will try to adjust the lines so that they	 */
        /* are close to the same size.  Not the last line.	 */

        for (ii = 0; ii < num_lines - 1; ii++)
            {
            for (;;)
                {
                FI_calc_text (font_id, messages[ii],
                              FI_strlen (messages[ii], font_type),
                              &font_height, &font_width,
                              &dummy1, font_type);

                if (font_width >= largest_font_width)
                    {
                    break;
                    }
                else
                    {
                    /*****************************/
                    /* If status is bad then the */
                    /* string cannot be added to */
                    /*****************************/

                    status = _FI_add_spaces (messages[ii], font_id,
                                             font_type, largest_font_width,
                                             space_width);
                    if (!status)
                        {
                        break;
                        }
                    }
                }
            }
        }

    st.xlo = 20;
    st.ylo = 10;
    st.xlo = 20;
    st.ylo = 10;

    /**************************************************/
    /* Create the TITLE only if the title is not null */
    /**************************************************/

    title_width = 0;
    title_height = 0;

    if (title && title[0])
        {
        st.fontname = title_font;
        st.bodysize = title_bodysize;
        st.text = title;
        st.off_color = title_color;

        FIg_new ((Form) form, FI_TEXT, TITLE_LABEL);
        FIg_set_standard_variables ((Form) form, TITLE_LABEL, &st);
        FIg_activate ((Form) form, TITLE_LABEL);
        FIg_set_notify_off ((Form) form, TITLE_LABEL);

        FIg_get_size ((Form) form, TITLE_LABEL, &title_width,
                      &title_height);
        title_width += 40;
        }

    /* Set the form width */

    form_width = largest_font_width + 80;

    min_form_size = ACCEPT_BTN_WIDTH + 40 + title_width;

    if (presentation_mode & FI_CANCEL)
        {
        min_form_size += ACCEPT_BTN_WIDTH;
        }

    if (form_width < min_form_size)
        {
        form_width = min_form_size;
        }

    /*****************************/
    /* Calculate the form height */
    /*****************************/

    form_height = 130;

    if (num_lines > 1)
        {
        form_height += (num_lines - 1) * font_height;
        }

    FIf_set_size ((Form) form, form_width, form_height);
    FIf_set_orig_size ((Form) form, form_width, form_height);


    /****************************/
    /* Create the accept button */
    /****************************/


    if (presentation_mode & FI_ACCEPT)
        {
        st.xlo = form_width - ACCEPT_BTN_WIDTH - 20;
        st.xhi = st.xlo + ACCEPT_BTN_WIDTH;
        st.yhi = st.ylo + ACCEPT_BTN_HEIGHT;
        st.off_color = FI_BLACK;
        st.on_color = FI_YELLOW;
        st.value = 0.0;
        st.fontname = "FIsym";
        st.symbol_index = 11;

        FIg_new ((Form) form, FI_BUTTON, ACCEPT_LABEL);
        FIg_set_standard_variables ((Form) form, ACCEPT_LABEL, &st);
        }

    /* Create the cancel button */

    if (presentation_mode & FI_CANCEL)
        {
        st.xlo = st.xlo - ACCEPT_BTN_WIDTH - 1;
        st.xhi = st.xlo + ACCEPT_BTN_WIDTH;
        st.symbol_index = 8;

        FIg_new ((Form) form, FI_BUTTON, CANCEL_LABEL);
        FIg_set_standard_variables ((Form) form, CANCEL_LABEL, &st);
        }


    /*******************************/
    /* Create the bezel if in mode */
    /*******************************/

    st.xlo = 20;
    st.xhi = form_width - 20;
    st.ylo += ACCEPT_BTN_HEIGHT + 15;
    st.yhi = form_height - 20;

    if (!(presentation_mode & FI_NO_BEZEL))
        {
        st.value = 1.0;
        st.off_color = FI_LT_GREY;
        st.fontname = "";

        FIg_new ((Form) form, FI_BEZEL, BEZEL_LABEL);
        FIg_set_standard_variables ((Form) form, BEZEL_LABEL, &st);
        }

    /****************************************/
    /* Check the coordinates of the form	 */
    /* and see if it needs centering.	 */
    /****************************************/

    if (xpos < 0)
        {
        /**************************************/
        /* Center the form in the x direction */
        /**************************************/

        xpos = (FI_current_screen_width - form_width) / 2;
        }

    if (ypos < 0)
        {
        /**************************************/
        /* Center the form in the y direction */
        /**************************************/

        ypos = (FI_current_screen_height - form_height) / 2;
        }

    /***********************************************/
    /* Create a text gadget to display the message */
    /******************************** GMD 10/2/91 **/

    multi_text[0] = 0;

    for (ii = 0; ii < num_lines; ii++)
        {
        if (ii != 0)
            {
            strcat (multi_text, "\n");
            }

        strcat (multi_text, messages[ii]);
        }

    st.fontname = message_font;
    st.bodysize = message_bodysize;
    st.text = multi_text;
    st.off_color = message_color;
    st.xlo = 30;
    st.ylo += 10;

    FIg_new ((Form) form, FI_TEXT, 999);
    FIg_set_standard_variables ((Form) form, 999, &st);

    /************************************/
    /* Activate the gadgets on the form */
    /************************************/

    FIg_activate ((Form) form, FI_FORM_GROUP);

    FIg_set_notify_off ((Form) form, 999);

    FIg_set_justification ((Form) form, 999, display_mode);


    FIf_set_location ((Form) form, xpos, ypos);

    /********************/
    /* Display the form */
    /********************/

    status = FIf_display ((Form) form);
    if (status)
        {
        return (status);
        }

/*
  FIf_set_resize_off ( (Form) form );
*/
/*  window = form->Xwindow;*/
    FIf_get_window (form, &window);
    button_selected = 0;

    /*****************************************/
    /* Make the Form be "save_under" always. */
    /*****************************************/

    form_xattr.save_under = TRUE;
    XChangeWindowAttributes (_FI_display, window, CWSaveUnder,
                             &form_xattr);

    /*****************************************/
    /* Loop until they hit the accept button */
    /*****************************************/

    for (;;)
        {
        /*** If the form is SAVE/RESTORE, then only events per-	   ***/
        /*** taining to the window will be removed from the queue. ***/
        /***************************************************************
        if ( presentation_mode & FI_SAVE_RESTORE )
          {
            XIfEvent ( _FI_display, &event, _FI_message_predicate,
                                                  ( char *) &window );
          }
        else
          {
        *********************************************** JAJ:11/21/91 ***/

        XNextEvent (_FI_display, &event);

        /***
          }
        ***/


        /************ JAJ:11/21/91 **************************************
        if (	( event.type == Expose )			&&
                  ( event.xany.window == form->Xwindow )		&&
                  ( presentation_mode & FI_SAVE_RESTORE )	 	 )
          {
            XGrabPointer ( _FI_display, form->Xwindow, False,
                          ButtonPressMask , GrabModeAsync, GrabModeAsync,
                          form->Xwindow, None, CurrentTime );
  
            XGrabServer ( _FI_display );
          }
        ****************************************************************/

        FI_process_event (&event, 0);

        if ((dismiss_by_keyboard &&
             ((event.type == ButtonPress) || (event.type == KeyPress))) ||
            (button_selected != 0) /* Set in notification */ )
            {
            /**************************** JAJ:11/21/91 ***********
            if ( presentation_mode & FI_SAVE_RESTORE )
              {
                XUngrabServer ( _FI_display );
  
                XUngrabPointer ( _FI_display, CurrentTime );
              }
            *****************************************************/

            FIf_delete ((Form) form);

            break;
            }
        }

    /*********************/
    /* Free the messages */
    /*********************/

    for (ii = 0; ii < num_lines; ii++)
        {
        if (orig_pointers[ii])
            {
            free (orig_pointers[ii]);
            }
        }

    if (orig_pointers)
        {
        free ((char *) orig_pointers);
        /*** orig_pointers = 0; ***/
        }

    if (messages)
        {
        free ((char *) messages);
        /*** messages = 0; ***/
        }

    /****************/
    /* Free scratch */
    /****************/

    if (begin_scratch)
        {
        free (begin_scratch);
        }

    if (button_selected == CANCEL_LABEL)
        return (0);
    else
        return (1);
    }


int HFI_msg_box ( char *title, int title_color, char *message, int message_color)
    {
    return (HFI_message_box (FI_CURRENT_SCREEN, -1, -1, title,
                           title_color, "dutch801b", (double) 25.0, message,
                             message_color, "swiss742b", (double) 20.0,
                             FI_FITTED, 40));
    }


int HFI_msg_box2 (char *title, int title_color, char *message, int message_color)
    {
    return (HFI_message_box2 (FI_CURRENT_SCREEN, -1, -1, title,
                           title_color, "dutch801b", (double) 25.0, message,
                              message_color, "swiss742b", (double) 20.0,
                              FI_FITTED, 40));
    }


int HFI_message_box (int screen, int xpos, int ypos, char *title, int title_color, char *title_font,
                       double title_bodysize, char *message, int message_color, char *message_font,
                         double message_bodysize, int display_mode, int line_length)
    {
    dismiss_by_keyboard = 0;

    return (HFI_confirm_box (screen, xpos, ypos, title, title_color,
                         title_font, title_bodysize, message, message_color,
                             message_font, message_bodysize, display_mode,
                             FI_ACCEPT,
                             line_length));
    }



int HFI_message_box2 (int screen, int xpos, int ypos, char *title, int title_color,
                          char *title_font, double title_bodysize, char *message,
                          int message_color, char *message_font,
                          double message_bodysize, int display_mode, int line_length)
    {
    dismiss_by_keyboard = 1;

    return (HFI_confirm_box (screen, xpos, ypos, title, title_color,
                         title_font, title_bodysize, message, message_color,
                             message_font, message_bodysize, display_mode,
                             0,
                             line_length));
    }

#else
int HFI_confirm_box (int screen,
                         int xpos,
                         int ypos,
                         char *title,
                         int title_color,
                         char *title_font,
                         double title_bodysize,
                         char *message,
                         int message_color,
                         char *message_font,
                         double message_bodysize,
                         int display_mode,
                         int presentation_mode,
                         int line_length)

    {
    int status;

    status = FI_confirm_box (screen, xpos, ypos, title, title_color,
                         title_font, title_bodysize, message, message_color,
                             message_font, message_bodysize, display_mode,
                             presentation_mode, line_length);

    return (status);
    }

#endif
