/*
Name
        genbarmenu

Description
        This program uses the FORMS genmenu program to produce a menu from an
        outline file, then adds some gadgets used by EMS to the menu.

History
        mrm     07/30/92    creation
        elp     01/05/93    port to NT
        mrm     03/10/93    added -a, -A, -t, and -T switches
        mrm     03/22/93    specify a colormap to FI_enter (on advice from
                            XFORMS dev to fix problem on SGI); fixed calls to
                            set adp field sizes
        mrm     07/29/93    changed font to mechsws742b
*/

#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#ifdef NT
#include <windows.h>
#define MAXPATHLEN _MAX_PATH
#else
#include <unistd.h>
#include <sys/param.h>
#endif

#ifdef X11
#include <X11/Intrinsic.h>
#endif

#ifdef ENV5
#include <tools.h>
#endif

#include <FI.h>
#include <FIdyn.h>

#include "adpdef.h"
#include "igrtypedef.h"

/*
        Miscellaneous definitions and exit codes.
*/

#define Success         0
#define ForkFailed      1
#define GenMenuFailed   2
#define RetrieveFailed  3
#define Usage           4

#define FormLabel       123

#define ADPGadgetsWidth 67
#define SwapTaskWidth   75 

#define MyBufferSize    MAXPATHLEN * 4

#define LineXLo         4
#define LineYLo         37
#define LineXHi         67
#define LineYHi         37

#define WeightXLo       5
#define WeightYLo       10
#define WeightXHi       23
#define WeightYHi       27

#define LayerXLo        30
#define LayerYLo        10
#define LayerXHi        66
#define LayerYHi        27

#define Null    ((char*)NULL)

/*
        Global and static data.
*/

#ifdef NT
#define EXIT return
#else
#define EXIT exit
#endif

static char *fontname = "mono821b";

#if defined( ENV5 ) || defined( NT )
static char *genmenu = "genmenu";
#endif

#ifdef X11
static char *genmenu = "xgenmenu";
#endif

/*
Name
        usage

Description
        This function prints an error messages and terminates the process.
*/

void usage(char *progname)
{
    fprintf(stderr, "Usage: %s [%s options] ", progname, progname);
    fprintf(stderr, "[%s options] <outline> <menu-file>\n", genmenu);
    fprintf(stderr, "%s options:\n", progname);
    fprintf(stderr, "\t-a\tadd Active Drawing Parameters gadgets (default)\n");
    fprintf(stderr, "\t-A\tomit Active Drawing Parameters gadgets\n");
    fprintf(stderr, "\t-t\tadd Task List button (default)\n");
    fprintf(stderr, "\t-T\tomit Task List button\n");
    fprintf(stderr, "%s options:\n", genmenu);
    fprintf(stderr, "\t-v\n");
    fprintf(stderr, "\t-p <palette name prefix>\n");
    exit(Usage);
}

/*
Name
        main

Description
        The main function handles command line arguments.
*/

#ifdef NT

int WINAPI WinMain( HINSTANCE hInst,
                    HINSTANCE hPrevInst,
                    LPSTR lpCmdLn,
                    int nShowCmd )

#else

main(int argc, char *argv[])

#endif
{
    char buf[MyBufferSize], grnuc[MAXPATHLEN], *menu_file;
    int sts;
    int i, x, y, n, w, h;
    int add_adp_gadgets = TRUE, add_task_button = TRUE;
    FILE *fp;
    Form form;
    struct standard_st st;
#ifdef X11
    Display *display;
    Widget top_level;
    XtAppContext app_context;
#endif
#ifdef NT
    int argc = 0;
    char **argv = 0;

    /*
     *  Convert argument lpCmdLn to argc & argv format
     */
    lpCmdLn_to_argc_argv( hInst, lpCmdLn, &argc, &argv );
#endif

    /* monkey with the command args to produce a "real" genmenu command line */
    sprintf(buf, "%s 2>&1 ", genmenu);
    for (i = 1; i < argc; i++)
    {
        if ((strcmp(argv[i], "-t") == 0) || (strcmp(argv[i], "-n") == 0))
            add_task_button = TRUE;
        else if (strcmp(argv[i], "-T") == 0)
            add_task_button = FALSE;
        else if (strcmp(argv[i], "-a") == 0)
            add_adp_gadgets = TRUE;
        else if (strcmp(argv[i], "-A") == 0)
            add_adp_gadgets = FALSE;
        else if (strcmp(argv[i], "-?") == 0)
            usage(argv[0]);
        else
            sprintf(&buf[strlen(buf)], "%s ", argv[i]);
    }

    /* assume menu name is the last arg and store a pointer to it */
    menu_file = argv[--i];
    /* fork the genmenu process to do most of the real work */
    if ((fp = (FILE *)popen(buf, "r")) == NULL)
    {
        fprintf(stderr, "Failed to execute %s\n", genmenu);
        EXIT(ForkFailed);
    }

    /* wait for it to finish */
    while (fgets(buf, MyBufferSize, fp))
        printf("%s", buf);

    /* get the results of the "real" genmenu */
    sts = pclose(fp) >> 8;
#ifdef ReliableReturnCode
    if (sts != 0)
    {
        fprintf(stderr, "%s failed: %d\n", genmenu, sts);
        EXIT(GenMenuFailed);
    }
#endif

    if (!add_adp_gadgets && !add_task_button)
    {
        /* nothing to add */
        exit(Success);
    }

#ifdef ENV5
    /* initialize the toolkit */
    Enter_tools_no_act();
    FI_enter();
    Enable_events(FI_EVENT_MASK);
#endif

#ifdef X11
    /* initialize the toolkit */
    top_level = XtVaAppInitialize(&app_context, "GRcpasm", NULL, NULL,
#ifdef SUNOS
                                  (Cardinal *)&argc,
#else
                                  (int *)&argc,
#endif
                                  (String *)argv, (String *)NULL, NULL);


    /* initialize the forms system */
    display = XtDisplay(top_level);
    FSEnter(display, 0);
    FI_enter(display, DefaultColormap(display, DefaultScreen(display)), 32);
#endif

#ifdef NT
    /* initialize the toolkit */
    FI_enter( hInst );
#endif

    /* retrieve the form */
    if ((sts = FIf_new(FormLabel, menu_file, NULL, &form)) != FI_SUCCESS)
    {
        fprintf(stderr, "Failed to retrieve %s: %d\n", menu_file, sts);
        EXIT(RetrieveFailed);
    }

    /* resize the form */
    FIf_get_size(form, &w, &h);
    FIf_set_scaling_off(form);
    if (add_adp_gadgets)
        w += ADPGadgetsWidth;
    if (add_task_button)
        w += SwapTaskWidth;
    FIf_set_size(form, w, h);
    FIf_set_orig_size(form, w, h);
    FIf_set_scaling_on(form);

    if (add_adp_gadgets)
    {
        /* slide all the buttons over to the right */
        FIf_get_next_label(form, &n);
        for (i = 11; i < n; i++)
        {
            FIg_get_location(form, i, &x, &y);
            x += ADPGadgetsWidth;
            FIg_set_location(form, i, x, y);

        }
    }

    if (add_task_button)
    {
        /* Make sure the font with the customized arrowhead can be found.
           Should use FI_append_FSfont_path, but that seems to be documented
           but nonexistent.  */
        GRget_product_data("Grnuc", Null, Null, Null, Null, grnuc);
        sprintf(buf, "%s/resrc/fontserver/typeface:%s/config/english/typeface",
                GRget_ingrhome(NULL), grnuc);
        FI_set_FSfont_path(buf);

        /* add the button */
        st.xlo = w - SwapTaskWidth - 3 + 1;
        st.ylo = 3; 
        st.xhi = w - 3;
        st.yhi = h - 3;
        st.off_color = FI_BLACK;
        st.on_color = FI_WHITE;
        st.command = "GRSwPr";
        st.fontname = "mechsws742b";
        st.bodysize = 12;
        st.attr_mask = FI_DEFAULT  | FI_TEXT_GADGET | FI_CMD_KEY;
        FIg_new(form, FI_BUTTON, TASK_LIST_BUTTON);
        FIg_set_standard_variables(form, TASK_LIST_BUTTON, &st);
        FIg_set_justification(form, TASK_LIST_BUTTON, FI_CENTER_JUSTIFIED);
        FIg_activate(form, TASK_LIST_BUTTON);
    }
    
    if (add_adp_gadgets)
    {
        /* add the color line */
        st.command = NULL;
        FIg_new(form, FI_LINE, ADP_LINE_LABEL);
        st.xlo = LineXLo;
        st.ylo = LineYLo;
        st.xhi = LineXHi;
        st.yhi = LineYHi;
        st.attr_mask = 0;       /* ?? */
        st.off_color = FI_DK_GREY;
        FIg_set_standard_variables(form, ADP_LINE_LABEL, &st);
        FIg_set_line_weight(form, ADP_LINE_LABEL, 1);
        FIg_activate(form, ADP_LINE_LABEL);

        /* add the weight field */
        FIg_new(form, FI_FIELD, ADP_WEIGHT_LABEL);
        st.xlo = WeightXLo;
        st.ylo = WeightYLo;
        st.xhi = WeightXHi;
        st.yhi = WeightYHi;
        st.bodysize = 15;
        st.fontname = fontname;
        st.attr_mask = FI_TEXT_GADGET;
        st.off_color = FI_BLACK;
        st.on_color = FI_BLACK;
        FIg_set_standard_variables(form, ADP_WEIGHT_LABEL, &st);
        FIg_set_justification(form, ADP_WEIGHT_LABEL, FI_RIGHT_JUSTIFIED);
        FIfld_set_attr(form, ADP_WEIGHT_LABEL, 0, 0);
        FIfld_set_type(form, ADP_WEIGHT_LABEL, 0, FI_INT);
        FIfld_set_mode(form, ADP_WEIGHT_LABEL, FI_REVIEW);
        FIg_activate(form, ADP_WEIGHT_LABEL);
        FIfld_set_num_vis_chars(form, ADP_WEIGHT_LABEL, 0, 2);
        FIfld_set_num_vis_rows(form, ADP_WEIGHT_LABEL, 1);

        /* add the layer field */
        FIg_new(form, FI_FIELD, ADP_LAYER_LABEL);
        st.xlo = LayerXLo;
        st.ylo = LayerYLo;
        st.xhi = LayerXHi;
        st.yhi = LayerYHi;
        st.bodysize = 15;
        st.fontname = fontname;
        st.attr_mask = FI_TEXT_GADGET;
        st.off_color = FI_BLACK;
        st.on_color = FI_BLACK;
        FIg_set_standard_variables(form, ADP_LAYER_LABEL, &st);
        FIg_set_justification(form, ADP_LAYER_LABEL, FI_RIGHT_JUSTIFIED);
        FIfld_set_attr(form, ADP_LAYER_LABEL, 0, 0);
        FIfld_set_type(form, ADP_LAYER_LABEL, 0, FI_INT);
        FIfld_set_mode(form, ADP_LAYER_LABEL, FI_REVIEW);
        FIg_activate(form, ADP_LAYER_LABEL);
        FIfld_set_num_vis_chars(form, ADP_LAYER_LABEL, 0, 4);
        FIfld_set_num_vis_rows(form, ADP_LAYER_LABEL, 1);
    }
    /* write the form */
    FIf_save(form, menu_file);

    EXIT(Success);
}
