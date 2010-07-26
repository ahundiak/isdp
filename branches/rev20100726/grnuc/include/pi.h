/*
Name
        pi.h

Description
        This file contains structures used by the plotting interface code.

Dependencies
        OMminimum.h
        igetypedef.h
        igrtypedef.h
        igr.h
        gr.h
        FI.h

History
        mrm     03/12/89    creation
                12/21/89    added raster and shvar fields to PI_plotdata
                01/05/89    added clipbox
	madhu	11/27/90    addred local plotting fields
	sampath 06/30/92    added rotation flag
*/

#ifndef PI_INCLUDE
#define PI_INCLUDE

struct PI_plotdata
{
    char file[128];             /* name of file to plot/create */
    char queue[128];            /* queue to which to submit plot */
    char date[128];             /* date to submit the plot */
    char jobtocan[128];         /* plot request id to cancel */
    char file_unit[8];          /* uom from the plotfile */
    char plot_unit[8];          /* uom for specifying the output plot */
    char plotter_unit[8];       /* plotter units */
    char lastjobqueue[128];     /* queue to which last job was submitted */
    char lastjobid[128];        /* NQS job id of last plot submitted */
    char lastjobname[128];      /* name of last plotfile submitted to NQS */
    char iplot[256];            /* IP/IPLOT create options */
    char rendattr[128];         /* rendering attributes filename */
    char pentable[128];         /* pentable  filename */
    char raster[128];           /* name of raster file to submit with plot */
    char shvar[16];             /* environment var to export with ras file */
    char port[128];		/* plotter port */
    int rotate_90;              /* Rotation flag */
    int command;                /* indicates which command (form) is active */
    int filetype;               /* IGDS or InterScript */
    int last_value;             /* most recently changed: plot_x, _y, scale */
    int mode;                   /* standalone or in graphics */
    int mail;                   /* mail results to user (see pidef.h) */
    int exit;                   /* set when form is dismissed */
    int copies;                 /* number of copies */
    int lcopies;                /* number of local plot copies */
    int pltype;			/* local or network plotting */
    unsigned clipbox[6];        /* from IGDS plotting type 5 */
    double lplot_x, lplot_y;    /* local plot size of the output */
    double lscale;		/* factor applied to lplot_x and lplot_y */
    double file_x, file_y;      /* size of the window in the plotfile */
    double plot_x, plot_y;      /* size of the output */
    double scale;               /* factor applied to file_x to get plot_x */
    double plotter_max[2];      /* plotter limits */
    Form submit_form;           /* id of the submit plot form */
    Form qstat_form;            /* id of the plot queue status form */
    Form create_form;           /* id of the create plot form */
    Form displayed_form;        /* indicates which form is on the screen */
};

typedef struct PI_plotdata PIplotdata;


struct PI_create
{
    int creflags;               /* Create Plot flags (see pidef.h) */
    int wftoggle;               /* window/fence toggle */
    int flood_index;            /* InterScript background flood color index */
    char ctable[128];           /* name of color table file */
    char seedfile[128];         /* name of seedfile used to create plotfiles */
    double range[12];           /* cube to plot - world and view coordinates */
    char *cvprism;              /* used to create a plot file from fence */
    struct GRid window;         /* window associated with plot */
};

typedef struct PI_create PIcreate;


#endif /* PI_INCLUDE */
