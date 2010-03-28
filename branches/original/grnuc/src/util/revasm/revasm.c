/*
Name
        revasm

Description
        This is the main function for the Revise Assembly code.

History
        mrm     ??/??/92        creation
        mrm     07/16/93        check for MDS if EMS is not loaded, removed
                                hacks added for custom Xerox build
*/

#include <stdio.h>
#include <unistd.h>
#include <string.h>
#include <sys/param.h>
#include <alloca.h>
#ifdef X11
#include <X11/Intrinsic.h>
#include <FI.h>
#endif
#ifdef ENV5
#include <tools.h>
#include <FI.h>
#endif
#include <UMS.h>
#include "grmsg.h"
#include "refdef.h"
#include "refco.h"

/*
        Miscellaneous definitions and exit codes.
*/

#define TRUE    1
#define FALSE   0
#define Null    ((char*)NULL)

#define Success         0
#define NoGrnuc         1
#define NoForm          2
#define InitError       3

/*
        External references.
*/

extern int optind;
extern char *optarg;
extern int errno;
extern void GRrevasm_callback();
extern void GRrevasm_button_intercept();

/*
        Global and static data.
*/

static int verbose = FALSE;
static int exit_status = Success;
static char *CopyAssemblyForm = "GRCopyAssy";

/*
Name
        usage

Description
        This function prints the command line syntax and a short explanation
        to stderr.  This function does not return; it terminates the process.
*/

void usage(progname)
char *progname;
{
    fprintf(stderr, "Usage: %s [-p path] [-s suffix] filename\n", progname);
    exit(1);
}

/*
Name
        main

Description
        The main function handles command line arguments.

*/

main(argc, argv)
int argc;
char *argv[];
{
    int i, sts, flags;
    char c, grnuc[MAXPATHLEN], buf[MAXPATHLEN], title[32];
    char *new_path, *suffix;
    Form form;
    GRrevasm_data cd;
#ifdef X11
    Display  *display;
    Widget top_level;
    XtAppContext app_context;
#endif

    /* initialize */
    new_path = NULL;
    suffix = NULL;
    flags = ChangeRefAttachments;

#ifdef ENV5
    Enter_tools();
    FI_enter();
    Enable_events(FI_EVENT_MASK);
#endif

#ifdef X11
    /* initialize the toolkit */
    top_level = XtVaAppInitialize(&app_context, "GRrevasm", NULL, NULL,
#ifdef SUNOS
                                  (Cardinal *)&argc,
#else
                                  (int *)&argc,
#endif
                                  (String *)argv, (String *)NULL, NULL);

    /* initialize the forms system */
    display = XtDisplay(top_level);
    FSEnter(display, 0);

    /* Specify a colormap to display form on SGI machines
       --Mrudula TR119303656 */

    FI_enter(display, DefaultColormap(display, DefaultScreen(display)), 32);
#endif

    FI_use_thin_bezel();

    /* parse the command line arguments */
    while ((c = getopt(argc, argv, "p:qs:v")) != EOF)
    {
        switch (c)
        {
          case 'p': new_path = optarg; break;
          case 'q': flags &= ~ChangeRefAttachments; break;
          case 's': suffix = optarg; break;
          case 'v': verbose = TRUE; GRrevasm_verbose(TRUE); break;
          default:  usage(argv[0]); break;
        }
    }

    /* make sure at least one filename was specified */
    if (optind >= argc) usage(argv[0]);

    /* make sure that the file can be read */
    if (access(argv[optind], R_OK) != 0)
    {
        fprintf(stderr,"Cannot read %s\n", argv[optind]);
        perror(argv[optind]);
        exit(InitError);
    }

    /* assign a suffix if the files are going into the same directory */
    if (new_path == NULL && suffix == NULL)
        suffix = "~";

    /* make sure the path to EXNUC is there, and utilities are executable */
    buf[0] = NULL;
    GRget_product_data("Exnuc", Null, Null, Null, Null, buf);
    if (buf[0] == NULL)
    {
        fprintf(stderr, "Failed to find Exnuc in $INGRHOME/product_data\n");
        exit(NoGrnuc);
    }
    i = strlen(buf);
    strcat(buf, "bin/dros");
    if (access(buf, X_OK) != 0)
    {
        fprintf(stderr,"Cannot execute %s\n", buf);
        perror(buf);
        exit(NoGrnuc);
    }
    buf[i] = NULL;
    strcat(buf, "bin/copyOS");
    if (access(buf, X_OK) != 0)
    {
        fprintf(stderr,"Cannot execute %s\n", buf);
        perror(buf);
        exit(NoGrnuc);
    }

    /* find the path to EMS */
    buf[0] = NULL;
    GRget_product_data("Emsui01", Null, Null, Null, Null, buf);
    if (buf[0] == NULL)
    {
        GRget_product_data("Emsui02", Null, Null, Null, Null, buf);
        if (buf[0] == NULL)
        {
            GRget_product_data("Mdsui01",  Null, Null, Null, Null, buf);
            if (buf[0] == NULL)
                GRget_product_data("Mdsui02",  Null, Null, Null, Null, buf);
        }
    }

    if (buf[0] == NULL)
    {
        fprintf(stderr,
                "Failed to find EMS or MDS in $INGRHOME/product_data\n");
        exit(NoGrnuc);
    }

    /* find the path to GRNUC */
    grnuc[0] = NULL;
    GRget_product_data("Grnuc", Null, Null, Null, Null, grnuc);
    if (grnuc[0] == NULL)
    {
        fprintf(stderr, "Failed to find Grnuc in $INGRHOME/product_data\n");
        exit(NoGrnuc);
    }

    /* initialize the message system */
    sprintf(buf, "%s/config/english/messages/grmsg.msg", grnuc);
    UMSInitMsg(buf, UMS_INDEX);

    /* set up the FORMS search paths */
    sprintf(buf, "%s/config/english/forms", grnuc);
    FI_set_form_path(buf);
    sprintf(buf, "%s/config/english/icons", grnuc);
    FI_set_symbol_path(buf);

    /* create the Revise Assembly form */
    form = (Form)NULL;
    sts = FIf_new(CopyAssemblyFormLabel, CopyAssemblyForm, 
                  GRrevasm_callback, &form);
    if ((sts != FI_SUCCESS) || (form == NULL))
    {
        fprintf(stderr, "Failed to create form %s\n", CopyAssemblyForm);
        exit(NoForm);
    }

    /* set up a button intercept routine to handle the "operation" field */
    sts = FIf_set_button_intercept_routine(form, GRrevasm_button_intercept);

    /* store some data in the form */
    if (suffix)
    {
        strncpy(cd.suffix, suffix, 16);
        cd.suffix[15] = NULL;
    }
    else
        cd.suffix[0] = NULL;
    cd.flags = flags;
    cd.command_os = 0;
    cd.command_id = ~0; /* value of NULL_OBJID */
    FIf_set_user_pointer(form, (char *)&cd);

    /* display the form */
    FIf_display(form);

    /* let the user know something is going on */
    UMSGetByNum(buf, GR_I_Working, 0);
    FIfld_set_text(form, FI_MSG_FIELD, 0, 0, buf, FALSE);

    /* fill in the data on the form */
    sts = GRinit_revasm_form(form, argc - optind, &argv[optind], new_path, 
                             suffix, &cd.total_file_count, &cd.list);
    if (!(sts & 1))
    {
        UMSGetByNum(buf, GR_E_NoRefFl, 0);
        UMSGetByNum(title, GR_I_Notice, 0);
        FI_msg_box2(title, FI_BLUE, buf, FI_BLACK);
        exit(InitError);
    }

    /* tell the user to start banging on gadgets */
    UMSGetByNum(buf, GR_P_SelFrForm, 0);
    FIfld_set_text(form, FI_MSG_FIELD, 0, 0, buf, FALSE);

    /* process input until the form is erased */
    FI_process_forms();

    /* exit the program */
    exit(exit_status);
}
