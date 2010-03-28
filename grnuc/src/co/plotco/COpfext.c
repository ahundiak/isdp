/* #######################    APOGEE COMPILED   ######################## */
/*
Name
        COpfext

Description
        This file contains functions used to determine the size
        of the window information in a plotfile.

History
        mrm     03/15/89    creation
                11/06/89    ifdef'ed out InterScript support
                01/04/90    added clipbox arg
                03/01/90    add check for EOF
        scw     07/17/92    ansi conversion
        dhm     10/07/92    type case number of points passed to MAptsxform
                            to be a long.
*/

#include "exsysdep.h"
#ifndef STANDALONE
#include "coimport.h"
#endif
#include <stdio.h>
#include "igrtypedef.h"
#include "igr.h"
#include "pidef.h"
#include "trans_ele.h"
#include "ems_plot_def.h"
#include "ems_plot_err.h"
#include "ems_plot_typ.h"
#include "cmd_struct.h"
#include "command_ids.h"

#define IGDS_NO_TYPE5 2
#define CANNOT_OPEN_FILE 4
#define swapint(s,d)				\
	{					\
	    short t;				\
	    t = *((short *)s); 		        \
	    *s = *(((short *) s) + 1); 	        \
	    *(((short *) s) + 1) = t;	        \
	    *d = *s;				\
	}

#ifdef INTERSCRIPT
extern int read_header(), ems_metafile_reader();
#endif

extern IGRboolean MAptsxform(), MAtrnmx();

/*
Name
        COget_plotfile_extents

Description
        This functions accepts a plotfile name and returns the x and y
        lengths, the length units, and the type of the plotfile (see
        plotdef.h).  If the file is an IGDS plotting metafile, the
        clip box from the plotting type 5 is also returned.

Return Codes
        int ()      PI_S_SUCCESS    success
                    PI_F_FAIL       unknown file type
*/

int COget_plotfile_extents (filename, x, y, unit, filetype, clipbox)
char     *filename;
double   *x, *y;
char     *unit;
int      *filetype;
unsigned *clipbox;
{
    int sts, msg;

    sts = PI_S_SUCCESS;

    /* try IGDS format first, then IGM */

    sts = IGDSfile_extents (&msg, filename, x, y, unit, clipbox);

    if (sts & msg & 1)
    {
        *filetype = PI_IGDS_FILE;
    }
    else
    {
#ifdef INTERSCRIPT
        sts = IGMfile_extents (&msg, filename, x, y, unit);

        if (sts & msg & 1)
        {
            *filetype = PI_IGM_FILE;
        }
        else
        {
            sts = PI_F_FAIL;
        }
#else
        sts = PI_F_FAIL;
#endif
    }

    return (sts);
}



int IGDSfile_extents (msg, filename, x, y, unit, clipbox)
int      *msg;
char     *filename;
double   *x, *y;
char     *unit;
unsigned *clipbox;
{
    char             mu_name[3];
    short            type9_found = FALSE;
    short            type5_found = FALSE;
    short            buf[2], n;
    short            type_level;
    short            type9_buf[768];
    int              found = FALSE, ii;
    long             sts, *long_ptr;
    long unsigned    musupu[3];
    double           cb[6], m[16];
    double           factor = 1;
    double           length = 0, height = 0;
    Trans_ele        type5;
    FILE            *plot_file = NULL;
#ifdef BIG_ENDIAN
    short            swapped_short, swapped_buf0, swapped_buf1;
    long             swapped_long;
    int              swapped_int1, swapped_int2;
    double           swapped_dbl;
#endif

    sts = PI_S_SUCCESS;
    *msg = PI_S_SUCCESS;

    if ((plot_file = fopen (filename, "r")) == 0)
    {
        sts = PI_F_FAIL;
        *msg = CANNOT_OPEN_FILE;
        goto wrapup;
    }

    /* make sure the file is an IGDS file */

    if (fread (buf, sizeof (short), 2, plot_file) != 2)
    {
        *msg = PI_F_FAIL;
        goto wrapup;
    }

#ifdef BIG_ENDIAN
    GRconv_short(&buf[0], &swapped_buf0);
    GRconv_short(&buf[1], &swapped_buf1);
    if ( (((swapped_buf0 & 0x7f00) >> 8) == 9) &&
           (swapped_buf1 == 766) )
#else
    if ((((buf[0] & 0x7f00) >> 8) == 9) && (buf[1] == 766))
#endif
    {
        rewind (plot_file);
    }
    else
    {
        *msg = PI_F_FAIL;
        goto wrapup;
    }

    /*
     *  read the metafile and find the first type 9 (for working units) and
     *  the plotting type 5 elements
     */

    while (!found)
    {
        if (fread (buf, sizeof (short), 2, plot_file) != 2 || buf[0] == EOF)
        {
            *msg = PI_F_FAIL;
            goto wrapup;
        }

#ifdef BIG_ENDIAN
        GRconv_short(&buf[0], &swapped_buf0);
        GRconv_short(&buf[1], &swapped_buf1);
        type_level = swapped_buf0;
#else
        type_level = buf[0];
#endif

        if ((((type_level & 0x7f00) >> 8) == 9) && (!type9_found))
        {
#ifdef BIG_ENDIAN
            if (fread (&type9_buf[2], sizeof (short), swapped_buf1, plot_file)
                != swapped_buf1)
#else
            if (fread (&type9_buf[2], sizeof (short), buf[1], plot_file)
                != buf[1])
#endif
            {
                *msg = PI_F_FAIL;
                goto wrapup;
            }
            memcpy((char *)&musupu[0], (char *)&type9_buf[554], 12);
            memcpy (&mu_name[0], (char *)&type9_buf[560], 2);
            mu_name[2] = '\0';
#ifdef BIG_ENDIAN
            GRconv_int(&musupu[1], &swapped_long);
            swapint (&swapped_long, &musupu[1]);
            GRconv_int(&musupu[2], &swapped_long);
            swapint (&swapped_long, &musupu[2]);
#else
            swapint (&musupu[1], &musupu[1]);
            swapint (&musupu[2], &musupu[2]);
#endif
            factor = musupu[1] * musupu[2];
            strcpy (unit, mu_name);
            type9_found = TRUE;
        }
        else if (type_level == 0x0504)
        {
            /* found plotting type 5, stop looking for elements */

            found = 1;
            type5_found = TRUE;
            type5.type_level = type_level;
#ifdef BIG_ENDIAN
            type5.words_to_follow = swapped_buf1;
            if (fread (&type5.xlow, sizeof (short), swapped_buf1, plot_file)
                != swapped_buf1)
#else
            type5.words_to_follow = buf[1];
            if (fread (&type5.xlow, sizeof (short), buf[1], plot_file) != buf[1])
#endif
            {
                *msg = PI_F_FAIL;
                goto wrapup;
            }
#ifdef BIG_ENDIAN
            GRconv_int(&type5.clip_xhigh, &swapped_int1);
            GRconv_int(&type5.clip_xlow, &swapped_int2);
            length = swapped_int1 - swapped_int2;
            GRconv_int(&type5.clip_yhigh, &swapped_int1);
            GRconv_int(&type5.clip_ylow, &swapped_int2);
            height = swapped_int1 - swapped_int2;
#else
            length = type5.clip_xhigh - type5.clip_xlow;
            height = type5.clip_yhigh - type5.clip_ylow;
#endif

#ifdef BIG_ENDIAN
            GRconv_int(&type5.clip_xlow, &swapped_int1);
            clipbox[0] = swapped_int1;
            GRconv_int(&type5.clip_ylow, &swapped_int1);
            clipbox[1] = swapped_int1;
            GRconv_int(&type5.clip_zlow, &swapped_int1);
            clipbox[2] = swapped_int1;
            GRconv_int(&type5.clip_xhigh, &swapped_int1);
            clipbox[3] = swapped_int1;
            GRconv_int(&type5.clip_yhigh, &swapped_int1);
            clipbox[4] = swapped_int1;
            GRconv_int(&type5.clip_zhigh, &swapped_int1);
            clipbox[5] = swapped_int1;
#else
            memcpy (clipbox, &type5.clip_xlow, sizeof (unsigned) * 6);
#endif

            long_ptr = (long *) type5.xform_plot_to_DB;
            fltvax_to_flt32 (16, long_ptr, m);

        }
        else
        {
#ifdef BIG_ENDIAN
            fseek (plot_file, swapped_buf1*2, 1);
#else
            fseek (plot_file, buf[1]*2, 1);    
#endif
        }
    }

    if (type5_found)
    {
        /* calculate the plot size in working units */

        *x = length / factor;
        *y = height / factor;

        /* convert the region to be plotted from plot space to working units */

        for (ii = 0; ii < 6; ii++)
            cb[ii] = (double)clipbox[ii];
        n = 4;
        MAtrnmx (&sts, &n, m, m);
        ii = 2;
        MAptsxform (&sts, (long *) &ii, m, cb, cb);
        for (ii = 0; ii < 6; ii++)
            clipbox[ii] = (int)cb[ii];
    }
    else
    {
        /* not an IGDS plotting metafile */

        *msg = IGDS_NO_TYPE5;
    }

wrapup:

    if (plot_file) fclose (plot_file);

    return (sts);
}

#ifdef INTERSCRIPT
int IGMfile_extents (msg, filename, x, y, unit)
int      *msg;
char     *filename;
double   *x, *y;
char     *unit;
{
    unsigned char                       command[2];
    unsigned short                      level;
    int                                 num, read_sts, sts;
    double                              range[6];
    FILE                               *fp;
    struct metafile_header              header;
    struct set_view_orientation_range  *view_info;

    sts = PI_F_FAIL;
    *msg = PI_F_FAIL;

    if (fp = fopen (filename, "r"))
    {
        sts = PI_S_SUCCESS; /* opened okay */
        read_sts = read_header (fp, &header);
        if (read_sts & 1)
        {
            while (*msg == PI_F_FAIL)
            {
                read_sts = ems_metafile_reader (fp, command, &level, range,
                                                &num, &view_info);
                if (!(read_sts & 1) || (read_sts == EP_I_EOF))
                {
                    break;
                }
                else if (command[0] == SETUP_COMMAND &&
                         command[1] == SET_VIEW_ORIENTATION_RANGE)
                {
                    *msg = PI_S_SUCCESS;
                    *x = view_info->range[3] - view_info->range[0];
                    *y = view_info->range[4] - view_info->range[1];
                    *x *= header.world_to_meters;
                    *y *= header.world_to_meters;
                    unit[0] = 'm'; unit[1] = NULL;
                }
            }
        }
        fclose (fp);
    }
    return (sts);
}
#endif

